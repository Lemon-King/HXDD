/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.bsp.data;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import net.mtrop.doom.object.BinaryObject;
import net.mtrop.doom.struct.io.SerialReader;
import net.mtrop.doom.struct.io.SerialWriter;
import net.mtrop.doom.util.RangeUtils;

/**
 * 12-byte BSP Segment information for a BSP tree in Doom.
 * @author Matthew Tropiano
 */
public class BSPSegment implements BinaryObject
{
	/** Byte length of this object. */
	public static final int LENGTH = 12;

	/** Direction along linedef (same). */
	public final static int DIRECTION_SAME_AS_LINEDEF = 0;
	/** Direction along linedef (opposite). */
	public final static int DIRECTION_OPPOSITE_LINEDEF = 1;

	/** Binary angle. */
	public final static int ANGLE_EAST = 0;
	/** Binary angle. */
	public final static int ANGLE_NORTH = 16384;
	/** Binary angle. */
	public final static int ANGLE_SOUTH = -16384;
	/** Binary angle. */
	public final static int ANGLE_WEST = -32768;

	/** This Seg's start vertex index reference. */
	protected int vertexStartIndex;
	/** This Seg's end vertex index reference. */
	protected int vertexEndIndex;
	/** This Seg's angle. */
	protected int angle;
	/** This Seg's linedef index. */
	protected int linedefIndex;
	/** This Seg's direction. */
	protected int direction;
	/** This Seg's offset along linedef. */
	protected int offset;

	/**
	 * Creates a new BSP Segment.
	 */
	public BSPSegment()
	{
		vertexStartIndex = -1;
		vertexEndIndex = -1;
		angle = 0;
		linedefIndex = -1;
		direction = DIRECTION_SAME_AS_LINEDEF;
		offset = 0;
	}

	/** 
	 * @return this Seg's start vertex index reference. 
	 */
	public int getVertexStartIndex()
	{
		return vertexStartIndex;
	}

	/** 
	 * Sets this Seg's start vertex index reference. 
	 * @param val the new starting vertex reference. 
	 * @throws IllegalArgumentException if the provided value is outside the range 0 to 65535.
	 */
	public void setVertexStartIndex(int val)
	{
		RangeUtils.checkShort("Vertex Start Index", vertexStartIndex);
		vertexStartIndex = val;
	}

	/** 
	 * @return this Seg's end vertex index reference. 
	 */
	public int getVertexEndIndex()
	{
		return vertexEndIndex;
	}

	/** 
	 * Sets this Seg's end vertex index reference. 
	 * @param val the new ending vertex reference. 
	 * @throws IllegalArgumentException if the provided value is outside the range 0 to 65535.
	 */
	public void setVertexEndIndex(int val)
	{
		RangeUtils.checkShort("Vertex End Index", vertexEndIndex);
		vertexEndIndex = val;
	}

	/** 
	 * @return this Seg's angle in degrees. 
	 */
	public int getAngle()
	{
		return angle;
	}

	/** 
	 * Sets this Seg's binary angle. 
	 * @param val the new binary angle. 
	 * @throws IllegalArgumentException if the provided value is outside the range -32768 to 32767.
	 */
	public void setAngle(int val)
	{
		RangeUtils.checkShort("Angle", angle);
		angle = val;
	}

	/** 
	 * @return this Seg's linedef index. 
	 */
	public int getLinedefIndex()
	{
		return linedefIndex;
	}

	/** 
	 * Sets this Seg's linedef index. 
	 * @param val the new linedef index. 
	 * @throws IllegalArgumentException if the provided value is outside the range -32768 to 32767.
	 */
	public void setLinedefIndex(int val)
	{
		RangeUtils.checkShort("Linedef Index", linedefIndex);
		linedefIndex = val;
	}

	/** 
	 * @return this Seg's direction. 
	 */
	public int getDirection()
	{
		return direction;
	}

	/** 
	 * Sets this Seg's directionality. 
	 * @param val the new directionality. 
	 * @throws IllegalArgumentException if the provided value is neither {@link BSPSegment#DIRECTION_OPPOSITE_LINEDEF} to {@link BSPSegment#DIRECTION_SAME_AS_LINEDEF}.
	 */
	public void setDirection(int val)
	{
		RangeUtils.checkRange("Direction", DIRECTION_SAME_AS_LINEDEF, DIRECTION_OPPOSITE_LINEDEF, direction);
		direction = val;
	}

	/** 
	 * @return this Seg's linedef offset. 
	 */
	public int getOffset()
	{
		return offset;
	}

	/** 
	 * Sets this Seg's linedef offset (distance along line until start of seg). 
	 * @param val the linedef offset. 
	 * @throws IllegalArgumentException if the provided value is outside the range 0 to 65535.
	 */
	public void setOffset(int val)
	{
		RangeUtils.checkShort("Offset", offset);
		offset = val;
	}

	@Override
	public void readBytes(InputStream in) throws IOException
	{
		SerialReader sr = new SerialReader(SerialReader.LITTLE_ENDIAN);
		vertexStartIndex = sr.readUnsignedShort(in);
		vertexEndIndex = sr.readUnsignedShort(in);
		angle = sr.readUnsignedShort(in);
		linedefIndex = sr.readUnsignedShort(in);
		direction = sr.readUnsignedShort(in);
		offset = sr.readUnsignedShort(in);
	}

	@Override
	public void writeBytes(OutputStream out) throws IOException
	{
		SerialWriter sw = new SerialWriter(SerialWriter.LITTLE_ENDIAN);
		sw.writeUnsignedShort(out, vertexStartIndex);
		sw.writeUnsignedShort(out, vertexEndIndex);
		sw.writeUnsignedShort(out, angle);
		sw.writeUnsignedShort(out, linedefIndex);
		sw.writeUnsignedShort(out, direction);
		sw.writeUnsignedShort(out, offset);
	}

}
