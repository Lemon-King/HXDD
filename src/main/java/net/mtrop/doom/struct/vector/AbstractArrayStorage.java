/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.struct.vector;

/**
 * This class contains the base for all data structures 
 * that make use of a contiguous memory structure.
 * @author Matthew Tropiano
 * @param <T> the value type that this contains.
 */
public abstract class AbstractArrayStorage<T extends Object>
{
	/** Default capacity for a new array. */
	public static final int DEFAULT_CAPACITY = 8;
	
	/** Underlying object array. */
	protected Object[] storageArray;

	/**
	 * Initializes the array with the default storage capacity.
	 */
	protected AbstractArrayStorage()
	{
		this(DEFAULT_CAPACITY);
	}

	/**
	 * Initializes the array with a particular storage capacity.
	 * @param capacity the desired capacity.
	 */
	protected AbstractArrayStorage(int capacity)
	{
		storageArray = new Object[capacity];
	}
	
	/**
	 * Gets data at a particular index in the array.
	 * @param index the desired index.
	 * @return the data at a particular index in the array.
	 * @throws ArrayIndexOutOfBoundsException if the index falls outside of the array bounds.
	 */
	@SuppressWarnings("unchecked")
	protected T get(int index)
	{
		return (T)storageArray[index];
	}
	
	/**
	 * Sets the data at a particular index in the array.
	 * @param index the desired index.
	 * @param object the object to set.
	 * @throws ArrayIndexOutOfBoundsException if the index falls outside of the array bounds.
	 */
	protected void set(int index, T object)
	{
		storageArray[index] = object;
	}
	
}