/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom;

import java.io.BufferedInputStream;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.RandomAccessFile;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import net.mtrop.doom.exception.WadException;
import net.mtrop.doom.object.BinaryObject;
import net.mtrop.doom.object.TextObject;
import net.mtrop.doom.struct.io.SerialWriter;
import net.mtrop.doom.struct.io.SerializerUtils;
import net.mtrop.doom.util.NameUtils;
import net.mtrop.doom.util.TextUtils;

/**
 * The class that reads WadFile information and provides random access to Wad files.
 * <p>
 * Use of this class is recommended for reading WAD information or small additions of data, as the overhead needed to
 * do so is minimal in this class. 
 * <p>
 * Many writing I/O operations will cause the opened file to be changed many times, the length of time of 
 * which being dictated by the length of the entry list (as the list grows, so does the time it takes to write/change it).
 * Bulk reads/additions/writes/changes are best left for the {@link WadBuffer} class, however,
 * if only additions need to happen, using {@link Adder} via {@link #createAdder()} is a viable method for 
 * bulk addition with little overhead.
 * <p>Since this WadFile maintains current file position for reads and writes, most operations are <b>not thread-safe!</b>
 * @author Matthew Tropiano
 */
public class WadFile implements Wad, AutoCloseable
{
	/** The relay buffer used by relay(). */
	private static final ThreadLocal<byte[]> RELAY_BUFFER = ThreadLocal.withInitial(()->new byte[4096]);

	/** File handle. */
	private RandomAccessFile file;
	
	/** WAD File's name (equivalent to File.getName()). */
	private String fileName;
	/** WAD File's path (equivalent to File.getPath()). */
	private String filePath;
	/** WAD File's absolute path (equivalent to File.getAbsolutePath()). */
	private String fileAbsolutePath;
	
	/** List of this Wad's entries. */
	private List<WadEntry> entries;

	/** Type of Wad File (IWAD or PWAD). */
	private Type type;

	/** Offset of the beginning of the entry list. */
	private int entryListOffset;
	
	/** If true, writing is possible to this WadFile. */
	private boolean writeEnabled;
	/** Flush on close switch. */
	private boolean flushOnClose;
	
	/**
	 * Opens a WadFile from a file specified by "path."
	 * The file will be opened in a mode appropriate for file permission capabilities. 
	 * @param path the path to the File.
	 * @throws IOException if the file can't be read or an incompatible mode was used for access.
	 * @throws FileNotFoundException if the file can't be found.
	 * @throws SecurityException if you don't have permission to access the file.
	 * @throws WadException if the file isn't a Wad file.
	 * @throws NullPointerException if <code>path</code> is null.
	 */
	public WadFile(String path) throws IOException
	{
		this(new File(path), null);
	}

	/**
	 * Opens a WadFile from a file specified by "path."
	 * @param path the path to the File.
	 * @param readOnly if <code>true</code>, the file will be opened in read-only mode. 
	 * 		If <code>false</code>, this will attempt to open the file in a mode that allows writing.
	 * 		If <code>null</code>, this will attempt to detect whether or not the file can be written
	 * 		to. If so, open in a writable mode. If not, open in read-only mode.
	 * @throws IOException if the file can't be read or an incompatible mode was used for access.
	 * @throws FileNotFoundException if the file can't be found.
	 * @throws SecurityException if you don't have permission to access the file.
	 * @throws WadException if the file isn't a Wad file.
	 * @throws NullPointerException if <code>path</code> is null.
	 * @see File#canWrite()
	 * @since 2.14.0
	 */
	public WadFile(String path, Boolean readOnly) throws IOException
	{
		this(new File(path), readOnly);
	}

	/**
	 * Opens a WadFile from a file.
	 * The file will be opened in a mode appropriate for file permission capabilities. 
	 * @param f	the file.
	 * @throws IOException if the file can't be read or an incompatible mode was used for access.
	 * @throws FileNotFoundException if the file can't be found.
	 * @throws SecurityException if you don't have permission to access the file.
	 * @throws WadException if the file isn't a Wad file.
	 * @throws NullPointerException if <code>f</code> is null.
	 */
	public WadFile(File f) throws IOException
	{
		this(f, null);
	}
	
	/**
	 * Opens a WadFile from a file.
	 * @param f	the file.
	 * @param readOnly if <code>true</code>, the file will be opened in read-only mode. 
	 * 		If <code>false</code>, this will attempt to open the file in a mode that allows writing.
	 * 		If <code>null</code>, this will attempt to detect whether or not the file can be written
	 * 		to. If so, open in a writable mode. If not, open in read-only mode.
	 * @throws IOException if the file can't be read or an incompatible mode was used for access.
	 * @throws FileNotFoundException if the file can't be found.
	 * @throws SecurityException if you don't have permission to access the file.
	 * @throws WadException if the file isn't a Wad file.
	 * @throws NullPointerException if <code>f</code> is null.
	 * @since 2.14.0
	 */
	public WadFile(File f, Boolean readOnly) throws IOException
	{
		if (!f.exists())
			throw new FileNotFoundException(f.getPath() + " does not exist!");
		
		this.writeEnabled = readOnly == null ? f.canWrite() : !readOnly;
		
		this.file = new RandomAccessFile(f, writeEnabled ? "rws" : "r");
		byte[] buffer = new byte[4];

		// read header
		file.seek(0);
		file.read(buffer);
		String head = new String(buffer, "ASCII");
		if (!head.equals(Type.IWAD.toString()) && !head.equals(Type.PWAD.toString()))
			throw new WadException("Not a Wad file or supported Wad file type.");

		if (head.equals(Type.IWAD.toString()))
			type = Type.IWAD;
			
		if (head.equals(Type.PWAD.toString()))
			type = Type.PWAD;
		
		this.fileName = f.getName();
		this.filePath = f.getPath();
		this.fileAbsolutePath = f.getAbsolutePath();
		
		file.read(buffer);
		int size = SerializerUtils.bytesToInt(buffer, 0, SerializerUtils.LITTLE_ENDIAN);

		file.read(buffer);
		entryListOffset = SerializerUtils.bytesToInt(buffer, 0, SerializerUtils.LITTLE_ENDIAN);
		
		this.entries = new ArrayList<WadEntry>((size + 1) * 2);
		
		// seek to entry list.
		file.seek(entryListOffset);
		
		// read entries.
		byte[] entrybytes = new byte[16];
		for (int i = 0; i < size; i++)
		{
			file.read(entrybytes);
			WadEntry entry = WadEntry.create(entrybytes);
			if (entry.getName().length() > 0 || entry.getSize() > 0)
				entries.add(entry);
		}
	}

	/**
	 * Creates a new, empty WadFile and returns a reference to it.
	 * @param path	the path of the new file in the form of a String.
	 * @return		a reference to the newly created WadFile, already open.
	 * @throws IOException if the file can't be written.
	 * @throws NullPointerException if <code>path</code> is null.
	 */
	public static WadFile createWadFile(String path) throws IOException
	{
		return createWadFile(new File(path));
	}

	/**
	 * Creates a new, empty WadFile (PWAD Type) and returns a reference to it.
	 * @param f		the file object referring to the new Wad.
	 * @return		a reference to the newly created WadFile, already open.
	 * @throws IOException if the file can't be written.
	 * @throws NullPointerException if <code>f</code> is null.
	 */
	public static WadFile createWadFile(File f) throws IOException
	{
		FileOutputStream fo = new FileOutputStream(f);
		SerialWriter sw = new SerialWriter(SerialWriter.LITTLE_ENDIAN);
		sw.writeBytes(fo, Type.PWAD.name().getBytes("ASCII"));
		sw.writeInt(fo, 0);		// number of entries.
		sw.writeInt(fo, 12);	// offset to entry list.
		fo.close();
		try{
			return new WadFile(f);
		} catch (WadException e) {
			throw new RuntimeException("INTERNAL ERROR.");
		}
	}

	/**
	 * Creates a new WadFile from a subset of entries (and their data) from another Wad.
	 * <p>Entry extraction is sequential - if you have memory to spare, you may be better off
	 * using {@link WadBuffer#extract(Wad, int, int)} since it will have far less overhead.
	 * <p><b>NOTE: This will overwrite the destination file, if it exists!</b>
	 * @param targetFile the file to create.
	 * @param source the the source Wad.
	 * @param startIndex the starting entry index.
	 * @param maxLength the maximum amount of entries from the starting index to copy.
	 * @return a new WadBuffer that only contains the desired entries, plus their data.
	 * @throws IOException if an error occurs on read from the source Wad.
	 * @since 2.1.0
	 */
	public static WadFile extract(File targetFile, Wad source, int startIndex, int maxLength) throws IOException
	{
		return extract(targetFile, source, source.mapEntries(startIndex, maxLength));
	}

	/**
	 * Creates a new WadFile from a subset of entries (and their data) from another Wad.
	 * <p>Entry extraction is sequential - if you have memory to spare, you may be better off
	 * using {@link WadBuffer#extract(Wad, WadEntry...)} since it will have far less overhead. 
	 * <p><b>NOTE: This will overwrite the destination file, if it exists!</b>
	 * @param targetFile the file to create.
	 * @param source the the source Wad.
	 * @param entries the entries to copy over.
	 * @return a new WadBuffer that only contains the desired entries, plus their data.
	 * @throws IOException if an error occurs on read from the source Wad.
	 * @since 2.1.0
	 */
	public static WadFile extract(File targetFile, Wad source, WadEntry ... entries) throws IOException
	{
		WadFile out = WadFile.createWadFile(targetFile);
		out.addFrom(source, entries);
		return out;
	}

	private void writeHeader() throws IOException
	{
		file.seek(0);
		file.write(type.name().getBytes(TextUtils.ASCII));
		byte[] b = new byte[4];
		SerializerUtils.intToBytes(entries.size(), SerializerUtils.LITTLE_ENDIAN, b, 0);
		file.write(b);
		SerializerUtils.intToBytes(entryListOffset, SerializerUtils.LITTLE_ENDIAN, b, 0);
		file.write(b);
	}

	private void writeEntryList() throws IOException
	{
		file.seek(entryListOffset);
		for (WadEntry wfe : entries)
			file.write(wfe.toBytes());
		if (file.getFilePointer() < file.length())
			file.setLength(file.getFilePointer());
	}

	/**
	 * Writes the header and the entry list out to the Wad file.
	 * @throws IOException if the header/entry list cannot be written.
	 */
	public final void flushEntries() throws IOException
	{
		writeHeader();
		writeEntryList();
		flushOnClose = false;
	}

	/**
	 * Sets the type of WAD that this is.
	 * @param type the WAD type.
	 * @throws IOException if the header could not be written.
	 */
	public final void setType(Type type) throws IOException
	{
		this.type = type;
		writeHeader();
	}

	/**
	 * Gets the type of WAD that this is.
	 * @return the WAD type.
	 */
	public final Type getType()
	{
		return type;
	}

	/**
	 * Returns this Wad's file name. 
	 * @return this file's name (and just the name).
	 * @see File#getName()
	 */
	public final String getFileName()
	{
		return fileName;
	}
	
	/**
	 * Gets this Wad's file path. 
	 * @return this file's path.
	 * @see File#getPath()
	 */
	public final String getFilePath()
	{
		return filePath;
	}

	/**
	 * Returns this Wad's file absolute path. 
	 * @return this file's name (and just the name).
	 * @see File#getAbsolutePath()
	 */
	public final String getFileAbsolutePath()
	{
		return fileAbsolutePath;
	}

	/**
	 * @return the starting byte offset of the entry list (where the content ends). 
	 */
	public final int getEntryListOffset()
	{
		return entryListOffset;
	}
	
	@Override
	public int getContentLength()
	{
		return entryListOffset - 12;
	}
	
	@Override
	public boolean isIWAD()
	{
		return type == Type.IWAD;
	}
	
	@Override
	public boolean isPWAD()
	{
		return type == Type.PWAD;
	}
	
	@Override
	public int getEntryCount()
	{
		return entries.size();
	}

	@Override	
	public WadEntry getEntry(int n)
	{
		return entries.get(n);
	}

	@Override
	public void fetchContent(int offset, int length, byte[] dest, int destOffset) throws IOException
	{
		file.seek(offset);
		if (file.read(dest, destOffset, length) < length)
			throw new IndexOutOfBoundsException("length + destination offset exceeds dest length");
	}

	@Override
	public WadEntry removeEntry(int n) throws IOException
	{
		WadEntry entry = entries.remove(n);
		flushEntries();
		return entry;
	}

	@Override
	public WadEntry deleteEntry(int n) throws IOException
	{
		// get removed WadEntry.
		WadEntry entry = entries.remove(n);
		if (entry == null)
			throw new IOException("Index is out of range.");
	
		if (entry.getSize() > 0)
		{
			byte[] buffer = new byte[65536];
			int offset = entry.getOffset();
			int dataOffset = entry.getOffset() + entry.getSize();
		
			while (dataOffset < entryListOffset)
			{
				int amount = Math.min(entryListOffset - dataOffset, buffer.length);
				file.seek(dataOffset);
				int readAmount = file.read(buffer, 0, amount);
				file.seek(offset);
				file.write(buffer, 0, readAmount);
				offset += readAmount;
				dataOffset += readAmount;
			}
		
			entryListOffset = dataOffset;
		
			// adjust offsets.
			for (int i = 0; i < entries.size(); i++)
			{
				WadEntry e = entries.get(i);
				if (e.getOffset() > entry.getOffset())
					entries.set(i, e.withNewOffset(e.getOffset() - entry.getSize()));
			}
		}
	
		flushEntries();
		return entry;
	}

	@Override
	public void renameEntry(int index, String newName) throws IOException
	{
		WadEntry entry = getEntry(index);
		if (entry == null)
			throw new IOException("Index is out of range.");
		
		NameUtils.checkValidEntryName(newName);
		
		entries.set(index, entry.withNewName(newName));
	
		// update in file.
		file.seek(entryListOffset + (16 * index) + 8);
		file.write(entry.getNameBytes());
	}

	@Override
	public void replaceEntry(int index, byte[] data) throws IOException
	{
		WadEntry entry = getEntry(index);
		if (entry == null)
			throw new IOException("Index is out of range.");
		
		if (data.length != entry.getSize())
		{
			deleteEntry(index);
			String name = entry.getName();
			addDataAt(index, name, data);
		}
		else
		{
			file.seek(entry.getOffset());
			file.write(data);
		}
	}

	@Override
	public void unmapEntries(int startIndex, WadEntry... entryList) throws IOException
	{
		for (int i = 0; i < entryList.length; i++)
		{
			if (startIndex + i >= entries.size())
				entries.add(entryList[i]);
			else
				entries.set(startIndex + i, entryList[i]);
		}
		flushEntries();
	}

	@Override
	public void setEntries(WadEntry... entryList) throws IOException
	{
		entries.clear();
		for (WadEntry entry : entryList)
			entries.add(entry);
		flushEntries();
	}

	@Override
	public WadEntry addEntryAt(int index, WadEntry entry) throws IOException 
	{
		entries.add(index, entry);
		flushEntries();
		return entry;
	}

	@Override
	public WadEntry addDataAt(int index, String entryName, InputStream in, int maxLength) throws IOException
	{
		return addDataAt(index, entryName, in, maxLength, false);
	}

	@Override
	// Overridden to use bulk adder.
	public void addFromAt(int destIndex, Wad source, WadEntry ... entries) throws IOException
	{
		try (Adder adder = createAdder())
		{
			for (int i = 0; i < entries.length; i++)
				adder.addDataAt(destIndex + i, entries[i].getName(), source.getData(entries[i]));
		}
	}

	/**
	 * Adds data to this Wad at a particular entry offset, using <code>entryName</code> as the name of the entry. 
	 * The provided input stream is read until the end of the stream is reached or <code>maxLength</code> bytes are read.
	 * The rest of the entries in the wad are shifted down one index. 
	 * The overhead for multiple additions may be expensive I/O-wise depending on the Wad implementation.
	 * <p>
	 * <b>NOTE: If this is called with <code>noFlush</code> being true, you <i>must</i> call {@link #flushEntries()} or
	 * get {@link #close()} called on this somehow (either directly or auto-closed via <code>try</code>) to close the Wad correctly, or the Wad file will be in an unreadable state!</b>
	 * @param index the index at which to add the entry.
	 * @param entryName the name of the entry to add this as.
	 * @param in the input stream to read.
	 * @param maxLength the maximum amount of bytes to read from the InputStream, or a value &lt; 0 to keep reading until end-of-stream.
	 * @param noFlush if true, this will not update the header nor flush the new entries to the file.
	 * @return a WadEntry that describes the added data.
	 * @throws IllegalArgumentException if the provided name is not a valid name.
	 * @throws IndexOutOfBoundsException if the provided index &lt; 0 or &gt; <code>getEntryCount()</code>.
	 * @throws IOException if the data cannot be written or the stream could not be read.
	 * @throws NullPointerException if <code>entryName</code> or <code>data</code> is <code>null</code>.
	 */
	private WadEntry addDataAt(int index, String entryName, InputStream in, int maxLength, boolean noFlush) throws IOException
	{
		int offset = entryListOffset;
		file.seek(entryListOffset);
		
		int len = relay(in, file, maxLength);
		entryListOffset += len;
	
		WadEntry entry = WadEntry.create(entryName, offset, len);
		entries.add(index, entry);
		
		flushOnClose = noFlush;
		
		if (!noFlush)
			flushEntries();
		return entry;
	}

	/**
	 * Creates an object for bulk-adding data to this WadFile and ensuring that the
	 * entry list gets written on completion.
	 * <p>
	 * All methods on this object manipulate the WadFile it is created from, and
	 * defers the final writing of the entry list until it is closed. The object 
	 * returned is meant to be created via a try-with-resources block, like so:
	 * <pre>
	 * try (WadFile.Adder adder = wad.createAdder())
	 * {
	 *     adder.addData(....);
	 *     ...
	 * }
	 * </pre> 
	 * ...upon which the entries are committed to the file on close (but they are still available
	 * via {@link #getEntry(int)} and associated methods). 
	 * This will still commit the list even on an error occurring during add, unless the the 
	 * writing of the list results in an error as well.
	 * @return a new {@link Adder} instance.
	 */
	public Adder createAdder()
	{
		return new Adder(this);
	}
	
	@Override
	public Iterator<WadEntry> iterator()
	{
		return entries.iterator();
	}

	/**
	 * Closes this Wad, but calls {@link #flushEntries()} first to commit 
	 * any changes that happened that did not auto-flush the entries, if
	 * writing is enabled on this file.
	 * @throws IOException if an error occurred during close.
	 */
	@Override
	public void close() throws IOException
	{
		if (flushOnClose)
			flushEntries();
		file.close();
	}
	
	/**
	 * Reads from an input stream, reading in a consistent set of data
	 * and writing it to an open file. The read/write is buffered
	 * so that it does not bog down the OS's other I/O requests.
	 * This method finishes when the end of the source stream is reached.
	 * Note that this may block if the input stream is a type of stream
	 * that will block if the input stream blocks for additional input.
	 * This method is thread-safe.
	 * @param in the input stream to grab data from.
	 * @param out the file to write the data to.
	 * @param maxLength the maximum amount of bytes to relay, or a value &lt; 0 for no max.
	 * @return the total amount of bytes relayed.
	 * @throws IOException if a read or write error occurs.
	 */
	private int relay(InputStream in, RandomAccessFile out, int maxLength) throws IOException
	{
		int total = 0;
		int buf = 0;
			
		byte[] BUFFER = RELAY_BUFFER.get();
		
		while ((buf = in.read(BUFFER, 0, Math.min(maxLength < 0 ? Integer.MAX_VALUE : maxLength, BUFFER.length))) > 0)
		{
			out.write(BUFFER, 0, buf);
			total += buf;
			if (maxLength >= 0)
				maxLength -= buf;
		}
		return total;
	}

	/**
	 * Bulk add mechanism for WadFile.
	 * All methods on this object manipulate the WadFile it is created from, and
	 * defers the final writing of the entry list until it is closed. This object is meant
	 * to be created via a try-with-resources block, like so:
	 * <pre>
	 * try (WadFile.Adder adder = wad.createAdder())
	 * {
	 *     adder.addData(....);
	 *     ...
	 * }
	 * </pre> 
	 * ...upon which the entries are committed on close. This will still commit the list
	 * even on an error occurring during add, unless the the writing of the list results
	 * in an error as well.
	 * @since 2.7.0
	 */
	public class Adder implements AutoCloseable
	{
		private WadFile self;
		
		private Adder(WadFile self)
		{
			this.self = self;
		}
		
		@Override
		public void close() throws IOException
		{
			self.flushEntries();
		}

		/**
		 * Adds a new entry to the Wad, but with an explicit offset and size.
		 * Exercise caution with this method, since you can reference anywhere in the Wad!
		 * <p>
		 * <b>NOTE:</b> The entry is not written until {@link #close()} is called (or the {@link Adder} is closed automatically).
		 * @param entryName the name of the entry.
		 * @param offset the entry's content start byte.
		 * @param length the entry's length in bytes.
		 * @return the entry that was created.
		 * @throws IllegalArgumentException if the provided name is not a valid name, or the offset/size is negative.
		 * @throws IOException if the entry cannot be written.
		 * @throws NullPointerException if <code>name</code> is <code>null</code>.
		 */
		public WadEntry addEntry(String entryName, int offset, int length) throws IOException
		{
			WadEntry entry = WadEntry.create(entryName, offset, length);
			entries.add(entry);
			return entry;
		}

		/**
		 * Adds an entry marker to the Wad (entry with 0 size, arbitrary offset).
		 * 
		 * @param entryName the name of the entry.
		 * @return the entry that was added.
		 * @throws IllegalArgumentException if the provided name is not a valid name.
		 * @throws IOException if the entry cannot be written.
		 * @throws NullPointerException if <code>name</code> is <code>null</code>.
		 */
		public WadEntry addMarker(String entryName) throws IOException
		{
			return addData(entryName, NO_DATA);
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
		public WadEntry addMarkerAt(int index, String entryName) throws IOException
		{
			return addDataAt(index, entryName, NO_DATA);
		}

		/**
		 * Adds data to this Wad, using <code>entryName</code> as the name of the new entry. 
		 * The overhead for multiple additions may be expensive I/O-wise depending on the Wad implementation.
		 * 
		 * @param entryName the name of the entry to add this as.
		 * @param data the bytes of data to add as this wad's data.
		 * @return a WadEntry that describes the added data.
		 * @throws IllegalArgumentException if the provided name is not a valid name.
		 * @throws IOException if the data cannot be written.
		 * @throws NullPointerException if <code>entryName</code> or <code>data</code> is <code>null</code>.
		 */
		public WadEntry addData(String entryName, byte[] data) throws IOException
		{
			return addDataAt(getEntryCount(), entryName, data);
		}

		/**
		 * Adds data to this Wad, using <code>entryName</code> as the name of the new entry. 
		 * The overhead for multiple additions may be expensive I/O-wise depending on the Wad implementation.
		 * 
		 * @param entryName the name of the entry to add this as.
		 * @param data the BinaryObject to add as this wad's data (converted via {@link BinaryObject#toBytes()}).
		 * @param <BO> a BinaryObject type.
		 * @return a WadEntry that describes the added data.
		 * @throws IllegalArgumentException if the provided name is not a valid name.
		 * @throws IOException if the data cannot be written.
		 * @throws NullPointerException if <code>entryName</code> or <code>data</code> is <code>null</code>.
		 */
		public <BO extends BinaryObject> WadEntry addData(String entryName, BO data) throws IOException
		{
			return addDataAt(getEntryCount(), entryName, data);
		}

		/**
		 * Adds data to this Wad, using <code>entryName</code> as the name of the new entry.
		 * The BinaryObjects provided have all of their converted data concatenated together as one blob of contiguous data.
		 * The overhead for multiple additions may be expensive I/O-wise depending on the Wad implementation.
		 * 
		 * @param entryName the name of the entry to add this as.
		 * @param data the BinaryObjects to add as this wad's data (converted via {@link BinaryObject#toBytes()}).
		 * @param <BO> a BinaryObject type.
		 * @return a WadEntry that describes the added data.
		 * @throws IllegalArgumentException if the provided name is not a valid name.
		 * @throws IOException if the data cannot be written.
		 * @throws NullPointerException if <code>entryName</code> or <code>data</code> is <code>null</code>.
		 */
		public <BO extends BinaryObject> WadEntry addData(String entryName, BO[] data) throws IOException
		{
			return addDataAt(getEntryCount(), entryName, data);
		}

		/**
		 * Adds data to this Wad, using <code>entryName</code> as the name of the new entry. 
		 * The overhead for multiple additions may be expensive I/O-wise depending on the Wad implementation.
		 * 
		 * @param entryName the name of the entry to add this as.
		 * @param data the TextObject to add as this wad's data (converted via {@link TextObject#toText()}, then {@link String#getBytes(Charset)}).
		 * @param encoding the encoding type for the data written to the Wad.
		 * @param <TO> a TextObject type.
		 * @return a WadEntry that describes the added data.
		 * @throws IllegalArgumentException if the provided name is not a valid name.
		 * @throws IOException if the data cannot be written.
		 * @throws NullPointerException if <code>entryName</code> or <code>data</code> or <code>encoding</code> is <code>null</code>.
		 */
		public <TO extends TextObject> WadEntry addData(String entryName, TO data, Charset encoding) throws IOException
		{
			return addDataAt(getEntryCount(), entryName, data, encoding);
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
		 * @throws NullPointerException if <code>entryName</code> or <code>data</code> or <code>encoding</code> is <code>null</code>.
		 * @since 2.7.0
		 */
		public WadEntry addData(String entryName, File fileToAdd) throws IOException
		{
			return addDataAt(getEntryCount(), entryName, fileToAdd);
		}

		/**
		 * Adds data to this Wad, using <code>entryName</code> as the name of the new entry.
		 * The provided input stream is read until the end of the stream is reached.
		 * The overhead for multiple additions may be expensive I/O-wise depending on the Wad implementation.
		 * 
		 * @param entryName the name of the entry to add this as.
		 * @param in the input stream to read.
		 * @return a WadEntry that describes the added data.
		 * @throws IllegalArgumentException if the provided name is not a valid name.
		 * @throws IOException if the data cannot be written or the stream could not be read.
		 * @throws NullPointerException if <code>entryName</code> or <code>data</code> or <code>encoding</code> is <code>null</code>.
		 */
		public WadEntry addData(String entryName, InputStream in) throws IOException
		{
			return addDataAt(getEntryCount(), entryName, in);
		}

		/**
		 * Adds data to this Wad, using <code>entryName</code> as the name of the new entry.
		 * The provided input stream is read until the end of the stream is reached or <code>maxLength</code> bytes are read.
		 * The overhead for multiple additions may be expensive I/O-wise depending on the Wad implementation.
		 * 
		 * @param entryName the name of the entry to add this as.
		 * @param in the input stream to read.
		 * @param maxLength the maximum amount of bytes to read from the InputStream, or a value &lt; 0 to keep reading until end-of-stream.
		 * @return a WadEntry that describes the added data.
		 * @throws IllegalArgumentException if the provided name is not a valid name.
		 * @throws IOException if the data cannot be written or the stream could not be read.
		 * @throws NullPointerException if <code>entryName</code> or <code>data</code> or <code>encoding</code> is <code>null</code>.
		 */
		public WadEntry addData(String entryName, InputStream in, int maxLength) throws IOException
		{
			return addDataAt(getEntryCount(), entryName, in, maxLength);
		}

		/**
		 * Adds data to this Wad at a particular entry offset, using <code>entryName</code> as the name of the entry. 
		 * The rest of the entries in the wad are shifted down one index. 
		 * The overhead for multiple additions may be expensive I/O-wise depending on the Wad implementation.
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
		public WadEntry addDataAt(int index, String entryName, byte[] data) throws IOException
		{
			return addDataAt(index, entryName, new ByteArrayInputStream(data));
		}

		/**
		 * Adds data to this Wad at a particular entry offset, using <code>entryName</code> as the name of the entry. 
		 * The rest of the entries in the wad are shifted down one index. 
		 * The overhead for multiple additions may be expensive I/O-wise depending on the Wad implementation.
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
		 */
		public <BO extends BinaryObject> WadEntry addDataAt(int index, String entryName, BO data) throws IOException
		{
			return addDataAt(index, entryName, data.toBytes());
		}

		/**
		 * Adds data to this Wad at a particular entry offset, using <code>entryName</code> as the name of the entry. 
		 * The rest of the entries in the wad are shifted down one index. 
		 * The BinaryObjects provided have all of their converted data concatenated together as one blob of contiguous data.
		 * The overhead for multiple additions may be expensive I/O-wise depending on the Wad implementation.
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
		 */
		public <BO extends BinaryObject> WadEntry addDataAt(int index, String entryName, BO[] data) throws IOException
		{
			return addDataAt(index, entryName, BinaryObject.toBytes(data));
		}

		/**
		 * Adds data to this Wad at a particular entry offset, using <code>entryName</code> as the name of the entry. 
		 * The rest of the entries in the wad are shifted down one index. 
		 * The overhead for multiple additions may be expensive I/O-wise depending on the Wad implementation.
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
		 */
		public <TO extends TextObject> WadEntry addDataAt(int index, String entryName, TO data, Charset encoding) throws IOException
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
		 * @throws NullPointerException if <code>entryName</code> or <code>data</code> or <code>encoding</code> is <code>null</code>.
		 * @since 2.7.0
		 */
		public WadEntry addDataAt(int index, String entryName, File fileToAdd) throws IOException
		{
			try (InputStream in = new BufferedInputStream(new FileInputStream(fileToAdd), 8192))
			{
				return addDataAt(index, entryName, in, (int)fileToAdd.length());
			}
		}

		/**
		 * Adds data to this Wad at a particular entry offset, using <code>entryName</code> as the name of the entry. 
		 * The provided input stream is read until the end of the stream is reached.
		 * The rest of the entries in the wad are shifted down one index. 
		 * The overhead for multiple additions may be expensive I/O-wise depending on the Wad implementation.
		 * 
		 * @param index the index at which to add the entry.
		 * @param entryName the name of the entry to add this as.
		 * @param in the input stream to read.
		 * @return a WadEntry that describes the added data.
		 * @throws IllegalArgumentException if the provided name is not a valid name.
		 * @throws IndexOutOfBoundsException if the provided index &lt; 0 or &gt; <code>getEntryCount()</code>.
		 * @throws IOException if the data cannot be written or the stream could not be read.
		 * @throws NullPointerException if <code>entryName</code> or <code>data</code> is <code>null</code>.
		 */
		public WadEntry addDataAt(int index, String entryName, InputStream in) throws IOException
		{
			return addDataAt(index, entryName, in, -1);
		}

		/**
		 * Adds data to this Wad at a particular entry offset, using <code>entryName</code> as the name of the entry. 
		 * The provided input stream is read until the end of the stream is reached or <code>maxLength</code> bytes are read.
		 * The rest of the entries in the wad are shifted down one index. 
		 * The overhead for multiple additions may be expensive I/O-wise depending on the Wad implementation.
		 * 
		 * @param index the index at which to add the entry.
		 * @param entryName the name of the entry to add this as.
		 * @param in the input stream to read.
		 * @param maxLength the maximum amount of bytes to read from the InputStream, or a value &lt; 0 to keep reading until end-of-stream.
		 * @return a WadEntry that describes the added data.
		 * @throws IllegalArgumentException if the provided name is not a valid name.
		 * @throws IndexOutOfBoundsException if the provided index &lt; 0 or &gt; <code>getEntryCount()</code>.
		 * @throws IOException if the data cannot be written or the stream could not be read.
		 * @throws NullPointerException if <code>entryName</code> or <code>data</code> is <code>null</code>.
		 */
		public WadEntry addDataAt(int index, String entryName, InputStream in, int maxLength) throws IOException
		{
			return self.addDataAt(index, entryName, in, -1, true);
		}
		
	}

}
