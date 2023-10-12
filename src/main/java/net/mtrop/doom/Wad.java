/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.RandomAccessFile;
import java.io.Reader;
import java.nio.charset.Charset;
import java.util.Arrays;
import java.util.LinkedList;
import java.util.List;
import java.util.Queue;

import net.mtrop.doom.object.BinaryObject;
import net.mtrop.doom.object.BinaryObject.Scanner;
import net.mtrop.doom.object.BinaryObject.InlineScanner;
import net.mtrop.doom.object.TextObject;
import net.mtrop.doom.struct.io.IOUtils;

/**
 * Base interface for all WAD file type implementations for reading and writing to WAD structures, either in memory or
 * on disk.
 * <p>
 * All entries in a WAD are abstracted as WadEntry objects, which contain the name and offsets for the corresponding
 * data in a WAD file. Note that there may be several entries in a WAD that have the same name; entry "equality" should
 * be determined by name, size and offset.
 * <p>
 * Entries are by no means attached to their source WADs. Attempting to retrieve content from one WAD using entry data
 * from another WAD may have unintended consequences!
 * <p>
 * There may be some implementations of this structure that do not support certain operations, so in those cases, those
 * methods may throw an {@link UnsupportedOperationException}. Also, certain implementations may be more suited for
 * better tasks, so be sure to figure out which implementation suits your needs!
 * <p>
 * Most of the common methods are "defaulted" in this interface. Implementors are encouraged to override these if your implementation
 * can provide a more performant version than the one-size-fits-all methods here.
 * <p>
 * <b>All methods in Wad implementations cannot be guaranteed to be thread-safe.</b>
 *   
 * @author Matthew Tropiano
 */
public interface Wad extends Iterable<WadEntry>
{
	static final WadEntry[] NO_ENTRIES = new WadEntry[0];
	static final byte[] NO_DATA = new byte[0];

	/**
	 * Internal WAD type.
	 */
	public enum Type
	{
		PWAD, 
		IWAD;
	}

	/**
	 * Checks if a file is a valid WAD file.
	 * This opens the provided file for reading only, inspects 
	 * the first four bytes for a valid header, and then closes it.
	 * @param file the file to inspect.
	 * @return true if the file exists, is a file, and is a WAD file, or false otherwise.
	 * @throws IOException if the file cannot be read.
	 * @throws SecurityException if you don't have permission to read the file.
	 * @since 2.3.0
	 */
	static boolean isWAD(File file) throws IOException
	{
		if (!file.exists() || file.isDirectory())
			return false;
		
		byte[] buf = new byte[4];
		try (RandomAccessFile raf = new RandomAccessFile(file, "r"))
		{
			raf.seek(0L);
			if (raf.read(buf) != 4)
				return false;
			String head = new String(buf, "ASCII");
			if (Type.IWAD.name().equals(head) || Type.PWAD.name().equals(head))
				return true;
		}
		
		return false;
	}

	/**
	 * Checks if this WAD is an Internal WAD.
	 * @return true if so, false if not.
	 */
	boolean isIWAD();
	
	/**
	 * Checks if this WAD is a Patch WAD.
	 * @return true if so, false if not.
	 */
	boolean isPWAD();
	
	/**
	 * @return the number of entries in this Wad.
	 */
	int getEntryCount();

	/**
	 * @return the amount of content data in this Wad in bytes.
	 */
	int getContentLength();

	/**
	 * Gets the WadEntry at index n.
	 * 
	 * @param n the index of the entry in the entry list.
	 * @throws ArrayIndexOutOfBoundsException if n &lt; 0 or &gt;= size.
	 * @return the entry at <code>n</code>.
	 */
	WadEntry getEntry(int n);

	/**
	 * Gets the first WadEntry named <code>entryName</code>.
	 * <p>The name is case-insensitive.
	 * @param entryName the name of the entry.
	 * @return the first entry named <code>entryName</code> or <code>null</code> if not found.
	 */
	default WadEntry getEntry(String entryName)
	{
		int i = indexOf(entryName, 0);
		return i != -1 ? getEntry(i) : null;
	}

	/**Z
	 * Gets the first WadEntry named <code>entryName</code>, starting from a particular index.
	 * <p>The name is case-insensitive.
	 * @param entryName the name of the entry.
	 * @param start the index with which to start the search (a value less than 0 is considered 0).
	 * @return the first entry named <code>entryName</code> or <code>null</code> if not found.
	 */
	default WadEntry getEntry(String entryName, int start)
	{
		int i = indexOf(entryName, start);
		return i != -1 ? getEntry(i) : null;
	}

	/**
	 * Gets the first WadEntry named <code>entryName</code>, starting from a particular entry's index.
	 * If <code>startEntryName</code> is not found, the search returns null. 
	 * <p>The names are case-insensitive.
	 * @param entryName the name of the entry.
	 * @param startEntryName the name of the starting entry to find (first occurrence).
	 * @return the first entry named <code>entryName</code> or <code>null</code> if <code>entryName</code> or <code>startEntryName</code> not found.
	 * @throws NullPointerException if <code>entryName</code> or <code>startEntryName</code> is <code>null</code>.
	 */
	default WadEntry getEntry(String entryName, String startEntryName)
	{
		int start = indexOf(startEntryName);
		return start >= 0 ? getEntry(entryName, start) : null;
	}

	/**
	 * Gets the n-th WadEntry named <code>entryName</code>.
	 * <p>The name is case-insensitive.
	 * @param entryName the name of the entry.
	 * @param n the n-th occurrence to find, 0-based (0 is first, 1 is second, and so on).
	 * @return the n-th entry named <code>entryName</code> or <code>null</code> if not found.
	 */
	default WadEntry getNthEntry(String entryName, int n)
	{
		int x = 0;
		int s = getEntryCount();
		for (int i = 0; i < s; i++)
		{
			WadEntry entry = getEntry(i);
			if (entry.getName().equalsIgnoreCase(entryName))
			{
				if (x++ == n)
					return entry;
			}
		}
		return null;
	}

	/**
	 * Gets the last WadEntry named <code>entryName</code>.
	 * <p>The name is case-insensitive.
	 * @param entryName the name of the entry.
	 * @return the last entry named <code>entryName</code> or <code>null</code> if not found.
	 */
	default WadEntry getLastEntry(String entryName)
	{
		int s = getEntryCount();
		for (int i = s - 1; i >= 0; i--)
		{
			WadEntry entry = getEntry(i);
			if (entry.getName().equalsIgnoreCase(entryName))
				return entry;
		}
		return null;
	}


	/**
	 * Returns all WadEntry objects (in a new array).
	 * @return an array of all of the WadEntry objects.
	 */
	default WadEntry[] getAllEntries()
	{
		WadEntry[] out = new WadEntry[getEntryCount()];
		for (int i = 0; i < out.length; i++)
			out[i] = getEntry(i);
		return out;
	}

	/**
	 * Returns all WadEntry objects named <code>entryName</code>.
	 * <p>The name is case-insensitive.
	 * @param entryName the name of the entry.
	 * @return an array of all of the WadEntry objects with the name <code>entryName</code>.
	 */
	default WadEntry[] getAllEntries(String entryName)
	{
		Queue<WadEntry> w = new LinkedList<>();
		
		int s = getEntryCount();
		for (int i = 0; i < s; i++)
		{
			WadEntry entry = getEntry(i);
			if (entry.getName().equalsIgnoreCase(entryName))
				w.add(entry);
		}
		
		WadEntry[] out = new WadEntry[w.size()];
		w.toArray(out);
		return out;
	}

	/**
	 * Gets the indices of all WadEntry objects named <code>entryName</code>.
	 * <p>The name is case-insensitive.
	 * @param entryName the name of the entry.
	 * @return an array of all of the WadEntry objects with the name <code>entryName</code>.
	 */
	default int[] getAllEntryIndices(String entryName)
	{
		Queue<Integer> w = new LinkedList<Integer>();
		
		int s = getEntryCount();
		for (int i = 0; i < s; i++)
		{
			WadEntry entry = getEntry(i);
			if (entry.getName().equalsIgnoreCase(entryName))
				w.add(i);
		}
		
		int[] out = new int[w.size()];
		for (int i = 0; i < out.length; i++)
			out[i] = w.poll();
		return out;
	}

	/**
	 * Gets the first index of an entry of name <code>entryName</code>.
	 * <p>The name is case-insensitive.
	 * @param entryName the name of the entry to find.
	 * @return the index of the entry in this file, or -1 if not found.
	 */
	default int indexOf(String entryName)
	{
		return indexOf(entryName, 0);
	}

	/**
	 * Gets the first index of an entry of name "entryName" from a starting point.
	 * <p>The name is case-insensitive.
	 * @param entryName the name of the entry to find.
	 * @param start the index with which to start the search (a value less than 0 is considered 0).
	 * @return the index of the entry in this file, or -1 if not found.
	 * @throws ArrayIndexOutOfBoundsException if start &lt; 0 or &gt;= size.
	 */
	default int indexOf(String entryName, int start)
	{
		int s = getEntryCount();
		for (int i = Math.max(0, start); i < s; i++)
			if (getEntry(i).getName().equalsIgnoreCase(entryName))
				return i;
		return -1;
	}

	/**
	 * Gets the first index of an entry of name "entryName" from a starting point entry "startEntryName".
	 * If <code>startEntryName</code> is not found, the search returns null. 
	 * <p>The names are case-insensitive.
	 * @param entryName the name of the entry.
	 * @param startEntryName the name of the starting entry to find (first occurrence).
	 * @return the index of the entry named <code>entryName</code> in this file, or -1 if <code>entryName</code> or <code>startEntryName</code> not found.
	 */
	default int indexOf(String entryName, String startEntryName)
	{
		int start = indexOf(startEntryName);
		return start >= 0 ? indexOf(entryName, start) : -1;
	}

	/**
	 * Gets the last index of an entry of name <code>entryName</code>.
	 * <p>The name is case-insensitive.
	 * @param entryName the name of the entry to find.
	 * @return the index of the entry in this file, or -1 if not found.
	 */
	default int lastIndexOf(String entryName)
	{
		int out = -1;
		int s = getEntryCount();
		for (int i = 0; i < s; i++)
			if (getEntry(i).getName().equalsIgnoreCase(entryName))
				out = i;
		return out;
	}
	
	/**
	 * Fetches a series of bytes from an arbitrary place in the Wad 
	 * and puts them into a provided array.
	 * This is will attempt to get the full provided length, throwing an exception if it does not.
	 * @param offset the offset byte into that data to start at.
	 * @param length the amount of bytes to fetch.
	 * @param out the destination array of bytes.
	 * @param outOffset the offset into the destination array to put the bytes into.
	 * @throws IndexOutOfBoundsException if offset plus length will go past the end of the destination array.
	 * @throws IOException if an error occurs during read.
	 * @throws NullPointerException if out is null.
	 * @since 2.4.0
	 */
	void fetchContent(int offset, int length, byte[] out, int outOffset) throws IOException;

	/**
	 * Retrieves the data of a particular entry index and puts it in a provided array
	 * and puts it in a provided array.
	 * @param n the index of the entry in the Wad.
	 * @param out the output array of bytes.
	 * @param offset the offset into the array to to put the read bytes.
	 * @return the amount of bytes read.
	 * @throws ArrayIndexOutOfBoundsException if n &lt; 0 or &gt;= size.
	 * @throws IndexOutOfBoundsException if offset plus length will go past the end of the content area.
	 * @throws IOException if an error occurs during read.
	 * @throws NullPointerException if out is null.
	 * @since 2.4.0
	 */
	default int fetchData(int n, byte[] out, int offset) throws IOException
	{
		WadEntry entry = getEntry(n);
		return fetchData(entry, out, offset);
	}
	
	/**
	 * Retrieves the data of the first occurrence of a particular entry
	 * and puts it in a provided array.
	 * <p>The name is case-insensitive.
	 * @param entryName the name of the entry to find.
	 * @param out the output array of bytes.
	 * @param offset the offset into the array to to put the read bytes.
	 * @return the amount of bytes read, or -1 if the entry could not be found.
	 * @throws IndexOutOfBoundsException if offset plus length will go past the end of the content area.
	 * @throws IOException if an error occurs during read.
	 * @throws NullPointerException if out is null.
	 * @since 2.4.0
	 */
	default int fetchData(String entryName, byte[] out, int offset) throws IOException
	{
		WadEntry entry = getEntry(entryName);
		if (entry == null) 
			return -1;
		return fetchData(entry, out, offset);
	}
	
	/**
	 * Retrieves the data of the first occurrence of a particular entry from a starting index
	 * and puts it in a provided array.
	 * <p>The name is case-insensitive.
	 * @param entryName the name of the entry to find.
	 * @param start the index with which to start the search.
	 * @param out the output array of bytes.
	 * @param offset the offset into the array to to put the read bytes.
	 * @return the amount of bytes read, or -1 if the entry could not be found.
	 * @throws IndexOutOfBoundsException if offset plus length will go past the end of the content area.
	 * @throws IOException if an error occurs during read.
	 * @throws NullPointerException if out is null.
	 * @since 2.4.0
	 */
	default int fetchData(String entryName, int start, byte[] out, int offset) throws IOException
	{
		WadEntry entry = getEntry(entryName, start);
		if (entry == null) 
			return -1;
		return fetchData(entry, out, offset);
	}

	/**
	 * Retrieves the data of the first occurrence of a particular entry from a starting entry (by name)
	 * and puts it in a provided array.
	 * <p>The names are case-insensitive.
	 * @param entryName the name of the entry to find.
	 * @param startEntryName the starting entry (by name) with which to start the search.
	 * @param out the output array of bytes.
	 * @param offset the offset into the array to to put the read bytes.
	 * @return the amount of bytes read, or -1 if the entry could not be found.
	 * @throws IndexOutOfBoundsException if offset plus length will go past the end of the content area.
	 * @throws IOException if an error occurs during read.
	 * @throws NullPointerException if out is null.
	 * @since 2.4.0
	 */
	default int fetchData(String entryName, String startEntryName, byte[] out, int offset) throws IOException
	{
		WadEntry entry = getEntry(entryName, startEntryName);
		if (entry == null) 
			return -1;
		return fetchData(entry, out, offset);
	}
	
	/**
	 * Fetches the data of the specified entry and puts it in a provided array.
	 * @param entry the entry to use.
	 * @param out the output array of bytes.
	 * @param offset the offset into the array to to put the read bytes.
	 * @return the amount of bytes read.
	 * @throws IndexOutOfBoundsException if offset plus length will go past the end of the content area.
	 * @throws IOException if an error occurs during read.
	 * @throws NullPointerException if out is null.
	 * @since 2.4.0
	 */
	default int fetchData(WadEntry entry, byte[] out, int offset) throws IOException
	{
		fetchContent(entry.getOffset(), entry.getSize(), out, offset);
		return entry.getSize();
	}

	/**
	 * Retrieves the data of a particular entry index and returns it as a stream.
	 * 
	 * @param n the index of the entry in the file.
	 * @return an open input stream of the data, or null if it can't be retrieved.
	 * @throws IOException if the data couldn't be retrieved.
	 * @throws ArrayIndexOutOfBoundsException if n &lt; 0 or &gt;= size.
	 */
	default InputStream getInputStream(int n) throws IOException
	{
		return getInputStream(getEntry(n));
	}

	/**
	 * Retrieves the data of the first occurrence of a particular entry and returns it as a stream.
	 * <p>The name is case-insensitive.
	 * @param entryName the name of the entry to find.
	 * @return an open input stream of the data, or null if it can't be retrieved.
	 * @throws IOException if the data couldn't be retrieved.
	 * @throws NullPointerException if <code>entryName</code> is <code>null</code>.
	 */
	default InputStream getInputStream(String entryName) throws IOException
	{
		int index = indexOf(entryName);
		return index >= 0 ? getInputStream(index) : null;
	}

	/**
	 * Retrieves the data of the first occurrence of a particular entry from a starting index and returns it as a stream.
	 * <p>The name is case-insensitive.
	 * @param entryName the name of the entry to find.
	 * @param start the index with which to start the search.
	 * @return an open input stream of the data, or null if it can't be retrieved.
	 * @throws IOException if the data couldn't be retrieved.
	 * @throws NullPointerException if <code>entryName</code> is <code>null</code>.
	 * @throws ArrayIndexOutOfBoundsException if start &lt; 0 or &gt;= size.
	 */
	default InputStream getInputStream(String entryName, int start) throws IOException
	{
		int index = indexOf(entryName, start);
		return index >= 0 ? getInputStream(index) : null;
	}

	/**
	 * Retrieves the data of the first occurrence of a particular entry from a starting entry (by name) and returns it as a stream.
	 * <p>The names are case-insensitive.
	 * @param entryName the name of the entry to find.
	 * @param startEntryName the starting entry with which to start the search.
	 * @return an open input stream of the data, or null if it can't be retrieved.
	 * @throws IOException if the data couldn't be retrieved.
	 * @throws NullPointerException if <code>entryName</code> is <code>null</code>.
	 * @throws ArrayIndexOutOfBoundsException if start &lt; 0 or &gt;= size.
	 */
	default InputStream getInputStream(String entryName, String startEntryName) throws IOException
	{
		int index = indexOf(entryName, startEntryName);
		return index >= 0 ? getInputStream(index) : null;
	}

	/**
	 * Retrieves the data of the specified entry from a starting index and returns it as a stream.
	 * 
	 * @param entry the entry to use.
	 * @return an open input stream of the data.
	 * @throws IOException if the data couldn't be retrieved or the entry's offsets breach the file extents.
	 * @throws NullPointerException if <code>entry</code> is <code>null</code>.
	 */
	default InputStream getInputStream(WadEntry entry) throws IOException
	{
		return new ByteArrayInputStream(getData(entry));
	}

	/**
	 * Retrieves a Reader for an entry at a particular index as a decoded stream of characters.
	 * @param n the index of the entry in the Wad.
	 * @param charset the source charset encoding.
	 * @return a Reader for reading the character stream.
	 * @throws IOException if the data couldn't be retrieved.
	 * @throws ArrayIndexOutOfBoundsException if n &lt; 0 or &gt;= size.
	 * @see BinaryObject#create(Class, byte[])
	 */
	default Reader getReader(int n, Charset charset) throws IOException
	{
		return new BufferedReader(new InputStreamReader(getInputStream(n), charset));
	}

	/**
	 * Retrieves a Reader for the first occurrence of a particular entry as a decoded stream of characters.
	 * <p>The name is case-insensitive.
	 * @param entryName the name of the entry to find.
	 * @param charset the source charset encoding.
	 * @return a Reader for reading the character stream, or null if the entry doesn't exist.
	 * @throws IOException if the data couldn't be retrieved or the entry's offsets breach the file extents.
	 * @throws NullPointerException if <code>entryName</code> is <code>null</code>.
	 * @see BinaryObject#create(Class, byte[])
	 */
	default Reader getReader(String entryName, Charset charset) throws IOException
	{
		InputStream in = getInputStream(entryName);
		return in != null ? new BufferedReader(new InputStreamReader(in, charset)) : null;
	}

	/**
	 * Retrieves a Reader for the first occurrence of a particular entry from a starting index as a decoded stream of characters.
	 * <p>The name is case-insensitive.
	 * @param entryName the name of the entry to find.
	 * @param start the starting index to search from.
	 * @param charset the source charset encoding.
	 * @return a Reader for reading the character stream, or null if the entry doesn't exist.
	 * @throws IOException if the data couldn't be retrieved or the entry's offsets breach the file extents.
	 * @throws NullPointerException if <code>entryName</code> is <code>null</code>.
	 * @see BinaryObject#create(Class, byte[])
	 */
	default Reader getReader(String entryName, int start, Charset charset) throws IOException
	{
		InputStream in = getInputStream(entryName, start);
		return in != null ? new BufferedReader(new InputStreamReader(in, charset)) : null;
	}

	/**
	 * Retrieves a Reader for the first occurrence of a particular entry from a starting entry (by name) as a decoded stream of characters.
	 * <p>The names are case-insensitive.
	 * @param entryName the name of the entry to find.
	 * @param startEntryName the starting entry (by name) with which to start the search.
	 * @param charset the source charset encoding.
	 * @return a Reader for reading the character stream, or null if the entry doesn't exist.
	 * @throws IOException if the data couldn't be retrieved or the entry's offsets breach the file extents.
	 * @throws NullPointerException if <code>entryName</code> is <code>null</code>.
	 * @see BinaryObject#create(Class, byte[])
	 */
	default Reader getReader(String entryName, String startEntryName, Charset charset) throws IOException
	{
		InputStream in = getInputStream(entryName, startEntryName);
		return in != null ? new BufferedReader(new InputStreamReader(in, charset)) : null;
	}

	/**
	 * Retrieves a Reader for the specified entry as a decoded stream of characters.
	 * @param entry the entry to use.
	 * @param charset the source charset encoding.
	 * @return a Reader for reading the character stream.
	 * @throws IOException if the data couldn't be retrieved or the entry's offsets breach the file extents.
	 * @throws NullPointerException if <code>entry</code> is <code>null</code>.
	 * @see BinaryObject#create(Class, byte[])
	 */
	default Reader getReader(WadEntry entry, Charset charset) throws IOException
	{
		return new BufferedReader(new InputStreamReader(getInputStream(entry), charset));
	}

	/**
	 * Gets a series of bytes representing the data at an arbitrary place in the Wad.
	 * @param offset the offset byte into that data to start at.
	 * @param length the amount of bytes to return.
	 * @return a copy of the byte data as an array of bytes.
	 * @throws IndexOutOfBoundsException if offset plus length will go past the end of the content area.
	 * @throws IOException if an error occurs during read.
	 * @since 2.2.0
	 */
	default byte[] getContent(int offset, int length) throws IOException
	{
		byte[] out = new byte[length];
		fetchContent(offset, length, out, 0);
		return out;
	}

	/**
	 * Retrieves the data of a particular entry index.
	 * 
	 * @param n the index of the entry in the Wad.
	 * @throws IOException if the data couldn't be retrieved.
	 * @throws ArrayIndexOutOfBoundsException if n &lt; 0 or &gt;= size.
	 * @return a byte array of the data.
	 */
	default byte[] getData(int n) throws IOException
	{
		return getData(getEntry(n));
	}

	/**
	 * Retrieves the data of the first occurrence of a particular entry.
	 * <p>The name is case-insensitive.
	 * @param entryName the name of the entry to find.
	 * @return a byte array of the data, or null if the entry doesn't exist.
	 * @throws IOException if the data couldn't be retrieved.
	 */
	default byte[] getData(String entryName) throws IOException
	{
		return getData(entryName, 0);
	}

	/**
	 * Retrieves the data of the first occurrence of a particular entry from a starting index.
	 * <p>The name is case-insensitive.
	 * @param entryName the name of the entry to find.
	 * @param start the index with which to start the search.
	 * @return a byte array of the data, or null if the entry doesn't exist.
	 * @throws IOException if the data couldn't be retrieved.
	 * @throws NullPointerException if <code>entryName</code> is <code>null</code>.
	 * @throws ArrayIndexOutOfBoundsException if start &lt; 0 or &gt;= size.
	 */
	default byte[] getData(String entryName, int start) throws IOException
	{
		int i = indexOf(entryName, start);
		return i != -1 ? getData(i) : null;
	}

	/**
	 * Retrieves the data of the first occurrence of a particular entry from a starting entry (by name).
	 * <p>The names are case-insensitive.
	 * @param entryName the name of the entry to find.
	 * @param startEntryName the starting entry (by name) with which to start the search.
	 * @return a byte array of the data, or null if the entry doesn't exist.
	 * @throws IOException if the data couldn't be retrieved.
	 * @throws NullPointerException if <code>entryName</code> or <code>startEntryName</code> is <code>null</code>.
	 */
	default byte[] getData(String entryName, String startEntryName) throws IOException
	{
		int i = indexOf(entryName, startEntryName);
		return i != -1 ? getData(i) : null;
	}

	/**
	 * Retrieves the data of the specified entry.
	 * 
	 * @param entry the entry to use.
	 * @return a byte array of the data.
	 * @throws IOException if the data couldn't be retrieved or the entry's offsets breach the file extents.
	 * @throws NullPointerException if <code>entry</code> is <code>null</code>.
	 */
	default byte[] getData(WadEntry entry) throws IOException
	{
		return getContent(entry.getOffset(), entry.getSize());
	}

	/**
	 * Retrieves the data of an entry at a particular index as a decoded string of characters.
	 * @param n the index of the entry in the Wad.
	 * @param charset the source charset encoding.
	 * @return the data, decoded.
	 * @throws IOException if the data couldn't be retrieved.
	 * @throws ArrayIndexOutOfBoundsException if n &lt; 0 or &gt;= size.
	 * @see BinaryObject#create(Class, byte[])
	 */
	default String getTextData(int n, Charset charset) throws IOException
	{
		return new String(getData(n), charset);
	}

	/**
	 * Retrieves the data of the first occurrence of a particular entry as a decoded string of characters.
	 * <p>The name is case-insensitive.
	 * @param entryName the name of the entry to find.
	 * @param charset the source charset encoding.
	 * @return the data, decoded, or null if the entry doesn't exist.
	 * @throws IOException if the data couldn't be retrieved or the entry's offsets breach the file extents.
	 * @throws NullPointerException if <code>entryName</code> is <code>null</code>.
	 * @see BinaryObject#create(Class, byte[])
	 */
	default String getTextData(String entryName, Charset charset) throws IOException
	{
		byte[] data = getData(entryName);
		return data != null ? new String(data, charset) : null;
	}

	/**
	 * Retrieves the data of the first occurrence of a particular entry from a starting index as a decoded string of characters.
	 * <p>The name is case-insensitive.
	 * @param entryName the name of the entry to find.
	 * @param start the starting index to search from.
	 * @param charset the source charset encoding.
	 * @return the data, decoded, or null if the entry doesn't exist.
	 * @throws IOException if the data couldn't be retrieved or the entry's offsets breach the file extents.
	 * @throws NullPointerException if <code>entryName</code> is <code>null</code>.
	 * @see BinaryObject#create(Class, byte[])
	 */
	default String getTextData(String entryName, int start, Charset charset) throws IOException
	{
		byte[] data = getData(entryName, start);
		return data != null ? new String(data, charset) : null;
	}

	/**
	 * Retrieves the data of the first occurrence of a particular entry from a starting entry (by name) as a decoded string of characters.
	 * <p>The names are case-insensitive.
	 * @param entryName the name of the entry to find.
	 * @param startEntryName the starting entry (by name) with which to start the search.
	 * @param charset the source charset encoding.
	 * @return the data, decoded, or null if the entry doesn't exist.
	 * @throws IOException if the data couldn't be retrieved or the entry's offsets breach the file extents.
	 * @throws NullPointerException if <code>entryName</code> is <code>null</code>.
	 * @see BinaryObject#create(Class, byte[])
	 */
	default String getTextData(String entryName, String startEntryName, Charset charset) throws IOException
	{
		byte[] data = getData(entryName, startEntryName);
		return data != null ? new String(data, charset) : null;
	}

	/**
	 * Retrieves the data of the specified entry as a decoded string of characters.
	 * @param entry the entry to use.
	 * @param charset the source charset encoding.
	 * @return the data, decoded.
	 * @throws IOException if the data couldn't be retrieved or the entry's offsets breach the file extents.
	 * @throws NullPointerException if <code>entry</code> is <code>null</code>.
	 * @see BinaryObject#create(Class, byte[])
	 */
	default String getTextData(WadEntry entry, Charset charset) throws IOException
	{
		return new String(getData(entry), charset);
	}
	
	/**
	 * Retrieves the text data of an entry at a particular index as an interpreted text-originating object.
	 * @param <TO> the result type.
	 * @param n the index of the entry in the Wad.
	 * @param charset the source charset encoding.
	 * @param type the object type to convert the text data to.
	 * @return the data, decoded.
	 * @throws IOException if the data couldn't be retrieved.
	 * @throws ArrayIndexOutOfBoundsException if n &lt; 0 or &gt;= size.
	 * @see TextObject#read(Class, Reader)
	 */
	default <TO extends TextObject> TO getTextDataAs(int n, Charset charset, Class<TO> type) throws IOException
	{
		try (Reader reader = getReader(n, charset))
		{
			return TextObject.read(type, reader);
		}
	}

	/**
	 * Retrieves the data of the first occurrence of a particular entry as an interpreted text-originating object.
	 * <p>The name is case-insensitive.
	 * @param <TO> the result type.
	 * @param entryName the name of the entry to find.
	 * @param charset the source charset encoding.
	 * @param type the object type to convert the text data to.
	 * @return the data, decoded, or null if the entry doesn't exist.
	 * @throws IOException if the data couldn't be retrieved or the entry's offsets breach the file extents.
	 * @throws NullPointerException if <code>entryName</code> is <code>null</code>.
	 * @see TextObject#read(Class, Reader)
	 */
	default <TO extends TextObject> TO getTextDataAs(String entryName, Charset charset, Class<TO> type) throws IOException
	{
		Reader reader = getReader(entryName, charset);
		if (reader == null)
			return null;
		try
		{
			return TextObject.read(type, reader);
		}
		finally
		{
			IOUtils.close(reader);
		}
	}

	/**
	 * Retrieves the data of the first occurrence of a particular entry from a starting index as an interpreted text-originating object.
	 * <p>The name is case-insensitive.
	 * @param <TO> the result type.
	 * @param entryName the name of the entry to find.
	 * @param start the starting index to search from.
	 * @param charset the source charset encoding.
	 * @param type the object type to convert the text data to.
	 * @return the data, decoded, or null if the entry doesn't exist.
	 * @throws IOException if the data couldn't be retrieved or the entry's offsets breach the file extents.
	 * @throws NullPointerException if <code>entryName</code> is <code>null</code>.
	 * @see TextObject#read(Class, Reader)
	 */
	default <TO extends TextObject> TO getTextDataAs(String entryName, int start, Charset charset, Class<TO> type) throws IOException
	{
		Reader reader = getReader(entryName, start, charset);
		if (reader == null)
			return null;
		try
		{
			return TextObject.read(type, reader);
		}
		finally
		{
			IOUtils.close(reader);
		}
	}

	/**
	 * Retrieves the data of the first occurrence of a particular entry from a starting entry (by name) as an interpreted text-originating object.
	 * <p>The names are case-insensitive.
	 * @param <TO> the result type.
	 * @param entryName the name of the entry to find.
	 * @param startEntryName the starting entry (by name) with which to start the search.
	 * @param charset the source charset encoding.
	 * @param type the object type to convert the text data to.
	 * @return the data, decoded, or null if the entry doesn't exist.
	 * @throws IOException if the data couldn't be retrieved or the entry's offsets breach the file extents.
	 * @throws NullPointerException if <code>entryName</code> is <code>null</code>.
	 * @see TextObject#read(Class, Reader)
	 */
	default <TO extends TextObject> TO getTextDataAs(String entryName, String startEntryName, Charset charset, Class<TO> type) throws IOException
	{
		Reader reader = getReader(entryName, startEntryName, charset);
		if (reader == null)
			return null;
		try
		{
			return TextObject.read(type, reader);
		}
		finally
		{
			IOUtils.close(reader);
		}
	}

	/**
	 * Retrieves the data of the specified entry as an interpreted text-originating object.
	 * @param <TO> the result type.
	 * @param entry the entry to use.
	 * @param charset the source charset encoding.
	 * @param type the type to decode to.
	 * @return the data, decoded.
	 * @throws IOException if the data couldn't be retrieved or the entry's offsets breach the file extents.
	 * @throws NullPointerException if <code>entry</code> is <code>null</code>.
	 * @see TextObject#read(Class, Reader)
	 */
	default <TO extends TextObject> TO getTextDataAs(WadEntry entry, Charset charset, Class<TO> type) throws IOException
	{
		Reader reader = getReader(entry, charset);
		if (reader == null)
			return null;
		try
		{
			return TextObject.read(type, reader);
		}
		finally
		{
			IOUtils.close(reader);
		}
	}
	
	/**
	 * Retrieves the data of an entry at a particular index as a deserialized lump.
	 * <p>Note that if the lump ordinarily as multiple amounts of the object type in question, this
	 * will read only the first one.
	 * @param <BO> the result type.
	 * @param n the index of the entry in the Wad.
	 * @param type the class type to deserialize into.
	 * @return the data, deserialized, or null if the entry doesn't exist.
	 * @throws IOException if the data couldn't be retrieved.
	 * @throws ArrayIndexOutOfBoundsException if n &lt; 0 or &gt;= size.
	 * @see BinaryObject#create(Class, byte[])
	 */
	default <BO extends BinaryObject> BO getDataAs(int n, Class<BO> type) throws IOException
	{
		byte[] data = getData(n);
		return data != null ? BinaryObject.create(type, data) : null;
	}

	/**
	 * Retrieves the data of the first occurrence of a particular entry as a deserialized lump.
	 * <p>The name is case-insensitive.
	 * <p>Note that if the lump ordinarily as multiple amounts of the object type in question, this
	 * will read only the first one.
	 * @param <BO> the result type.
	 * @param entryName the name of the entry to find.
	 * @param type the class type to deserialize into.
	 * @return the data, deserialized, or null if the entry doesn't exist.
	 * @throws IOException if the data couldn't be retrieved or the entry's offsets breach the file extents.
	 * @throws NullPointerException if <code>entryName</code> is <code>null</code>.
	 * @see BinaryObject#create(Class, byte[])
	 */
	default <BO extends BinaryObject> BO getDataAs(String entryName, Class<BO> type) throws IOException
	{
		byte[] data = getData(entryName);
		return data != null ? BinaryObject.create(type, data) : null;
	}

	/**
	 * Retrieves the data of the first occurrence of a particular entry from a starting index as a deserialized lump.
	 * <p>The name is case-insensitive.
	 * <p>Note that if the lump ordinarily as multiple amounts of the object type in question, this
	 * will read only the first one.
	 * @param <BO> the result type.
	 * @param entryName the name of the entry to find.
	 * @param start the index with which to start the search.
	 * @param type the class type to deserialize into.
	 * @return the data, deserialized, or null if the entry doesn't exist.
	 * @throws IOException if the data couldn't be retrieved or the entry's offsets breach the file extents.
	 * @throws NullPointerException if <code>entryName</code> is <code>null</code>.
	 * @see BinaryObject#create(Class, byte[])
	 */
	default <BO extends BinaryObject> BO getDataAs(String entryName, int start, Class<BO> type) throws IOException
	{
		byte[] data = getData(entryName, start);
		return data != null ? BinaryObject.create(type, data) : null;
	}

	/**
	 * Retrieves the data of the first occurrence of a particular entry from a starting entry (by name) as a deserialized lump.
	 * <p>The names are case-insensitive.
	 * <p>Note that if the lump ordinarily as multiple amounts of the object type in question, this
	 * will read only the first one.
	 * @param <BO> the result type.
	 * @param entryName the name of the entry to find.
	 * @param startEntryName the starting entry (by name) with which to start the search.
	 * @param type the class type to deserialize into.
	 * @return the data, deserialized, or null if the entry doesn't exist.
	 * @throws IOException if the data couldn't be retrieved or the entry's offsets breach the file extents.
	 * @throws NullPointerException if <code>entryName</code> is <code>null</code>.
	 * @see BinaryObject#create(Class, byte[])
	 */
	default <BO extends BinaryObject> BO getDataAs(String entryName, String startEntryName, Class<BO> type) throws IOException
	{
		byte[] data = getData(entryName, startEntryName);
		return data != null ? BinaryObject.create(type, data) : null;
	}

	/**
	 * Retrieves the data of the specified entry as a deserialized lump.
	 * <p>Note that if the lump ordinarily as multiple amounts of the object type in question, this
	 * will read only the first one.
	 * @param <BO> the result type.
	 * @param entry the entry to use.
	 * @param type the class type to deserialize into.
	 * @return the data, deserialized.
	 * @throws IOException if the data couldn't be retrieved or the entry's offsets breach the file extents.
	 * @throws NullPointerException if <code>entry</code> is <code>null</code>.
	 * @see BinaryObject#create(Class, byte[])
	 */
	default <BO extends BinaryObject> BO getDataAs(WadEntry entry, Class<BO> type) throws IOException
	{
		return BinaryObject.create(type, getData(entry));
	}

	/**
	 * Retrieves the data of an entry at a particular index as a deserialized lump of multiple objects.
	 * @param <BO> the result type.
	 * @param n the index of the entry in the Wad.
	 * @param type the class type to deserialize into.
	 * @param objectLength the length of each individual object in bytes.
	 * @return the data, deserialized.
	 * @throws IOException if the data couldn't be retrieved.
	 * @throws ArrayIndexOutOfBoundsException if n &lt; 0 or &gt;= size.
	 * @see BinaryObject#create(Class, byte[])
	 */
	default <BO extends BinaryObject> BO[] getDataAs(int n, Class<BO> type, int objectLength) throws IOException
	{
		byte[] data = getData(n);
		return BinaryObject.create(type, data, data.length / objectLength);
	}

	/**
	 * Retrieves the data of the first occurrence of a particular entry as a deserialized lump of multiple objects.
	 * <p>The name is case-insensitive.
	 * @param <BO> the result type.
	 * @param entryName the name of the entry to find.
	 * @param type the class type to deserialize into.
	 * @param objectLength the length of each individual object in bytes.
	 * @return the data, deserialized, or null if the entry doesn't exist.
	 * @throws IOException if the data couldn't be retrieved or the entry's offsets breach the file extents.
	 * @throws NullPointerException if <code>entryName</code> is <code>null</code>.
	 * @see BinaryObject#create(Class, byte[])
	 */
	default <BO extends BinaryObject> BO[] getDataAs(String entryName, Class<BO> type, int objectLength) throws IOException
	{
		byte[] data = getData(entryName);
		return data != null ? BinaryObject.create(type, data, data.length / objectLength) : null;
	}

	/**
	 * Retrieves the data of the first occurrence of a particular entry from a starting index as a deserialized lump of multiple objects.
	 * <p>The name is case-insensitive.
	 * @param <BO> the result type.
	 * @param entryName the name of the entry to find.
	 * @param start the index with which to start the search.
	 * @param type the class type to deserialize into.
	 * @param objectLength the length of each individual object in bytes.
	 * @return the data, deserialized, or null if the entry doesn't exist.
	 * @throws IOException if the data couldn't be retrieved or the entry's offsets breach the file extents.
	 * @throws NullPointerException if <code>entryName</code> is <code>null</code>.
	 * @see BinaryObject#create(Class, byte[])
	 */
	default <BO extends BinaryObject> BO[] getDataAs(String entryName, int start, Class<BO> type, int objectLength) throws IOException
	{
		byte[] data = getData(entryName, start);
		return data != null ? BinaryObject.create(type, data, data.length / objectLength) : null;
	}

	/**
	 * Retrieves the data of the first occurrence of a particular entry from a starting entry (by name) as a deserialized lump of multiple objects.
	 * <p>The names are case-insensitive.
	 * @param <BO> the result type.
	 * @param entryName the name of the entry to find.
	 * @param startEntryName the starting entry (by name) with which to start the search.
	 * @param type the class type to deserialize into.
	 * @param objectLength the length of each individual object in bytes.
	 * @return the data, deserialized, or null if the entry doesn't exist.
	 * @throws IOException if the data couldn't be retrieved or the entry's offsets breach the file extents.
	 * @throws NullPointerException if <code>entryName</code> is <code>null</code>.
	 * @see BinaryObject#create(Class, byte[])
	 */
	default <BO extends BinaryObject> BO[] getDataAs(String entryName, String startEntryName, Class<BO> type, int objectLength) throws IOException
	{
		byte[] data = getData(entryName, startEntryName);
		return data != null ? BinaryObject.create(type, data, data.length / objectLength) : null;
	}

	/**
	 * Retrieves the data of the specified entry as a deserialized lump of multiple objects.
	 * @param <BO> the result type.
	 * @param entry the entry to use.
	 * @param type the class type to deserialize into.
	 * @param objectLength the length of each individual object in bytes.
	 * @return the data, deserialized.
	 * @throws IOException if the data couldn't be retrieved or the entry's offsets breach the file extents.
	 * @throws NullPointerException if <code>entry</code> is <code>null</code>.
	 * @see BinaryObject#create(Class, byte[])
	 */
	default <BO extends BinaryObject> BO[] getDataAs(WadEntry entry, Class<BO> type, int objectLength) throws IOException
	{
		byte[] data = getData(entry);
		return BinaryObject.create(type, data, data.length / objectLength);
	}

	/**
	 * Retrieves the data of an entry at a particular index as a deserialized lump of multiple objects.
	 * @param <BO> the result type.
	 * @param n the index of the entry in the Wad.
	 * @param type the class type to deserialize into.
	 * @param objectLength the length of each individual object in bytes.
	 * @return the data, deserialized.
	 * @throws IOException if the data couldn't be retrieved.
	 * @throws ArrayIndexOutOfBoundsException if n &lt; 0 or &gt;= size.
	 * @see BinaryObject#create(Class, byte[])
	 */
	default <BO extends BinaryObject> List<BO> getDataAsList(int n, Class<BO> type, int objectLength) throws IOException
	{
		byte[] data = getData(n);
		return Arrays.asList(BinaryObject.create(type, data, data.length / objectLength));
	}

	/**
	 * Retrieves the data of the first occurrence of a particular entry as a deserialized lump of multiple objects.
	 * <p>The name is case-insensitive.
	 * @param <BO> the result type.
	 * @param entryName the name of the entry to find.
	 * @param type the class type to deserialize into.
	 * @param objectLength the length of each individual object in bytes.
	 * @return the data, deserialized, or null if the entry doesn't exist.
	 * @throws IOException if the data couldn't be retrieved or the entry's offsets breach the file extents.
	 * @throws NullPointerException if <code>entryName</code> is <code>null</code>.
	 * @see BinaryObject#create(Class, byte[])
	 */
	default <BO extends BinaryObject> List<BO> getDataAsList(String entryName, Class<BO> type, int objectLength) throws IOException
	{
		byte[] data = getData(entryName);
		return data != null ? Arrays.asList(BinaryObject.create(type, data, data.length / objectLength)) : null;
	}

	/**
	 * Retrieves the data of the first occurrence of a particular entry from a starting index as a deserialized lump of multiple objects.
	 * <p>The name is case-insensitive.
	 * @param <BO> the result type.
	 * @param entryName the name of the entry to find.
	 * @param start the index with which to start the search.
	 * @param type the class type to deserialize into.
	 * @param objectLength the length of each individual object in bytes.
	 * @return the data, deserialized, or null if the entry doesn't exist.
	 * @throws IOException if the data couldn't be retrieved or the entry's offsets breach the file extents.
	 * @throws NullPointerException if <code>entryName</code> is <code>null</code>.
	 * @see BinaryObject#create(Class, byte[])
	 */
	default <BO extends BinaryObject> List<BO> getDataAsList(String entryName, int start, Class<BO> type, int objectLength) throws IOException
	{
		byte[] data = getData(entryName, start);
		return data != null ? Arrays.asList(BinaryObject.create(type, data, data.length / objectLength)) : null;
	}

	/**
	 * Retrieves the data of the first occurrence of a particular entry from a starting entry (by name) as a deserialized lump of multiple objects.
	 * <p>The names are case-insensitive.
	 * @param <BO> the result type.
	 * @param entryName the name of the entry to find.
	 * @param startEntryName the starting entry (by name) with which to start the search.
	 * @param type the class type to deserialize into.
	 * @param objectLength the length of each individual object in bytes.
	 * @return the data, deserialized, or null if the entry doesn't exist.
	 * @throws IOException if the data couldn't be retrieved or the entry's offsets breach the file extents.
	 * @throws NullPointerException if <code>entryName</code> is <code>null</code>.
	 * @see BinaryObject#create(Class, byte[])
	 */
	default <BO extends BinaryObject> List<BO> getDataAsList(String entryName, String startEntryName, Class<BO> type, int objectLength) throws IOException
	{
		byte[] data = getData(entryName, startEntryName);
		return data != null ? Arrays.asList(BinaryObject.create(type, data, data.length / objectLength)) : null;
	}

	/**
	 * Retrieves the data of the specified entry as a deserialized lump of multiple objects.
	 * @param <BO> the result type.
	 * @param entry the entry to use.
	 * @param type the class type to deserialize into.
	 * @param objectLength the length of each individual object in bytes.
	 * @return the data, deserialized.
	 * @throws IOException if the data couldn't be retrieved or the entry's offsets breach the file extents.
	 * @throws NullPointerException if <code>entry</code> is <code>null</code>.
	 * @see BinaryObject#create(Class, byte[])
	 */
	default <BO extends BinaryObject> List<BO> getDataAsList(WadEntry entry, Class<BO> type, int objectLength) throws IOException
	{
		byte[] data = getData(entry);
		return Arrays.asList(BinaryObject.create(type, data, data.length / objectLength));
	}

	/**
	 * Retrieves the data of a particular entry at a specific index and returns it as 
	 * a deserializing scanner iterator that returns independent instances of objects.
	 * <p>Use of this to iterate through objects may be preferable when all of them in a lump do not need to be scanned or deserialized.
	 * <p>If you don't intend to read the entirety of the entry via the {@link InlineScanner}, close it after you finish (or use a try-with-resources block)!
	 * @param <BO> the result type.
	 * @param n the index of the entry.
	 * @param type the class type to deserialize into.
	 * @param objectLength the length of each object in the entry in bytes.
	 * @return a scanner for the data.
	 * @throws IOException if the data couldn't be retrieved or the entry's offsets breach the file extents.
	 * @throws ArrayIndexOutOfBoundsException if n &lt; 0 or &gt;= size.
	 */
	default <BO extends BinaryObject> BinaryObject.Scanner<BO> getScanner(int n, Class<BO> type, int objectLength) throws IOException
	{
		return BinaryObject.scanner(type, getInputStream(n), objectLength);
	}

	/**
	 * Retrieves the data of the first occurrence of a particular entry and returns it as 
	 * a deserializing scanner iterator that returns independent instances of objects.
	 * <p>Use of this to iterate through objects may be preferable when all of them in a lump do not need to be scanned or deserialized.
	 * <p>The name is case-insensitive.
	 * <p>If you don't intend to read the entirety of the entry via the {@link Scanner}, close it after you finish (or use a try-with-resources block)!
	 * @param <BO> the result type.
	 * @param entryName the name of the entry to find.
	 * @param type the class type to deserialize into.
	 * @param objectLength the length of each object in the entry in bytes.
	 * @return a scanner for the data, or null if the entry can't be found.
	 * @throws IOException if the data couldn't be retrieved or the entry's offsets breach the file extents.
	 */
	default <BO extends BinaryObject> BinaryObject.Scanner<BO> getScanner(String entryName, Class<BO> type, int objectLength) throws IOException
	{
		InputStream in = getInputStream(entryName);
		return in != null ? BinaryObject.scanner(type, in, objectLength) : null;
	}

	/**
	 * Retrieves the data of the first occurrence of a particular entry from a starting index and returns it as 
	 * a deserializing scanner iterator that returns independent instances of objects.
	 * <p>Use of this to iterate through objects may be preferable when all of them in a lump do not need to be scanned or deserialized.
	 * <p>The name is case-insensitive.
	 * <p>If you don't intend to read the entirety of the entry via the {@link Scanner}, close it after you finish (or use a try-with-resources block)!
	 * @param <BO> the result type.
	 * @param entryName the name of the entry to find.
	 * @param start the index with which to start the search.
	 * @param type the class type to deserialize into.
	 * @param objectLength the length of each object in the entry in bytes.
	 * @return a scanner for the data, or null if the entry can't be found.
	 * @throws IOException if the data couldn't be retrieved or the entry's offsets breach the file extents.
	 */
	default <BO extends BinaryObject> BinaryObject.Scanner<BO> getScanner(String entryName, int start, Class<BO> type, int objectLength) throws IOException
	{
		InputStream in = getInputStream(entryName, start);
		return in != null ? BinaryObject.scanner(type, in, objectLength) : null;
	}

	/**
	 * Retrieves the data of the first occurrence of a particular entry from a starting entry (by name) and returns it as 
	 * a deserializing scanner iterator that returns independent instances of objects.
	 * <p>Use of this to iterate through objects may be preferable when all of them in a lump do not need to be scanned or deserialized.
	 * <p>The names are case-insensitive.
	 * <p>If you don't intend to read the entirety of the entry via the {@link Scanner}, close it after you finish (or use a try-with-resources block)!
	 * @param <BO> the result type.
	 * @param entryName the name of the entry to find.
	 * @param startEntryName the starting entry (by name) with which to start the search.
	 * @param type the class type to deserialize into.
	 * @param objectLength the length of each object in the entry in bytes.
	 * @return a scanner for the data, or null if the entry can't be found.
	 * @throws IOException if the data couldn't be retrieved or the entry's offsets breach the file extents.
	 */
	default <BO extends BinaryObject> BinaryObject.Scanner<BO> getScanner(String entryName, String startEntryName, Class<BO> type, int objectLength) throws IOException
	{
		InputStream in = getInputStream(entryName, startEntryName);
		return in != null ? BinaryObject.scanner(type, in, objectLength) : null;
	}

	/**
	 * Retrieves the data of the specified entry and returns it as 
	 * a deserializing scanner iterator that returns independent instances of objects.
	 * <p>Use of this to iterate through objects may be preferable when all of them in a lump do not need to be scanned or deserialized.
	 * <p>If you don't intend to read the entirety of the entry via the {@link Scanner}, close it after you finish (or use a try-with-resources block)!
	 * @param <BO> the result type.
	 * @param entry the entry to use.
	 * @param type the class type to deserialize into.
	 * @param objectLength the length of each object in the entry in bytes.
	 * @return a scanner for the data.
	 * @throws IOException if the data couldn't be retrieved or the entry's offsets breach the file extents.
	 * @throws NullPointerException if <code>entry</code> is <code>null</code>.
	 */
	default <BO extends BinaryObject> BinaryObject.Scanner<BO> getScanner(WadEntry entry, Class<BO> type, int objectLength) throws IOException
	{
		return BinaryObject.scanner(type, getInputStream(entry), objectLength);
	}

	/**
	 * Retrieves the data of a particular entry at a specific index and returns it as 
	 * a deserializing scanner iterator that returns the same object instance with its contents changed.
	 * <p>This is useful for when you would want to quickly scan through a set of serialized objects while
	 * ensuring low memory use. Do NOT store the references returned by <code>next()</code> anywhere as the contents
	 * of that reference will be changed by the next call to <code>next()</code>.
	 * <p>If you don't intend to read the entirety of the entry via the {@link InlineScanner}, close it after you finish (or use a try-with-resources block)!
	 * @param <BO> the result type.
	 * @param n the index of the entry.
	 * @param type the class type to deserialize into.
	 * @param objectLength the length of each object in the entry in bytes.
	 * @return a scanner for the data.
	 * @throws IOException if the data couldn't be retrieved or the entry's offsets breach the file extents.
	 * @throws ArrayIndexOutOfBoundsException if n &lt; 0 or &gt;= size.
	 */
	default <BO extends BinaryObject> BinaryObject.InlineScanner<BO> getInlineScanner(int n, Class<BO> type, int objectLength) throws IOException
	{
		InputStream in = getInputStream(n);
		return BinaryObject.inlineScanner(type, in, objectLength);
	}

	/**
	 * Retrieves the data of the first occurrence of a particular entry and returns it as 
	 * a deserializing scanner iterator that returns the same object instance with its contents changed.
	 * <p>This is useful for when you would want to quickly scan through a set of serialized objects while
	 * ensuring low memory use. Do NOT store the references returned by <code>next()</code> anywhere as the contents
	 * of that reference will be changed by the next call to <code>next()</code>.
	 * <p>The name is case-insensitive.
	 * <p>If you don't intend to read the entirety of the entry via the {@link InlineScanner}, close it after you finish (or use a try-with-resources block)!
	 * @param <BO> the result type.
	 * @param entryName the name of the entry to find.
	 * @param type the class type to deserialize into.
	 * @param objectLength the length of each object in the entry in bytes.
	 * @return a scanner for the data, or null if the entry can't be found.
	 * @throws IOException if the data couldn't be retrieved or the entry's offsets breach the file extents.
	 */
	default <BO extends BinaryObject> BinaryObject.InlineScanner<BO> getInlineScanner(String entryName, Class<BO> type, int objectLength) throws IOException
	{
		InputStream in = getInputStream(entryName);
		return in != null ? BinaryObject.inlineScanner(type, in, objectLength) : null;
	}

	/**
	 * Retrieves the data of the first occurrence of a particular entry from a starting index and returns it as 
	 * a deserializing scanner iterator that returns the same object instance with its contents changed.
	 * <p>This is useful for when you would want to quickly scan through a set of serialized objects while
	 * ensuring low memory use. Do NOT store the references returned by <code>next()</code> anywhere as the contents
	 * of that reference will be changed by the next call to <code>next()</code>.
	 * <p>The name is case-insensitive.
	 * <p>If you don't intend to read the entirety of the entry via the {@link InlineScanner}, close it after you finish (or use a try-with-resources block)!
	 * @param <BO> the result type.
	 * @param entryName the name of the entry to find.
	 * @param start the index with which to start the search.
	 * @param type the class type to deserialize into.
	 * @param objectLength the length of each object in the entry in bytes.
	 * @return a scanner for the data, or null if the entry can't be found.
	 * @throws IOException if the data couldn't be retrieved or the entry's offsets breach the file extents.
	 */
	default <BO extends BinaryObject> BinaryObject.InlineScanner<BO> getInlineScanner(String entryName, int start, Class<BO> type, int objectLength) throws IOException
	{
		InputStream in = getInputStream(entryName, start);
		return in != null ? BinaryObject.inlineScanner(type, in, objectLength) : null;
	}

	/**
	 * Retrieves the data of the first occurrence of a particular entry from a starting entry (by name) and returns it as 
	 * a deserializing scanner iterator that returns the same object instance with its contents changed.
	 * <p>This is useful for when you would want to quickly scan through a set of serialized objects while
	 * ensuring low memory use. Do NOT store the references returned by <code>next()</code> anywhere as the contents
	 * of that reference will be changed by the next call to <code>next()</code>.
	 * <p>The names are case-insensitive.
	 * <p>If you don't intend to read the entirety of the entry via the {@link InlineScanner}, close it after you finish (or use a try-with-resources block)!
	 * @param <BO> the result type.
	 * @param entryName the name of the entry to find.
	 * @param startEntryName the starting entry (by name) with which to start the search.
	 * @param type the class type to deserialize into.
	 * @param objectLength the length of each object in the entry in bytes.
	 * @return a scanner for the data, or null if the entry can't be found.
	 * @throws IOException if the data couldn't be retrieved or the entry's offsets breach the file extents.
	 */
	default <BO extends BinaryObject> BinaryObject.InlineScanner<BO> getInlineScanner(String entryName, String startEntryName, Class<BO> type, int objectLength) throws IOException
	{
		InputStream in = getInputStream(entryName, startEntryName);
		return in != null ? BinaryObject.inlineScanner(type, in, objectLength) : null;
	}

	/**
	 * Retrieves the data of the specified entry and returns it as a 
	 * deserializing scanner iterator that returns the same object instance with its contents changed.
	 * <p>This is useful for when you would want to quickly scan through a set of serialized objects while
	 * ensuring low memory use. Do NOT store the references returned by <code>next()</code> anywhere as the contents
	 * of that reference will be changed by the next call to <code>next()</code>.
	 * <p>If you don't intend to read the entirety of the entry via the {@link InlineScanner}, close it after you finish (or use a try-with-resources block)!
	 * @param <BO> the result type.
	 * @param entry the entry to use.
	 * @param type the class type to deserialize into.
	 * @param objectLength the length of each object in the entry in bytes.
	 * @return a scanner for the data.
	 * @throws IOException if the data couldn't be retrieved or the entry's offsets breach the file extents.
	 * @throws NullPointerException if <code>entry</code> is <code>null</code>.
	 */
	default <BO extends BinaryObject> BinaryObject.InlineScanner<BO> getInlineScanner(WadEntry entry, Class<BO> type, int objectLength) throws IOException
	{
		return BinaryObject.inlineScanner(type, getInputStream(entry), objectLength);
	}

	/**
	 * Retrieves the deserialized data of a particular entry index, 
	 * optionally transforms it, then writes it back to the Wad.
	 * @param <BO> the data type.
	 * @param n the index of the entry in the Wad.
	 * @param type the class type to deserialize into.
	 * @param transformer the transformer function to use - called on each object read.
	 * @throws IOException if the data couldn't be retrieved.
	 * @throws ArrayIndexOutOfBoundsException if n &lt; 0 or &gt;= size.
	 * @since 2.1.0
	 */
	default <BO extends BinaryObject> void transformData(int n, Class<BO> type, BinaryObject.Transformer<BO> transformer) throws IOException
	{
		BO bo = getDataAs(n, type);
		transformer.transform(bo, 0);
		replaceEntry(n, bo.toBytes());
	}

	/**
	 * Retrieves the deserialized data of a particular entry, 
	 * optionally transforms it, then writes it back to the Wad.
	 * @param <BO> the data type.
	 * @param entryName the name of the entry to find.
	 * @param type the class type to deserialize into.
	 * @param transformer the transformer function to use - called on each object read.
	 * @return true if the entry was found and the transformer function was called at least once, false otherwise.
	 * @throws IOException if the data couldn't be retrieved.
	 * @throws ArrayIndexOutOfBoundsException if n &lt; 0 or &gt;= size.
	 * @since 2.1.0
	 */
	default <BO extends BinaryObject> boolean transformData(String entryName, Class<BO> type, BinaryObject.Transformer<BO> transformer) throws IOException
	{
		int index = indexOf(entryName);
		if (index >= 0)
		{
			transformData(index, type, transformer);
			return true;
		}
		else
			return false;
	}

	/**
	 * Retrieves the deserialized data of a particular entry, 
	 * optionally transforms it, then writes it back to the Wad.
	 * @param <BO> the data type.
	 * @param entryName the name of the entry to find.
	 * @param start the index with which to start the search.
	 * @param type the class type to deserialize into.
	 * @param transformer the transformer function to use - called on each object read.
	 * @return true if the entry was found and the transformer function was called at least once, false otherwise.
	 * @throws IOException if the data couldn't be retrieved.
	 * @throws ArrayIndexOutOfBoundsException if n &lt; 0 or &gt;= size.
	 * @since 2.1.0
	 */
	default <BO extends BinaryObject> boolean transformData(String entryName, int start, Class<BO> type, BinaryObject.Transformer<BO> transformer) throws IOException
	{
		int index = indexOf(entryName, start);
		if (index >= 0)
		{
			transformData(index, type, transformer);
			return true;
		}
		else
			return false;
	}

	/**
	 * Retrieves the deserialized data of a particular entry, 
	 * optionally transforms it, then writes it back to the Wad.
	 * @param <BO> the data type.
	 * @param entryName the name of the entry to find.
	 * @param startEntryName the starting entry (by name) with which to start the search.
	 * @param type the class type to deserialize into.
	 * @param transformer the transformer function to use - called on each object read.
	 * @return true if the entry was found and the transformer function was called at least once, false otherwise.
	 * @throws IOException if the data couldn't be retrieved.
	 * @throws ArrayIndexOutOfBoundsException if n &lt; 0 or &gt;= size.
	 * @since 2.1.0
	 */
	default <BO extends BinaryObject> boolean transformData(String entryName, String startEntryName, Class<BO> type, BinaryObject.Transformer<BO> transformer) throws IOException
	{
		int index = indexOf(entryName, startEntryName);
		if (index >= 0)
		{
			transformData(index, type, transformer);
			return true;
		}
		else
			return false;
	}

	/**
	 * Retrieves the data of a particular entry index as a deserialized lump of multiple objects, 
	 * optionally transforms it, then writes it back to the Wad.
	 * @param <BO> the data type.
	 * @param n the index of the entry in the Wad.
	 * @param type the class type to deserialize into.
	 * @param objectLength the length of each object in the entry in bytes.
	 * @param transformer the transformer function to use - called on each object read.
	 * @throws IOException if the data couldn't be retrieved.
	 * @throws ArrayIndexOutOfBoundsException if n &lt; 0 or &gt;= size.
	 * @since 2.1.0
	 */
	default <BO extends BinaryObject> void transformData(int n, Class<BO> type, int objectLength, BinaryObject.Transformer<BO> transformer) throws IOException
	{
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		BinaryObject.InlineScanner<BO> scanner = getInlineScanner(n, type, objectLength);
		int i = 0;
		while (scanner.hasNext())
		{
			BO next = scanner.next();
			transformer.transform(next, i++);
			next.writeBytes(bos);
		}
		replaceEntry(n, bos.toByteArray());
	}

	/**
	 * Retrieves the deserialized data of a particular entry, 
	 * optionally transforms it, then writes it back to the Wad.
	 * @param <BO> the data type.
	 * @param entryName the name of the entry to find.
	 * @param type the class type to deserialize into.
	 * @param objectLength the length of each object in the entry in bytes.
	 * @param transformer the transformer function to use - called on each object read.
	 * @return true if the entry was found and the transformer function was called at least once, false otherwise.
	 * @throws IOException if the data couldn't be retrieved.
	 * @throws ArrayIndexOutOfBoundsException if n &lt; 0 or &gt;= size.
	 * @since 2.1.0
	 */
	default <BO extends BinaryObject> boolean transformData(String entryName, Class<BO> type, int objectLength, BinaryObject.Transformer<BO> transformer) throws IOException
	{
		int index = indexOf(entryName);
		if (index >= 0)
		{
			transformData(index, type, objectLength, transformer);
			return true;
		}
		else
			return false;
	}

	/**
	 * Retrieves the deserialized data of a particular entry, 
	 * optionally transforms it, then writes it back to the Wad.
	 * @param <BO> the data type.
	 * @param entryName the name of the entry to find.
	 * @param start the index with which to start the search.
	 * @param type the class type to deserialize into.
	 * @param objectLength the length of each object in the entry in bytes.
	 * @param transformer the transformer function to use - called on each object read.
	 * @return true if the entry was found and the transformer, false
	 * @throws IOException if the data couldn't be retrieved.
	 * @throws ArrayIndexOutOfBoundsException if n &lt; 0 or &gt;= size.
	 * @since 2.1.0
	 */
	default <BO extends BinaryObject> boolean transformData(String entryName, int start, Class<BO> type, int objectLength, BinaryObject.Transformer<BO> transformer) throws IOException
	{
		int index = indexOf(entryName, start);
		if (index >= 0)
		{
			transformData(index, type, objectLength, transformer);
			return true;
		}
		else
			return false;
	}

	/**
	 * Retrieves the deserialized data of a particular entry, 
	 * optionally transforms it, then writes it back to the Wad.
	 * @param <BO> the data type.
	 * @param entryName the name of the entry to find.
	 * @param startEntryName the starting entry (by name) with which to start the search.
	 * @param type the class type to deserialize into.
	 * @param objectLength the length of each object in the entry in bytes.
	 * @param transformer the transformer function to use - called on each object read.
	 * @return true if the entry was found and the transformer, false
	 * @throws IOException if the data couldn't be retrieved.
	 * @throws ArrayIndexOutOfBoundsException if n &lt; 0 or &gt;= size.
	 * @since 2.1.0
	 */
	default <BO extends BinaryObject> boolean transformData(String entryName, String startEntryName, Class<BO> type, int objectLength, BinaryObject.Transformer<BO> transformer) throws IOException
	{
		int index = indexOf(entryName, startEntryName);
		if (index >= 0)
		{
			transformData(index, type, objectLength, transformer);
			return true;
		}
		else
			return false;
	}

	/**
	 * Retrieves the decoded data of a particular entry index, 
	 * optionally transforms it, then writes it back to the Wad.
	 * @param <TO> the data type.
	 * @param n the index of the entry in the Wad.
	 * @param charset the source charset encoding.
	 * @param type the class type to deserialize into.
	 * @param transformer the transformer function to use - called on each object read.
	 * @throws IOException if the data couldn't be retrieved.
	 * @throws ArrayIndexOutOfBoundsException if n &lt; 0 or &gt;= size.
	 * @since 2.1.0
	 */
	default <TO extends TextObject> void transformTextData(int n, Charset charset, Class<TO> type, TextObject.Transformer<TO> transformer) throws IOException
	{
		TO to = getTextDataAs(n, charset, type);
		transformer.transform(to);
		replaceEntry(n, to.toText().getBytes(charset));
	}

	/**
	 * Retrieves the decoded data of a particular entry, 
	 * optionally transforms it, then writes it back to the Wad.
	 * @param <TO> the data type.
	 * @param entryName the name of the entry to find.
	 * @param charset the source charset encoding.
	 * @param type the class type to deserialize into.
	 * @param transformer the transformer function to use - called on each object read.
	 * @return true if the entry was found and the transformer function was called at least once, false otherwise.
	 * @throws IOException if the data couldn't be retrieved.
	 * @throws ArrayIndexOutOfBoundsException if n &lt; 0 or &gt;= size.
	 * @since 2.1.0
	 */
	default <TO extends TextObject> boolean transformTextData(String entryName, Charset charset, Class<TO> type, TextObject.Transformer<TO> transformer) throws IOException
	{
		int index = indexOf(entryName);
		if (index >= 0)
		{
			transformTextData(index, charset, type, transformer);
			return true;
		}
		else
			return false;
	}

	/**
	 * Retrieves the decoded data of a particular entry, 
	 * optionally transforms it, then writes it back to the Wad.
	 * @param <TO> the data type.
	 * @param entryName the name of the entry to find.
	 * @param start the index with which to start the search.
	 * @param charset the source charset encoding.
	 * @param type the class type to deserialize into.
	 * @param transformer the transformer function to use - called on each object read.
	 * @return true if the entry was found and the transformer function was called at least once, false otherwise.
	 * @throws IOException if the data couldn't be retrieved.
	 * @throws ArrayIndexOutOfBoundsException if n &lt; 0 or &gt;= size.
	 * @since 2.1.0
	 */
	default <TO extends TextObject> boolean transformTextData(String entryName, int start, Charset charset, Class<TO> type, TextObject.Transformer<TO> transformer) throws IOException
	{
		int index = indexOf(entryName, start);
		if (index >= 0)
		{
			transformTextData(index, charset, type, transformer);
			return true;
		}
		else
			return false;
	}

	/**
	 * Retrieves the decoded data of a particular entry, 
	 * optionally transforms it, then writes it back to the Wad.
	 * @param <TO> the data type.
	 * @param entryName the name of the entry to find.
	 * @param startEntryName the starting entry (by name) with which to start the search.
	 * @param charset the source charset encoding.
	 * @param type the class type to deserialize into.
	 * @param transformer the transformer function to use - called on each object read.
	 * @return true if the entry was found and the transformer function was called at least once, false otherwise.
	 * @throws IOException if the data couldn't be retrieved.
	 * @throws ArrayIndexOutOfBoundsException if n &lt; 0 or &gt;= size.
	 * @since 2.1.0
	 */
	default <TO extends TextObject> boolean transformTextData(String entryName, String startEntryName, Charset charset, Class<TO> type, TextObject.Transformer<TO> transformer) throws IOException
	{
		int index = indexOf(entryName, startEntryName);
		if (index >= 0)
		{
			transformTextData(index, charset, type, transformer);
			return true;
		}
		else
			return false;
	}

	/**
	 * Checks if this Wad contains a particular entry, false otherwise.
	 * <p>The name is case-insensitive.
	 * @param entryName the name of the entry.
	 * @return true if so, false if not.
	 */
	default boolean contains(String entryName)
	{
		return indexOf(entryName, 0) > -1;
	}

	/**
	 * Checks if this Wad contains a particular entry from a starting entry index, false otherwise.
	 * <p>The name is case-insensitive.
	 * @param entryName the name of the entry.
	 * @param index the index to start from.
	 * @return true if so, false if not.
	 */
	default boolean contains(String entryName, int index)
	{
		return indexOf(entryName, index) > -1;
	}

	/**
	 * Checks if this Wad contains a particular entry from a starting entry (by name), false otherwise.
	 * <p>The names are case-insensitive.
	 * @param entryName the name of the entry.
	 * @param startEntryName the starting entry (by name). 
	 * @return true if so, false if not.
	 */
	default boolean contains(String entryName, String startEntryName)
	{
		return indexOf(entryName, startEntryName) > -1;
	}

	/**
	 * Adds a new entry to the Wad, but with an explicit offset and size.
	 * Exercise caution with this method, since you can reference anywhere in the Wad!
	 *  
	 * @param entryName the name of the entry.
	 * @param offset the entry's content start byte.
	 * @param length the entry's length in bytes.
	 * @return the entry that was created.
	 * @throws IllegalArgumentException if the provided name is not a valid name, or the offset/size is negative.
	 * @throws IOException if the entry cannot be written.
	 * @throws NullPointerException if <code>name</code> is <code>null</code>.
	 */
	default WadEntry addEntry(String entryName, int offset, int length) throws IOException
	{
		return addEntryAt(getEntryCount(), entryName, offset, length);
	}

	/**
	 * Adds a new entry to the Wad.
	 * Exercise caution with this method, as this entry is added as-is, and an entry can reference anywhere in the Wad!
	 *  
	 * @param entry the entry to add.
	 * @return the entry added.
	 * @throws IOException if the entry cannot be written.
	 * @throws NullPointerException if <code>entry</code> is <code>null</code>.
	 * @since 2.9.0
	 */
	default WadEntry addEntry(WadEntry entry) throws IOException
	{
		return addEntryAt(getEntryCount(), entry);
	}

	/**
	 * Adds a new entry to the Wad at a specific index, but with an explicit offset and size.
	 * The rest of the entries afterward are shifted an index forward.
	 * Exercise caution with this method, since you can reference anywhere in the Wad!
	 * 
	 * @param index the index at which to add the entry.
	 * @param entryName the name of the entry.
	 * @param offset the entry's content start byte.
	 * @param length the entry's length in bytes.
	 * @return the entry that was created.
	 * @throws IllegalArgumentException if the provided name is not a valid name, or the offset/size is negative.
	 * @throws IOException if the entry cannot be written.
	 * @throws NullPointerException if <code>name</code> is <code>null</code>.
	 * @since 2.7.0
	 */
	default WadEntry addEntryAt(int index, String entryName, int offset, int length) throws IOException
	{
		return addEntryAt(index, WadEntry.create(entryName, offset, length));
	}

	/**
	 * Adds a new entry to the Wad.
	 * Exercise caution with this method, as this entry is added as-is, and an entry can reference anywhere in the Wad!
	 * 
	 * @param index the index at which to add the entry.
	 * @param entry the entry to add.
	 * @return the entry added.
	 * @throws IOException if the entry cannot be written.
	 * @throws NullPointerException if <code>entry</code> is <code>null</code>.
	 * @since 2.9.0
	 */
	WadEntry addEntryAt(int index, WadEntry entry) throws IOException;
	
	/**
	 * Adds an entry marker to the Wad (entry with 0 size, arbitrary offset).
	 * 
	 * @param entryName the name of the entry.
	 * @return the entry that was added.
	 * @throws IllegalArgumentException if the provided name is not a valid name.
	 * @throws IOException if the entry cannot be written.
	 * @throws NullPointerException if <code>name</code> is <code>null</code>.
	 */
	default WadEntry addMarker(String entryName) throws IOException
	{
		return addEntry(WadEntry.create(entryName, getContentLength(), 0));
	}

	/**
	 * Adds an entry marker to the Wad (entry with 0 size, arbitrary offset).
	 * 
	 * @param index the index at which to add the marker.
	 * @param entryName the name of the entry.
	 * @return the entry that was added.
	 * @throws IllegalArgumentException if the provided name is not a valid name.
	 * @throws IOException if the entry cannot be written.
	 * @throws NullPointerException if <code>name</code> is <code>null</code>.
	 */
	default WadEntry addMarkerAt(int index, String entryName) throws IOException
	{
		return addEntryAt(index, WadEntry.create(entryName, getContentLength(), 0));
	}

	/**
	 * Adds data to this Wad, using <code>entryName</code> as the name of the new entry. 
	 * The overhead for multiple individual additions may be expensive I/O-wise depending on the Wad implementation.
	 * 
	 * @param entryName the name of the entry to add this as.
	 * @param data the bytes of data to add as this wad's data.
	 * @return a WadEntry that describes the added data.
	 * @throws IllegalArgumentException if the provided name is not a valid name.
	 * @throws IOException if the data cannot be written.
	 * @throws NullPointerException if <code>entryName</code> or <code>data</code> is <code>null</code>.
	 */
	default WadEntry addData(String entryName, byte[] data) throws IOException
	{
		return addDataAt(getEntryCount(), entryName, data);
	}

	/**
	 * Adds data to this Wad, using <code>entryName</code> as the name of the new entry. 
	 * The overhead for multiple individual additions may be expensive I/O-wise depending on the Wad implementation.
	 * 
	 * @param entryName the name of the entry to add this as.
	 * @param data the BinaryObject to add as this wad's data (converted via {@link BinaryObject#toBytes()}).
	 * @param <BO> a BinaryObject type.
	 * @return a WadEntry that describes the added data.
	 * @throws IllegalArgumentException if the provided name is not a valid name.
	 * @throws IOException if the data cannot be written.
	 * @throws NullPointerException if <code>entryName</code> or <code>data</code> is <code>null</code>.
	 * @since 2.2.0
	 */
	default <BO extends BinaryObject> WadEntry addData(String entryName, BO data) throws IOException
	{
		return addDataAt(getEntryCount(), entryName, data.toBytes());
	}

	/**
	 * Adds data to this Wad, using <code>entryName</code> as the name of the new entry.
	 * The BinaryObjects provided have all of their converted data concatenated together as one blob of contiguous data.
	 * The overhead for multiple individual additions may be expensive I/O-wise depending on the Wad implementation.
	 * 
	 * @param entryName the name of the entry to add this as.
	 * @param data the BinaryObjects to add as this wad's data (converted via {@link BinaryObject#toBytes()}).
	 * @param <BO> a BinaryObject type.
	 * @return a WadEntry that describes the added data.
	 * @throws IllegalArgumentException if the provided name is not a valid name.
	 * @throws IOException if the data cannot be written.
	 * @throws NullPointerException if <code>entryName</code> or <code>data</code> is <code>null</code>.
	 * @since 2.2.0
	 */
	default <BO extends BinaryObject> WadEntry addData(String entryName, BO[] data) throws IOException
	{
		return addDataAt(getEntryCount(), entryName, BinaryObject.toBytes(data));
	}

	/**
	 * Adds data to this Wad, using <code>entryName</code> as the name of the new entry. 
	 * The overhead for multiple individual additions may be expensive I/O-wise depending on the Wad implementation.
	 * 
	 * @param entryName the name of the entry to add this as.
	 * @param data the TextObject to add as this wad's data (converted via {@link TextObject#toText()}, then {@link String#getBytes(Charset)}).
	 * @param encoding the encoding type for the data written to the Wad.
	 * @param <TO> a TextObject type.
	 * @return a WadEntry that describes the added data.
	 * @throws IllegalArgumentException if the provided name is not a valid name.
	 * @throws IOException if the data cannot be written.
	 * @throws NullPointerException if <code>entryName</code> or <code>data</code> or <code>encoding</code> is <code>null</code>.
	 * @since 2.2.0
	 */
	default <TO extends TextObject> WadEntry addData(String entryName, TO data, Charset encoding) throws IOException
	{
		return addDataAt(getEntryCount(), entryName, data.toText().getBytes(encoding));
	}

	/**
	 * Adds data to this Wad, using <code>entryName</code> as the name of the new entry.
	 * The provided File is read until the end of the file is reached.
	 * The overhead for multiple individual additions may be expensive I/O-wise depending on the Wad implementation.
	 * 
	 * @param entryName the name of the entry to add this as.
	 * @param fileToAdd the file to add the contents of.
	 * @return a WadEntry that describes the added data.
	 * @throws IllegalArgumentException if the provided name is not a valid name.
	 * @throws FileNotFoundException if the file path refers to a file that is a directory or doesn't exist.
	 * @throws IOException if the data cannot be written or the stream could not be read.
	 * @throws NullPointerException if <code>entryName</code> or <code>fileToAdd</code> is <code>null</code>.
	 * @since 2.7.0
	 */
	default WadEntry addData(String entryName, File fileToAdd) throws IOException
	{
		return addDataAt(getEntryCount(), entryName, fileToAdd);
	}

	/**
	 * Adds data to this Wad, using <code>entryName</code> as the name of the new entry.
	 * The provided input stream is read until the end of the stream is reached.
	 * The input stream is NOT CLOSED, afterward.
	 * The overhead for multiple individual additions may be expensive I/O-wise depending on the Wad implementation.
	 * 
	 * @param entryName the name of the entry to add this as.
	 * @param in the input stream to read.
	 * @return a WadEntry that describes the added data.
	 * @throws IllegalArgumentException if the provided name is not a valid name.
	 * @throws IOException if the data cannot be written or the stream could not be read.
	 * @throws NullPointerException if <code>entryName</code> or <code>in</code> is <code>null</code>.
	 * @since 2.7.0
	 */
	default WadEntry addData(String entryName, InputStream in) throws IOException
	{
		return addDataAt(getEntryCount(), entryName, in, -1);
	}

	/**
	 * Adds data to this Wad, using <code>entryName</code> as the name of the new entry.
	 * The provided input stream is read until the end of the stream is reached or <code>maxLength</code> bytes are read.
	 * The input stream is NOT CLOSED, afterward.
	 * The overhead for multiple individual additions may be expensive I/O-wise depending on the Wad implementation.
	 * 
	 * @param entryName the name of the entry to add this as.
	 * @param in the input stream to read.
	 * @param maxLength the maximum amount of bytes to read from the InputStream, or a value &lt; 0 to keep reading until end-of-stream.
	 * @return a WadEntry that describes the added data.
	 * @throws IllegalArgumentException if the provided name is not a valid name.
	 * @throws IOException if the data cannot be written or the stream could not be read.
	 * @throws NullPointerException if <code>entryName</code> or <code>in</code> is <code>null</code>.
	 * @since 2.7.0
	 */
	default WadEntry addData(String entryName, InputStream in, int maxLength) throws IOException
	{
		return addDataAt(getEntryCount(), entryName, in, maxLength);
	}

	/**
	 * Adds data to this Wad at a particular entry offset, using <code>entryName</code> as the name of the entry. 
	 * The rest of the entries in the wad are shifted down one index. 
	 * The overhead for multiple individual additions may be expensive I/O-wise depending on the Wad implementation.
	 * 
	 * @param index the index at which to add the entry.
	 * @param entryName the name of the entry to add this as.
	 * @param data the bytes of data to add as this wad's data.
	 * @return a WadEntry that describes the added data.
	 * @throws IllegalArgumentException if the provided name is not a valid name.
	 * @throws IndexOutOfBoundsException if the provided index &lt; 0 or &gt; <code>getEntryCount()</code>.
	 * @throws IOException if the data cannot be written.
	 * @throws NullPointerException if <code>entryName</code> or <code>data</code> is <code>null</code>.
	 */
	default WadEntry addDataAt(int index, String entryName, byte[] data) throws IOException
	{
		return addDataAt(index, entryName, new ByteArrayInputStream(data));
	}

	/**
	 * Adds data to this Wad at a particular entry offset, using <code>entryName</code> as the name of the entry. 
	 * The rest of the entries in the wad are shifted down one index. 
	 * The overhead for multiple individual additions may be expensive I/O-wise depending on the Wad implementation.
	 * 
	 * @param index the index at which to add the entry.
	 * @param entryName the name of the entry to add this as.
	 * @param data the BinaryObject to add as this wad's data (converted via {@link BinaryObject#toBytes()}).
	 * @param <BO> a BinaryObject type.
	 * @return a WadEntry that describes the added data.
	 * @throws IllegalArgumentException if the provided name is not a valid name.
	 * @throws IndexOutOfBoundsException if the provided index &lt; 0 or &gt; <code>getEntryCount()</code>.
	 * @throws IOException if the data cannot be written.
	 * @throws NullPointerException if <code>entryName</code> or <code>data</code> is <code>null</code>.
	 * @since 2.2.0
	 */
	default <BO extends BinaryObject> WadEntry addDataAt(int index, String entryName, BO data) throws IOException
	{
		return addDataAt(index, entryName, data.toBytes());
	}

	/**
	 * Adds data to this Wad at a particular entry offset, using <code>entryName</code> as the name of the entry. 
	 * The rest of the entries in the wad are shifted down one index. 
	 * The BinaryObjects provided have all of their converted data concatenated together as one blob of contiguous data.
	 * The overhead for multiple individual additions may be expensive I/O-wise depending on the Wad implementation.
	 * 
	 * @param index the index at which to add the entry.
	 * @param entryName the name of the entry to add this as.
	 * @param data the BinaryObjects to add as this wad's data (converted via {@link BinaryObject#toBytes()}).
	 * @param <BO> a BinaryObject type.
	 * @return a WadEntry that describes the added data.
	 * @throws IllegalArgumentException if the provided name is not a valid name.
	 * @throws IndexOutOfBoundsException if the provided index &lt; 0 or &gt; <code>getEntryCount()</code>.
	 * @throws IOException if the data cannot be written.
	 * @throws NullPointerException if <code>entryName</code> or <code>data</code> is <code>null</code>.
	 * @since 2.2.0
	 */
	default <BO extends BinaryObject> WadEntry addDataAt(int index, String entryName, BO[] data) throws IOException
	{
		return addDataAt(index, entryName, BinaryObject.toBytes(data));
	}

	/**
	 * Adds data to this Wad at a particular entry offset, using <code>entryName</code> as the name of the entry. 
	 * The rest of the entries in the wad are shifted down one index. 
	 * The overhead for multiple individual additions may be expensive I/O-wise depending on the Wad implementation.
	 * 
	 * @param index the index at which to add the entry.
	 * @param entryName the name of the entry to add this as.
	 * @param data the TextObject to add as this wad's data (converted via {@link TextObject#toText()}, then {@link String#getBytes(Charset)}).
	 * @param encoding the encoding type for the data written to the Wad.
	 * @param <TO> a TextObject type.
	 * @return a WadEntry that describes the added data.
	 * @throws IllegalArgumentException if the provided name is not a valid name.
	 * @throws IndexOutOfBoundsException if the provided index &lt; 0 or &gt; <code>getEntryCount()</code>.
	 * @throws IOException if the data cannot be written.
	 * @throws NullPointerException if <code>entryName</code> or <code>data</code> is <code>null</code>.
	 * @since 2.2.0
	 */
	default <TO extends TextObject> WadEntry addDataAt(int index, String entryName, TO data, Charset encoding) throws IOException
	{
		return addDataAt(index, entryName, data.toText().getBytes(encoding));
	}

	/**
	 * Adds data to this Wad, using <code>entryName</code> as the name of the new entry.
	 * The provided File is read until the end of the file is reached.
	 * The overhead for multiple individual additions may be expensive I/O-wise depending on the Wad implementation.
	 * 
	 * @param index the index at which to add the entry.
	 * @param entryName the name of the entry to add this as.
	 * @param fileToAdd the file to add the contents of.
	 * @return a WadEntry that describes the added data.
	 * @throws IllegalArgumentException if the provided name is not a valid name.
	 * @throws FileNotFoundException if the file path refers to a file that is a directory or doesn't exist.
	 * @throws IOException if the data cannot be written or the stream could not be read.
	 * @throws NullPointerException if <code>entryName</code> or <code>fileToAdd</code> is <code>null</code>.
	 * @since 2.7.0
	 */
	default WadEntry addDataAt(int index, String entryName, File fileToAdd) throws IOException
	{
		try (InputStream in = new BufferedInputStream(new FileInputStream(fileToAdd), 8192))
		{
			return addDataAt(index, entryName, in, (int)fileToAdd.length());
		}
	}

	/**
	 * Adds data to this Wad at a particular entry offset, using <code>entryName</code> as the name of the entry. 
	 * The provided input stream is read until the end of the stream is reached.
	 * The input stream is NOT CLOSED, afterward.
	 * The rest of the entries in the wad are shifted down one index. 
	 * The overhead for multiple individual additions may be expensive I/O-wise depending on the Wad implementation.
	 * 
	 * @param index the index at which to add the entry.
	 * @param entryName the name of the entry to add this as.
	 * @param in the input stream to read.
	 * @return a WadEntry that describes the added data.
	 * @throws IllegalArgumentException if the provided name is not a valid name.
	 * @throws IndexOutOfBoundsException if the provided index &lt; 0 or &gt; <code>getEntryCount()</code>.
	 * @throws IOException if the data cannot be written or the stream could not be read.
	 * @throws NullPointerException if <code>entryName</code> or <code>in</code> is <code>null</code>.
	 * @since 2.7.0
	 */
	default WadEntry addDataAt(int index, String entryName, InputStream in) throws IOException
	{
		return addDataAt(index, entryName, in, -1);
	}

	/**
	 * Adds data to this Wad at a particular entry offset, using <code>entryName</code> as the name of the entry. 
	 * The provided input stream is read until the end of the stream is reached or <code>maxLength</code> bytes are read. 
	 * The input stream is NOT CLOSED, afterward.
	 * The rest of the entries in the wad are shifted down one index. 
	 * The overhead for multiple individual additions may be expensive I/O-wise depending on the Wad implementation.
	 * 
	 * @param index the index at which to add the entry.
	 * @param entryName the name of the entry to add this as.
	 * @param in the input stream to read.
	 * @param maxLength the maximum amount of bytes to read from the InputStream, or a value &lt; 0 to keep reading until end-of-stream.
	 * @return a WadEntry that describes the added data.
	 * @throws IllegalArgumentException if the provided name is not a valid name.
	 * @throws IndexOutOfBoundsException if the provided index &lt; 0 or &gt; <code>getEntryCount()</code>.
	 * @throws IOException if the data cannot be written or the stream could not be read.
	 * @throws NullPointerException if <code>entryName</code> or <code>in</code> is <code>null</code>.
	 * @since 2.7.0
	 */
	WadEntry addDataAt(int index, String entryName, InputStream in, int maxLength) throws IOException;

	/**
	 * Takes entries and their data from another Wad and adds it to this one.
	 * @param source the the source Wad.
	 * @param startIndex the starting entry index.
	 * @param maxLength the maximum amount of entries from the starting index to copy.
	 * @throws IOException if an error occurs on read from the source Wad or write to this Wad.
	 * @since 2.5.0
	 */
	default void addFrom(Wad source, int startIndex, int maxLength) throws IOException
	{
		addFromAt(getEntryCount(), source, source.mapEntries(startIndex, maxLength));
	}
	
	/**
	 * Takes entries and their data from another Wad and adds it to this one.
	 * @param source the the source Wad.
	 * @param entries the entries to copy over.
	 * @throws IOException if an error occurs on read from the source Wad or write to this Wad.
	 * @since 2.5.0
	 */
	default void addFrom(Wad source, WadEntry ... entries) throws IOException
	{
		addFromAt(getEntryCount(), source, entries);
	}
	
	/**
	 * Takes entries and their data from another Wad and adds it to this one at a specific index.
	 * @param destIndex the index at which to add the entries.
	 * @param source the the source Wad.
	 * @param startIndex the starting entry index.
	 * @param maxLength the maximum amount of entries from the starting index to copy.
	 * @throws IndexOutOfBoundsException if the provided index &lt; 0 or &gt; <code>getEntryCount()</code>.
	 * @throws IOException if an error occurs on read from the source Wad or write to this Wad.
	 * @since 2.5.0
	 */
	default void addFromAt(int destIndex, Wad source, int startIndex, int maxLength) throws IOException
	{
		addFromAt(destIndex, source, source.mapEntries(startIndex, maxLength));
	}
	
	/**
	 * Takes entries and their data from another Wad and adds it to this one at a specific index.
	 * @param destIndex the index at which to add the entries.
	 * @param source the the source Wad.
	 * @param entries the entries to copy over.
	 * @throws IndexOutOfBoundsException if the provided index &lt; 0 or &gt; <code>getEntryCount()</code>.
	 * @throws IOException if an error occurs on read from the source Wad or write to this Wad.
	 * @since 2.5.0
	 */
	default void addFromAt(int destIndex, Wad source, WadEntry ... entries) throws IOException
	{
		for (int i = 0; i < entries.length; i++)
			addDataAt(destIndex + i, entries[i].getName(), source.getData(entries[i]));
	}
	
	/**
	 * Replaces the entry at an index in the Wad.
	 * If the incoming data is the same size as the entry at the index, 
	 * this will change the data in-place without deleting and adding.
	 * 
	 * @param index the index of the entry to replace.
	 * @param data the data to replace the entry with.
	 * @throws IndexOutOfBoundsException if index &lt; 0 or &gt;= size.
	 * @throws IOException if the entry cannot be replaced.
	 * @throws NullPointerException if <code>data</code> is <code>null</code>.
	 */
	void replaceEntry(int index, byte[] data) throws IOException;

	/**
	 * Replaces the entry at an index in the Wad.
	 * If the incoming data is the same size as the entry at the index, 
	 * this will change the data in-place without deleting and adding.
	 * 
	 * @param index the index of the entry to replace.
	 * @param data the data to replace the entry with.
	 * @param <BO> the BinaryObject type.
	 * @throws IndexOutOfBoundsException if index &lt; 0 or &gt;= size.
	 * @throws IOException if the entry cannot be replaced.
	 * @throws NullPointerException if <code>data</code> is <code>null</code>.
	 * @since 2.4.0
	 */
	default <BO extends BinaryObject> void replaceEntry(int index, BO data) throws IOException
	{
		replaceEntry(index, data.toBytes());
	}

	/**
	 * Replaces the entry at an index in the Wad.
	 * If the incoming data is the same size as the entry at the index, 
	 * this will change the data in-place without deleting and adding.
	 * 
	 * @param index the index of the entry to replace.
	 * @param data the BinaryObjects to replace as this wad's data (converted via {@link BinaryObject#toBytes()}).
	 * @param <BO> the BinaryObject type.
	 * @throws IndexOutOfBoundsException if index &lt; 0 or &gt;= size.
	 * @throws IOException if the entry cannot be replaced.
	 * @throws NullPointerException if <code>data</code> is <code>null</code>.
	 * @since 2.4.0
	 */
	default <BO extends BinaryObject> void replaceEntry(int index, BO[] data) throws IOException
	{
		replaceEntry(index, BinaryObject.toBytes(data));
	}

	/**
	 * Replaces the entry at an index in the Wad.
	 * If the incoming data is the same size as the entry at the index, 
	 * this will change the data in-place without deleting and adding.
	 * 
	 * @param index the index of the entry to replace.
	 * @param data the TextObject to add as this Wad's data (converted via {@link TextObject#toText()}, then {@link String#getBytes(Charset)}).
	 * @param encoding the encoding type for the data written to the Wad.
	 * @param <TO> a TextObject type.
	 * @throws IndexOutOfBoundsException if index &lt; 0 or &gt;= size.
	 * @throws IOException if the entry cannot be replaced.
	 * @throws NullPointerException if <code>data</code> is <code>null</code>.
	 * @since 2.4.0
	 */
	default <TO extends TextObject> void replaceEntry(int index, TO data, Charset encoding) throws IOException
	{
		replaceEntry(index, data.toText().getBytes(encoding));
	}

	/**
	 * Renames the entry at an index in the Wad.
	 * 
	 * @param index the index of the entry to rename.
	 * @param newName the new name of the entry.
	 * @throws IndexOutOfBoundsException if index &lt; 0 or &gt;= size.
	 * @throws IOException if the entry cannot be renamed.
	 */
	void renameEntry(int index, String newName) throws IOException;

	/**
	 * Remove a Wad's entry (but not contents).
	 * This will leave abandoned, un-addressed data in a Wad file and will not be removed until the data
	 * is purged. 
	 * 
	 * @param index the index of the entry to delete.
	 * @return the entry removed from the Wad.
	 * @throws IndexOutOfBoundsException if index &lt; 0 or &gt;= size.
	 * @throws IOException if the entry cannot be removed.
	 */
	WadEntry removeEntry(int index) throws IOException;

	/**
	 * Deletes a Wad's entry and its contents. The overhead for multiple deletions may be expensive I/O-wise.
	 * 
	 * @param index the index of the entry to delete.
	 * @return the entry deleted.
	 * @throws IndexOutOfBoundsException if index &lt; 0 or &gt;= size.
	 * @throws IOException if the entry cannot be deleted.
	 */
	WadEntry deleteEntry(int index) throws IOException;

	/**
	 * Replaces an entry in the Wad - no content, just descriptor.
	 * Exercise caution with this method, as this entry is added as-is, and an entry can reference anywhere in the Wad!
	 * <p>This is equivalent to: <code>unmapEntries(index, entry)</code>.
	 * @param index the index of the entry to change.
	 * @param entry the entry to set.
	 * @throws IndexOutOfBoundsException if index &lt; 0 or &gt;= size.
	 * @throws IOException if the file cannot be altered in such a manner.
	 * @see #unmapEntries(int, WadEntry...)
	 * @since 2.9.0
	 */
	default void setEntry(int index, WadEntry entry) throws IOException
	{
		unmapEntries(index, entry);
	}
	
	/**
	 * Retrieves a contiguous set of entries from this Wad, starting from a desired index. If the amount of entries
	 * desired goes outside the Wad's potential set of entries, this will retrieve up to those entries (for example,
	 * <code>mapEntries(5, 10)</code> in an 8-entry Wad will only return 3 entries: 5, 6, and 7).
	 * 
	 * @param startIndex the starting index to map from (inclusive).
	 * @param maxLength the amount of entries to retrieve from the index position.
	 * @return an array of references to {@link WadEntry} objects.
	 * @throws IllegalArgumentException if startIndex is less than 0.
	 */
	default WadEntry[] mapEntries(int startIndex, int maxLength)
	{
		if (startIndex < 0)
			throw new IllegalArgumentException("Starting index cannot be less than 0.");
	
		int len = Math.min(maxLength, getEntryCount() - startIndex);
		if (len <= 0)
			return NO_ENTRIES;
		WadEntry[] out = new WadEntry[len];
		for (int i = 0; i < len; i++)
			out[i] = getEntry(startIndex + i);
		return out;
	}

	/**
	 * Replaces a series of WadEntry objects in this Wad, using the provided list of entries as the replacement list. If
	 * the list of entries plus the starting index would breach the original list of entries, the excess is appended to
	 * the Wad.
	 * 
	 * @param startIndex the starting index to replace from (inclusive).
	 * @param entryList the set of entries to replace (in order) from the starting index.
	 * @throws IOException if the entries could not be written.
	 * @throws IllegalArgumentException if startIndex is less than 0.
	 */
	void unmapEntries(int startIndex, WadEntry... entryList) throws IOException;

	/**
	 * Completely replaces the list of entries in this Wad with a completely different set of entries.
	 * 
	 * @param entryList the set of entries that will make up this Wad.
	 * @throws IOException if the entries could not be written.
	 * @throws IllegalArgumentException if startIndex is less than 0.
	 */
	void setEntries(WadEntry... entryList) throws IOException;

	/**
	 * Closes this Wad.
	 * Does nothing on some implementations. 
	 * @throws IOException if an error occurred during close.
	 */
	void close() throws IOException;
	
}
