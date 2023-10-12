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

/**
 * Doom/Boom/MBF 10-byte format implementation of Thing.
 * @author Matthew Tropiano
 */
public class DoomThing extends CommonThing implements BinaryObject
{
	/** Byte length of this object. */
	public static final int LENGTH = 10;
	
	/**
	 * Creates a new thing.
	 */
	public DoomThing()
	{
		super();
	}

	@Override
	public void readBytes(InputStream in) throws IOException
	{
		SerialReader sr = new SerialReader(SerialReader.LITTLE_ENDIAN);
		x = sr.readShort(in);
		y = sr.readShort(in);
		angle = sr.readUnsignedShort(in);
		type = sr.readUnsignedShort(in);
		flags = sr.readUnsignedShort(in);
	}

	@Override
	public void writeBytes(OutputStream out) throws IOException
	{
		SerialWriter sw = new SerialWriter(SerialWriter.LITTLE_ENDIAN);
		sw.writeShort(out, (short)x);
		sw.writeShort(out, (short)y);
		sw.writeShort(out, (short)angle);
		sw.writeShort(out, (short)type);
		sw.writeUnsignedShort(out, flags & 0x0FFFF);		
	}
	
	@Override
	public String toString()
	{
		StringBuilder sb = new StringBuilder();
		sb.append("Thing");
		sb.append(" (").append(x).append(", ").append(y).append(")");
		sb.append(" Type:").append(type);
		sb.append(" Angle:").append(angle);
		sb.append(' ').append("Flags 0x").append(String.format("%016x", flags & 0x0FFFF));
		return sb.toString();
	}

}
