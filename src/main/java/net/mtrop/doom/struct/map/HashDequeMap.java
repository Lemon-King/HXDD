/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.struct.map;

import java.util.Collection;
import java.util.Deque;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.NoSuchElementException;

/**
 * A hash map that stores deques of a particular type.
 * @author Matthew Tropiano
 * @param <K> the key type.
 * @param <V> the value type stored.
 */
public class HashDequeMap<K, V> extends HashMap<K, Deque<V>>
{
	private static final long serialVersionUID = -2338142686254656072L;
	
	/**
	 * Creates a new HashDequeMap that has default capacity and load factor.
	 */
	public HashDequeMap()
	{
		super();
	}

	/**
	 * Creates a new HashDequeMap that has a specific capacity and default load factor.
	 * @param initialCapacity the initial capacity.
	 */
	public HashDequeMap(int initialCapacity)
	{
		super(initialCapacity);
	}

	/**
	 * Creates a new HashDequeMap that has a specific capacity and default load factor.
	 * @param initialCapacity the initial capacity.
	 * @param loadFactor the load factor.
	 */
	public HashDequeMap(int initialCapacity, float loadFactor)
	{
		super(initialCapacity, loadFactor);
	}

	/**
	 * Called to create a new Deque implementation that gets stored in the table.
	 * By default, this calls <code>new LinkedList&lt;&gt;()</code>.
	 * @return a new deque.
	 */
	protected Deque<V> create()
	{
		return new LinkedList<>();
	}
	
	// Gets or creates a new deque. Used by "insert" logic.
	private Deque<V> getOrCreate(K key)
	{
		Deque<V> out;
		if ((out = get(key)) == null)
			put(key, out = create());
		return out;
	}
	
	/**
	 * Adds a value to the beginning of a deque. 
	 * If no corresponding deque, this creates a new deque.
	 * @param key the key.
	 * @param value the value.
	 * @see Deque#addFirst(Object)
 	 */
	public void addFirst(K key, V value)
	{
		getOrCreate(key).addFirst(value);
	}
	
	/**
	 * Adds a value to the end of a deque. 
	 * If no corresponding deque, this creates a new deque.
	 * @param key the key.
	 * @param value the value.
	 * @see Deque#addLast(Object)
 	 */
	public void addLast(K key, V value)
	{
		getOrCreate(key).addLast(value);
	}

	/**
	 * Removes a value from the beginning of a deque. 
	 * If no corresponding deque, this throws an exception.
	 * @param key the key.
	 * @return the element removed.
	 * @see Deque#removeFirst()
	 * @throws NoSuchElementException if the key does not correspond to an existing deque.
 	 */
	public V removeFirst(K key)
	{
		Deque<V> deque;
		if ((deque = get(key)) == null)
			throw new NoSuchElementException("key "+ key +"does not correspond to a Deque");
		V out = deque.removeFirst();
		if (deque.isEmpty())
			remove(key);
		return out;
	}

	/**
	 * Removes a value from the end of a deque. 
	 * If no corresponding deque, this throws an exception.
	 * @param key the key.
	 * @return the element removed.
	 * @see Deque#removeLast()
	 * @throws NoSuchElementException if the key does not correspond to an existing deque.
 	 */
	public V removeLast(K key)
	{
		Deque<V> deque;
		if ((deque = get(key)) == null)
			throw new NoSuchElementException("key "+ key +"does not correspond to a Deque");
		V out = deque.removeLast();
		if (deque.isEmpty())
			remove(key);
		return out;
	}

	/**
	 * Removes a value from the beginning of a deque. 
	 * If no corresponding deque, this returns null.
	 * @param key the key.
	 * @return the element removed, or null if no element.
	 * @see Deque#pollFirst()
 	 */
	public V pollFirst(K key)
	{
		Deque<V> deque;
		if ((deque = get(key)) == null)
			return null;
		V out = deque.pollFirst();
		if (deque.isEmpty())
			remove(key);
		return out;
	}

	/**
	 * Removes a value from the end of a deque. 
	 * If no corresponding deque, this returns null.
	 * @param key the key.
	 * @return the element removed, or null if no element.
	 * @see Deque#pollLast()
 	 */
	public V pollLast(K key)
	{
		Deque<V> deque;
		if ((deque = get(key)) == null)
			return null;
		V out = deque.pollLast();
		if (deque.isEmpty())
			remove(key);
		return out;
	}

	/**
	 * Returns the value at the beginning of a deque. 
	 * If no corresponding deque, this returns null.
	 * @param key the key.
	 * @return the element found, or null if no element.
	 * @see Deque#peekFirst()
 	 */
	public V peekFirst(K key)
	{
		Deque<V> deque;
		if ((deque = get(key)) == null)
			return null;
		return deque.peekFirst();
	}

	/**
	 * Returns the value at the end of a deque. 
	 * If no corresponding deque, this returns null.
	 * @param key the key.
	 * @return the element found, or null if no element.
	 * @see Deque#peekLast()
 	 */
	public V peekLast(K key)
	{
		Deque<V> deque;
		if ((deque = get(key)) == null)
			return null;
		return deque.peekLast();
	}

	/**
	 * Adds a value to the end of a deque. 
	 * If no corresponding deque, this creates a new deque.
	 * @param key the key.
	 * @param value the value.
	 * @return true (as specified by {@link Collection#add(Object)})
	 * @see Deque#add(Object)
	 */
	public boolean add(K key, V value)
	{
		return getOrCreate(key).add(value);
	}

	/**
	 * Removes a value from a deque. 
	 * If no corresponding deque, this returns false.
	 * @param key the key.
	 * @param value the value to remove.
	 * @see Deque#remove(Object)
	 * @return {@code true} if an element was removed as a result of this call
	 * @throws ClassCastException if the class of the specified element
	 *		 is incompatible with the deque
	 * (<a href="{@docRoot}/java.base/java/util/Collection.html#optional-restrictions">optional</a>)
	 * @throws NullPointerException if the specified element is null and this
	 *		 deque does not permit null elements
	 * (<a href="{@docRoot}/java.base/java/util/Collection.html#optional-restrictions">optional</a>)
	 */
	public boolean removeValue(K key, V value)
	{
		Deque<V> deque;
		if ((deque = get(key)) == null)
			throw new NoSuchElementException("key "+ key +"does not correspond to a Deque");
		boolean out = deque.remove(value);
		if (deque.isEmpty())
			remove(key);
		return out;
	}

	/**
	 * Removes a value from the front of a deque. 
	 * If no corresponding deque, this throws an exception.
	 * @param key the key.
	 * @see Deque#pop()
	 * @return the element removed.
	 * @throws NoSuchElementException if the key does not correspond to an existing deque.
 	 */
	public V pop(K key)
	{
		Deque<V> deque;
		if ((deque = get(key)) == null)
			throw new NoSuchElementException("key "+ key +"does not correspond to a Deque");
		V out = deque.pop();
		if (deque.isEmpty())
			remove(key);
		return out;
	}

	/**
	 * Removes a value from the front of a deque. 
	 * If no corresponding deque, this returns null.
	 * @param key the key.
	 * @see Deque#poll()
	 * @return the element removed, or null if no element.
 	 */
	public V poll(K key)
	{
		Deque<V> deque;
		if ((deque = get(key)) == null)
			return null;
		V out = deque.poll();
		if (deque.isEmpty())
			remove(key);
		return out;
	}

	/**
	 * Adds a value to the front of a deque. 
	 * If no corresponding deque, this creates it.
	 * @param key the key.
	 * @param value the value.
	 * @see Deque#push(Object)
 	 */
	public void push(K key, V value)
	{
		getOrCreate(key).push(value);
	}

}
