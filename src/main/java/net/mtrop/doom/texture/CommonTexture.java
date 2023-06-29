/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.texture;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import net.mtrop.doom.object.BinaryObject;
import net.mtrop.doom.util.NameUtils;
import net.mtrop.doom.util.RangeUtils;

/**
 * Common contents of texture definitions.
 * @author Matthew Tropiano
 * @param <P> the contained CommonPatch type.
 */
public abstract class CommonTexture<P extends CommonPatch> implements BinaryObject, Iterable<P>, Comparable<CommonTexture<?>>
{
	/** Texture name. */
	protected String name;
	/** Width of texture. */
	protected int width;
	/** Height of texture. */
	protected int height;
	/** List of patches. */
	protected List<P> patches;

	/**
	 * Creates a new blank texture.
	 */
	protected CommonTexture()
	{
		this("UNNAMED");
	}
	
	/**
	 * Creates a new texture.
	 * @param name the new texture name.
	 * @throws IllegalArgumentException if the texture name is invalid.
	 */
	public CommonTexture(String name)
	{
		NameUtils.checkValidTextureName(name);
		this.name = name;
		width = 0;
		height = 0;
		patches = new ArrayList<P>(2);
	}
	
	/**
	 * @return the name of this texture.
	 */
	public String getName()
	{
		return name;
	}
	
	/**
	 * @return the width of this texture in pixels.
	 */
	public int getWidth()
	{
		return width;
	}
	
	/**
	 * Sets the width of this texture in pixels.
	 * @param width the new texture width.
	 * @throws IllegalArgumentException if the width is outside the range 0 to 65535.
	 */
	public void setWidth(int width)
	{
		RangeUtils.checkShortUnsigned("Width", width);
		this.width = width;
	}
	
	/**
	 * @return the height of this texture in pixels.
	 */
	public int getHeight()
	{
		return height;
	}
	
	/**
	 * Sets the height of this texture in pixels.
	 * @param height the new texture height.
	 * @throws IllegalArgumentException if the height is outside the range 0 to 65535.
	 */
	public void setHeight(int height)
	{
		RangeUtils.checkShortUnsigned("Height", height);
		this.height = height;
	}

	/**
	 * Creates a new patch entry on this texture, at the end of the list.
	 * The patch has no information set on it, including its name index value and offsets.
	 * @return a newly-added Patch object.
	 */
	public abstract P createPatch();
	
	/**
	 * Shifts the ordering of a patch on this texture.
	 * The ordering of the patches in this texture will change depending on the indexes provided.
	 * @param index the index to shift.
	 * @param newIndex the destination index.
	 */
	public void shiftPatch(int index, int newIndex)
	{
		// move earlier
		if (newIndex < index)
		{
			P p = patches.get(index);
			for (int i = index; i > newIndex; i--)
				patches.set(i, patches.get(i - 1));
			patches.set(newIndex, p);
		}
		// move later
		else if (newIndex > index)
		{
			P p = patches.get(index);
			for (int i = index; i < newIndex; i++)
				patches.set(i, patches.get(i + 1));
			patches.set(newIndex, p);
		}
	}
	
	/**
	 * Removes a patch entry from this texture by index.
	 * The ordering of the patches in this texture will change depending on the index provided.
	 * @param i	the index of the patch to remove.
	 * @return the patch removed, or null if no patch at that index.
	 */
	public P removePatch(int i)
	{
		return patches.remove(i);
	}
	
	/**
	 * Gets a patch from this texture.
	 * @param i	the index of the patch.
	 * @return the corresponding patch, or null if no patch at that index.
	 */
	public P getPatch(int i)
	{
		return patches.get(i);
	}
	
	/**
	 * @return the amount of patches on this texture.
	 */
	public int getPatchCount()
	{
		return patches.size();
	}

	@Override
	public Iterator<P> iterator()
	{
		return patches.iterator();
	}

	@Override
	public int compareTo(CommonTexture<?> o)
	{
		return name.compareTo(o.name);
	}

}
