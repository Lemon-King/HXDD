/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.graphics;

import java.io.*;

import net.mtrop.doom.object.BinaryObject;
import net.mtrop.doom.util.MathUtils;

/**
 * This is a single entry that indexes the palette indices for color lookup.
 * The COLORMAP lump contains several of these.
 * Other commercial IWAD lumps that are colormaps or contain many colormaps are the TRANTBL lumps in Hexen and TINTTAB.
 * @author Matthew Tropiano
 */
public class Colormap implements BinaryObject
{
	/** A single colormap's length in bytes. */
	public static final int LENGTH = 256;
	/** The number of total indices in a standard Doom color map. */
	public static final int NUM_INDICES = 256;
	
	/** The index list in this map. */
	protected int[] indices;

	/**
	 * Creates a new identity colormap where all indices point to their own index.
	 */
	public Colormap()
	{
		indices = new int[NUM_INDICES];
		setIdentity();
	}
	
	/**
	 * Creates a new colormap by copying the contents of another.
	 * @param map the source map to copy.
	 */
	public Colormap(Colormap map)
	{
		System.arraycopy(map.indices, 0, indices, 0, NUM_INDICES);
	}
	
	/**
	 * Creates a color map where each color is mapped to its own index
	 * (index 0 is palette color 0 ... index 255 is palette color 255).
	 * @return a new color map with the specified indices already mapped.
	 */
	public static Colormap createIdentityMap()
	{
		Colormap out = new Colormap();
		out.setIdentity();
		return out;
	}

	/**
	 * Resets the color map to where each color is mapped to its own index
	 * (index 0 is palette color 0 ... index 255 is palette color 255).
	 * @return itself, to chain colormap calls.
	 */
	public Colormap setIdentity()
	{
		for (int i = 0; i < NUM_INDICES; i++)
			indices[i] = i;
		return this;
	}

	/**
	 * Sets a colormap translation by remapping groups of contiguous indices.
	 * @param startIndex the starting replacement index (inclusive).
	 * @param endIndex the ending replacement index (inclusive).
	 * @param startValue the starting replacement value (inclusive).
	 * @param endValue the ending replacement value (inclusive).
	 * @return itself, to chain colormap calls.
	 */
	public Colormap setTranslation(int startIndex, int endIndex, int startValue, int endValue)
	{
		int min = Math.min(startIndex, endIndex);
		int max = Math.max(startIndex, endIndex);
		
		float len = Math.abs(startValue - endValue) + 1f;
		
		for (int i = min; i <= max; i++)
			indices[i] = (int)MathUtils.linearInterpolate((i - min) / len, startValue, endValue);
		return this;
	}
	
	/**
	 * Creates a new colormap by copying the contents of this one.
	 * @return itself, to chain colormap calls.
	 */
	public Colormap copy()
	{
		return new Colormap(this);
	}
	
	/**
	 * Returns the palette index of a specific index in the map.
	 * @param index	the index number of the entry.
	 * @return the corresponding palette index.
	 * @throws ArrayIndexOutOfBoundsException if index is greater than NUM_INDICES or less than 0.
	 */
	public int getPaletteIndex(int index)
	{
		return indices[index];
	}
	
	/**
	 * Sets the palette index of a specific index in the map.
	 * @param index	the index number of the entry.
	 * @param paletteIndex the new index.
	 * @return itself, to chain colormap calls.
	 * @throws ArrayIndexOutOfBoundsException if index is greater than 255 or less than 0.
	 * @throws IllegalArgumentException if paletteIndex is less than 0 or greater than 255.
	 */
	public Colormap setPaletteIndex(int index, int paletteIndex)
	{
		if (paletteIndex < 0 || paletteIndex > 255)
			throw new IllegalArgumentException("Palette index is out of range. Must be from 0 to 255.");
		indices[index] = paletteIndex;
		return this;
	}
	
	@Override
	public void readBytes(InputStream in) throws IOException
	{
		for (int i = 0; i < NUM_INDICES; i++)
		{
			int b = in.read();
			if (b == -1)
				throw new IOException("end of stream reached after index "+i);
			indices[i] = b & 0x0ff;
		}
	}

	@Override
	public void writeBytes(OutputStream out) throws IOException
	{
		for (int i : indices)
			out.write(i & 0x0ff);
	}

	@Override
	public String toString()
	{
		return "Colormap " + java.util.Arrays.toString(indices);
	}
	
}
