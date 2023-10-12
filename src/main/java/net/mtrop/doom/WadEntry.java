/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import net.mtrop.doom.struct.io.SerialReader;
import net.mtrop.doom.struct.io.SerialWriter;
import net.mtrop.doom.util.NameUtils;

/**
 * Abstraction of a single entry from a WAD.
 * This entry contains NO DATA - this is a descriptor for the data in the originating WAD.
 * @author Matthew Tropiano
 */
public class WadEntry
{
	/** Byte length of this object. */
	public static final int LENGTH = 16;

	/** The name of the entry. */
	private String name;
	/** The offset into the original WAD for the start of the data. */
	private int offset;
	/** The size of the entry content in bytes. */
	private int size;
	
	private WadEntry()
	{
		this(null, 0, 0);
	}
	
	private WadEntry(String name, int offset, int size)
	{
		this.name = name;
		this.offset = offset;
		this.size = size;
	}

	/**
	 * Creates an empty WadEntry with an offset of 12 (beginning of content) and size zero.
	 * These empty entries are called "marker" entries.
	 * @param name the name of the entry.
	 * @return the constructed WadEntry.
	 * @throws IllegalArgumentException if the name is invalid or the offset or size is negative.
	 * @since 2.9.0
	 */
	public static WadEntry create(String name)
	{
		return create(name, 12, 0); 
	}
	
	/**
	 * Creates a WadEntry.
	 * @param name the name of the entry.
	 * @param offset the offset into the WAD in bytes.
	 * @param size the size of the entry in bytes.
	 * @return the constructed WadEntry.
	 * @throws IllegalArgumentException if the name is invalid or the offset or size is negative.
	 */
	public static WadEntry create(String name, int offset, int size)
	{
		NameUtils.checkValidEntryName(name);
		if (offset < 0)
			throw new IllegalArgumentException("Entry offset is negative.");
		if (size < 0)
			throw new IllegalArgumentException("Entry size is negative.");
		
		return new WadEntry(name, offset, size); 
	}
	
	/**
	 * Creates a WadEntry.
	 * @param b the entry as serialized bytes.
	 * @return the constructed WadEntry.
	 * @throws IOException if an entry cannot be read.
	 * @throws IllegalArgumentException if the name is invalid or the offset or size is negative.
	 */
	public static WadEntry create(byte[] b) throws IOException
	{
		WadEntry out = new WadEntry();
		out.fromBytes(b);
		return out; 
	}

	/**
	 * Makes a copy of this entry with a new name.
	 * @param name the new name.
	 * @return the new entry.
	 * @throws IllegalArgumentException if the name is invalid.
	 * @since 2.1.0
	 */
	public WadEntry withNewName(String name)
	{
		NameUtils.checkValidEntryName(name);
		return new WadEntry(name, offset, size); 
	}
	
	/**
	 * Makes a copy of this entry with a new offset.
	 * @param offset the new offset.
	 * @return the new entry.
	 * @throws IllegalArgumentException if the offset is negative.
	 * @since 2.1.0
	 */
	public WadEntry withNewOffset(int offset)
	{
		if (offset < 0)
			throw new IllegalArgumentException("Entry offset is negative.");
		return new WadEntry(name, offset, size); 
	}
	
	/**
	 * Makes a copy of this entry with a new size.
	 * @param size the new offset.
	 * @return the new entry.
	 * @throws IllegalArgumentException if the size is negative.
	 * @since 2.1.0
	 */
	public WadEntry withNewSize(int size)
	{
		if (size < 0)
			throw new IllegalArgumentException("Entry size is negative.");
		return new WadEntry(name, offset, size); 
	}
	
	/**
	 * @return the name of the entry.
	 */
	public String getName()
	{
		return name;
	}

	/**
	 * @return the offset into the original WAD for the start of the data.
	 */
	public int getOffset()
	{
		return offset;
	}

	/**
	 * @return the size of the entry content in bytes.
	 */
	public int getSize()
	{
		return size;
	}
	
	/**
	 * Tests if this entry is a "marker" entry. Marker entries have 0 size.
	 * @return true if size = 0, false if not.
	 */
	public boolean isMarker()
	{
		return size == 0;
	}

	/**
	 * Returns this entry's name as how it is represented in a WAD.
	 * @return a byte array of length 8 containing the output data.
	 */
	public byte[] getNameBytes()
	{
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		SerialWriter sw = new SerialWriter(SerialWriter.LITTLE_ENDIAN);

		try {
			sw.writeBytes(bos, name.getBytes("ASCII"));
			// null pad out to 8
			for (int n = name.length(); n < 8; n++)
				sw.writeByte(bos, (byte)0x00);
		} catch (IOException e) {
			// Should not happen.
		}
		
		return bos.toByteArray();
	}

	/**
	 * Gets the byte representation of this object. 
	 * @return this object as a series of bytes.
	 */
	byte[] toBytes()
	{
		ByteArrayOutputStream bos = new ByteArrayOutputStream(128);
		try { writeBytes(bos); } catch (IOException e) { /* Shouldn't happen. */ }
		return bos.toByteArray();
	}

	/**
	 * Reads in the byte representation of this object and sets its fields.
	 * @param data the byte array to read from. 
	 * @throws IOException if a read error occurs.
	 */
	void fromBytes(byte[] data) throws IOException
	{
		ByteArrayInputStream bin = new ByteArrayInputStream(data);
		readBytes(bin);
	}

	/**
	 * Reads from an {@link InputStream} and sets this object's fields. 
	 * @param in the {@link InputStream} to read from. 
	 * @throws IOException if a read error occurs.
	 */
	void readBytes(InputStream in) throws IOException
	{
		SerialReader sr = new SerialReader(SerialReader.LITTLE_ENDIAN);
		offset = sr.readInt(in);
		size = sr.readInt(in);
		name = NameUtils.nullTrim(sr.readString(in, 8, "ASCII"));
	}

	/**
	 * Writes this object to an {@link OutputStream}.
	 * @param out the {@link OutputStream} to write to.
	 * @throws IOException if a write error occurs.
	 */
	void writeBytes(OutputStream out) throws IOException
	{
		SerialWriter sw = new SerialWriter(SerialWriter.LITTLE_ENDIAN);
		sw.writeInt(out, offset);
		sw.writeInt(out, size);
		sw.writeBytes(out, name.getBytes("ASCII"));
		// null pad out to 8
		for (int n = name.length(); n < 8; n++)
			sw.writeByte(out, (byte)0x00);
	}

	@Override
	public String toString()
	{
		return String.format("WadEntry %-8s Offset: %d, Size: %d", name, offset, size);
	}
	
}
