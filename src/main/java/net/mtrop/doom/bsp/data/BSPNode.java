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
 * This contains the BSP tree information for a single 28-byte node in the tree.
 * @author Matthew Tropiano
 */
public class BSPNode implements BinaryObject
{
	/** Byte length of this object. */
	public static final int LENGTH = 28;

	/** Leaf node value. */
	public static final int LEAF_NODE_INDEX = 0xffff8000;
	
	/** This node's partition line's X-coordinate. */
	protected int partitionLineX;
	/** This node's partition line's Y-coordinate. */
	protected int partitionLineY;
	/** This node's partition line's change in X to the end of the line. */
	protected int partitionDeltaX;
	/** This node's partition line's change in Y to the end of the line. */
	protected int partitionDeltaY;
	/** This node's right bounding box coordinates. */
	protected int[] rightRect;
	/** This node's left bounding box coordinates. */
	protected int[] leftRect;

	/** This node's right child index or subsector index. */
	protected int rightSubsectorIndex;
	/** This node's left child index or subsector index. */
	protected int leftSubsectorIndex;

	/**
	 * Creates a new BSP Node.
	 */
	public BSPNode()
	{
		partitionLineX = 0;
		partitionLineY = 0;
		partitionDeltaX = 0;
		partitionDeltaY = 0;
		rightRect = new int[4];
		leftRect = new int[4];
		rightSubsectorIndex = 0;
		leftSubsectorIndex = 0;
	}

	/** @return this node's partition line's X-coordinate. */
	public int getPartitionLineX()
	{
		return partitionLineX;
	}

	/** 
	 * Sets this node's partition line's X-coordinate. 
	 * @param val the new partition line x-coordinate.
	 * @throws IllegalArgumentException if the value is outside the range -32768 to 32767. 
	 */
	public void setPartitionLineX(int val)
	{
		RangeUtils.checkShort("Partition Line X", partitionLineX);
		partitionLineX = val;
	}

	/** @return this node's partition line's Y-coordinate. */
	public int getPartitionLineY()
	{
		return partitionLineY;
	}

	/** 
	 * Sets this node's partition line's Y-coordinate. 
	 * @param val the new partition line y-coordinate.
	 * @throws IllegalArgumentException if the value is outside the range -32768 to 32767. 
	 */
	public void setPartitionLineY(int val)
	{
		RangeUtils.checkShort("Partition Line Y", partitionLineY);
		partitionLineY = val;
	}

	/** @return this node's partition line's change in X to the end of the line. */
	public int getPartitionDeltaX()
	{
		return partitionDeltaX;
	}

	/** 
	 * Sets this node's partition line's change in X to the end of the line. 
	 * @param val the new partition line delta X.
	 * @throws IllegalArgumentException if the value is outside the range -32768 to 32767. 
	 */
	public void setPartitionDeltaX(int val)
	{
		RangeUtils.checkShort("Partition Delta X", partitionDeltaX);
		partitionDeltaX = val;
	}

	/** @return this node's partition line's change in Y to the end of the line. */
	public int getPartitionDeltaY()
	{
		return partitionDeltaY;
	}

	/** 
	 * Sets this node's partition line's change in Y to the end of the line. 
	 * @param val the new partition line delta Y.
	 * @throws IllegalArgumentException if the value is outside the range -32768 to 32767. 
	 */
	public void setPartitionDeltaY(int val)
	{
		RangeUtils.checkShort("Partition Delta Y", partitionDeltaY);
		partitionDeltaY = val;
	}

	/**
	 * @return this node's right bounding box coordinates (top, bottom, left, right).
	 */
	public int[] getRightRect()
	{
		return rightRect;
	}

	/**
	 * Sets this node's right bounding box coordinates (top, bottom, left, right).
	 * @param top the top of the box.
	 * @param bottom the bottom of the box.
	 * @param left the left side of the box.
	 * @param right the right side of the box.
	 * @throws IllegalArgumentException if any of the values are outside the range -32768 to 32767. 
	 */
	public void setRightRect(int top, int bottom, int left, int right)
	{
		RangeUtils.checkShort("Right Box Top", rightRect[0]);
		RangeUtils.checkShort("Right Box Bottom", rightRect[1]);
		RangeUtils.checkShort("Right Box Left", rightRect[2]);
		RangeUtils.checkShort("Right Box Right", rightRect[3]);
		rightRect[0] = top;
		rightRect[1] = bottom;
		rightRect[2] = left;
		rightRect[3] = right;
	}

	/**
	 * @return this node's left bounding box coordinates (top, bottom, left, right).
	 */
	public int[] getLeftRect()
	{
		return leftRect;
	}

	/**
	 * Sets this node's left bounding box coordinates (top, bottom, left, right).
	 * @param top the top of the box.
	 * @param bottom the bottom of the box.
	 * @param left the left side of the box.
	 * @param right the right side of the box.
	 * @throws IllegalArgumentException if any of the values are outside the range -32768 to 32767. 
	 */
	public void setLeftRect(int top, int bottom, int left, int right)
	{
		RangeUtils.checkShort("Left Box Top", leftRect[0]);
		RangeUtils.checkShort("Left Box Bottom", leftRect[1]);
		RangeUtils.checkShort("Left Box Left", leftRect[2]);
		RangeUtils.checkShort("Left Box Right", leftRect[3]);
		leftRect[0] = top;
		leftRect[1] = bottom;
		leftRect[2] = left;
		leftRect[3] = right;
	}

	/** 
	 * @return true, if this node's right node is a leaf, false if not. 
	 */
	public boolean getRightChildIsLeaf()
	{
		return rightSubsectorIndex == LEAF_NODE_INDEX;
	}

	/** 
	 * @return this node's right subsector index. 
	 */
	public int getRightSubsectorIndex()
	{
		return rightSubsectorIndex;
	}

	/** 
	 * Sets this node's right subsector index. 
	 * @param val the new right subsector index.
	 * @throws IllegalArgumentException if the value is outside the range 0 to 32767, or isn't {@link BSPNode#LEAF_NODE_INDEX}. 
	 */
	public void setRightSubsectorIndex(int val)
	{
		if (val == LEAF_NODE_INDEX)
			rightSubsectorIndex = val;
		else
		{
			RangeUtils.checkRange("Right Subsector Index", 0, 32767, rightSubsectorIndex);
			rightSubsectorIndex = val;
		}
	}

	/** 
	 * @return this node's left subsector index. 
	 */
	public int getLeftSubsectorIndex()
	{
		return leftSubsectorIndex;
	}

	/** 
	 * @return true, if this node's left node is a leaf, false if not.  
	 */
	public boolean getLeftChildIsLeaf()
	{
		return leftSubsectorIndex == LEAF_NODE_INDEX;
	}

	/** 
	 * Sets this node's left subsector index. 
	 * @param val the new left subsector index.
	 * @throws IllegalArgumentException if the value is outside the range 0 to 32767, or isn't {@link BSPNode#LEAF_NODE_INDEX}. 
	 */
	public void setLeftSubsectorIndex(int val)
	{
		if (val == LEAF_NODE_INDEX)
			leftSubsectorIndex = val;
		else
		{
			RangeUtils.checkRange("Left Subsector Index", 0, 32767, leftSubsectorIndex);
			leftSubsectorIndex = val;
		}
	}

	@Override
	public void readBytes(InputStream in) throws IOException
	{
		SerialReader sr = new SerialReader(SerialReader.LITTLE_ENDIAN);
		partitionLineX = sr.readShort(in);
		partitionLineY = sr.readShort(in);
		partitionDeltaX = sr.readShort(in);
		partitionDeltaY = sr.readShort(in);
		for (int i = 0; i < 4; i++)
			rightRect[i] = sr.readShort(in);
		for (int i = 0; i < 4; i++)
			leftRect[i] = sr.readShort(in);
		rightSubsectorIndex = sr.readShort(in);
		leftSubsectorIndex = sr.readShort(in);
	}

	@Override
	public void writeBytes(OutputStream out) throws IOException
	{
		SerialWriter sw = new SerialWriter(SerialWriter.LITTLE_ENDIAN);
		sw.writeShort(out, (short)partitionLineX);
		sw.writeShort(out, (short)partitionLineY);
		sw.writeShort(out, (short)partitionDeltaX);
		sw.writeShort(out, (short)partitionDeltaY);
		for (int i = 0; i < 4; i++)
			sw.writeShort(out, (short)rightRect[i]);
		for (int i = 0; i < 4; i++)
			sw.writeShort(out, (short)leftRect[i]);
		sw.writeShort(out, (short)rightSubsectorIndex);
		sw.writeShort(out, (short)leftSubsectorIndex);
	}

}
