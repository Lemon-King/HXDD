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

import net.mtrop.doom.object.BinaryObject;
import net.mtrop.doom.struct.io.SerialReader;
import net.mtrop.doom.struct.io.SerialWriter;
import net.mtrop.doom.util.RangeUtils;

/**
 * Doom/Boom 14-byte format implementation of Linedef.
 * @author Matthew Tropiano
 */
public class DoomLinedef extends CommonLinedef implements BinaryObject
{
	/** Byte length of this object. */
	public static final int LENGTH = 14;

	/** Linedef special tag. */
	protected int tag;

	/**
	 * Creates a new linedef.
	 */
	public DoomLinedef()
	{
		super();
		this.tag = 0;
	}

	/**
	 * Sets this linedef's special tag.
	 * @param tag the new tag.
	 */
	public void setTag(int tag)
	{
		RangeUtils.checkShortUnsigned("Tag", tag);
		this.tag = tag;
	}

	/**
	 * @return this linedef's special tag.
	 */
	public int getTag()
	{
		return tag;
	}

	@Override
	public void readBytes(InputStream in) throws IOException
	{
		SerialReader sr = new SerialReader(SerialReader.LITTLE_ENDIAN);
		vertexStartIndex = sr.readUnsignedShort(in);
		vertexEndIndex = sr.readUnsignedShort(in);
		flags = sr.readUnsignedShort(in);
		special = sr.readUnsignedShort(in);
		tag = sr.readUnsignedShort(in);
		sidedefFrontIndex = sr.readShort(in);
		sidedefBackIndex = sr.readShort(in);
	}

	@Override
	public void writeBytes(OutputStream out) throws IOException 
	{
		SerialWriter sw = new SerialWriter(SerialWriter.LITTLE_ENDIAN);
		sw.writeUnsignedShort(out, vertexStartIndex);
		sw.writeUnsignedShort(out, vertexEndIndex);
		sw.writeUnsignedShort(out, flags & 0x0FFFF);
		sw.writeUnsignedShort(out, special);
		sw.writeUnsignedShort(out, tag);
		sw.writeShort(out, (short)sidedefFrontIndex);
		sw.writeShort(out, (short)sidedefBackIndex);
	}
	
	@Override
	public String toString()
	{
		StringBuilder sb = new StringBuilder();
		sb.append("Linedef");
		sb.append(' ').append(vertexStartIndex).append(" to ").append(vertexEndIndex);
		sb.append(' ').append("Front Sidedef ").append(sidedefFrontIndex);
		sb.append(' ').append("Back Sidedef ").append(sidedefBackIndex);
		sb.append(' ').append("Flags 0x").append(String.format("%016x", flags & 0x0FFFF));
		sb.append(' ').append("Special ").append(special);
		sb.append(' ').append("Tag ").append(tag);
		return sb.toString();
	}
	
}
