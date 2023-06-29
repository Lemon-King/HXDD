/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.struct.vector;

import java.util.Comparator;
import java.util.HashMap;
import java.util.Map;

/**
 * A special type of vector that also as a one-to-one mapping of an object to
 * an index. Changes to the indices of the stored objects trigger re-mappings
 * of the objects that shift positions.
 * <p>
 * Map lookups are by hash, so they are O(c), c = longest chain in map. O(c) &lt; O(n);
 * @author Matthew Tropiano
 * @param <T> the type of Object that this vector contains.
 * @param <K> the mapped key type that this vector uses to map one object to an index.
 * 		The key is assumed to be unique.
 */
public abstract class AbstractMappedVector<T extends Object, K extends Object> extends AbstractVector<T>
{
	/** The key map. */
	protected Map<K, Integer> indexMap;
	
	/**
	 * Makes a new mapped vector.
	 */
	public AbstractMappedVector()
	{
		this(DEFAULT_CAPACITY);
	}
	
	/**
	 * Makes a new mapped vector that doubles every resize.
	 * @param capacity the initial capacity of this vector. If 0 or less, it is 1. 
	 */
	public AbstractMappedVector(int capacity)
	{
		this(capacity, 0);
	}
	
	/**
	 * Makes a new mapped vector.
	 * @param capacity the initial capacity of this vector.
	 * @param capacityIncrement what to increase the capacity of this vector by 
	 * if this reaches the max. if 0 or less, it will double.
	 */
	public AbstractMappedVector(int capacity, int capacityIncrement)
	{
		this(capacity, capacityIncrement, true);
	}
	
	/**
	 * Makes a new mapped vector.
	 * @param capacity the initial capacity of this vector.
	 * @param capacityIncrement what to increase the capacity of this vector by 
	 * if this reaches the max. if 0 or less, it will double.
	 * @param constructMap if true, this all create the underlying map.
	 * 		Extenders of this class that want to change the nature of the hash map
	 * 		should call this with false, so that the map isn't created twice.
	 */
	protected AbstractMappedVector(int capacity, int capacityIncrement, boolean constructMap)
	{
		super(capacity, capacityIncrement);
		indexMap = new HashMap<K, Integer>();
	}
	
	/**
	 * Returns the mapping value to use for mapping an object.
	 * @param object the object to get a mapping key from.
	 * @return a key to use to associate with this object.
	 */
	protected abstract K getMappingKey(T object);

	/**
	 * Re-maps a single object to its index.
	 * @param startIndex the starting index to start the remap (inclusive).
	 * @param endIndex the ending index to start the remap (exclusive).
	 */
	private void reMap(int index)
	{
		K key = getMappingKey(get(index));
		indexMap.remove(key);
		indexMap.put(key, index);
	}
	
	/**
	 * Re-maps objects to indices.
	 * @param startIndex the starting index to start the remap (inclusive).
	 * @param endIndex the ending index to start the remap (exclusive).
	 */
	private void reMap(int startIndex, int endIndex)
	{
		for (int i = startIndex; i >= 0 && i < size() && i < endIndex; i++)
			reMap(i);
	}
	
	/**
	 * Retrieves an object in this mapping using a key. 
	 * @param key the key to use.
	 * @return the corresponding index, or -1 if not found.
	 */
	public int getIndexUsingKey(K key)
	{
		Integer i = indexMap.get(key);
		return i != null ? i : -1;
	}
	
	/**
	 * Retrieves an object in this mapping using a key. 
	 * @param key the key to use.
	 * @return the corresponding index, or -1 if not found.
	 */
	public boolean containsKey(K key)
	{
		return getIndexUsingKey(key) >= 0;
	}
	
	/**
	 * Retrieves an object in this mapping that corresponds to a particular key.
	 * @param key the key to use.
	 * @return the corresponding object, or null if not found.
	 */
	public T getUsingKey(K key)
	{
		int i = getIndexUsingKey(key);
		return i >= 0 ? get(i) : null;
	}
	
	/**
	 * Removes an object in this mapping that corresponds to a particular key.
	 * @param key the key to use.
	 * @return the removed object, or null if not found.
	 */
	public T removeUsingKey(K key)
	{
		int i = getIndexUsingKey(key);
		return i >= 0 ? removeIndex(i) : null;
	}
	
	@Override
	public void add(int index, T object)
	{
		super.add(index, object);
		reMap(index > size() - 1 ? size() - 1 : index, size());
	}
	
	@Override
	public T removeIndex(int index)
	{
		T out = super.removeIndex(index);
		if (out != null)
		{
			indexMap.remove(getMappingKey(out));
			reMap(index, size());
		}
		return out;
	}

	@Override
	public void sort()
	{
		super.sort();
		reMap(0, size());
	}

	@Override
	public void sort(Comparator<? super T> comp)
	{
		super.sort(comp);
		reMap(0, size());
	}

	@Override
	public void sort(int startIndex, int endIndex)
	{
		super.sort(startIndex, endIndex);
		reMap(startIndex, endIndex);
	}

	@Override
	public void sort(Comparator<? super T> comp, int startIndex, int endIndex)
	{
		super.sort(comp, startIndex, endIndex);
		reMap(startIndex, endIndex);
	}

	@Override
	public void swap(int index0, int index1)
	{
		super.swap(index0, index1);
		reMap(index0);
		reMap(index1);
	}

	@Override
	public void shift(int sourceIndex, int targetIndex)
	{
		super.shift(sourceIndex, targetIndex);
		if (targetIndex < sourceIndex)
			reMap(targetIndex, sourceIndex + 1);
		else if (targetIndex > sourceIndex)
			reMap(sourceIndex, targetIndex + 1);
	}

}