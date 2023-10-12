/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.struct.io;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.Charset;

/**
 * Assists in endian reading from an input stream.
 * @author Matthew Tropiano
 */
public class SerialReader
{
	private static final int SIZEOF_INT = Integer.SIZE/Byte.SIZE;
	private static final int SIZEOF_SHORT = Short.SIZE/Byte.SIZE;
	private static final int SIZEOF_LONG = Long.SIZE/Byte.SIZE;
	private static final int SIZEOF_FLOAT = Float.SIZE/Byte.SIZE;
	private static final int SIZEOF_DOUBLE = Double.SIZE/Byte.SIZE;

	public static final boolean LITTLE_ENDIAN =	true;
	public static final boolean BIG_ENDIAN = false;

	/** Endian mode switch. */
	private boolean endianMode;
	
	/**
	 * Wraps a super reader around an InputStream.  
	 * @param endianMode an _ENDIAN mode.
	 */
	public SerialReader(boolean endianMode)
	{
		setEndianMode(endianMode);
	}
	
	/**
	 * Sets the byte endian mode for the byte conversion methods.
	 * LITTLE_ENDIAN (Intel), the default, orients values from lowest byte to highest, while
	 * BIG_ENDIAN (Motorola, VAX) orients values from highest byte to lowest.
	 * @param mode an _ENDIAN mode.
	 */
	public void setEndianMode(boolean mode)
	{
		endianMode = mode;
	}
	
	/**
	 * Reads a byte from the bound stream.
	 * @param in the input stream to read from.
	 * @return the byte read or -1 if the end of the stream is reached.
	 * @throws IOException if a read error occurs.
	 */
	protected synchronized int byteRead(InputStream in) throws IOException
	{
		return in.read();
	}
	
	/**
	 * Reads a series of bytes from the bound stream into a byte array until end of 
	 * stream is reached or the array is filled with bytes.
	 * @param in the input stream to read from.
	 * @param b the target array to fill with bytes.
	 * @return the amount of bytes read or -1 if the end of the stream 
	 * 		is reached before a single byte is read.
	 * @throws IOException if a read error occurs.
	 */
	protected int byteRead(InputStream in, byte[] b) throws IOException
	{
		return byteRead(in, b, b.length);
	}

	/**
	 * Reads a series of bytes from the bound stream into a byte array until end of 
	 * stream is reached or <code>maxlen</code> bytes have been read.
	 * @param in the input stream to read from.
	 * @param b the target array to fill with bytes.
	 * @param maxlen the maximum amount of bytes to read.
	 * @return the amount of bytes read or -1 if the end of the stream 
	 * 		is reached before a single byte is read.
	 * @throws IOException if a read error occurs.
	 */
	protected synchronized int byteRead(InputStream in, byte[] b, int maxlen) throws IOException
	{
		return in.read(b, 0, maxlen);
	}

	// Casts a short to a char.
	private char shortToChar(short s)
	{
		return (char)(s & 0xFFFF);
	}

	/**
	 * Keeps reading until it hits a specific byte pattern.
	 * @param in the input stream to read from.
	 * @param b the pattern to search for.
	 * @return true if the pattern is found, returns false if the end of the stream is reached before the pattern is matched.
	 * @throws IOException if a read error occurs.
	 */
	public boolean seekToPattern(InputStream in, byte[] b) throws IOException
	{
		int i = 0;
		int x = b.length;
		Cache cache = CACHE.get();
		
		while (i < x)
		{
			int buf = byteRead(in, cache.buffer, 1);
			if (buf < 1)
				return false;
			if (cache.buffer[0] == b[i])
				i++;
			else
				i = 0;
		}
		return true;
	}
	
	/**
	 * Reads a bunch of bytes and checks to see if a set of bytes match completely
	 * with the input byte string. It reads up to the length of b before it starts the check.
	 * @param in the input stream to read from.
	 * @param b	the input byte string.
	 * @return true if the bytes read equal the the same bytes in the input array.
	 * @throws IOException if a read error occurs.
	 */
	public boolean readFor(InputStream in, byte[] b) throws IOException
	{
		byte[] read = new byte[b.length];
		byteRead(in, read);
		for (int i = 0; i < b.length; i++)
			if (read[i] != b[i])
				return false;
		return true;
	}
	
	/**
	 * Reads a byte array in from the reader.
	 * @param in the input stream to read from.
	 * @return an array of bytes
	 * @throws IOException if the end of the stream is reached prematurely.
	 */
	public byte[] readByteArray(InputStream in) throws IOException
	{
		byte[] out = new byte[readInt(in)];
		if (out.length == 0)
			return out;
		int buf = byteRead(in, out);
		if (buf < out.length)
			throw new IOException("Not enough bytes for byte array.");
		return out;
	}

	/**
	 * Reads a char array and returns it as a String.
	 * @param in the input stream to read from.
	 * @return the resulting String.
	 * @throws IOException if an I/O error occurs.
	 */
	public String readString(InputStream in) throws IOException
	{
		return new String(readCharArray(in));
	}

	/**
	 * Reads a byte vector (an int followed by a series of bytes) and returns it as a String
	 * in a particular encoding.
	 * @param in the input stream to read from.
	 * @param encoding	the name of the encoding scheme.
	 * @return the decoded string.
	 * @throws IOException if an I/O error occurs.
	 */
	public String readString(InputStream in, String encoding) throws IOException
	{
		return new String(readByteArray(in), encoding);
	}

	/**
	 * Reads a byte vector (an int followed by a series of bytes) and returns it as a String
	 * in a particular encoding.
	 * @param in the input stream to read from.
	 * @param charset the name of the charset to use.
	 * @return the decoded string.
	 * @throws IOException if an I/O error occurs.
	 */
	public String readString(InputStream in, Charset charset) throws IOException
	{
		return new String(readByteArray(in), charset);
	}

	/**
	 * Reads a byte vector of specific length and returns it as a String
	 * in a particular encoding.
	 * @param in the input stream to read from.
	 * @param bytes the amount of bytes to read.
	 * @param encoding	the name of the encoding scheme.
	 * @return the decoded string.
	 * @throws IOException if an I/O error occurs.
	 */
	public String readString(InputStream in, int bytes, String encoding) throws IOException
	{
		return new String(readBytes(in, bytes), encoding);
	}

	/**
	 * Reads a byte vector of specific length and returns it as a String
	 * in a particular encoding.
	 * @param in the input stream to read from.
	 * @param bytes the amount of bytes to read.
	 * @param charset the name of the charset to use.
	 * @return the decoded string.
	 * @throws IOException if an I/O error occurs.
	 */
	public String readString(InputStream in, int bytes, Charset charset) throws IOException
	{
		return new String(readBytes(in, bytes), charset);
	}

	/**
	 * Reads in an array of strings.
	 * Basically reads an integer length which is the length of the array and then reads that many strings.
	 * @param in the input stream to read from.
	 * @return the decoded string array.
	 * @throws IOException if an error occurred during the read.
	 */
	public String[] readStringArray(InputStream in) throws IOException
	{
		String[] out = new String[readInt(in)];
		for (int i = 0; i < out.length; i++)
			out[i] = readString(in);
		return out;
	}

	/**
	 * Reads a byte as a boolean value.
	 * @param in the input stream to read from.
	 * @return a boolean value.
	 * @throws IOException if an error occurred during the read.
	 */
	public boolean readBoolean(InputStream in) throws IOException
	{
		return readByte(in) != 0;
	}

	/**
	 * Reads in an array of boolean values.
	 * Basically reads an integer length which is the amount of booleans and then reads 
	 * in an integer at a time scanning bits for the boolean values.
	 * @param in the input stream to read from.
	 * @throws IOException if an error occurred during the read.
	 * @return the boolean array.
	 */
	public boolean[] readBooleanArray(InputStream in) throws IOException
	{
		boolean[] out = new boolean[readInt(in)];
			
		int currint = 0;
		for (int i = 0; i < out.length; i++)
		{
			if (i%Integer.SIZE == 0)
				currint = readInt(in);
			
			out[i] = bitIsSet(currint,(1<<(i%Integer.SIZE)));
		}
		return out;
	}
	
	/**
	 * Reads in a long value.
	 * @param in the input stream to read from.
	 * @return the decoded value.
	 * @throws IOException if an error occurred during the read.
	 */
	public long readLong(InputStream in) throws IOException
	{
		byte[] buffer = new byte[SIZEOF_LONG];
		int buf = byteRead(in, buffer);
		if (buf < SIZEOF_LONG) 
			throw new IOException("Not enough bytes for a long.");
		return bytesToLong(buffer, endianMode);
	}

	/**
	 * Reads in an amount of long values specified by the user.
	 * @param in the input stream to read from.
	 * @param n the amount of long integers to read.
	 * @return the decoded value.
	 * @throws IOException if an error occurred during the read.
	 */
	public long[] readLongs(InputStream in, int n) throws IOException
	{
		long[] out = new long[n];
		for (int i = 0; i < out.length; i++)
			out[i] = readLong(in);
		return out;
	}

	/**
	 * Reads in an array of long values.
	 * Basically reads an integer length which is the length of the array and then reads that many longs.
	 * @param in the input stream to read from.
	 * @return the decoded value.
	 * @throws IOException if an error occurred during the read.
	 */
	public long[] readLongArray(InputStream in) throws IOException
	{
		return readLongs(in, readInt(in));
	}

	/**
	 * Reads in a single byte.
	 * @param in the input stream to read from.
	 * @return the decoded value.
	 * @throws IOException if an error occurred during the read.
	 */
	public byte readByte(InputStream in) throws IOException
	{
		Cache cache = CACHE.get();
		int buf = byteRead(in, cache.buffer, 1);
		if (buf < 1)
			throw new IOException("not enough bytes");
		else if (buf < 1) throw new IOException("Not enough bytes for a byte.");
		return cache.buffer[0];
	}

	/**
	 * Reads in a single byte, cast to a short to eliminate sign.
	 * @param in the input stream to read from.
	 * @return the decoded value.
	 * @throws IOException if an error occurred during the read.
	 */
	public short readUnsignedByte(InputStream in) throws IOException
	{
		return (short)(readByte(in) & 0x0ff);
	}

	/**
	 * Reads a series of bytes from the bound stream into a byte array until end of 
	 * stream is reached or the array is filled with bytes.
	 * @param in the input stream to read from.
	 * @param b the target array to fill with bytes.
	 * @return	the amount of bytes read or END_OF_STREAM if the end of the stream 
	 * 			is reached before a single byte is read.
	 * @throws IOException if an error occurred during the read.
	 */
	public int readBytes(InputStream in, byte[] b) throws IOException
	{
		return byteRead(in, b);
	}

	/**
	 * Reads a series of bytes from the bound stream into a byte array until end of 
	 * stream is reached or <code>maxlen</code> bytes have been read.
	 * @param in the input stream to read from.
	 * @param b the target array to fill with bytes.
	 * @param maxlen the maximum amount of bytes to read.
	 * @return	the amount of bytes read or END_OF_STREAM if the end of the stream 
	 * 			is reached before a single byte is read.
	 * @throws IOException if an error occurred during the read.
	 */
	public int readBytes(InputStream in, byte[] b, int maxlen) throws IOException
	{
		return byteRead(in, b, maxlen);
	}

	/**
	 * Reads in a specified amount of bytes, returned as an array.
	 * @param in the input stream to read from.
	 * @param n the amount of bytes to read.
	 * @return the decoded value.
	 * @throws IOException if an error occurred during the read.
	 */
	public byte[] readBytes(InputStream in, int n) throws IOException
	{
		byte[] out = new byte[n];
		int buf = byteRead(in, out);
		if (buf < n) 
			throw new IOException("Not enough bytes to read.");
		return out;
	}

	/**
	 * Reads in a integer, cast to a long, discarding sign.
	 * @param in the input stream to read from.
	 * @return the decoded value.
	 * @throws IOException if an error occurred during the read.
	 */
	public long readUnsignedInt(InputStream in) throws IOException
	{
		return readInt(in) & 0x0ffffffffL;
	}
	
	/**
	 * Reads in an integer.
	 * @param in the input stream to read from.
	 * @return the decoded value.
	 * @throws IOException if an error occurred during the read.
	 */
	public int readInt(InputStream in) throws IOException
	{
		byte[] buffer = new byte[SIZEOF_INT];
		int buf = byteRead(in, buffer);
		if (buf < SIZEOF_INT) 
			throw new IOException("Not enough bytes for an int.");
		return bytesToInt(buffer, endianMode);
	}

	/**
	 * Reads in a 24-bit integer.
	 * @param in the input stream to read from.
	 * @return the decoded value.
	 * @throws IOException if an error occurred during the read.
	 */
	public int read24BitInt(InputStream in) throws IOException
	{
		byte[] bbu = new byte[3];
		byte[] buffer = new byte[SIZEOF_INT];
		int buf = byteRead(in, bbu,3);
		if (buf < 3)
			throw new IOException("not enough bytes");
		else if (buf < bbu.length) throw new IOException("Not enough bytes for a 24-bit int.");
		if (endianMode == BIG_ENDIAN)
			System.arraycopy(bbu, 0, buffer, 1, 3);
		else if (endianMode == LITTLE_ENDIAN)
			System.arraycopy(bbu, 0, buffer, 0, 3);
		return bytesToInt(buffer, endianMode);
	}

	/**
	 * Reads in a specified amount of integers.
	 * @param in the input stream to read from.
	 * @param n the amount of integers to read.
	 * @return the decoded value.
	 * @throws IOException if an error occurred during the read.
	 */
	public int[] readInts(InputStream in, int n) throws IOException
	{
		int[] out = new int[n];
		for (int i = 0; i < out.length; i++)
			out[i] = readInt(in);
		return out;
	}

	/**
	 * Reads in an array of integers.
	 * Basically reads an integer length which is the length of the array and then reads that many integers.
	 * @param in the input stream to read from.
	 * @return the decoded value.
	 * @throws IOException if an error occurred during the read.
	 */
	public int[] readIntArray(InputStream in) throws IOException
	{
		return readInts(in, readInt(in));
	}

	/**
	 * Reads in a 32-bit float.
	 * @param in the input stream to read from.
	 * @return the decoded value.
	 * @throws IOException if an error occurred during the read.
	 */
	public float readFloat(InputStream in) throws IOException
	{
		byte[] buffer = new byte[SIZEOF_FLOAT];
		int buf = byteRead(in, buffer);
		if (buf < SIZEOF_FLOAT) 
			throw new IOException("Not enough bytes for a float.");
		return bytesToFloat(buffer, endianMode);
	}

	/**
	 * Reads in a specified amount of 32-bit floats.
	 * @param in the input stream to read from.
	 * @param n the amount of floats to read.
	 * @return the decoded value.
	 * @throws IOException if an error occurred during the read.
	 */
	public float[] readFloats(InputStream in, int n) throws IOException
	{
		float[] out = new float[n];
		for (int i = 0; i < out.length; i++)
			out[i] = readFloat(in);
		return out;
	}

	/**
	 * Reads in an array 32-bit floats.
	 * Basically reads an integer length which is the length of the array and then reads that many floats.
	 * @param in the input stream to read from.
	 * @return the decoded value.
	 * @throws IOException if an error occurred during the read.
	 */
	public float[] readFloatArray(InputStream in) throws IOException
	{
		return readFloats(in, readInt(in));
	}

	/**
	 * Reads in a 64-bit float.
	 * @param in the input stream to read from.
	 * @return the decoded value.
	 * @throws IOException if an error occurred during the read.
	 */
	public double readDouble(InputStream in) throws IOException
	{
		byte[] buffer = new byte[SIZEOF_DOUBLE];
		int buf = byteRead(in, buffer);
		if (buf < SIZEOF_DOUBLE) 
			throw new IOException("Not enough bytes for a double.");
		return Double.longBitsToDouble(bytesToLong(buffer, endianMode));
	}

	/**
	 * Reads in a specified amount of 64-bit floats.
	 * @param in the input stream to read from.
	 * @param n the amount of doubles to read.
	 * @return the decoded value.
	 * @throws IOException if an error occurred during the read.
	 */
	public double[] readDoubles(InputStream in, int n) throws IOException
	{
		double[] out = new double[n];
		for (int i = 0; i < out.length; i++)
			out[i] = readDouble(in);
		return out;
	}

	/**
	 * Reads in an array 64-bit floats.
	 * Basically reads an integer length which is the length of the array and then reads that many doubles.
	 * @param in the input stream to read from.
	 * @return the decoded value.
	 * @throws IOException if an error occurred during the read.
	 */
	public double[] readDoubleArray(InputStream in) throws IOException
	{
		return readDoubles(in, readInt(in));
	}

	/**
	 * Reads in a short.
	 * @param in the input stream to read from.
	 * @return the decoded value.
	 * @throws IOException if an error occurred during the read.
	 */
	public short readShort(InputStream in) throws IOException
	{
		byte[] buffer = new byte[SIZEOF_SHORT];
		int buf = byteRead(in, buffer);
		if (buf < SIZEOF_SHORT) 
			throw new IOException("Not enough bytes for a short.");
		return bytesToShort(buffer, endianMode);
	}

	/**
	 * Reads in a short, cast to an integer, discarding sign.
	 * @param in the input stream to read from.
	 * @return the decoded value.
	 * @throws IOException if an error occurred during the read.
	 */
	public int readUnsignedShort(InputStream in) throws IOException
	{
		return readShort(in) & 0x0ffff;
	}
	
	/**
	 * Reads in a specified amount of shorts.
	 * @param in the input stream to read from.
	 * @param n the amount of shorts to read.
	 * @return the decoded value.
	 * @throws IOException if an error occurred during the read.
	 */
	public short[] readShorts(InputStream in, int n) throws IOException
	{
		short[] out = new short[n];
		for (int i = 0; i < out.length; i++)
			out[i] = readShort(in);
		return out;
	}

	/**
	 * Reads in an array of shorts.
	 * Basically reads an integer length which is the length of the array and then reads that many shorts.
	 * @param in the input stream to read from.
	 * @return the decoded value.
	 * @throws IOException if an error occurred during the read.
	 */
	public short[] readShortArray(InputStream in) throws IOException
	{
		return readShorts(in, readInt(in));
	}

	/**
	 * Reads in a character.
	 * @param in the input stream to read from.
	 * @return the decoded value.
	 * @throws IOException if an error occurred during the read.
	 */
	public char readChar(InputStream in) throws IOException
	{
		return shortToChar(readShort(in));
	}

	/**
	 * Reads in a specific amount of characters.
	 * @param in the input stream to read from.
	 * @param n the amount of characters to read (16-bit).
	 * @return the decoded value.
	 * @throws IOException if an error occurred during the read.
	 */
	public char[] readChars(InputStream in, int n) throws IOException
	{
		char[] out = new char[n];
		for (int i = 0; i < out.length; i++)
			out[i] = readChar(in);
		return out;
	}

	/**
	 * Reads in an array of characters.
	 * Basically reads an integer length which is the length of the array and then reads that many characters.
	 * @param in the input stream to read from.
	 * @return the decoded value.
	 * @throws IOException if an error occurred during the read.
	 */
	public char[] readCharArray(InputStream in) throws IOException
	{
		short[] s = readShortArray(in);
		char[] out = new char[s.length];
		for (int i = 0; i < s.length; i++)
			out[i] = shortToChar(s[i]);
		return out;
	}

	/**
	 * Reads an integer from an input stream that is variable-length encoded.
	 * Reads up to four bytes. Due to the nature of this value, it is always
	 * read in a Big-Endian fashion.
	 * @param in the input stream to read from.
	 * @return an int value from 0x00000000 to 0x0FFFFFFF.
	 * @throws IOException if the next byte to read is not available.
	 */
	public int readVariableLengthInt(InputStream in) throws IOException
	{
		int out = 0;
		byte b = 0;
		do {
			b = readByte(in);
			out |= b & 0x7f;
			if ((b & 0x80) != 0)
				out <<= 7;
		} while ((b & 0x80) != 0);
		return out;
	}

	/**
	 * Reads a long from an input stream that is variable-length encoded.
	 * Reads up to eight bytes. Due to the nature of this value, it is always
	 * read in a Big-Endian fashion.
	 * @param in the input stream to read from.
	 * @return a long value from 0x0000000000000000 to 0x7FFFFFFFFFFFFFFF.
	 * @throws IOException if the next byte to read is not available.
	 */
	public long readVariableLengthLong(InputStream in) throws IOException
	{
		long out = 0;
		byte b = 0;
		do {
			b = readByte(in);
			out |= b & 0x7f;
			if ((b & 0x80) != 0)
				out <<= 7;
		} while ((b & 0x80) != 0);
		return out;
	}

	private static boolean bitIsSet(long value, long test)
	{
		return (value & test) == test;
	}

	private static float bytesToFloat(byte[] b, boolean endianMode)
	{
		return Float.intBitsToFloat(bytesToInt(b, endianMode));
	}

	private static short bytesToShort(byte[] b, boolean endianMode)
	{
		short out = 0;
	
		int stop = Math.min(b.length,SIZEOF_SHORT);
		for (int x = 0; x < stop; x++)
			out |= (b[x]&0xFF) << Byte.SIZE*(endianMode ? x : SIZEOF_SHORT-1-x);
	
		return out;
	}

	private static int bytesToInt(byte[] b, boolean endianMode)
	{
		int out = 0;
	
		int stop = Math.min(b.length,SIZEOF_INT);
		for (int x = 0; x < stop; x++)
			out |= (b[x]&0xFF) << Byte.SIZE*(endianMode ? x : SIZEOF_INT-1-x);
	
		return out;
	}

	private static long bytesToLong(byte[] b, boolean endianMode)
	{
		long out = 0;
	
		int stop = Math.min(b.length,SIZEOF_LONG);
		for (int x = 0; x < stop; x++)
			out |= (long)(b[x]&0xFFL) << (long)(Byte.SIZE*(endianMode ? x : SIZEOF_LONG-1-x));
	
		return out;
	}

	private static final ThreadLocal<Cache> CACHE = ThreadLocal.withInitial(()->new Cache());
	
	private static class Cache
	{
		byte[] buffer;
		private Cache()
		{
			this.buffer = new byte[8];
		}
	}
	
}
