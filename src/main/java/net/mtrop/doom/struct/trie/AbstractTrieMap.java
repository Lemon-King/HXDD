/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.struct.trie;

import java.util.List;
import java.util.Map;

/**
 * A trie is a data structure that maps an object to another object, using a path
 * of objects derived from the key. This structure is not thread-safe - wrap calls
 * with synchronized blocks if necessary.
 * @author Matthew Tropiano
 * @param <K> the key type.
 * @param <V> the value type that this holds.
 * @param <S> the type of the split segments used for searching.
 */
public abstract class AbstractTrieMap<K extends Object, V extends Object, S extends Object> extends AbstractTrie<Map.Entry<K, V>, S>
{
	/**
	 * Creates a new trie map.
	 */
	public AbstractTrieMap()
	{
		super();
	}

	@Override
	protected final S[] getSegments(Map.Entry<K, V> pair)
	{
		return getSegmentsForKey(pair.getKey());
	}

	/**
	 * Creates the segments necessary to find/store values with keys.
	 * This should always create the same segments for the same key.
	 * @param key the key to generate significant segments for.
	 * @return the list of segments for the key.
	 */
	protected abstract S[] getSegmentsForKey(K key);

	/**
	 * Associates a key to a value in this map.
	 * The policy of "put" is that if it an object already in the set, its value is replaced with the new value. 
	 * @param key the map key.
	 * @param value the corresponding value.
	 * @see #equalityMethodForKey(Object, Object)
	 */
	public void put(K key, V value)
	{
		super.add(new TrieMapEntry<>(key, value));
	}

	/**
	 * Checks if an object (by equality) is present in the structure.
	 * @param key the object to use for checking presence.
	 * @return true if it is in the map, false otherwise.
	 */
	public boolean containsKey(K key)
	{
		Result<Map.Entry<K, V>, S> out = searchByKey(key, false, false);
		return out.getFoundValue() != null;
	}

	/**
	 * Returns a value for the key provided.
	 * @param key the key.
	 * @return the corresponding value, or null if there is no value associated with that key.
	 */
	public V get(K key)
	{
		Result<Map.Entry<K, V>, S> out = searchByKey(key, false, false);
		return out.getFoundValue() != null ? out.getFoundValue().getValue() : null;
	}

	/**
	 * Returns all values in the order that they are found on the way through the Trie searching for a
	 * particular corresponding value. Result may include the value corresponding to the key.
	 * <p>The results are set in the output list provided by the user - an offset before
	 * the end of the list replaces, not adds!
	 * @param key the key to search for.
	 * @param out the output list.
	 * @return the amount of items returned into the list.
	 */
	public int getBeforeKey(K key, List<V> out)
	{
		return getBeforeKey(key, out, out.size());
	}
	
	/**
	 * Returns all values in the order that they are found on the way through the Trie searching for a
	 * particular corresponding value. Result may include the value corresponding to the key.
	 * <p>The results are set in the output list provided by the user - an offset before
	 * the end of the list replaces, not adds!
	 * @param key the key to search for.
	 * @param out the output list.
	 * @param startOffset the starting offset into the list to set values.
	 * @return the amount of items returned into the list.
	 */
	public int getBeforeKey(K key, List<V> out, int startOffset)
	{
		Result<Map.Entry<K, V>, S> result = searchByKey(key, true, false);
		int added = 0;
		for (Map.Entry<K, V> pair : result.getEncounteredValues())
		{
			int index = startOffset + (added++);
			if (index < out.size())
				out.set(index, pair.getValue());
			else
				out.add(pair.getValue());
		}
		return added;
	}
	
	/**
	 * Returns all values descending from the end of a search for a
	 * particular key. Result may include the value corresponding to the key. 
	 * <p>The values returned may not be returned in any consistent or stable order.
	 * <p>The results are added to the end of the list.
	 * @param key the key to search for.
	 * @param out the output list.
	 * @return the amount of items returned into the list.
	 */
	public int getAfterKey(K key, List<V> out)
	{
		return getAfterKey(key, out, out.size());
	}

	/**
	 * Returns all values descending from the end of a search for a
	 * particular value. Result may include the value corresponding to the key. 
	 * <p>The values returned may not be returned in any consistent or stable order.
	 * <p>The results are set in the output list provided by the user - an offset before
	 * the end of the list replaces, not adds!
	 * @param key the key to search for.
	 * @param out the output list.
	 * @param startOffset the starting offset into the list to set values.
	 * @return the amount of items returned into the list.
	 */
	public int getAfterKey(K key, List<V> out, int startOffset)
	{
		Result<Map.Entry<K, V>, S> result = searchByKey(key, false, true);
		int added = 0;
		for (Map.Entry<K, V> pair : result.getDescendantValues())
		{
			int index = startOffset + (added++);
			if (index < out.size())
				out.set(index, pair.getValue());
			else
				out.add(pair.getValue());
		}
		return added;
	}

	/**
	 * Returns the last-encountered value down a trie search.
	 * This is the remainder of the segments generated by the key from the last-matched
	 * segment.
	 * @param key the key to search for.
	 * @param out the output list.
	 * @return the last-encountered value.
	 */
	public V getWithRemainderByKey(K key, List<S> out)
	{
		return getWithRemainderByKey(key, out, 0);
	}

	/**
	 * Returns the last-encountered value down a trie search.
	 * This is the remainder of the segments generated by the key from the last-matched
	 * segment.
	 * @param key the key to search for.
	 * @param out the output list.
	 * @param startOffset the starting offset into the list to set values.
	 * @return the last-encountered value, or null if none encountered.
	 */
	public V getWithRemainderByKey(K key, List<S> out, int startOffset)
	{
		Result<Map.Entry<K, V>, S> result = searchByKey(key, true, false);
		
		if (result.getFoundValue() != null)
		{
			return result.getFoundValue().getValue();
		}
		else
		{
			for (int i = result.getMovesToLastEncounter(); i < result.getSegments().length; i++)
			{
				int index = startOffset + (i - result.getMovesToLastEncounter());
				if (index < out.size())
					out.set(index, result.getSegments()[i]);
				else
					out.add(result.getSegments()[i]);
			}
			
			if (!result.getEncounteredValues().isEmpty())
				return result.getEncounteredValues().get(result.getEncounteredValues().size() - 1).getValue();
			else
				return null;
		}
	}

	/**
	 * Returns all keys in the order that they are found on the way through the Trie searching for a
	 * particular matching key. Result may include the provided key.
	 * <p>The results are set in the output list provided by the user - an offset before
	 * the end of the list replaces, not adds!
	 * @param key the key to search for.
	 * @param out the output list.
	 * @return the amount of items returned into the list.
	 */
	public int getKeysBeforeKey(K key, List<K> out)
	{
		return getKeysBeforeKey(key, out, out.size());
	}

	/**
	 * Returns all keys in the order that they are found on the way through the Trie searching for a
	 * particular matching key. Result may include the the provided key.
	 * <p>The results are set in the output list provided by the user - an offset before
	 * the end of the list replaces, not adds!
	 * @param key the key to search for.
	 * @param out the output list.
	 * @param startOffset the starting offset into the list to set keys.
	 * @return the amount of items returned into the list.
	 */
	public int getKeysBeforeKey(K key, List<K> out, int startOffset)
	{
		Result<Map.Entry<K, V>, S> result = searchByKey(key, true, false);
		int added = 0;
		for (Map.Entry<K, V> pair : result.getEncounteredValues())
		{
			int index = startOffset + (added++);
			if (index < out.size())
				out.set(index, pair.getKey());
			else
				out.add(pair.getKey());
		}
		return added;
	}

	/**
	 * Returns all keys descending from the end of a search for a
	 * particular key. Result may include the provided key. 
	 * <p>The keys returned may not be returned in any consistent or stable order.
	 * <p>The results are added to the end of the list.
	 * @param key the key to search for.
	 * @param out the output list.
	 * @return the amount of items returned into the list.
	 */
	public int getKeysAfterKey(K key, List<K> out)
	{
		return getKeysAfterKey(key, out, out.size());
	}

	/**
	 * Returns all keys descending from the end of a search for a
	 * particular key. Result may include the provided key. 
	 * <p>The keys returned may not be returned in any consistent or stable order.
	 * <p>The results are set in the output list provided by the user - an offset before
	 * the end of the list replaces, not adds!
	 * @param key the key to search for.
	 * @param out the output list.
	 * @param startOffset the starting offset into the list to set keys.
	 * @return the amount of items returned into the list.
	 */
	public int getKeysAfterKey(K key, List<K> out, int startOffset)
	{
		Result<Map.Entry<K, V>, S> result = searchByKey(key, false, true);
		int added = 0;
		for (Map.Entry<K, V> pair : result.getDescendantValues())
		{
			int index = startOffset + (added++);
			if (index < out.size())
				out.set(index, pair.getKey());
			else
				out.add(pair.getKey());
		}
		return added;
	}

	/**
	 * Returns the last-encountered key down a trie search, plus
	 * the remainder of the segments generated by the key from the last-matched segment.
	 * @param key the key to search for.
	 * @param out the output list.
	 * @return the last-encountered value.
	 */
	public K getKeyWithRemainderByKey(K key, List<S> out)
	{
		return getKeyWithRemainderByKey(key, out, 0);
	}

	/**
	 * Returns the last-encountered key down a trie search, plus
	 * the remainder of the segments generated by the key from the last-matched segment.
	 * @param key the key to search for.
	 * @param out the output list.
	 * @param startOffset the starting offset into the list to set keys.
	 * @return the last-encountered value.
	 */
	public K getKeyWithRemainderByKey(K key, List<S> out, int startOffset)
	{
		Result<Map.Entry<K, V>, S> result = searchByKey(key, true, false);
		
		if (result.getFoundValue() != null)
		{
			return result.getFoundValue().getKey();
		}
		else
		{
			for (int i = result.getMovesToLastEncounter(); i < result.getSegments().length; i++)
			{
				int index = startOffset + (i - result.getMovesToLastEncounter());
				if (index < out.size())
					out.set(index, result.getSegments()[i]);
				else
					out.add(result.getSegments()[i]);
			}
			
			return result.getEncounteredValues().get(result.getEncounteredValues().size() - 1).getKey();
		}
	}

	/**
	 * Search using a key.
	 * @param key the key to search for.
	 * @param includeEncountered if true, include all visited nodes in the result.
	 * @param includeDescendants if true, include all descendants after the ending node in the result.
	 * @return the result of the search.
	 */
	protected Result<Map.Entry<K, V>, S> searchByKey(K key, boolean includeEncountered, boolean includeDescendants)
	{
		return search(new TrieMapEntry<>(key, null), includeEncountered, includeDescendants);
	}
	

	/**
	 * Removes a value from this map, corresponding to a key.
	 * @param key the key to use for checking presence.
	 * @return the corresponding value if it was removed from the map, null otherwise.
	 */
	public V removeEntry(K key)
	{
		Map.Entry<K, V> p = new TrieMapEntry<>(key, null);
		S[] segments = getSegments(p);
		if ((p = removeRecurse(p, root, segments, 0)) != null)
		{
			return p.getValue();
		}
		return null; 
	}

	/**
	 * Copies the keys of this map into an array.
	 * The order of the contents are not guaranteed unless otherwise noted.
	 * @param out the target array to copy the key objects into.
	 * @throws ArrayIndexOutOfBoundsException if the target array is too small to contain the objects.
	 * @see #toArray(Object[])
	 */
	public void toArrayKeys(K[] out)
	{
		int i = 0;
		for (Map.Entry<K, V> value : this)
			out[i++] = value.getKey();
	}
	
	/**
	 * Copies the values of this map into an array.
	 * Values are not distinct - if more than one value is in this map, it is added as well.
	 * The order of the contents are not guaranteed unless otherwise noted.
	 * @param out the target array to copy the key objects into.
	 * @throws ArrayIndexOutOfBoundsException if the target array is too small to contain the objects.
	 * @see #toArray(Object[])
	 */
	public void toArrayValues(V[] out)
	{
		int i = 0;
		for (Map.Entry<K, V> value : this)
			out[i++] = value.getValue();
	}
	
	@Override
	protected final boolean equalityMethod(Map.Entry<K, V> object1, Map.Entry<K, V> object2)
	{
		if (object1 == null)
			return object2 == null;
		else if (object2 == null)
			return false;
		else
			return equalityMethodForKey(object1.getKey(), object2.getKey());
	}

	/**
	 * Determines if two keys are equal. This can be implemented differently
	 * in case a map has a different concept of what keys are considered equal.
	 * @param key1 the first key.
	 * @param key2 the second key.
	 * @return true if the keys are considered equal, false otherwise.
	 */
	protected boolean equalityMethodForKey(K key1, K key2)
	{
		if (key1 == null)
			return key2 == null;
		else if (key2 == null)
			return false;
		else 
			return key1.equals(key2);
	}
	
	/**
	 * A single key-value pair.
	 * @param <K> key type.
	 * @param <V> value type.
	 */
	private static class TrieMapEntry<K, V> implements Map.Entry<K, V>
	{
		private K key;
		private V value;
		
		public TrieMapEntry(K key, V value)
		{
			this.key = key;
			this.value = value;
		}
		
		@Override
		public K getKey()
		{
			return key;
		}

		@Override
		public V getValue()
		{
			return value;
		}

		@Override
		public V setValue(V value)
		{
			V old = this.value;
			this.value = value;
			return old;
		}
		
	}
	
}

