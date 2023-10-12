/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.struct.map;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import net.mtrop.doom.struct.Sizable;

/**
 * This is a grid that contains a grid of Object data generally used for maps and lookups.
 * This map is <i>sparse</i>, which means it uses as little memory as possible, which can increase the lookup time in most cases.
 * @author Matthew Tropiano
 * @param <T> the value type.
 */
public class SparseGridIndex<T extends Object> implements Iterable<Map.Entry<SparseGridIndex.Pair, T>>, Sizable
{
	private static final ThreadLocal<Pair> CACHEPAIR = ThreadLocal.withInitial(()->new Pair());

	/** List of grid codes. */
	protected HashMap<Pair, T> data;
	
	/**
	 * Creates a new sparse grid of an unspecified width and height.
	 * @throws IllegalArgumentException if capacity is negative or ratio is 0 or less.
	 */
	public SparseGridIndex()
	{
		data = new HashMap<Pair, T>();
	}
	
	/**
	 * Clears everything from the grid.
	 */
	public void clear()
	{
		data.clear();
	}

	/**
	 * Sets an object at a particular part of the grid.
	 * @param x	the grid position x to set info.
	 * @param y	the grid position y to set info.
	 * @param object the object to set. Can be null.
	 */
	public void set(int x, int y, T object)
	{
		Pair tempPair = CACHEPAIR.get();
		tempPair.x = x;
		tempPair.y = y;
		if (object == null)
			data.remove(tempPair);
		else
			data.put(new Pair(x, y), object);
	}

	/**
	 * Gets the object at a particular part of the grid.
	 * @param x	the grid position x to get info.
	 * @param y	the grid position y to get info.
	 * @return the object at that set of coordinates or null if not object.
	 */
	public T get(int x, int y)
	{
		Pair tempPair = CACHEPAIR.get();
		tempPair.x = x;
		tempPair.y = y;
		return data.get(tempPair);
	}
	
	@Override
	public String toString()
	{
		return data.toString();
	}

	@Override
	public Iterator<Map.Entry<Pair, T>> iterator()
	{
		return data.entrySet().iterator();
	}

	@Override
	public int size()
	{
		return data.size();
	}

	@Override
	public boolean isEmpty()
	{
		return size() == 0;
	}
	
	/**
	 * Ordered Pair integer object. 
	 */
	public static class Pair
	{
		/** X-coordinate. */
		private int x;
		/** Y-coordinate. */
		private int y;
		
		/**
		 * Creates a new Pair (0,0).
		 */
		private Pair()
		{
			this(0, 0);
		}
		
		/**
		 * Creates a new Pair.
		 * @param x the x-coordinate value.
		 * @param y the y-coordinate value.
		 */
		private Pair(int x, int y)
		{
			this.x = x;
			this.y = y;
		}
		
		public int getX()
		{
			return x;
		}
		
		public int getY()
		{
			return y;
		}
		
		@Override
		public int hashCode()
		{
			return x ^ ~y;
		}
		
		@Override
		public boolean equals(Object obj)
		{
			if (obj instanceof Pair)
				return equals((Pair)obj);
			else
				return super.equals(obj);
		}
		
		/**
		 * Checks if this pair equals another.
		 * @param p the other pair.
		 * @return true if so, false if not.
		 */
		public boolean equals(Pair p)
		{
			return x == p.x && y == p.y;
		}

		@Override
		public String toString()
		{
			return "(" + x + ", " + y + ")";
		}
		
	}
	
}