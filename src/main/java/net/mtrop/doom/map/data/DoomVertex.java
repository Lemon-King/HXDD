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
 * The 4-byte representation of a vertex.
 * @author Matthew Tropiano
 */
public class DoomVertex implements BinaryObject
{
	/** Byte length of this object. */
	public static final int LENGTH = 4;

	/** Vertex: X-coordinate. */
	private int x;
	/** Vertex: X-coordinate. */
	private int y;
	
	/**
	 * Creates a new vertex with default values set.
	 */
	public DoomVertex()
	{
		this.x = 0;
		this.y = 0;
	}

	/**
	 * Sets the coordinates of this vertex.
	 * @param x the new x-coordinate value.
	 * @param y the new y-coordinate value.
	 */
	public void set(int x, int y)
	{
		setX(x);
		setY(y);
	}
	
	/**
	 * @return the X-coordinate value of this vertex.
	 */
	public int getX()
	{
		return x;
	}

	/**
	 * Sets the X-coordinate value of this vertex.
	 * @param x the new x-coordinate value.
	 * @throws IllegalArgumentException if x is outside of the range -32768 to 32767.
	 */
	public void setX(int x)
	{
		RangeUtils.checkShort("X-coordinate", x);
		this.x = x;
	}
	
	/**
	 * @return the Y-coordinate value of this vertex.
	 */
	public int getY()
	{
		return y;
	}

	/**
	 * Sets the Y-coordinate value of this vertex.
	 * @param y the new y-coordinate value.
	 * @throws IllegalArgumentException if y is outside of the range -32768 to 32767.
	 */
	public void setY(int y)
	{
		RangeUtils.checkShort("Y-coordinate", y);
		this.y = y;
	}
	
	@Override
	public void readBytes(InputStream in) throws IOException
	{
		SerialReader sr = new SerialReader(SerialReader.LITTLE_ENDIAN);
		x = sr.readShort(in);
		y = sr.readShort(in);
	}

	@Override
	public void writeBytes(OutputStream out) throws IOException
	{
		RangeUtils.checkShort("X-coordinate", x);
		RangeUtils.checkShort("Y-coordinate", y);

		SerialWriter sw = new SerialWriter(SerialWriter.LITTLE_ENDIAN);
		sw.writeShort(out, (short)x);
		sw.writeShort(out, (short)y);
	}

	@Override
	public String toString()
	{
		return "Vertex (" + x + ", " + y + ")";
	}
	
}
