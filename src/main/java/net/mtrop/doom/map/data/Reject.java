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
 * Represents the Reject lump.
 * <p>
 * The reject lump is a lookup grid that hold information on what sectors can
 * "see" other sectors on the map used for thing sight algorithms. 
 * @author Matthew Tropiano
 */
public class Reject implements BinaryObject
{
	private static final byte[] BITMASK = {0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, (byte)0x80};
	
	/** The reject grid itself. */
	private boolean[][] grid;
	
	/**
	 * Creates a new blank reject grid.
	 * @param sectors the number of sectors.
	 */
	public Reject(int sectors)
	{
		grid = new boolean[sectors][sectors];
	}
	
	/**
	 * Checks whether a sector is visible from another.
	 * @param sectorIndex the sector index viewing from.
	 * @param targetSectorIndex the sector index viewing into.
	 * @return true if so, false if not.
	 */
	public boolean getSectorIsVisibleTo(int sectorIndex, int targetSectorIndex)
	{
		return grid[targetSectorIndex][sectorIndex];
	}
	
	/**
	 * Sets whether a sector is visible from another.
	 * @param sectorIndex the sector index viewing from.
	 * @param targetSectorIndex the sector index viewing into.
	 * @param flag true if visible, false if not.
	 */
	public void setSectorIsVisibleTo(int sectorIndex, int targetSectorIndex, boolean flag)
	{
		grid[targetSectorIndex][sectorIndex] = flag;
	}
	
	@Override
	public void readBytes(InputStream in) throws IOException
	{
		SerialReader sr = new SerialReader(SerialReader.LITTLE_ENDIAN);

		byte curByte = 0;
		int bit = 0;
		
		for (int i = 0; i < grid.length; i++)
			for (int j = 0; j < grid[i].length && in.available() > 0; j++)
			{
				if (bit == 8)
				{
					curByte = sr.readByte(in);
					bit = 0;
				}
				grid[i][j] = (curByte & BITMASK[bit]) != 0;
				bit++;
			}
	}

	@Override
	public void writeBytes(OutputStream out) throws IOException
	{
		SerialWriter sw = new SerialWriter(SerialWriter.LITTLE_ENDIAN);
		byte curByte = 0;
		int bit = 0;
		
		for (int i = 0; i < grid.length; i++)
			for (int j = 0; j < grid[i].length; j++)
			{
				if (grid[i][j])
					curByte &= (byte)(0x01 << bit);
				bit++;
				if (bit == 8)
				{
					sw.writeByte(out, curByte);
					bit = 0;
				}
			}
		if (bit != 0)
			sw.writeByte(out, curByte);
	}

}
