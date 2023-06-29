/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.map;

/**
 * Interface for looking into Doom maps.
 * @author Matthew Tropiano
 * @param <V> the class type for vertices.
 * @param <L> the class type for linedefs.
 * @param <S> the class type for sidedefs.
 * @param <E> the class type for sectors.
 * @param <T> the class type for things.
 */
public interface MapView<V, L, S, E, T>
{
	/**
	 * Gets the vertex at a specific index.
	 * @param i the desired index.
	 * @return the vertex at the index, or null if the index is out of range.
	 */
	public V getVertex(int i);

	/**
	 * @return the amount of vertices in this map.
	 */
	public int getVertexCount();

	/**
	 * Gets the linedef at a specific index.
	 * @param i the desired index.
	 * @return the linedef at the index, or null if the index is out of range.
	 */
	public L getLinedef(int i);

	/**
	 * @return the amount of linedefs in this map.
	 */
	public int getLinedefCount();

	/**
	 * Gets the sidedef at a specific index.
	 * @param i the desired index.
	 * @return the sidedef at the index, or null if the index is out of range.
	 */
	public S getSidedef(int i);

	/**
	 * @return the amount of sidedefs in this map.
	 */
	public int getSidedefCount();

	/**
	 * Gets the sector at a specific index.
	 * @param i the desired index.
	 * @return the sector at the index, or null if the index is out of range.
	 */
	public E getSector(int i);

	/**
	 * @return the amount of sectors in this map.
	 */
	public int getSectorCount();

	/**
	 * Gets the thing at a specific index.
	 * @param i the desired index.
	 * @return the thing at the index, or null if the index is out of range.
	 */
	public T getThing(int i);

	/**
	 * @return the amount of things in this map.
	 */
	public int getThingCount();

}
