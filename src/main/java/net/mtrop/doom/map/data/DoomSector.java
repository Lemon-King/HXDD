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
 * Doom/Boom 26-byte format implementation of Sector.
 * @author Matthew Tropiano
 */
public class DoomSector implements BinaryObject
{
	/** Byte length of this object. */
	public static final int LENGTH = 26;

	/** Sector Floor height. */
	protected int heightFloor;
	/** Sector Ceiling height. */
	protected int heightCeiling;
	/** Sector Floor texture. */
	protected String textureFloor;
	/** Sector Ceiling texture. */
	protected String textureCeiling;
	/** Sector light level. */
	protected int lightLevel;
	/** Sector special. */
	protected int special;
	/** Sector tag. */
	protected int tag;
	
	/**
	 * Creates a new sector.
	 */
	public DoomSector()
	{
		this.heightFloor = 0;
		this.heightCeiling = 0;
		this.textureFloor = MapObjectConstants.TEXTURE_BLANK;
		this.textureCeiling = MapObjectConstants.TEXTURE_BLANK;
		this.lightLevel = 0;
		this.special = 0;
		this.tag = 0;
	}
	
	/**
	 * Sets this sector's floor height. 
	 * @param heightFloor the new height.
	 * @throws IllegalArgumentException if floorHeight is outside of the range -32768 to 32767.
	 * @since 2.9.0, naming convention change.
	 */
	public void setHeightFloor(int heightFloor)
	{
		RangeUtils.checkShort("Floor Height", heightFloor);
		this.heightFloor = heightFloor;
	}

	/**
	 * @return the sector's floor height.
	 * @since 2.9.0, naming convention change.
	 */
	public int getHeightFloor()
	{
		return heightFloor;
	}

	/**
	 * Sets the sector's ceiling height. 
	 * @param heightCeiling the new height.
	 * @throws IllegalArgumentException if floorHeight is outside of the range -32768 to 32767.
	 * @since 2.9.0, naming convention change.
	 */
	public void setHeightCeiling(int heightCeiling)
	{
		RangeUtils.checkShort("Ceiling Height", heightCeiling);
		this.heightCeiling = heightCeiling;
	}

	/**
	 * @return the sector's ceiling height.
	 * @since 2.9.0, naming convention change.
	 */
	public int getHeightCeiling()
	{
		return heightCeiling;
	}

	/**
	 * Sets the sector's floor texture.
	 * @param textureFloor the new texture.
	 * @throws IllegalArgumentException if the texture name is invalid. 
	 */
	public void setTextureFloor(String textureFloor)
	{
		NameUtils.checkValidTextureName(textureFloor);
		this.textureFloor = textureFloor;
	}

	/**
	 * @return the sector's floor texture.
	 */
	public String getTextureFloor()
	{
		return textureFloor;
	}

	/**
	 * Sets the sector's ceiling texture. 
	 * @param textureCeiling the new texture.
	 * @throws IllegalArgumentException if the texture name is invalid. 
	 */
	public void setTextureCeiling(String textureCeiling)
	{
		NameUtils.checkValidTextureName(textureCeiling);
		this.textureCeiling = textureCeiling;
	}

	/**
	 * @return the sector's ceiling texture. 
	 */
	public String getTextureCeiling()
	{
		return textureCeiling;
	}

	/**
	 * Sets the sector's light level. 
	 * @param lightLevel the new light level.
	 * @throws IllegalArgumentException if lightLevel is outside the range -32768 to 32767.
	 */
	public void setLightLevel(int lightLevel)
	{
		RangeUtils.checkShort("Light Level", lightLevel);
		this.lightLevel = lightLevel;
	}
	
	/**
	 * @return the sector's light level.
	 */
	public int getLightLevel()
	{
		return lightLevel;
	}

	/**
	 * Sets the sector's special. 
	 * @param special the new special number.
	 * @throws IllegalArgumentException if special is outside the range -32768 to 32767.
	 */
	public void setSpecial(int special)
	{
		RangeUtils.checkShort("Special", special);
		this.special = special;
	}
	
	/**
	 * @return the sector's special. 
	 */
	public int getSpecial()
	{
		return special;
	}

	/**
	 * Sets the sector's tag. 
	 * @param tag the new tag.
	 * @throws IllegalArgumentException if tag is outside the range -32768 to 32767.
	 */
	public void setTag(int tag)
	{
		RangeUtils.checkShort("Tag", tag);
		this.tag = tag;
	}
	
	/**
	 * @return the sector's tag.
	 */
	public int getTag()
	{
		return tag;
	}

	@Override
	public void readBytes(InputStream in) throws IOException
	{
		SerialReader sr = new SerialReader(SerialReader.LITTLE_ENDIAN);
		heightFloor = sr.readShort(in);
		heightCeiling = sr.readShort(in);
		textureFloor = NameUtils.nullTrim(sr.readString(in, 8, "ASCII"));
		textureCeiling = NameUtils.nullTrim(sr.readString(in, 8, "ASCII"));
		lightLevel = sr.readShort(in);
		special = sr.readShort(in);
		tag = sr.readShort(in);
	}

	@Override
	public void writeBytes(OutputStream out) throws IOException
	{
		SerialWriter sw = new SerialWriter(SerialWriter.LITTLE_ENDIAN);
		sw.writeShort(out, (short)heightFloor);
		sw.writeShort(out, (short)heightCeiling);
		sw.writeBytes(out, NameUtils.toASCIIBytes(textureFloor, 8));
		sw.writeBytes(out, NameUtils.toASCIIBytes(textureCeiling, 8));
		sw.writeShort(out, (short)lightLevel);
		sw.writeShort(out, (short)special);
		sw.writeShort(out, (short)tag);
	}

	@Override
	public String toString()
	{
		StringBuilder sb = new StringBuilder();
		sb.append("Sector");
		sb.append(' ').append("Ceiling ").append(heightCeiling).append(" Floor ").append(heightFloor);
		sb.append(' ').append(String.format("%-8s %-8s", textureCeiling, textureFloor));
		sb.append(' ').append("Light ").append(lightLevel);
		sb.append(' ').append("Special ").append(special);
		sb.append(' ').append("Tag ").append(tag);
		return sb.toString();
	}

}
