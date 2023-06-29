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
 * 4-byte BSP Subsector information that lists all of the BSP segment indices for a sector.
 * These are essentially the mappings of Nodes to other nodes.
 * @author Matthew Tropiano
 */
public class BSPSubsector implements BinaryObject
{
	/** Byte length of this object. */
	public static final int LENGTH = 4;

	/** This Subsector's BSP Segment count. */
	protected int segCount;
	/** This Subsector's starting segment index. */
	protected int segStartIndex;

	/**
	 * Creates a new BSP Subsector.
	 */
	public BSPSubsector()
	{
		segCount = 0;
		segStartIndex = -1;
	}
	
	/**
	 * @return the amount of BSPSegments pointed to by this subsector.
	 */
	public int getSegCount()
	{
		return segCount;
	}

	/**
	 * Sets the amount of BSPSegments pointed to by this subsector.
	 * @param segCount the amount of segments.
	 * @throws IllegalArgumentException if the provided value is outside the range 0 to 65535.
	 */
	public void setSegCount(int segCount)
	{
		RangeUtils.checkShortUnsigned("Segment Count", segCount);
		this.segCount = segCount;
	}

	/**
	 * @return the starting offset index of this subsector's BSPSegments in the Segs lump.
	 */
	public int getSegStartIndex()
	{
		return segStartIndex;
	}

	/**
	 * Sets the starting offset index of this subsector's BSPSegments in the Segs lump.
	 * @param segStartIndex the starting index.
	 * @throws IllegalArgumentException if the provided value is outside the range 0 to 65535.
	 */
	public void setSegStartIndex(int segStartIndex)
	{
		RangeUtils.checkShortUnsigned("Segment Start Index", segStartIndex);
		this.segStartIndex = segStartIndex;
	}

	@Override
	public void readBytes(InputStream in) throws IOException
	{
		SerialReader sr = new SerialReader(SerialReader.LITTLE_ENDIAN);
		segCount = sr.readUnsignedShort(in);
		segStartIndex = sr.readUnsignedShort(in);
	}

	@Override
	public void writeBytes(OutputStream out) throws IOException
	{
		SerialWriter sw = new SerialWriter(SerialWriter.LITTLE_ENDIAN);
		sw.writeUnsignedShort(out, segCount);
		sw.writeUnsignedShort(out, segStartIndex);
	}

}
