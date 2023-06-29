/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.map;

import java.util.ArrayList;
import java.util.List;

/**
 * Common map implementation.
 * @param <V> the class type for vertices.
 * @param <L> the class type for linedefs.
 * @param <S> the class type for sidedefs.
 * @param <E> the class type for sectors.
 * @param <T> the class type for things.
 * @author Matthew Tropiano
 */
abstract class CommonMap<V, L, S, E, T> implements MapView<V, L, S, E, T>
{
	/** List of Vertices. */
	private List<V> vertices;
	/** List of Linedefs. */
	private List<L> linedefs;
	/** List of Sidedefs. */
	private List<S> sidedefs;
	/** List of Sectors. */
	private List<E> sectors;
	/** List of Things. */
	private List<T> things;

	/**
	 * Creates a blank map.
	 */
	public CommonMap()
	{
		this.vertices = new ArrayList<V>(2048);
		this.linedefs = new ArrayList<L>(1024);
		this.sidedefs = new ArrayList<S>(2048);
		this.sectors = new ArrayList<E>(256);
		this.things = new ArrayList<T>(256);
	}

	/**
	 * Clears the contents of this map.
	 */
	public void clear()
	{
		vertices.clear();
		linedefs.clear();
		sidedefs.clear();
		sectors.clear();
		things.clear();
	}
	
	/**
	 * @return the underlying list of vertices.
	 */
	public List<V> getVertices()
	{
		return vertices;
	}

	/**
	 * Replaces the list of vertices in the map.
	 * Input objects are copied to the underlying list.
	 * @param vertices the new list of vertices.
	 */
	public void setVertices(Iterable<V> vertices)
	{
		this.vertices.clear();
		for (V obj : vertices)
			this.vertices.add(obj);
	}

	/**
	 * Adds a vertex to this map.
	 * @param vertex the vertex to add.
	 */
	public void addVertex(V vertex)
	{
		vertices.add(vertex);
	}

	@Override
	public int getVertexCount()
	{
		return vertices.size();
	}
	
	@Override
	public V getVertex(int i)
	{
		return vertices.get(i);
	}
	
	/**
	 * @return the underlying list of linedefs.
	 */
	public List<L> getLinedefs()
	{
		return linedefs;
	}

	/**
	 * Replaces the list of linedefs in the map.
	 * Input objects are copied to the underlying list.
	 * @param linedefs the new list of linedefs.
	 */
	public void setLinedefs(Iterable<L> linedefs)
	{
		this.linedefs.clear();
		for (L obj : linedefs)
			this.linedefs.add(obj);
	}

	/**
	 * Adds a linedef to this map.
	 * @param linedef the linedef to add.
	 */
	public void addLinedef(L linedef)
	{
		linedefs.add(linedef);
	}

	@Override
	public L getLinedef(int i)
	{
		return linedefs.get(i);
	}
	
	@Override
	public int getLinedefCount()
	{
		return linedefs.size();
	}
	
	/**
	 * @return the underlying list of sidedefs.
	 */
	public List<S> getSidedefs()
	{
		return sidedefs;
	}

	/**
	 * Replaces the list of sidedefs in the map.
	 * Input objects are copied to the underlying list.
	 * @param sidedefs the new list of sidedefs.
	 */
	public void setSidedefs(Iterable<S> sidedefs)
	{
		this.sidedefs.clear();
		for (S obj : sidedefs)
			this.sidedefs.add(obj);
	}

	/**
	 * Adds a sidedef to this map.
	 * @param sidedef the sidedef to add.
	 */
	public void addSidedef(S sidedef)
	{
		sidedefs.add(sidedef);
	}

	@Override
	public S getSidedef(int i)
	{
		return sidedefs.get(i);
	}
	
	@Override
	public int getSidedefCount()
	{
		return sidedefs.size();
	}
	
	/**
	 * @return the underlying list of sectors.
	 */
	public List<E> getSectors()
	{
		return sectors;
	}

	/**
	 * Replaces the list of sectors in the map.
	 * Input objects are copied to the underlying list.
	 * @param sectors the new list of sectors.
	 */
	public void setSectors(Iterable<E> sectors)
	{
		this.sectors.clear();
		for (E obj : sectors)
			this.sectors.add(obj);
	}

	/**
	 * Adds a sector to this map.
	 * @param sector the sector to add.
	 */
	public void addSector(E sector)
	{
		sectors.add(sector);
	}

	@Override
	public E getSector(int i)
	{
		return sectors.get(i);
	}
	
	@Override
	public int getSectorCount()
	{
		return sectors.size();
	}
	
	/**
	 * @return the underlying list of things.
	 */
	public List<T> getThings()
	{
		return things;
	}

	/**
	 * Sets the things on this map. 
	 * Input objects are copied to the underlying list.
	 * @param things the new list of things.
	 */
	public void setThings(Iterable<T> things)
	{
		this.things.clear();
		for (T obj : things)
			this.things.add(obj);
	}

	/**
	 * Adds a thing to this map.
	 * @param thing the thing to add.
	 */
	public void addThing(T thing)
	{
		things.add(thing);
	}

	@Override
	public T getThing(int i)
	{
		return things.get(i);
	}
	
	@Override
	public int getThingCount()
	{
		return things.size();
	}
	
}
