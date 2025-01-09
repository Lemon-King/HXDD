/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.graphics;

import java.awt.Color;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Arrays;

import net.mtrop.doom.object.BinaryObject;
import net.mtrop.doom.util.MathUtils;

/**
 * The palette that makes up the Doom Engine's color palette.
 * The colors are all opaque. This contains an indexed set of 256 colors.
 * Doom's PLAYPAL lump contains several of these.
 * TODO: Revisit "nearest match" with better algorithm.
 * @author Matthew Tropiano
 */
public class Palette implements BinaryObject
{
	private static final ThreadLocal<byte[]> TEMP_COLOR = ThreadLocal.withInitial(()->new byte[3]);
	
	/** The number of total colors in a standard Doom palette. */
	public static final int NUM_COLORS = 256;
	/** Number of bytes per color in a Doom palette. */
	public static final int BYTES_PER_COLOR = 3;
	/** A single palette's length in bytes. */
	public static final int LENGTH = NUM_COLORS * BYTES_PER_COLOR;

	/** The palette of colors. */
	protected byte[][] colorPalette;
	
	/**
	 * Creates a new palette of black, opaque colors.
	 */
	public Palette()
	{
		colorPalette = new byte[NUM_COLORS][3];
	}
	
	/**
	 * Makes a copy of this palette.
	 * @return a new Palette that is a copy of this one.
	 * @since 2.2.0
	 */
	public Palette copy()
	{
		Palette out = new Palette();
		for (int i = 0; i < NUM_COLORS; i++)
			System.arraycopy(this.colorPalette[i], 0, out.colorPalette[i], 0, BYTES_PER_COLOR);
		return out;
	}
	
	/**
	 * Returns the Color of a specific index in the palette.
	 * @param index	the index number of the color.
	 * @throws ArrayIndexOutOfBoundsException if index is greater than or equal to NUM_COLORS or less than 0.
	 * @return the color as a java.awt.Color.
	 */
	public Color getColor(int index)
	{
		byte[] c = colorPalette[index];
		return new Color(
			(int)(c[0] & 0x0ff), 
			(int)(c[1] & 0x0ff), 
			(int)(c[2] & 0x0ff)
		);
	}
	
	/**
	 * Returns the Color of a specific index in the palette as a 32-bit ARGB integer.
	 * Alpha is always 255 (opaque).
	 * @param index	the index number of the color.
	 * @throws ArrayIndexOutOfBoundsException if index is greater than or equal to NUM_COLORS or less than 0.
	 * @return the color as an ARGB integer.
	 */
	public int getColorARGB(int index)
	{
		byte[] c = colorPalette[index];
		return 0xff000000 | ((c[0] & 0x0ff) << 16) | ((c[1] & 0x0ff) << 8) | (c[2] & 0x0ff);
	}
	
	/**
	 * Returns the index of the color nearest to a color in the palette.
	 * @param argb the ARGB color.
	 * @return the closest index.
	 */
	public int getNearestColorIndex(int argb)
	{
		return getNearestColorIndex(argb, false);
	}

	/**
	 * Returns the index of the color nearest to a color in the palette.
	 * @param argb the ARGB color.
	 * @param exclude255 if true, exclude the 255th color in the palette as a candidate (for patches).
	 * @since 2.16.0
	 * @return the closest index.
	 */
	public int getNearestColorIndex(int argb, boolean exclude255)
	{
		return getNearestColorIndex((0x00ff0000 & argb) >> 16, (0x0000ff00 & argb) >> 8, (0x000000ff & argb), exclude255);
	}

	/**
	 * Returns the index of the color nearest to a color in the palette.
	 * @param red the red component amount (0 to 255).
	 * @param green the green component amount (0 to 255).
	 * @param blue the blue component amount (0 to 255).
	 * @return the closest index.
	 */
	public int getNearestColorIndex(int red, int green, int blue)
	{
		return getNearestColorIndex(red, green, blue, false);
	}

	/**
	 * Returns the index of the color nearest to a color in the palette.
	 * @param red the red component amount (0 to 255).
	 * @param green the green component amount (0 to 255).
	 * @param blue the blue component amount (0 to 255).
	 * @param exclude255 if true, exclude the 255th color in the palette as a candidate (for patches).
	 * @since 2.16.0
	 * @return the closest index.
	 */
	public int getNearestColorIndex(int red, int green, int blue, boolean exclude255)
	{
		byte[] cbyte = TEMP_COLOR.get();
		cbyte[0] = (byte)red;
		cbyte[1] = (byte)green;
		cbyte[2] = (byte)blue;
		long minDist = Long.MAX_VALUE;
		int closest = -1;
		int max = exclude255 ? NUM_COLORS - 1 : NUM_COLORS;
		for (int i = 0; i < max; i++)
		{
			long dist = getColorDistance(cbyte, colorPalette[i]);
			if (dist == 0)
			{
				return i;
			}
			else if (dist < minDist)
			{
				minDist = dist;
				closest = i;
			}
		}
		return closest;
	}

	/**
	 * Sets the color of a specific index in the Palette.
	 * @param index	the index number of the color to change.
	 * @param argb the ARGB color.
	 * @return itself, for chaining calls.
	 * @throws ArrayIndexOutOfBoundsException if index is greater than or equal to NUM_COLORS or less than 0.
	 * @since 2.2.0, this returns itself.
	 */
	public Palette setColor(int index, int argb)
	{
		return setColor(index, (0x00ff0000 & argb) >> 16, (0x0000ff00 & argb) >> 8, (0x000000ff & argb));
	}

	/**
	 * Sets the color of a specific index in the Palette.
	 * @param index	the index number of the color to change.
	 * @param red the red component amount (0 to 255, clamped).
	 * @param green the green component amount (0 to 255, clamped).
	 * @param blue the blue component amount (0 to 255, clamped).
	 * @return itself, for chaining calls.
	 * @throws ArrayIndexOutOfBoundsException if index is greater than or equal to NUM_COLORS or less than 0.
	 * @since 2.2.0, this returns itself.
	 */
	public Palette setColor(int index, int red, int green, int blue)
	{
		setColorNoSort(index, red, green, blue);
		sortIndices();
		return this;
	}

	/**
	 * Sets the color of a specific index in the Palette by blending it with another color.
	 * @param index	the index number of the color to change.
	 * @param scalar the scalar intensity of the blend (0 to 1, 0 is none, 1 is replace).
	 * @param argb the ARGB color.
	 * @return itself, for chaining calls.
	 * @throws ArrayIndexOutOfBoundsException if index is greater than or equal to NUM_COLORS or less than 0.
	 * @since 2.2.0
	 */
	public Palette mixColor(int index, double scalar, int argb)
	{
		return mixColor(index, scalar, (0x00ff0000 & argb) >> 16, (0x0000ff00 & argb) >> 8, (0x000000ff & argb));
	}

	/**
	 * Sets the color of a specific index in the Palette by blending it with another color.
	 * @param index	the index number of the color to change.
	 * @param scalar the scalar intensity of the blend (0 to 1, 0 is none, 1 is replace).
	 * @param red the red component amount (0 to 255, clamped).
	 * @param green the green component amount (0 to 255, clamped).
	 * @param blue the blue component amount (0 to 255, clamped).
	 * @return itself, for chaining calls.
	 * @throws ArrayIndexOutOfBoundsException if index is greater than or equal to NUM_COLORS or less than 0.
	 * @since 2.2.0
	 */
	public Palette mixColor(int index, double scalar, int red, int green, int blue)
	{
		if (scalar == 0.0)
			return this;
		mixColorNoSort(index, scalar, red, green, blue);
		sortIndices();
		return this;
	}

	/**
	 * Sets the color of a specific index in the Palette by additively blending it with another color.
	 * @param index	the index number of the color to change.
	 * @param scalar the scalar amount of each component to add (0 to 1).
	 * @param argb the ARGB color.
	 * @return itself, for chaining calls.
	 * @throws ArrayIndexOutOfBoundsException if index is greater than or equal to NUM_COLORS or less than 0.
	 * @since 2.2.0
	 */
	public Palette addColor(int index, double scalar, int argb)
	{
		return addColor(index, scalar, (0x00ff0000 & argb) >> 16, (0x0000ff00 & argb) >> 8, (0x000000ff & argb));
	}

	/**
	 * Sets the color of a specific index in the Palette by additively blending it with another color.
	 * @param index	the index number of the color to change.
	 * @param scalar the scalar amount of each component to add (0 to 1).
	 * @param red the red component amount (0 to 255, clamped).
	 * @param green the green component amount (0 to 255, clamped).
	 * @param blue the blue component amount (0 to 255, clamped).
	 * @return itself, for chaining calls.
	 * @throws ArrayIndexOutOfBoundsException if index is greater than or equal to NUM_COLORS or less than 0.
	 * @since 2.2.0
	 */
	public Palette addColor(int index, double scalar, int red, int green, int blue)
	{
		if (scalar == 0.0)
			return this;
		addColorNoSort(index, scalar, red, green, blue);
		sortIndices();
		return this;
	}

	/**
	 * Sets the color of a range of indices in the Palette by subtractively blending it with another color.
	 * @param startIndex the starting index number of the color to change (inclusive).
	 * @param endIndex the ending index number of the color to change (inclusive).
	 * @param scalar the scalar amount of each component to subtract (0 to 1).
	 * @param argb the ARGB color.
	 * @return itself, for chaining calls.
	 * @throws ArrayIndexOutOfBoundsException if startIndex or endIndex is greater than or equal to NUM_COLORS or less than 0.
	 * @since 2.2.0
	 */
	public Palette subtractColor(int startIndex, int endIndex, double scalar, int argb)
	{
		return subtractColor(startIndex, endIndex, scalar, (0x00ff0000 & argb) >> 16, (0x0000ff00 & argb) >> 8, (0x000000ff & argb));
	}

	/**
	 * Sets the color of a specific index in the Palette by subtractively blending it with another color.
	 * @param index	the index number of the color to change.
	 * @param scalar the scalar amount of each component to subtract (0 to 1).
	 * @param red the red component amount (0 to 255, clamped).
	 * @param green the green component amount (0 to 255, clamped).
	 * @param blue the blue component amount (0 to 255, clamped).
	 * @return itself, for chaining calls.
	 * @throws ArrayIndexOutOfBoundsException if index is greater than or equal to NUM_COLORS or less than 0.
	 * @since 2.2.0
	 */
	public Palette subtractColor(int index, double scalar, int red, int green, int blue)
	{
		if (scalar == 0.0)
			return this;
		subtractColorNoSort(index, scalar, red, green, blue);
		sortIndices();
		return this;
	}

	/**
	 * Sets the color of a specific index in the Palette by multiplicatively blending it with another color.
	 * @param index	the index number of the color to change.
	 * @param scalar the scalar intensity of the blend (0 to 1, 1 is full blend).
	 * @param argb the ARGB color.
	 * @return itself, for chaining calls.
	 * @throws ArrayIndexOutOfBoundsException if index is greater than or equal to NUM_COLORS or less than 0.
	 * @since 2.2.0
	 */
	public Palette multiplyColor(int index, double scalar, int argb)
	{
		return multiplyColor(index, scalar, (0x00ff0000 & argb) >> 16, (0x0000ff00 & argb) >> 8, (0x000000ff & argb));
	}

	/**
	 * Sets the color of a specific index in the Palette by multiplicatively blending it with another color.
	 * @param index	the index number of the color to change.
	 * @param scalar the scalar intensity of the blend (0 to 1, 1 is full blend).
	 * @param red the red component amount (0 to 255, clamped).
	 * @param green the green component amount (0 to 255, clamped).
	 * @param blue the blue component amount (0 to 255, clamped).
	 * @return itself, for chaining calls.
	 * @throws ArrayIndexOutOfBoundsException if index is greater than or equal to NUM_COLORS or less than 0.
	 * @since 2.2.0
	 */
	public Palette multiplyColor(int index, double scalar, int red, int green, int blue)
	{
		if (scalar == 0.0)
			return this;
		multiplyColorNoSort(index, scalar, red, green, blue);
		sortIndices();
		return this;
	}

	/**
	 * Sets the color of a range of indices in the Palette.
	 * @param startIndex the starting index number of the color to change (inclusive).
	 * @param endIndex the ending index number of the color to change (inclusive).
	 * @param argb the ARGB color.
	 * @return itself, for chaining calls.
	 * @throws ArrayIndexOutOfBoundsException if startIndex or endIndex is greater than or equal to NUM_COLORS or less than 0.
	 * @since 2.2.0
	 */
	public Palette setColor(int startIndex, int endIndex, int argb)
	{
		return setColor(startIndex, endIndex, (0x00ff0000 & argb) >> 16, (0x0000ff00 & argb) >> 8, (0x000000ff & argb));
	}

	/**
	 * Sets the color of a range of indices in the Palette.
	 * @param startIndex the starting index number of the color to change (inclusive).
	 * @param endIndex the ending index number of the color to change (inclusive).
	 * @param red the red component amount (0 to 255, clamped).
	 * @param green the green component amount (0 to 255, clamped).
	 * @param blue the blue component amount (0 to 255, clamped).
	 * @return itself, for chaining calls.
	 * @throws ArrayIndexOutOfBoundsException if startIndex or endIndex is greater than or equal to NUM_COLORS or less than 0.
	 * @since 2.2.0
	 */
	public Palette setColor(int startIndex, int endIndex, int red, int green, int blue)
	{
		int min = Math.min(startIndex, endIndex);
		int max = Math.max(startIndex, endIndex);
		for (int i = min; i <= max; i++)
			setColorNoSort(i, red, green, blue);
		sortIndices();
		return this;
	}

	/**
	 * Sets the color of a range of indices in the Palette by blending it with another color.
	 * @param startIndex the starting index number of the color to change (inclusive).
	 * @param endIndex the ending index number of the color to change (inclusive).
	 * @param scalar the scalar intensity of the blend (0 to 1, 0 is none, 1 is replace).
	 * @param argb the ARGB color.
	 * @return itself, for chaining calls.
	 * @throws ArrayIndexOutOfBoundsException if startIndex or endIndex is greater than or equal to NUM_COLORS or less than 0.
	 * @since 2.2.0
	 */
	public Palette mixColor(int startIndex, int endIndex, double scalar, int argb)
	{
		return mixColor(startIndex, endIndex, scalar, (0x00ff0000 & argb) >> 16, (0x0000ff00 & argb) >> 8, (0x000000ff & argb));
	}

	/**
	 * Sets the color of a range of indices in the Palette by blending it with another color.
	 * @param startIndex the starting index number of the color to change (inclusive).
	 * @param endIndex the ending index number of the color to change (inclusive).
	 * @param scalar the scalar intensity of the blend (0 to 1, 0 is none, 1 is replace).
	 * @param red the red component amount (0 to 255, clamped).
	 * @param green the green component amount (0 to 255, clamped).
	 * @param blue the blue component amount (0 to 255, clamped).
	 * @return itself, for chaining calls.
	 * @throws ArrayIndexOutOfBoundsException if startIndex or endIndex is greater than or equal to NUM_COLORS or less than 0.
	 * @since 2.2.0
	 */
	public Palette mixColor(int startIndex, int endIndex, double scalar, int red, int green, int blue)
	{
		if (scalar == 0.0)
			return this;
		int min = Math.min(startIndex, endIndex);
		int max = Math.max(startIndex, endIndex);
		for (int i = min; i <= max; i++)
			mixColorNoSort(i, scalar, red, green, blue);
		sortIndices();
		return this;
	}

	/**
	 * Sets the color of a range of indices in the Palette by additively blending it with another color.
	 * @param startIndex the starting index number of the color to change (inclusive).
	 * @param endIndex the ending index number of the color to change (inclusive).
	 * @param scalar the scalar amount of each component to add (0 to 1).
	 * @param argb the ARGB color.
	 * @return itself, for chaining calls.
	 * @throws ArrayIndexOutOfBoundsException if startIndex or endIndex is greater than or equal to NUM_COLORS or less than 0.
	 * @since 2.2.0
	 */
	public Palette addColor(int startIndex, int endIndex, double scalar, int argb)
	{
		return addColor(startIndex, endIndex, scalar, (0x00ff0000 & argb) >> 16, (0x0000ff00 & argb) >> 8, (0x000000ff & argb));
	}

	/**
	 * Sets the color of a range of indices in the Palette by additively blending it with another color.
	 * @param startIndex the starting index number of the color to change (inclusive).
	 * @param endIndex the ending index number of the color to change (inclusive).
	 * @param scalar the scalar amount of each component to add (0 to 1).
	 * @param red the red component amount (0 to 255, clamped).
	 * @param green the green component amount (0 to 255, clamped).
	 * @param blue the blue component amount (0 to 255, clamped).
	 * @return itself, for chaining calls.
	 * @throws ArrayIndexOutOfBoundsException if startIndex or endIndex is greater than or equal to NUM_COLORS or less than 0.
	 * @since 2.2.0
	 */
	public Palette addColor(int startIndex, int endIndex, double scalar, int red, int green, int blue)
	{
		if (scalar == 0.0)
			return this;
		int min = Math.min(startIndex, endIndex);
		int max = Math.max(startIndex, endIndex);
		for (int i = min; i <= max; i++)
			addColorNoSort(i, scalar, red, green, blue);
		sortIndices();
		return this;
	}

	/**
	 * Sets the color of a specific index in the Palette by subtractively blending it with another color.
	 * @param index	the index number of the color to change.
	 * @param scalar the scalar amount of each component to subtract (0 to 1).
	 * @param argb the ARGB color.
	 * @return itself, for chaining calls.
	 * @throws ArrayIndexOutOfBoundsException if index is greater than or equal to NUM_COLORS or less than 0.
	 * @since 2.2.0
	 */
	public Palette subtractColor(int index, double scalar, int argb)
	{
		return subtractColor(index, scalar, (0x00ff0000 & argb) >> 16, (0x0000ff00 & argb) >> 8, (0x000000ff & argb));
	}

	/**
	 * Sets the color of a range of indices in the Palette by subtractively blending it with another color.
	 * @param startIndex the starting index number of the color to change (inclusive).
	 * @param endIndex the ending index number of the color to change (inclusive).
	 * @param scalar the scalar amount of each component to subtract (0 to 1).
	 * @param red the red component amount (0 to 255, clamped).
	 * @param green the green component amount (0 to 255, clamped).
	 * @param blue the blue component amount (0 to 255, clamped).
	 * @return itself, for chaining calls.
	 * @throws ArrayIndexOutOfBoundsException if startIndex or endIndex is greater than or equal to NUM_COLORS or less than 0.
	 * @since 2.2.0
	 */
	public Palette subtractColor(int startIndex, int endIndex, double scalar, int red, int green, int blue)
	{
		if (scalar == 0.0)
			return this;
		int min = Math.min(startIndex, endIndex);
		int max = Math.max(startIndex, endIndex);
		for (int i = min; i <= max; i++)
			subtractColorNoSort(i, scalar, red, green, blue);
		sortIndices();
		return this;
	}

	/**
	 * Sets the color of a range of indices in the Palette by multiplicatively blending it with another color.
	 * @param startIndex the starting index number of the color to change (inclusive).
	 * @param endIndex the ending index number of the color to change (inclusive).
	 * @param scalar the scalar intensity of the blend (0 to 1, 1 is full blend).
	 * @param argb the ARGB color.
	 * @return itself, for chaining calls.
	 * @throws ArrayIndexOutOfBoundsException if startIndex or endIndex is greater than or equal to NUM_COLORS or less than 0.
	 * @since 2.2.0
	 */
	public Palette multiplyColor(int startIndex, int endIndex, double scalar, int argb)
	{
		return multiplyColor(startIndex, endIndex, scalar, (0x00ff0000 & argb) >> 16, (0x0000ff00 & argb) >> 8, (0x000000ff & argb));
	}

	/**
	 * Sets the color of a range of indices in the Palette by multiplicatively blending it with another color.
	 * @param startIndex the starting index number of the color to change (inclusive).
	 * @param endIndex the ending index number of the color to change (inclusive).
	 * @param scalar the scalar intensity of the blend (0 to 1, 1 is full blend).
	 * @param red the red component amount (0 to 255, clamped).
	 * @param green the green component amount (0 to 255, clamped).
	 * @param blue the blue component amount (0 to 255, clamped).
	 * @return itself, for chaining calls.
	 * @throws ArrayIndexOutOfBoundsException if startIndex or endIndex is greater than or equal to NUM_COLORS or less than 0.
	 * @since 2.2.0
	 */
	public Palette multiplyColor(int startIndex, int endIndex, double scalar, int red, int green, int blue)
	{
		if (scalar == 0.0)
			return this;
		int min = Math.min(startIndex, endIndex);
		int max = Math.max(startIndex, endIndex);
		for (int i = min; i <= max; i++)
			multiplyColorNoSort(i, scalar, red, green, blue);
		sortIndices();
		return this;
	}

	/**
	 * Sets the color of a specific index in the Palette by saturating/desaturating it.
	 * @param index	the index number of the color to change.
	 * @param scalar the scalar intensity of the final saturation (0 to 1, 0 is desaturated, 1 is no change, higher values saturate).
	 * @return itself, for chaining calls.
	 * @throws ArrayIndexOutOfBoundsException if index is greater than or equal to NUM_COLORS or less than 0.
	 * @since 2.2.0
	 */
	public Palette saturateColor(int index, double scalar)
	{
		if (scalar == 1.0)
			return this;
		saturateColorNoSort(index, scalar);
		sortIndices();
		return this;
	}

	/**
	 * Sets the color of a range of indices in the Palette by saturating/desaturating it.
	 * @param startIndex the starting index number of the color to change (inclusive).
	 * @param endIndex the ending index number of the color to change (inclusive).
	 * @param scalar the scalar intensity of the final saturation (0 to 1, 0 is desaturated, 1 is no change, higher values saturate).
	 * @return itself, for chaining calls.
	 * @throws ArrayIndexOutOfBoundsException if index is greater than or equal to NUM_COLORS or less than 0.
	 * @since 2.2.0
	 */
	public Palette saturateColor(int startIndex, int endIndex, double scalar)
	{
		if (scalar == 1.0)
			return this;
		int min = Math.min(startIndex, endIndex);
		int max = Math.max(startIndex, endIndex);
		for (int i = min; i <= max; i++)
			saturateColorNoSort(i, scalar);
		sortIndices();
		return this;
	}

	/**
	 * Sets the color of a range of indices in the Palette by creating a linear color gradient.
	 * @param startIndex the starting index number of the color to change (inclusive).
	 * @param endIndex the ending index number of the color to change (inclusive).
	 * @param argb0 the first ARGB color.
	 * @param argb1 the second ARGB color.
	 * @return itself, for chaining calls.
	 * @throws ArrayIndexOutOfBoundsException if index is greater than or equal to NUM_COLORS or less than 0.
	 * @since 2.2.0
	 */
	public Palette setColorGradient(int startIndex, int endIndex, int argb0, int argb1)
	{
		return setColorGradient(startIndex, endIndex, 
			(0x00ff0000 & argb0) >> 16, (0x0000ff00 & argb0) >> 8, (0x000000ff & argb0),
			(0x00ff0000 & argb1) >> 16, (0x0000ff00 & argb1) >> 8, (0x000000ff & argb1)
		);
	}

	/**
	 * Sets the color of a range of indices in the Palette by creating a linear color gradient.
	 * @param startIndex the starting index number of the color to change (inclusive).
	 * @param endIndex the ending index number of the color to change (inclusive).
	 * @param red0 the first color's red component amount (0 to 255, clamped).
	 * @param green0 the first color's green component amount (0 to 255, clamped).
	 * @param blue0 the first color's blue component amount (0 to 255, clamped).
	 * @param red1 the second color's red component amount (0 to 255, clamped).
	 * @param green1 the second color's green component amount (0 to 255, clamped).
	 * @param blue1 the second color's blue component amount (0 to 255, clamped).
	 * @return itself, for chaining calls.
	 * @throws ArrayIndexOutOfBoundsException if index is greater than or equal to NUM_COLORS or less than 0.
	 * @since 2.2.0
	 */
	public Palette setColorGradient(int startIndex, int endIndex, int red0, int green0, int blue0, int red1, int green1, int blue1)
	{
		int min = Math.min(startIndex, endIndex);
		int max = Math.max(startIndex, endIndex);
		int steps = max - min;
		double scaleStep = 1.0 / (max - min);
		for (int i = 0; i < steps; i++)
		{
			setColorNoSort(i + min, red0, green0, blue0);
			mixColorNoSort(i + min, scaleStep * i, red1, green1, blue1);
		}
		setColorNoSort(max, red1, green1, blue1);
		sortIndices();
		return this;
	}

	/**
	 * Sets the color of a specific index in the Palette and doesn't trigger a re-sort.
	 * @param index	the index number of the color.
	 * @param red the red component amount (0 to 255).
	 * @param green the green component amount (0 to 255).
	 * @param blue the blue component amount (0 to 255).
	 * @throws ArrayIndexOutOfBoundsException if index is greater than or equal to NUM_COLORS or less than 0.
	 */
	protected void setColorNoSort(int index, int red, int green, int blue)
	{
		colorPalette[index][0] = (byte)red;
		colorPalette[index][1] = (byte)green;
		colorPalette[index][2] = (byte)blue;
	}

	/**
	 * Sort indexes into color.
	 */
	protected void sortIndices()
	{
		// Do nothing.
	}

	private void mixColorNoSort(int index, double scalar, int red, int green, int blue)
	{
		setColorNoSort(index, 
			MathUtils.clampValue((int)MathUtils.linearInterpolate(scalar, (0x0ff & colorPalette[index][0]), red), 0, 255), 
			MathUtils.clampValue((int)MathUtils.linearInterpolate(scalar, (0x0ff & colorPalette[index][1]), green), 0, 255), 
			MathUtils.clampValue((int)MathUtils.linearInterpolate(scalar, (0x0ff & colorPalette[index][2]), blue), 0, 255)
		);
	}

	private void addColorNoSort(int index, double scalar, int red, int green, int blue)
	{
		setColorNoSort(index, 
			MathUtils.clampValue((0x0ff & colorPalette[index][0]) + (int)(scalar * red), 0, 255), 
			MathUtils.clampValue((0x0ff & colorPalette[index][1]) + (int)(scalar * green), 0, 255), 
			MathUtils.clampValue((0x0ff & colorPalette[index][2]) + (int)(scalar * blue), 0, 255)
		);
	}

	private void subtractColorNoSort(int index, double scalar, int red, int green, int blue)
	{
		setColorNoSort(index, 
			MathUtils.clampValue((0x0ff & colorPalette[index][0]) - (int)(scalar * red), 0, 255), 
			MathUtils.clampValue((0x0ff & colorPalette[index][1]) - (int)(scalar * green), 0, 255), 
			MathUtils.clampValue((0x0ff & colorPalette[index][2]) - (int)(scalar * blue), 0, 255)
		);
	}

	private void multiplyColorNoSort(int index, double scalar, int red, int green, int blue)
	{
		mixColorNoSort(index, scalar, 
			(0x0ff & colorPalette[index][0]) * red / 255, 
			(0x0ff & colorPalette[index][1]) * green / 255, 
			(0x0ff & colorPalette[index][2]) * blue / 255
		);
	}

	private void saturateColorNoSort(int index, double scalar)
	{
		int lum = (int)(getLuminance(colorPalette[index]) * 255);
		mixColorNoSort(index, scalar, lum, lum, lum);
	}

	private static float getLuminance(byte[] color)
	{
		float r = (color[0] & 0x0ff) / 255f;
		float g = (color[1] & 0x0ff) / 255f;
		float b = (color[2] & 0x0ff) / 255f;
		return 0.2126f * r + 0.7152f * g + 0.0722f * b;
	}

	private static long getColorDistance(byte[] color1, byte[] color2)
	{
		long dr = (0x0ff & color1[0]) - (0x0ff & color2[0]);
		long dg = (0x0ff & color1[1]) - (0x0ff & color2[1]);
		long db = (0x0ff & color1[2]) - (0x0ff & color2[2]);
		return dr * dr + dg * dg + db * db;
	}

	@Override
	public void readBytes(InputStream in) throws IOException
	{
		for (int i = 0; i < NUM_COLORS; i++)
		{
			int r = in.read();
			int g = in.read();
			int b = in.read();
			if (r == -1 || g == -1 || b == -1)
				throw new IOException("end of stream reached in color index "+i);
			setColorNoSort(i,
				r & 0x0ff,
				g & 0x0ff,
				b & 0x0ff
			);
		}
		sortIndices();
	}

	@Override
	public void writeBytes(OutputStream out) throws IOException
	{
		for (byte[] c : colorPalette)
			out.write(c);
	}

	@Override
	public String toString()
	{
		StringBuilder sb = new StringBuilder();
		sb.append("Palette");
		for (int i = 0; i < NUM_COLORS; i++)
		{
			sb.append(' ').append(i).append(":").append(Arrays.toString(colorPalette[i]));
			if (i < NUM_COLORS - 1)
				sb.append(", ");
		}
		return sb.toString();
	}
	
}
