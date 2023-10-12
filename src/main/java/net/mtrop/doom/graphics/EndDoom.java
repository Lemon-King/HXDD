/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.graphics;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.ByteBuffer;
import java.nio.CharBuffer;

import net.mtrop.doom.object.BinaryObject;
import net.mtrop.doom.struct.io.SerialReader;
import net.mtrop.doom.struct.io.SerialWriter;
import net.mtrop.doom.util.TextUtils;

/**
 * Abstraction of the ENDOOM and other similarly-formatted lumps for the Doom Engine.
 * An example of this would be the screen that is dumped to DOS after the player quits
 * or the loading screen for Heretic.
 * <p>
 * All characters are converted using the CP437 charset (<code>TextUtils.CP437</code>), a.k.a. the MS-DOS encoding for extended ASCII.
 * @author Matthew Tropiano
 */
public class EndDoom implements BinaryObject
{
	/** A single colormap's length in bytes. */
	public static final int LENGTH = 2 * 80 * 25;

	public static final byte
	BGCOLOR_BLACK = 0,
	BGCOLOR_BLUE = 1,
	BGCOLOR_GREEN = 2,
	BGCOLOR_CYAN = 3,
	BGCOLOR_RED = 4,
	BGCOLOR_MAGENTA = 5,
	BGCOLOR_BROWN = 6,
	BGCOLOR_GRAY = 7;

	public static final byte
	FGCOLOR_BLACK = 0,
	FGCOLOR_BLUE = 1,
	FGCOLOR_GREEN = 2,
	FGCOLOR_CYAN = 3,
	FGCOLOR_RED = 4,
	FGCOLOR_MAGENTA = 5,
	FGCOLOR_BROWN = 6,
	FGCOLOR_GRAY = 7,
	FGCOLOR_DARK_GRAY = 8,
	FGCOLOR_LIGHT_BLUE = 9,
	FGCOLOR_LIGHT_GREEN = 10,
	FGCOLOR_LIGHT_CYAN = 11,
	FGCOLOR_LIGHT_RED = 12,
	FGCOLOR_LIGHT_MAGENTA = 13,
	FGCOLOR_YELLOW = 14,
	FGCOLOR_WHITE = 15;
	
	/** The foreground colors for each character. */
	private byte[] fgColor;
	/** The background colors for each character. */
	private byte[] bgColor;
	/** The array of flags that dictate whether or not a foreground character is rendered blinking. */
	private boolean[] blinking;
	/** The character data in this object. */
	private byte[] characterData;

	private CharBuffer tempCharBuffer;
	private ByteBuffer tempByteBuffer;
	
	/** Creates a new, blank ENDOOM-type screen. */
	public EndDoom()
	{
		fgColor = new byte[80 * 25];
		bgColor = new byte[80 * 25];
		blinking = new boolean[80 * 25];
		characterData = new byte[80 * 25];
		tempCharBuffer = CharBuffer.allocate(1);
		tempByteBuffer = ByteBuffer.allocate(1);
	}
	
	/**
	 * Returns the VGA-formatted screen data for a particular ENDOOM screen coordinate.
	 * <p>
	 * The short contains the font character in the lower byte and the color info in
	 * the higher one. Should be exported in little-endian order to retain VGA spec ordering. 
	 * @param row the desired row (0 to 24).
	 * @param col the desired column (0 to 79).
	 * @return the VGA short value.
	 */
	public short getVGAShort(int row, int col)
	{
		short out = 0;
		int index = getIndex(row, col);
		
		out |= characterData[index] & 0x0ff;
		out |= (fgColor[index] & 0x0f) << 8;
		out |= (bgColor[index] & 0x07) << 12;
		out |= blinking[index] ? 0x8000 : 0x0000;
		
		return out;
	}

	/**
	 * Returns the Unicode character at the desired position. 
	 * @param row the desired row (0 to 24).
	 * @param col the desired column (0 to 79).
	 * @return the corresponding character.
	 */
	public char getCharAt(int row, int col)
	{
		return byteToUnicode(characterData[getIndex(row, col)]);
	}
	
	/**
	 * Sets the Unicode character at the desired position.
	 * Keep in mind that some characters not present the CP437
	 * charset will not encode properly.
	 * @param row the desired row (0 to 24).
	 * @param col the desired column (0 to 79).
	 * @param c the character to set.
	 */
	public void setCharAt(int row, int col, char c)
	{
		characterData[getIndex(row, col)] = unicodeToByte(c);
	}

	/**
	 * Gets the ANSI color to use for the foreground color for the desired position.
	 * @param row the desired row (0 to 24).
	 * @param col the desired column (0 to 79).
	 * @return the corresponding ANSI color.
	 */
	public int getForegroundColor(int row, int col)
	{
		return fgColor[getIndex(row, col)];
	}
	
	/**
	 * Sets the ANSI color to use for the foreground color for the desired position.
	 * @param row the desired row (0 to 24).
	 * @param col the desired column (0 to 79).
	 * @param color the ANSI color to use for the foreground color (0 to 15).
	 */
	public void setForegroundColor(int row, int col, int color)
	{
		if (color < FGCOLOR_BLACK || color > FGCOLOR_WHITE)
			throw new IllegalArgumentException("Foreground color must be from 0 to 15.");
		fgColor[getIndex(row, col)] = (byte)color;
	}
	
	/**
	 * Gets the ANSI color to use for the background color for the desired position.
	 * @param row the desired row (0 to 24).
	 * @param col the desired column (0 to 79).
	 * @return the corresponding ANSI color.
	 */
	public int getBackgroundColor(int row, int col)
	{
		return bgColor[getIndex(row, col)];
	}
	
	/**
	 * Sets the ANSI color to use for the background color for the desired position.
	 * @param row the desired row (0 to 24).
	 * @param col the desired column (0 to 79).
	 * @param color the ANSI color to use for the background color (0 to 7).
	 */
	public void setBackgroundColor(int row, int col, int color)
	{
		if (color < BGCOLOR_BLACK || color > BGCOLOR_GRAY)
			throw new IllegalArgumentException("Background color must be from 0 to 7.");
		fgColor[getIndex(row, col)] = (byte)color;
	}
	
	/**
	 * Gets if the foreground character is blinking for the desired position.
	 * @param row the desired row (0 to 24).
	 * @param col the desired column (0 to 79).
	 * @return true if so, false if not.
	 */
	public boolean getBlinking(int row, int col)
	{
		return blinking[getIndex(row, col)];
	}
	
	/**
	 * Sets if the foreground character is blinking for the desired position.
	 * @param row the desired row (0 to 24).
	 * @param col the desired column (0 to 79).
	 * @param blink true for blinking, false otherwise.
	 */
	public void setBlinking(int row, int col, boolean blink)
	{
		blinking[getIndex(row, col)] = blink;
	}
	
	/**
	 * Sets the VGA-formatted screen data for a particular ENDOOM screen coordinate using
	 * a little-endian short int containing the VGA screen code.
	 * <p>
	 * The short contains the font character in the lower byte and the color info in
	 * the higher one. Should be exported in little-endian order to retain VGA spec ordering. 
	 * @param row the desired row (0 to 24).
	 * @param col the desired column (0 to 79).
	 * @param s the short.
	 */
	protected void setVGAShort(int row, int col, short s)
	{
		int index = getIndex(row, col);
		characterData[index] = (byte)(s & 0x0ff);
		fgColor[index] = (byte)((s >>> 8) & 0x0f);
		bgColor[index] = (byte)((s >>> 12) & 0x07);
		blinking[index] = (s & 0x8000) != 0;
	}

	/**
	 * @param vgaByte the input VGA byte.
	 * @return a converted VGA (or IBM) byte to Unicode.
	 */
	protected char byteToUnicode(byte vgaByte)
	{
		tempByteBuffer.put(0, vgaByte);
		tempByteBuffer.rewind();
		return TextUtils.CP437.decode(tempByteBuffer).get(0);
	}
	
	/**
	 * @param c the input unicode character.
	 * @return a converted Unicode character to VGA byte.
	 */
	protected byte unicodeToByte(char c)
	{
		tempCharBuffer.put(0, c);
		tempCharBuffer.rewind();
		return TextUtils.CP437.encode(tempCharBuffer).get(0);
	}
	
	/**
	 * Returns the correct array index for a specific row/column.
	 * @param row the desired row (0 to 24).
	 * @param col the desired column (0 to 79).
	 * @return the correct array index for a specific row/column.
	 */
	protected int getIndex(int row, int col)
	{
		return row*80 + col;
	}
	
	@Override
	public void readBytes(InputStream in) throws IOException
	{
		SerialReader sr = new SerialReader(SerialReader.LITTLE_ENDIAN);
		for (int r = 0; r < 25; r++)
			for (int c = 0; c < 80; c++)
				setVGAShort(r, c, sr.readShort(in));
	}

	@Override
	public void writeBytes(OutputStream out) throws IOException
	{
		SerialWriter sw = new SerialWriter(SerialWriter.LITTLE_ENDIAN);
		for (int r = 0; r < 25; r++)
			for (int c = 0; c < 80; c++)
				sw.writeShort(out, getVGAShort(r, c));
	}

	@Override
	public String toString()
	{
		StringBuilder sb = new StringBuilder();
		for (int r = 0; r < 25; r++)
		{
			for (int c = 0; c < 80; c++)
				sb.append(getCharAt(r,c));
			sb.append('\n');
		}

		return sb.toString();
	}
	
}
