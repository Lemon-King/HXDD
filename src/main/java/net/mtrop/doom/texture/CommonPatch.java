/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.texture;

import net.mtrop.doom.object.BinaryObject;
import net.mtrop.doom.util.RangeUtils;

/**
 * Singular patch entry for a texture.
 */
public abstract class CommonPatch implements BinaryObject
{
	/** Horizontal offset of the patch. */
	protected int originX;
	/** Vertical offset of the patch. */
	protected int originY;
	/** Index of patch in patch names lump to use. */
	protected int patchIndex;

	public CommonPatch()
	{
		originX = 0;
		originY = 0;
		patchIndex = 0;
	}
	
	/** 
	 * @return the horizontal offset of the patch in pixels. 
	 */
	public int getOriginX()
	{
		return originX;
	}

	/** 
	 * Sets the horizontal offset of the patch in pixels. 
	 * @param originX the patch origin, x-coordinate.
	 * @throws IllegalArgumentException if <code>originX</code> is less than -32768 or more than 32767.
	 */
	public void setOriginX(int originX)
	{
		RangeUtils.checkShort("Patch Origin X", originX);
		this.originX = originX;
	}

	/** 
	 * @return the vertical offset of the patch in pixels. 
	 */
	public int getOriginY()
	{
		return originY;
	}

	/** 
	 * Sets the vertical offset of the patch in pixels. 
	 * @param originY the patch origin, y-coordinate.
	 * @throws IllegalArgumentException if <code>originY</code> is less than -32768 or more than 32767.
	 */
	public void setOriginY(int originY)
	{
		RangeUtils.checkShort("Patch Origin Y", originY);
		this.originY = originY;
	}

	/** 
	 * @return the patch's index into the patch name lump. 
	 */
	public int getNameIndex()
	{
		return patchIndex;
	}

	/** 
	 * Sets the patch's index into the patch name lump.
	 * @param patchIndex the patch index. 
	 * @throws IllegalArgumentException if <code>patchIndex</code> is less than 0 or more than 65535.
	 * @see PatchNames
	 */
	public void setNameIndex(int patchIndex)
	{
		RangeUtils.checkShortUnsigned("Patch Index", patchIndex);
		this.patchIndex = patchIndex;
	}

	@Override
	public String toString()
	{
		StringBuilder sb = new StringBuilder();
		sb.append("Patch Name #");
		sb.append(patchIndex);
		sb.append(" (");
		sb.append(originX);
		sb.append(", ");
		sb.append(originY);
		sb.append(")");
		return sb.toString();
	}

}
