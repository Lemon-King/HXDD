/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.struct.io;

import java.io.IOException;
import java.io.OutputStream;
import java.nio.charset.Charset;

/**
 * Assists in endian writing to an output stream.
 * @author Matthew Tropiano
 */
public class SerialWriter
{
	private static final int SIZEOF_INT = Integer.SIZE/Byte.SIZE;
	private static final int SIZEOF_SHORT = Short.SIZE/Byte.SIZE;
	private static final int SIZEOF_LONG = Long.SIZE/Byte.SIZE;

	public static final boolean LITTLE_ENDIAN =	true;
	public static final boolean BIG_ENDIAN = false;

	/** Endian mode switch. */
	private boolean endianMode;

	/**
	 * Creates a new serial writer.  
	 * @param endianMode an _ENDIAN mode.
	 */
	public SerialWriter(boolean endianMode)
	{
		setEndianMode(endianMode);
	}
	
	/**
	 * Sets the byte endian mode for the byte conversion methods.
	 * LITTLE_ENDIAN (Intel), the default, orients values from lowest byte to highest, while
	 * BIG_ENDIAN (Motorola) orients values from highest byte to lowest.
	 * @param mode an _ENDIAN mode.
	 */
	public void setEndianMode(boolean mode)
	{
		this.endianMode = mode;
	}
	
	/**
	 * Writes a String.
	 * @param out the output stream.
	 * @param s the String to write.
	 * @throws IOException if an error occurred during the write.
	 */
	public void writeString(OutputStream out, String s) throws IOException
	{
		writeCharArray(out, s.toCharArray());
	}

	/**
	 * Writes a String in a specific encoding.
	 * @param out the output stream.
	 * @param s	the String to write.
	 * @param encodingType the encoding type name.
	 * @throws IOException if an error occurred during the write.
	 */
	public void writeString(OutputStream out, String s, String encodingType) throws IOException
	{
		writeByteArray(out, s.getBytes(encodingType));
	}
	
	/**
	 * Writes a String in a specific encoding.
	 * @param out the output stream.
	 * @param s	the String to write.
	 * @param charset the encoding charset.
	 * @throws IOException if an error occurred during the write.
	 */
	public void writeString(OutputStream out, String s, Charset charset) throws IOException
	{
		writeByteArray(out, s.getBytes(charset));
	}
	
	/**
	 * Writes an array of Strings,
	 * which is the length of the array as an integer plus each String.
	 * @param out the output stream.
	 * @param s the array to write.
	 * @throws IOException if an error occurred during the write.
	 */
	public void writeStringArray(OutputStream out, String[] s) throws IOException
	{
		writeInt(out, s.length);
		for (int i = 0; i < s.length; i++)
			writeString(out, s[i]);
	}

	/**
	 * Writes a byte.
	 * @param out the output stream.
	 * @param b the value to write.
	 * @throws IOException if an error occurred during the write.
	 */
	public void writeByte(OutputStream out, byte b) throws IOException
	{
		out.write(b);
	}

	/**
	 * Writes a short that is less than 256 to a byte.
	 * @param out the output stream.
	 * @param s the value to write.
	 * @throws IOException if an error occurred during the write.
	 */
	public void writeUnsignedByte(OutputStream out, short s) throws IOException
	{
		writeByte(out, (byte)(s & 0x0ff));
	}

	/**
	 * Writes an int that is less than 256 to a byte.
	 * @param out the output stream.
	 * @param b the value to write.
	 * @throws IOException if an error occurred during the write.
	 */
	public void writeUnsignedByte(OutputStream out, int b) throws IOException
	{
		writeByte(out, (byte)(b & 0x0ff));
	}

	/**
	 * Writes a series of bytes.
	 * @param out the output stream.
	 * @param b the array to write.
	 * @throws IOException if an error occurred during the write.
	 */
	public void writeBytes(OutputStream out, byte[] b) throws IOException
	{
		out.write(b);
	}

	/**
	 * Writes a series of bytes.
	 * @param out the output stream.
	 * @param b the array to write.
	 * @param offset the offset into the array to write from.
	 * @param length the amount of bytes to write.
	 * @throws IOException if an error occurred during the write.
	 */
	public void writeBytes(OutputStream out, byte[] b, int offset, int length) throws IOException
	{
		out.write(b, offset, length);
	}

	/**
	 * Writes an array of bytes,
	 * which is the length of the array as an integer plus each byte.
	 * @param out the output stream.
	 * @param b the array to write.
	 * @throws IOException if an error occurred during the write.
	 */
	public void writeByteArray(OutputStream out, byte[] b) throws IOException
	{
		writeInt(out, b.length);
		out.write(b);
	}

	/**
	 * Writes a boolean as a byte.
	 * @param out the output stream.
	 * @param b the array to write.
	 * @throws IOException if an error occurred during the write.
	 */
	public void writeBoolean(OutputStream out, boolean b) throws IOException
	{
		writeByte(out, (byte)(b?1:0));
	}

	/**
	 * Writes a long that is less than 2^32 to an integer.
	 * @param out the output stream.
	 * @param l the value to write.
	 * @throws IOException if an error occurred during the write.
	 */
	public void writeUnsignedInteger(OutputStream out, long l) throws IOException
	{
		writeInt(out, (int)(l & 0x0ffffffffL));
	}

	/**
	 * Writes an integer.
	 * @param out the output stream.
	 * @param i the value to write.
	 * @throws IOException if an error occurred during the write.
	 */
	public void writeInt(OutputStream out, int i) throws IOException
	{
		byte[] buffer = CACHE.get().buffer;
		intToBytes(i, endianMode, buffer, 0);
		out.write(buffer, 0, 4);
	}

	/**
	 * Converts an integer from an int to a variable-length string of bytes.
	 * Makes up to four bytes. Due to the nature of this algorithm, it is always
	 * written out in a Big-Endian fashion.
	 * @param out the output stream.
	 * @param i	the int to convert.
	 * @throws IllegalArgumentException	if the int value to convert is above 0x0fffffff.
	 * @throws IOException if an error occurred during the write.
	 */
	public void writeVariableLengthInt(OutputStream out, int i) throws IOException
	{
		if ((i & 0xf0000000) != 0)
			throw new IllegalArgumentException("Int value out of bounds.");
		if (i == 0)
		{
			out.write(0);
			return;
		}
		byte[] b;
		int z = i, x = 0;
		while (z > 0) {z >>= 7; x++;}
		b = new byte[x];
		for (int n = x-1; n >= 0; n--)
		{
			b[n] = (byte)(i & 0x7f);
			i >>= 7;
			if (n != x-1)
				b[n] |= (byte)(0x80);
		}
		out.write(b);
	}

	/**
	 * Converts a long from a long to a variable-length string of bytes.
	 * Makes up to eight bytes. Due to the nature of this algorithm, it is always
	 * written out in a Big-Endian fashion.
	 * @param out the output stream.
	 * @param i	the long to convert.
	 * @throws IllegalArgumentException	if the long value to convert is above 0x7fffffffffffffffL.
	 * @throws IOException if an error occurred during the write.
	 */
	public void writeVariableLengthLong(OutputStream out, long i) throws IOException
	{
		if ((i & 0x8000000000000000L) != 0)
			throw new IllegalArgumentException("Long value too large.");
		if (i == 0)
		{
			out.write(0);
			return;
		}
		byte[] b;
		long z = i;
		int x = 0;
		while (z > 0) {z >>= 7; x++;}
		b = new byte[x];
		
		for (int n = x-1; n >= 0; n--)
		{
			b[n] = (byte)(i & 0x7f);
			i >>= 7;
			if (n != x-1)
				b[n] |= (byte)(0x80);
		}
		out.write(b);
	}

	/**
	 * Writes an integer array,
	 * which is the length of the array as an integer plus each integer.
	 * @param out the output stream.
	 * @param i the array to write.
	 * @throws IOException if an error occurred during the write.
	 */
	public void writeIntArray(OutputStream out, int[] i) throws IOException
	{
		writeInt(out, i.length);
		for (int x = 0; x < i.length; x++)
			writeInt(out, i[x]);
	}

	/**
	 * Writes a long.
	 * @param out the output stream.
	 * @param l the value to write.
	 * @throws IOException if an error occurred during the write.
	 */
	public void writeLong(OutputStream out, long l) throws IOException
	{
		byte[] buffer = CACHE.get().buffer;
		longToBytes(l, endianMode, buffer, 0);
		out.write(buffer);
	}

	/**
	 * Writes an array of longs,
	 * which is the length of the array as an integer plus each long.
	 * @param out the output stream.
	 * @param l the array to write.
	 * @throws IOException if an error occurred during the write.
	 */
	public void writeLongArray(OutputStream out, long[] l) throws IOException
	{
		writeInt(out, l.length);
		for (int x = 0; x < l.length; x++)
			writeLong(out, l[x]);
	}

	/**
	 * Writes an array of 32-bit floats,
	 * which is the length of the array as an integer plus each float.
	 * @param out the output stream.
	 * @param f the array to write.
	 * @throws IOException if an error occurred during the write.
	 */
	public void writeFloatArray(OutputStream out, float[] f) throws IOException
	{	
		writeInt(out, f.length);
		for (int x = 0; x < f.length; x++)
			writeFloat(out, f[x]);
	}

	/**
	 * Writes a 32-bit float.
	 * @param out the output stream.
	 * @param f the value to write.
	 * @throws IOException if an error occurred during the write.
	 */
	public void writeFloat(OutputStream out, float f) throws IOException
	{
		writeInt(out, Float.floatToIntBits(f));
	}

	/**
	 * Writes a 64-bit float.
	 * @param out the output stream.
	 * @param d the value to write.
	 * @throws IOException if an error occurred during the write.
	 */
	public void writeDouble(OutputStream out, double d) throws IOException
	{
		writeLong(out, Double.doubleToLongBits(d));
	}

	/**
	 * Writes an array of 64-bit floats,
	 * which is the length of the array as an integer plus each double.
	 * @param out the output stream.
	 * @param d the array to write.
	 * @throws IOException if an error occurred during the write.
	 */
	public void writeDoubleArray(OutputStream out, double[] d) throws IOException
	{	
		writeInt(out, d.length);
		for (int x = 0; x < d.length; x++)
			writeDouble(out, d[x]);
	}

	/**
	 * Writes a short.
	 * @param out the output stream.
	 * @param s the value to write.
	 * @throws IOException if an error occurred during the write.
	 */
	public void writeShort(OutputStream out, short s) throws IOException
	{
		byte[] buffer = CACHE.get().buffer;
		shortToBytes(s, endianMode, buffer, 0);
		out.write(buffer, 0, 2);
	}

	/**
	 * Writes an integer, less than 65536, as a short.
	 * @param out the output stream.
	 * @param s the value to write.
	 * @throws IOException if an error occurred during the write.
	 */
	public void writeUnsignedShort(OutputStream out, int s) throws IOException
	{
		writeShort(out, (short)(s & 0x0ffff));
	}

	/**
	 * Writes an array of shorts,
	 * which is the length of the array as an integer plus each short.
	 * @param out the output stream.
	 * @param s the array to write.
	 * @throws IOException if an error occurred during the write.
	 */
	public void writeShortArray(OutputStream out, short[] s) throws IOException
	{
		writeInt(out, s.length);
		for (int x = 0; x < s.length; x++)
			writeShort(out, s[x]);
	}

	/**
	 * Writes a character.
	 * @param out the output stream.
	 * @param c the value to write.
	 * @throws IOException if an error occurred during the write.
	 */
	public void writeChar(OutputStream out, char c) throws IOException
	{
		writeShort(out, charToShort(c));
	}

	/**
	 * Writes a character array,
	 * which is the length of the array as an integer plus each character.
	 * @param out the output stream.
	 * @param c the array to write.
	 * @throws IOException if an error occurred during the write.
	 */
	public void writeCharArray(OutputStream out, char[] c) throws IOException
	{
		writeInt(out, c.length);
		for (int x = 0; x < c.length; x++)
			writeChar(out, c[x]);
	}

	/**
	 * Writes a boolean array,
	 * which is the length of the array as an integer plus each boolean grouped into integer bits.
	 * @param out the output stream.
	 * @param b the array to write.
	 * @throws IOException if an error occurred during the write.
	 */
	public void writeBooleanArray(OutputStream out, boolean ... b) throws IOException
	{
		int[] bbits = new int[(b.length/Integer.SIZE)+((b.length%Integer.SIZE)!=0?1:0)];
		for (int i = 0; i < b.length; i++)
			if (b[i])
				bbits[i/Integer.SIZE] |= 1 << (i%Integer.SIZE);

		writeInt(out, b.length);
		for (int i = 0; i < bbits.length; i++)
			writeInt(out, bbits[i]);
	}

	private static short charToShort(char c)
	{
		return (short)(c & 0xFFFF);
	}

	private static int shortToBytes(short s, boolean endianMode, byte[] out, int offset)
	{
		for (int x = endianMode ? 0 : SIZEOF_SHORT-1; endianMode ? (x < SIZEOF_SHORT) : (x >= 0); x += endianMode ? 1 : -1)
			out[endianMode ? x : SIZEOF_SHORT-1 - x] = (byte)((s & (0xFF << Byte.SIZE*x)) >> Byte.SIZE*x); 
		return offset + SIZEOF_SHORT;
	}

	private static int intToBytes(int i, boolean endianMode, byte[] out, int offset)
	{
		for (int x = endianMode ? 0 : SIZEOF_INT-1; endianMode ? (x < SIZEOF_INT) : (x >= 0); x += endianMode ? 1 : -1)
			out[offset + (endianMode ? x : SIZEOF_INT-1 - x)] = (byte)((i & (0xFF << Byte.SIZE*x)) >> Byte.SIZE*x);
		return offset + SIZEOF_INT;
	}

	private static int longToBytes(long l, boolean endianMode, byte[] out, int offset)
	{
		for (int x = endianMode ? 0 : SIZEOF_LONG-1; endianMode ? (x < SIZEOF_LONG) : (x >= 0); x += endianMode ? 1 : -1)
			out[offset + (endianMode ? x : SIZEOF_LONG-1 - x)] = (byte)((l & (0xFFL << Byte.SIZE*x)) >> Byte.SIZE*x); 
		return offset + SIZEOF_LONG;
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