/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.struct.io;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Arrays;

public class PNGContainerReader implements AutoCloseable
{
	/** PNG Header. */
	private static final byte[] PNG_HEADER = {
		(byte)0x089, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A
	};
	
	private InputStream in;
	
	/**
	 * Creates a new PNG container reader from a file.
	 * @param f the file to read.
	 * @throws IOException if a read error occurs or this is not a PNG file.
	 */
	public PNGContainerReader(File f) throws IOException
	{
		this(new FileInputStream(f));
	}
	
	/**
	 * Creates a new PNG container reader using an input stream.
	 * @param i the input stream to read.
	 * @throws IOException if a read error occurs or this is not PNG data.
	 */
	public PNGContainerReader(InputStream i) throws IOException
	{
		this.in = i;
		if (!Arrays.equals(PNG_HEADER, (new SerialReader(SerialReader.BIG_ENDIAN)).readBytes(in, 8)))
			throw new IOException("Not a PNG file. Header may be corrupt.");
	}
	
	/**
	 * Reads the next chunk in this container stream.
	 * @return a new chunk.
	 * @throws IOException on a read error.
	 */
	public Chunk nextChunk() throws IOException
	{
		Chunk chunk = null;
		try {chunk = new Chunk(in);} catch (IOException e) {}
		return chunk;
	}

	@Override
	public void close() throws IOException
	{
		in.close();
	}

	/**
	 * PNG Chunk data.
	 */
	public static class Chunk
	{
		/** Chunk name. */
		private String name;
		/** CRC number. */
		private int crcNumber;
		/** Data. */
		private byte[] data;
		
		Chunk(InputStream in) throws IOException
		{
			SerialReader sr = new SerialReader(SerialReader.BIG_ENDIAN);
			int len = sr.readInt(in);
			name = sr.readString(in, 4, "ASCII").trim();
			data = sr.readBytes(in, len);
			crcNumber = sr.readInt(in);
		}

		/**
		 * @return this chunk's identifier.
		 */
		public String getName()
		{
			return name;
		}

		/**
		 * @return this chunk's CRC value.
		 */
		public int getCRCNumber()
		{
			return crcNumber;
		}

		/**
		 * @return the data in this chunk.
		 */
		public byte[] getData()
		{
			return data;
		}
		
		@Override
		public String toString()
		{
			return name + " Length: " + data.length + " CRC: " + String.format("%08x", crcNumber);
		}
		
		/**
		 * @return true if this chunk is not a part of the required image chunks.
		 */
		public boolean isAncillary()
		{
			return Character.isLowerCase(name.charAt(0));
		}
		
		/**
		 * @return true if this chunk is part of a non-public specification.
		 */
		public boolean isPrivate()
		{
			return Character.isLowerCase(name.charAt(1));
		}
		
		/**
		 * @return true if this chunk is this chunk has the reserved bit set.
		 */
		public boolean isReserved()
		{
			return Character.isLowerCase(name.charAt(2));
		}

		/**
		 * @return true if this chunk is safe to blindly copy, requiring no
		 * other chunks and contains no image-centric data.
		 */
		public boolean isSafeToCopy()
		{
			return Character.isLowerCase(name.charAt(3));
		}
	}
	
}