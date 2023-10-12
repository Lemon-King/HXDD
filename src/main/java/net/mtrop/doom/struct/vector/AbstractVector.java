/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.struct.vector;

import java.util.Arrays;
import java.util.Comparator;
import java.util.Iterator;

import net.mtrop.doom.struct.Sizable;

/**
 * An abstract class for performing unsynchronized Vector (data structure)
 * operatons and concepts. None of the methods are synchronized, so be careful
 * when using this in a multithreaded setting or extend this class with synchronized
 * methods.
 * @param <T> the underlying object type.
 * @author Matthew Tropiano
 */
public abstract class AbstractVector<T extends Object> extends AbstractArrayStorage<T> implements Iterable<T>, Sizable
{
	/** Capacity increment. */
	protected int capacityIncrement;
	/** Amount of objects in the storageArray. */
	protected int size;

	/**
	 * Makes a new vector.
	 */
	public AbstractVector()
	{
		this(DEFAULT_CAPACITY);
	}
	
	/**
	 * Makes a new vector that doubles every resize.
	 * @param capacity the initial capacity of this vector. If 0 or less, it is 1. 
	 */
	public AbstractVector(int capacity)
	{
		this(capacity, 0);
	}
	
	/**
	 * Makes a new vector.
	 * @param capacity the initial capacity of this vector.
	 * @param capacityIncrement what to increase the capacity of this vector by 
	 * if this reaches the max. if 0 or less, it will double.
	 */
	public AbstractVector(int capacity, int capacityIncrement)
	{
		if (capacity <= 0)
			capacity = 1;
		setCapacityIncrement(capacityIncrement);
		setCapacity(capacity);
	}

	/**
	 * Clears the vector.
	 */
	public void clear()
	{
		if (isEmpty()) 
			return;
		shallowClear();
		Arrays.fill(storageArray, null);
	}

	/**
	 * Clears the vector shallowly - removes no references and just sets the current size to 0.
	 * This can be prone to holding references in memory longer than necessary, so know what
	 * you are doing if you need to care about garbage collecting. 
	 */
	public void shallowClear()
	{
		if (isEmpty()) 
			return;
		size = 0;
	}

	/**
	 * Gets the capacity of this vector (size before it resizes itself).
	 * @return the current capacity.
	 */
	public int getCapacity()
	{
		return storageArray.length;
	}

	/**
	 * Sets this storageArray's capacity to some value. If this vector is set to a capacity
	 * that is less than the current one, it will cut the vector short. If the
	 * capacity argument is 0 or less, it is set to 1.
	 * @param capacity the new capacity of this vector.
	 */
	public void setCapacity(int capacity)
	{
		if (capacity < 1)
			capacity = 1;
		Object[] newList = new Object[capacity];
		if (storageArray != null)
			System.arraycopy(storageArray, 0, newList, 0, Math.min(newList.length, storageArray.length));
		if (newList.length < storageArray.length && newList.length < size)
			size = newList.length;
		storageArray = newList;
	}

	/**
	 * Sets this vector's capacity to its current size.
	 * If this vector's size is 0, it will be cleared and have its capacity set to 1,
	 * since you cannot have a vector with a capacity of less than 1. 
	 * @see #clear()
	 * @see #setCapacity(int)
	 * @see #size()
	 */
	public void trim()
	{
		if (isEmpty())
		{
			clear();
			setCapacity(1);
		}
		else
		{
			setCapacity(size());
		}
	}
	
	/**
	 * @return the capacity increment value.
	 * @see #setCapacityIncrement(int)
	 */
	public int getCapacityIncrement()
	{
		return capacityIncrement;
	}

	/**
	 * Sets the capacity increment value.
	 * @param capacityIncrement	what to increase the capacity of this vector by 
	 * if this reaches the max. if 0 or less, it will double.
	 */
	public void setCapacityIncrement(int capacityIncrement)
	{
		this.capacityIncrement = capacityIncrement;
	}

	/**
	 * Gets an object at an index in the vector.
	 * @param index the desired index.
	 * @return null if index is out of vector bounds.
	 */
	public T get(int index)
	{
		if (index < 0 || index >= size)
			return null;
		return super.get(index);
	}

	/**
	 * Adds an object to the end of the vector.
	 * @param object the object to add.
	 */
	public void add(T object)
	{
		add(size,object);
	}

	/**
	 * Adds an object at an index. 
	 * If index is greater than or equal to the size, it will add it at the end.
	 * If index is less than 0, it won't add it.
	 * @param index the index to add this at.
	 * @param object the object to add.
	 */
	public void add(int index, T object)
	{
		if (index < 0)
			return;
		if (index > size)
			index = size;
		if (size == storageArray.length)
			setCapacity(getCapacity()+(capacityIncrement <= 0 ? getCapacity() : capacityIncrement));
		if (storageArray[index] != null)
			System.arraycopy(storageArray, index, storageArray, index+1, size - index);
		set(index, object);
		size++;
	}

	/**
	 * Sets an object at an index. Used for replacing contents.
	 * If index is greater than or equal to the size, it will add it at the end.
	 * If index is less than 0, this does nothing.
	 * @param index the index to set this at.
	 * @param object the object to add.
	 */
	public void replace(int index, T object)
	{
		if (index < 0)
			return;
		if (index >= size)
			add(object);
		else
			set(index, object);
	}

	/**
	 * Removes an object from the vector, if it exists in the vector.
	 * Sequential search.
	 * @param object the object to search for and remove.
	 * @return true if removed, false if not in the vector.
	 * @throws NullPointerException if object is null.
	 */
	public boolean remove(T object)
	{
		int i = getIndexOf(object);
		if (i < 0)
			return false;
		return removeIndex(i) != null;
	}

	/**
	 * Removes an object from an index in the vector and shifts 
	 * everything after it down an index position.
	 * @param index the target index.
	 * @return null if the index is out of bounds or the object at that index.
	 */
	@SuppressWarnings("unchecked")
	public T removeIndex(int index)
	{
		if (index < 0 || index >= size)
			return null;
		T out = (T)storageArray[index];
		if (index+1 < size)
			System.arraycopy(storageArray, index+1, storageArray, index, size-index-1);
		size--;
		storageArray[size] = null;
		return out;
	}

	/**
	 * Checks if an object exists in this vector.
	 * Implementation may dictate how the object is searched.
	 * @param object the object to look for.
	 * @return true if an equal object exists, or false if not.
	 * @see #getIndexOf(Object)
	 */
	public boolean contains(T object)
	{
		return getIndexOf(object) != -1;
	}
	
	/**
	 * Gets the index of an object, presumably in the vector.
	 * @param object the object to search for.
	 * @return the index of the object if it is in the vector, or -1 if it is not present.
	 * @throws NullPointerException if object is null.
	 */
	public int getIndexOf(T object)
	{
		for (int i = 0; i < size; i++)
			if (object.equals(storageArray[i]))
				return i;
		return -1;
	}

	/**
	 * Gets the index of an object, presumably in the vector via binary search.
	 * Expects the contents of this vector to be sorted.
	 * @param object the object to search for.
	 * @param comparator the comparator to use for comparison or equivalence.
	 * @return the index of the object if it is in the vector, or less than 0 if it is not present.
	 * If less than 0, it is equal to where it would be added in the array. Add 1 then negate.
	 * @throws NullPointerException if object or comparator is null.
	 */
	@SuppressWarnings("unchecked")
	public int search(T object, Comparator<? super T> comparator)
	{
		return Arrays.binarySearch((T[])storageArray, 0, size, object, comparator);
	}

	/**
	 * Returns an iterator for this vector.
	 */
	public VectorIterator iterator()
	{
		return new VectorIterator();
	}

	/**
	 * Sorts this vector using NATURAL ORDERING.
	 * Calls {@link Arrays#sort(Object[], int, int)} on the internal storage array.
	 */
	@SuppressWarnings("unchecked")
	public void sort()
	{
		Arrays.sort((T[])storageArray, 0, size);
	}

	/**
	 * Sorts this vector using a comparator.
	 * Calls {@link Arrays#sort(Object[], int, int, Comparator)} on the internal storage array, using the specified comparator.
	 * @param comparator the comparator to use.
	 */
	@SuppressWarnings("unchecked")
	public void sort(Comparator<? super T> comparator)
	{
		Arrays.sort((T[])storageArray, 0, size, comparator);
	}

	/**
	 * Sorts this vector using NATURAL ORDERING.
	 * Calls {@link Arrays#sort(Object[], int, int)} on the internal storage array.
	 * @param startIndex the starting index of the sort.
	 * @param endIndex the ending index of the sort, exclusive.
	 */
	@SuppressWarnings("unchecked")
	public void sort(int startIndex, int endIndex)
	{
		Arrays.sort((T[])storageArray, startIndex, endIndex);
	}

	/**
	 * Sorts this vector using a comparator.
	 * Calls {@link Arrays#sort(Object[], int, int, Comparator)} on the internal storage array, using the specified comparator.
	 * @param comparator the comparator to use.
	 * @param startIndex the starting index of the sort.
	 * @param endIndex the ending index of the sort, exclusive.
	 */
	@SuppressWarnings("unchecked")
	public void sort(Comparator<? super T> comparator, int startIndex, int endIndex)
	{
		Arrays.sort((T[])storageArray, startIndex, endIndex, comparator);
	}

	/**
	 * Swaps the contents of two indices in the vector.
	 * <p>If index0 is equal to index1, this does nothing.
	 * <p>If one index is outside the bounds of this vector 
	 * (less than 0 or greater than or equal to {@link #size()}),
	 * this throws an exception. 
	 * @param index0 the first index.
	 * @param index1 the second index.
	 * @throws IllegalArgumentException if one index is outside the bounds of this vector 
	 * (less than 0 or greater than or equal to {@link #size()}).
	 */
	public void swap(int index0, int index1)
	{
		if (index0 < 0 || index0 >= size)
			throw new IllegalArgumentException("index0 cannot be outside the range of this vector.");
		if (index1 < 0 || index1 >= size)
			throw new IllegalArgumentException("index1 cannot be outside the range of this vector.");
		
		if (index0 == index1)
			return;
		
		T obj = get(index0);
		set(index0, get(index1));
		set(index1, obj);
	}
	
	/**
	 * Moves the object at an index in this vector to another index,
	 * shifting the contents between the two selected indices in this vector back or forward.
	 * <p>If sourceIndex is equal to targetIndex, this does nothing.
	 * <p>If one index is outside the bounds of this vector 
	 * (less than 0 or greater than or equal to {@link #size()}),
	 * this throws an exception. 
	 * @param sourceIndex the first index.
	 * @param targetIndex the second index.
	 * @throws IllegalArgumentException if one index is outside the bounds of this vector 
	 * (less than 0 or greater than or equal to {@link #size()}).
	 */
	public void shift(int sourceIndex, int targetIndex)
	{
		if (sourceIndex < 0 || sourceIndex >= size)
			throw new IllegalArgumentException("sourceIndex cannot be outside the range of this vector.");
		if (targetIndex < 0 || targetIndex >= size)
			throw new IllegalArgumentException("index1 cannot be outside the range of this vector.");
		
		if (sourceIndex == targetIndex)
			return;

		T obj = get(sourceIndex);
		if (targetIndex < sourceIndex)
			System.arraycopy(storageArray, targetIndex, storageArray, targetIndex + 1, sourceIndex - targetIndex);
		else if (targetIndex > sourceIndex)
			System.arraycopy(storageArray, sourceIndex + 1, storageArray, sourceIndex, targetIndex - sourceIndex);
		set(targetIndex, obj);
	}
	
	/**
	 * Returns the amount of objects in the vector.
	 */
	public int size()
	{
		return size;
	}

	/**
	 * Returns true if there is nothing in this vector, false otherwise.
	 * Equivalent to <code>size() == 0</code>.
	 */
	public boolean isEmpty()
	{
		return size() == 0;
	}

	/**
	 * Dumps the contents of this structure to an array.
	 * The output array must accommodate the entirety of the data in this structure.
	 * @param out the output array.
	 */
	@SuppressWarnings("unchecked")
	public void toArray(T[] out)
	{
		System.arraycopy((T[])storageArray, 0, out, 0, size);
	}
	
	/**
	 * Returns this storageArray as a string.
	 */
	public String toString()
	{
		StringBuilder sb = new StringBuilder();
		sb.append('[');
		for (int i = 0; i < size; i++)
		{
			sb.append(storageArray[i].toString());
			if (i < size-1)
				sb.append(", ");
		}
		sb.append(']');
		return sb.toString();
	}

	/**
	 * Iterator class for this vector.
	 */
	public class VectorIterator implements Iterator<T>
	{
		private int currIndex;
		private boolean removeCalled;
		
		public VectorIterator()
		{
			reset();
		}
		
		public boolean hasNext()
		{
			return currIndex < size();
		}
	
		public T next()
		{
			removeCalled = false;
			return get(currIndex++);
		}
	
		public void remove()
		{
			if (removeCalled)
				throw new IllegalStateException("remove() called before next()");
			
			removeIndex(currIndex - 1);
			currIndex--;
			removeCalled = true;
		}

		/**
		 * Resets this iterator to the beginning.
		 */
		public void reset()
		{
			currIndex = 0;
			removeCalled = true;
		}
		
	}
	
}