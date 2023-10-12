/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.texture;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import net.mtrop.doom.object.BinaryObject;
import net.mtrop.doom.struct.Sizable;
import net.mtrop.doom.struct.io.SerialReader;
import net.mtrop.doom.struct.io.SerialWriter;
import net.mtrop.doom.struct.vector.AbstractMappedVector;
import net.mtrop.doom.struct.vector.AbstractVector.VectorIterator;
import net.mtrop.doom.util.NameUtils;

/**
 * A list of names of available patch entries for texture composition.
 * Texture patches use indices that reference this list.
 * @author Matthew Tropiano
 */
public class PatchNames implements BinaryObject, Iterable<String>, Sizable
{
	/** List of names. */
	protected AbstractMappedVector<String, String> nameList;

	/**
	 * Creates a new PatchNames with a default starting capacity.
	 */
	public PatchNames()
	{
		this.nameList = new AbstractMappedVector<String, String>(32)
		{
			@Override
			protected String getMappingKey(String object) 
			{
				return object;
			}
		};
	}

	/**
	 * Clears this list of patches.
	 */
	public void clear()
	{
		nameList.clear();
	}

	/**
	 * Adds a patch entry.
	 * @param name the entry name.
	 * @return the index of the added entry, or an existing index if it was already in the list.
	 * @throws IllegalArgumentException if the provided name is not a valid entry name.
	 * @see NameUtils#isValidEntryName(String) 
	 */
	public int add(String name)
	{
		NameUtils.checkValidEntryName(name);
		if (nameList.contains(name))
			return nameList.getIndexOf(name);
		
		int out = nameList.size();
		nameList.add(name);
		return out;
	}
	
	/**
	 * Gets the patch entry at a specific index.
	 * @param index the index to look up.
	 * @return the corresponding index or <code>null</code> if no corresponding entry. 
	 */
	public String get(int index)
	{
		return nameList.get(index);
	}
	
	/**
	 * Gets the index of a patch name in this lump by its name.
	 * Search is sequential.
	 * @param name the name of the patch.
	 * @return a valid index if found, or -1 if not.
	 */
	public int indexOf(String name)
	{
		return nameList.getIndexOf(name);
	}

	/**
	 * Attempts to remove an entry by its name.
	 * Note that this will shift the indices of the other entries. 
	 * @param name the name of the entry.
	 * @return true if removed, false if not.
	 */
	public boolean remove(String name)
	{
		return nameList.remove(name);
	}
	
	/**
	 * Removes an entry at an index.
	 * Note that this will shift the indices of the other entries. 
	 * @param index the index to use. 
	 * @return the entry removed, or <code>null</code> if no entry at that index.
	 */
	public String removeIndex(int index)
	{
		return nameList.removeIndex(index);
	}
	
	@Override
	public void readBytes(InputStream in) throws IOException
	{
		clear();
		SerialReader sr = new SerialReader(SerialReader.LITTLE_ENDIAN);
		int n = sr.readInt(in);
		while (n-- > 0)
			add(NameUtils.toValidEntryName(NameUtils.nullTrim(new String(sr.readBytes(in, 8), "ASCII"))));
	}

	@Override
	public void writeBytes(OutputStream out) throws IOException
	{
		SerialWriter sw = new SerialWriter(SerialWriter.LITTLE_ENDIAN);
		sw.writeInt(out, size());
		for (String s : this)
			sw.writeBytes(out, NameUtils.toASCIIBytes(s, 8));
	}

	@Override
	@SuppressWarnings({ "rawtypes", "unchecked" })
	public VectorIterator iterator()
	{
		return nameList.iterator();
	}

	@Override
	public int size() 
	{
		return nameList.size();
	}

	@Override
	public boolean isEmpty() 
	{
		return nameList.isEmpty();
	}

}
