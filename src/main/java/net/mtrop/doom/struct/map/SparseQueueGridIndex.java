/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.struct.map;

import java.util.Iterator;
import java.util.LinkedList;
import java.util.Queue;

/**
 * A sparse grid index that contains lists of objects.
 * Be advised that the {@link #get(int, int)} method may return null if no objects
 * are queued at that particular spot.
 * @author Matthew Tropiano
 * @param <T> the value type.
 */
public class SparseQueueGridIndex<T extends Object> extends SparseGridIndex<Queue<T>>
{
	/** Holds the true size of this grid map. */
	private int trueSize;
	
	/**
	 * Creates a new sparse queue grid of an unspecified width and height.
	 * @throws IllegalArgumentException if capacity is negative or ratio is 0 or less.
	 */
	public SparseQueueGridIndex()
	{
		super();
		trueSize = 0;
	}
	
	/**
	 * Enqueues an object at a particular grid coordinate.
	 * @param x the x-coordinate.
	 * @param y the y-coordinate.
	 * @param object the object to add.
	 */
	public void enqueue(int x, int y, T object)
	{
		if (object != null)
		{
			getQueue(x, y).add(object);
			trueSize++;
		}
	}
	
	/**
	 * Dequeues an object at a particular grid coordinate.
	 * @param x the x-coordinate.
	 * @param y the y-coordinate.
	 * @return the first object added at the set of coordinates, null if no objects enqueued.
	 */
	public T dequeue(int x, int y)
	{
		T out =  getQueue(x, y).poll();
		if (out != null)
			trueSize--;
		return out;
	}
	
	/**
	 * Dequeues an object at a particular grid coordinate.
	 * @param x the x-coordinate.
	 * @param y the y-coordinate.
	 * @param object the object to remove.
	 * @return the first object added at the set of coordinates, null if no objects enqueued.
	 */
	public boolean remove(int x, int y, T object)
	{
		boolean out =  getQueue(x, y).remove(object);
		if (out)
			trueSize--;
		return out;
	}
	
	/**
	 * Returns an iterator for a queue at a particular grid coordinate.
	 * @param x the x-coordinate.
	 * @param y the y-coordinate.
	 * @return a resettable iterator for the queue, or null if no queue exists.
	 */
	public Iterator<T> iterator(int x, int y)
	{
		return getQueue(x, y).iterator();
	}
	
	/**
	 * Returns a queue for a set of coordinates. If no queue exists, it is created.
	 * This should NEVER return null.
	 * @param x the x-coordinate.
	 * @param y the y-coordinate.
	 * @return a reference to the queue using the provided coordinates.
	 */
	protected Queue<T> getQueue(int x, int y)
	{
		Queue<T> out = get(x, y);
		if (out == null)
		{
			out = new LinkedList<T>();
			set(x, y, out);
		}
		return out;
	}
	
	@Override
	public void set(int x, int y, Queue<T> queue)
	{
		Queue<T> oldQueue = get(x, y);
		if (oldQueue != null)
			trueSize -= oldQueue.size();
		super.set(x, y, queue);
		if (queue != null)
			trueSize += queue.size();
	}
	
	@Override
	public void clear()
	{
		super.clear();
		trueSize = 0;
	}
	
	@Override
	public int size()
	{
		return trueSize;
	}
	
	@Override
	public boolean isEmpty() 
	{
		return size() == 0;
	}
	
}