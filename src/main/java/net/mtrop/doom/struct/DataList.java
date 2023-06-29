/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.struct;

import java.util.Arrays;

/**
 * A mutable buffer of data. 
 * @author Matthew Tropiano
 */
public class DataList
{
	/** Default capacity for a new list. */
	public static final int DEFAULT_CAPACITY = 10;
	
	/** Capacity increment. */
	private int capacityIncrement;
	/** Amount of bytes in the buffer. */
	private int size;
	/** Byte array. */
	private byte[] buffer;

	/**
	 * Makes a new volatile list.
	 */
	public DataList()
	{
		this(DEFAULT_CAPACITY);
	}
	
	/**
	 * Makes a new buffer that doubles every resize.
	 * @param capacity the initial capacity of this list. If 0 or less, it is 1. 
	 */
	public DataList(int capacity)
	{
		this(capacity,0);
	}
	
	/**
	 * Makes a new buffer.
	 * @param capacity the initial capacity of this list.
	 * @param capacityInc what to increase the capacity of this list by if this reaches the max. if 0 or less, it will double.
	 */
	public DataList(int capacity, int capacityInc)
	{
		setCapacityIncrement(capacityInc);
		setCapacity(capacity);
	}
	
	/**
	 * Gets a byte of data from this buffer.
	 * @param index the byte index.
	 * @return a byte array of the requested data.
	 * @throws ArrayIndexOutOfBoundsException if index exceeds or meets size.
	 */
	public byte getData(int index)
	{
		return buffer[index];
	}
	
	/**
	 * Gets a subset of data from this buffer.
	 * @param offset the offset into the vector.
	 * @param length the length of data in bytes to copy.
	 * @return a byte array of the requested data.
	 * @throws IndexOutOfBoundsException if offset plus length exceeds size.
	 */
	public byte[] getData(int offset, int length)
	{
		byte[] out = new byte[length];
		if (offset + length > size)
			throw new IndexOutOfBoundsException("Offset + length exceeds size.");
		System.arraycopy(buffer, offset, out, 0, length);
		return out;
	}
	
	/**
	 * Gets a subset of data from this buffer.
	 * @param offset the offset into the vector.
	 * @param out the target array to copy into.
	 * @throws IndexOutOfBoundsException if offset plus length exceeds size.
	 */
	public void getData(int offset, byte[] out)
	{
		getData(offset, out, 0, out.length);
	}
	
	/**
	 * Gets a subset of data from this buffer.
	 * @param offset the offset into the vector.
	 * @param out the target array to copy into.
	 * @param outOffset the offset into the output buffer.
	 * @param length the amount of bytes to copy.
	 * @throws IndexOutOfBoundsException if offset plus length exceeds size.
	 */
	public void getData(int offset, byte[] out, int outOffset, int length)
	{
		if (offset + out.length > size || outOffset + length > out.length)
			throw new IndexOutOfBoundsException("Offset + out.length exceeds size.");
		System.arraycopy(buffer, offset, out, outOffset, length);
	}
	
	/**
	 * Sets a subset of data in this buffer.
	 * @param offset the offset into the vector.
	 * @param data the data to overwrite with.
	 * @throws IndexOutOfBoundsException if offset plus length exceeds size.
	 */
	public void setData(int offset, byte[] data)
	{
		capacityCheck(offset + data.length);
		System.arraycopy(data, 0, buffer, offset, data.length);
	}
	
	/**
	 * Gets the capacity of this buffer.
	 * @return the current capacity in bytes.
	 */
	public int getCapacity()
	{
		return buffer.length;
	}
	
	/**
	 * Sets this buffer's capacity to some value. If this buffer is set to a capacity
	 * that is less than the current one, it will cut the buffer short. If the
	 * capacity argument is 0 or less, it is set to 1.
	 * @param capacity the new capacity of this buffer.
	 */
	public void setCapacity(int capacity)
	{
		if (capacity < 1)
			capacity = 1;
		byte[] newbuffer = new byte[capacity];
		if (buffer != null)
		{
			System.arraycopy(buffer, 0, newbuffer, 0, Math.min(newbuffer.length, buffer.length));
			if (newbuffer.length < buffer.length && newbuffer.length < size)
				size = newbuffer.length;
		}
		else
			size = 0;
		buffer = newbuffer;
	}
	
	/**
	 * Returns the capacity increment value.
	 * @return the current capacity increment.
	 */
	public int getCapacityIncrement()
	{
		return capacityIncrement;
	}
	
	/**
	 * Sets the capacity increment value.
	 * @param capacityInc what to increase the capacity of this list by if this reaches the max. if 0 or less, it will double.
	 */
	public void setCapacityIncrement(int capacityInc)
	{
		capacityIncrement = capacityInc;
	}
	
	/**
	 * @return the amount of bytes in the buffer.
	 */
	public int size()
	{
		return size;
	}
	
	public boolean isEmpty() 
	{
		return size() == 0;
	}
	
	/**
	 * Appends a byte to the end of this buffer.
	 * @param b	the byte to add.
	 * @return this buffer, so that these commands can be chained.
	 */
	public DataList append(byte b)
	{
		capacityCheck(1);
		buffer[size++] = b;
		return this;
	}
	
	/**
	 * Appends a series of bytes to the end of this buffer.
	 * @param b	the bytes to add.
	 * @return this buffer, so that these commands can be chained.
	 */
	public DataList append(byte[] b)
	{
		return append(b, 0, b.length);
	}
	
	/**
	 * Appends a series of bytes to the end of this buffer.
	 * @param b	the bytes to add.
	 * @param offset the offset into the array to start the copy.
	 * @param length the amount of bytes to copy from the source array into the buffer.
	 * @return this buffer, so that these commands can be chained.
	 */
	public DataList append(byte[] b, int offset, int length)
	{
		capacityCheck(length);
		System.arraycopy(b, offset, buffer, size, length);
		size += length;
		return this;
	}
	
	/**
	 * Inserts a series of bytes into this buffer at a specific index.
	 * @param b	the bytes to add.
	 * @param startIndex the starting index into the buffer for removing bytes.
	 * @return this buffer, so that these commands can be chained.
	 */
	public DataList insertAt(byte[] b, int startIndex)
	{
		if (startIndex > size)
			throw new ArrayIndexOutOfBoundsException("Index is greater than size, "+size+".");
		capacityCheck(b.length);
		System.arraycopy(buffer, startIndex, buffer, startIndex + b.length, size - startIndex);
		System.arraycopy(b, 0, buffer, startIndex, b.length);
		size += b.length;
		return this;
	}
	
	/**
	 * Deletes a series of bytes from this buffer.
	 * @param startIndex the starting index into the buffer for removing bytes.
	 * @param length the amount of bytes to copy from the source array into the buffer.
	 * @return this buffer, so that these commands can be chained.
	 */
	public DataList delete(int startIndex, int length)
	{
		System.arraycopy(buffer, startIndex + length, buffer, startIndex, size - (startIndex + length));
		size -= length;
		return this;
	}
	
	/**
	 * Deletes all bytes from this buffer.
	 * @return this buffer, so that these commands can be chained.
	 */
	public DataList clear()
	{
		return delete(0,size);
	}
	
	/**
	 * Increases the size of the internal buffer if necessary.
	 * @param additionalLength the additional length that needs to be contained in the buffer.
	 */
	protected void capacityCheck(int additionalLength)
	{
		while (size + additionalLength > buffer.length)
			setCapacity(buffer.length + (capacityIncrement <= 0 ? buffer.length : capacityIncrement));
	}
	
	/**
	 * Returns the bytes in this vector into an array.
	 * @return a new array with this list's data.
	 */
	public byte[] toByteArray()
	{
		byte[] out = new byte[size];
		System.arraycopy(buffer, 0, out, 0, size);
		return out;
	}
	
	@Override
	public String toString()
	{
		return Arrays.toString(buffer);
	}
	
}
