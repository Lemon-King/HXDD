/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.map.data;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import net.mtrop.doom.map.MapObjectConstants;
import net.mtrop.doom.object.BinaryObject;
import net.mtrop.doom.struct.io.SerialReader;
import net.mtrop.doom.struct.io.SerialWriter;
import net.mtrop.doom.util.NameUtils;
import net.mtrop.doom.util.RangeUtils;

/**
 * Doom/Boom 30-byte format implementation of a Sidedef.
 * @author Matthew Tropiano
 */
public class DoomSidedef implements BinaryObject 
{
	/** Byte length of this object. */
	public static final int LENGTH = 30;

	/** Sidedef X Offset. */
	private int offsetX;
	/** Sidedef Y Offset. */
	private int offsetY;
	/** Sidedef top texture. */
	private String textureTop;
	/** Sidedef bottom texture. */
	private String textureBottom;
	/** Sidedef middle texture. */
	private String textureMiddle;
	/** Sidedef's sector reference. */
	private int sectorIndex;
	
	/**
	 * Creates a new sidedef.
	 */
	public DoomSidedef()
	{
		this.offsetX = 0;
		this.offsetY = 0;
		this.textureTop = MapObjectConstants.TEXTURE_BLANK;
		this.textureBottom = MapObjectConstants.TEXTURE_BLANK;
		this.textureMiddle = MapObjectConstants.TEXTURE_BLANK;
		this.sectorIndex = MapObjectConstants.NULL_REFERENCE;
	}
	
	/**
	 * Sets the sidedef's texture X offset.
	 * @param offsetX the new X offset.
	 * @throws IllegalArgumentException if the offset is outside the range -32768 to 32767.
	 */
	public void setOffsetX(int offsetX)
	{
		RangeUtils.checkShort("X-offset", offsetX);
		this.offsetX = offsetX;
	}
	
	/**
	 * @return the sidedef's texture X offset.
	 */
	public int getOffsetX()
	{
		return offsetX;
	}

	/**
	 * Sets the sidedef's texture Y offset.
	 * @param offsetY the new Y offset.
	 * @throws IllegalArgumentException if the offset is outside the range -32768 to 32767.
	 */
	public void setOffsetY(int offsetY)
	{
		RangeUtils.checkShort("Y-offset", offsetY);
		this.offsetY = offsetY;
	}
	
	/**
	 * @return the sidedef's texture Y offset.
	 */
	public int getOffsetY()
	{
		return offsetY;
	}

	/**
	 * Sets the top texture name.
	 * @param textureTop the new texture name.
	 * @throws IllegalArgumentException if the texture name is invalid. 
	 */
	public void setTextureTop(String textureTop)
	{
		NameUtils.checkValidTextureName(textureTop);
		this.textureTop = textureTop;
	}
	
	/**
	 * @return the top texture name.
	 */
	public String getTextureTop()
	{
		return textureTop;
	}

	/**
	 * Sets the bottom texture name.
	 * @param textureBottom the new texture name.
	 * @throws IllegalArgumentException if the texture name is invalid. 
	 */
	public void setTextureBottom(String textureBottom)
	{
		NameUtils.checkValidTextureName(textureBottom);
		this.textureBottom = textureBottom;
	}
	
	/**
	 * @return the bottom texture name.
	 */
	public String getTextureBottom()
	{
		return textureBottom;
	}

	/**
	 * Sets the middle texture name.
	 * @param textureMiddle the new texture name.
	 * @throws IllegalArgumentException if the texture name is invalid. 
	 */
	public void setTextureMiddle(String textureMiddle)
	{
		NameUtils.checkValidTextureName(textureMiddle);
		this.textureMiddle = textureMiddle;
	}
	
	/**
	 * @return the middle texture name.
	 */
	public String getTextureMiddle()
	{
		return textureMiddle;
	}

	/**
	 * Sets the sector reference index for this sidedef.
	 * @param sectorIndex the sector reference index.
	 * @throws IllegalArgumentException if the offset is outside the range 0 to 65535.
	 */
	public void setSectorIndex(int sectorIndex)
	{
		RangeUtils.checkShort("Sector Index", sectorIndex);
		this.sectorIndex = sectorIndex;
	}
	
	/**
	 * @return the index of the sector.
	 */
	public int getSectorIndex()
	{
		return sectorIndex;
	}

	@Override
	public void readBytes(InputStream in) throws IOException
	{
		SerialReader sr = new SerialReader(SerialReader.LITTLE_ENDIAN);
		offsetX = sr.readShort(in);
		offsetY = sr.readShort(in);
		textureTop = NameUtils.nullTrim(sr.readString(in, 8, "ASCII")).toUpperCase();
		textureBottom = NameUtils.nullTrim(sr.readString(in, 8, "ASCII")).toUpperCase();
		textureMiddle = NameUtils.nullTrim(sr.readString(in, 8, "ASCII")).toUpperCase();
		sectorIndex = sr.readShort(in);
	}

	@Override
	public void writeBytes(OutputStream out) throws IOException
	{
		SerialWriter sw = new SerialWriter(SerialWriter.LITTLE_ENDIAN);
		sw.writeShort(out, (short)offsetX);
		sw.writeShort(out, (short)offsetY);
		sw.writeBytes(out, NameUtils.toASCIIBytes(textureTop, 8));
		sw.writeBytes(out, NameUtils.toASCIIBytes(textureBottom, 8));
		sw.writeBytes(out, NameUtils.toASCIIBytes(textureMiddle, 8));
		sw.writeShort(out, (short)sectorIndex);
	}

	@Override
	public String toString()
	{
		StringBuilder sb = new StringBuilder();
		sb.append("Sidedef");
		sb.append(' ').append("Offset (").append(offsetX).append(", ").append(offsetY).append(")");
		sb.append(' ').append(String.format("%-8s %-8s %-8s", textureTop, textureBottom, textureMiddle));
		sb.append(' ').append("Sector ").append(sectorIndex);
		return sb.toString();
	}
	
}
