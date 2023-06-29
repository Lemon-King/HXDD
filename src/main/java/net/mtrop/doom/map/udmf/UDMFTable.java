/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.map.udmf;

import java.util.Deque;
import java.util.Map;

import net.mtrop.doom.struct.map.HashDequeMap;

/**
 * This holds a bunch of {@link UDMFObject}s for reading Doom information.
 * Also contains a structure for "global" fields in the UDMF, like "namespace".
 * @author Matthew Tropiano
 */
public class UDMFTable
{
	private static final UDMFObject[] EMPTY_OBJECT_LIST = new UDMFObject[0];
	
	/** Root fields table. */
	private UDMFObject globalFields;
	/** UDMF tables. */
	private HashDequeMap<String, UDMFObject> innerTable;
	
	/**
	 * Creates a new UDMFTable.
	 */
	public UDMFTable()
	{
		super();
		this.globalFields = new UDMFObject();
		this.innerTable = new HashDequeMap<>();
	}

	/**
	 * @return the root global fields structure.
	 */
	public UDMFObject getGlobalFields()
	{
		return globalFields;
	}
	
	/**
	 * Returns all objects of a specific type into an array.
	 * The names are case-insensitive.
	 * @param name	the name of the structures to retrieve.
	 * @return the queue of structures with the matching name in the order that
	 * they were added to the structure. If there are none, an empty array
	 * is returned.
	 */
	public UDMFObject[] getObjects(String name)
	{
		Deque<UDMFObject> list = innerTable.get(name);
		if (list == null)
			return EMPTY_OBJECT_LIST;
		UDMFObject[] out = new UDMFObject[list.size()];
		list.toArray(out);
		return out;
	}
	
	/**
	 * Adds an object of a particular type to this table.
	 * Keep in mind that the order in which these are added is important.
	 * @param name the name of this type of structure.
	 * @return a reference to the new structure created.
	 */
	public UDMFObject addObject(String name)
	{
		return addObject(name, new UDMFObject());
	}

	/**
	 * Adds an object of a particular type name to this table.
	 * Keep in mind that the order in which these are added is important.
	 * @param name the name of this type of structure.
	 * @param object the object to add. 
	 * @return a reference to the added structure.
	 */
	public UDMFObject addObject(String name, UDMFObject object)
	{
		innerTable.add(name, object);
		return object;
	}
	
	/**
	 * @return a list of all of the object type names in the table.
	 */
	public String[] getAllObjectNames()
	{
		String[] out = new String[innerTable.size()];
		int i = 0;
		for (Map.Entry<String, Deque<UDMFObject>> entry : innerTable.entrySet())
			out[i++] = entry.getKey();
		return out;
	}
	
}
