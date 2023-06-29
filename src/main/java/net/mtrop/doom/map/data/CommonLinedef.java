/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.map.data;

import net.mtrop.doom.map.MapObjectConstants;
import net.mtrop.doom.map.data.flags.BoomLinedefFlags;
import net.mtrop.doom.map.data.flags.DoomLinedefFlags;
import net.mtrop.doom.map.data.flags.HexenLinedefFlags;
import net.mtrop.doom.map.data.flags.StrifeLinedefFlags;
import net.mtrop.doom.map.data.flags.ZDoomLinedefFlags;
import net.mtrop.doom.object.BinaryObject;
import net.mtrop.doom.util.RangeUtils;

/**
 * Contains common elements of all binary linedefs.
 * @author Matthew Tropiano
 */
abstract class CommonLinedef implements BinaryObject
{
	/** Vertex start. */
	protected int vertexStartIndex;
	/** Vertex end. */
	protected int vertexEndIndex;

	/** Front sidedef. */
	protected int sidedefFrontIndex;
	/** Back sidedef. */
	protected int sidedefBackIndex;

	/** Behavior bitflags. */
	protected int flags;
	
	/** Linedef special. */
	protected int special;

	protected CommonLinedef()
	{
		this.vertexStartIndex = MapObjectConstants.NULL_REFERENCE;
		this.vertexEndIndex = MapObjectConstants.NULL_REFERENCE;
		this.sidedefFrontIndex = MapObjectConstants.NULL_REFERENCE;
		this.sidedefBackIndex = MapObjectConstants.NULL_REFERENCE;
		this.flags = 0;
		this.special = 0;
	}
	
	/**
	 * Sets the starting vertex index.
	 * @param vertexStartIndex the index of the start vertex.
	 * @throws IllegalArgumentException if index is outside the range 0 to 65535.
	 */
	public void setVertexStartIndex(int vertexStartIndex)
	{
		RangeUtils.checkShortUnsigned("Vertex Start Index", vertexStartIndex);
		this.vertexStartIndex = vertexStartIndex;
	}
	
	/**
	 * @return the starting vertex index.
	 */
	public int getVertexStartIndex()
	{
		return vertexStartIndex;
	}
	
	/**
	 * Sets the ending vertex index.
	 * @param vertexEndIndex the index of the end vertex.
	 * @throws IllegalArgumentException if index is outside the range 0 to 65535.
	 */
	public void setVertexEndIndex(int vertexEndIndex)
	{
		RangeUtils.checkShortUnsigned("Vertex End Index", vertexEndIndex);
		this.vertexEndIndex = vertexEndIndex;
	}
	
	/**
	 * @return the ending vertex index.
	 */
	public int getVertexEndIndex()
	{
		return vertexEndIndex;
	}
	
	/**
	 * Sets the front sidedef index.
	 * @param sidedefFrontIndex the index of the front sidedef.
	 * @throws IllegalArgumentException if special is outside the range -1 to 32767.
	 */
	public void setSidedefFrontIndex(int sidedefFrontIndex)
	{
		RangeUtils.checkRange("Sidedef Front Index", -1, Short.MAX_VALUE, sidedefFrontIndex);
		this.sidedefFrontIndex = sidedefFrontIndex;
	}
	/**
	 * @return the front sidedef index.
	 */
	public int getSidedefFrontIndex()
	{
		return sidedefFrontIndex;
	}
	
	/**
	 * Sets the back sidedef index.
	 * @param sidedefBackIndex the index of the back sidedef.
	 * @throws IllegalArgumentException if special is outside the range -1 to 32767.
	 */
	public void setSidedefBackIndex(int sidedefBackIndex)
	{
		RangeUtils.checkRange("Sidedef Back Index", -1, Short.MAX_VALUE, sidedefBackIndex);
		this.sidedefBackIndex = sidedefBackIndex;
	}
	
	/**
	 * @return the back sidedef index.
	 */
	public int getSidedefBackIndex()
	{
		return sidedefBackIndex;
	}
	
	/**
	 * Sets the linedef special type.
	 * @param special the number of the special. 
	 * @throws IllegalArgumentException if special is outside the range 0 to 65535.
	 */
	public void setSpecial(int special)
	{
		RangeUtils.checkShortUnsigned("Special", special);
		this.special = special;
	}
	
	/**
	 * @return the linedef special type. 
	 */
	public int getSpecial()
	{
		return special;
	}

	/**
	 * @return this linedef's full bitflags.
	 */
	public int getFlags()
	{
		return flags;
	}
	
	/**
	 * Sets/replaces this linedef's full bitflags.
	 * @param flags the flags to set
	 */
	public void setFlags(int flags)
	{
		this.flags = flags;
	}
	
	/**
	 * Check's if a flag bit is set.
	 * @param flagType the flag type (constant).
	 * @return true if set, false if not.
	 * @see DoomLinedefFlags
	 * @see BoomLinedefFlags
	 * @see HexenLinedefFlags
	 * @see StrifeLinedefFlags
	 * @see ZDoomLinedefFlags
	 */
	public boolean isFlagSet(int flagType)
	{
		return (flags & (1 << flagType)) != 0;
	}

	/**
	 * Sets/clears a bit flag.
	 * @param flagType the flag type (constant).
	 * @param set if true, set the bit. If false, clear it.
	 * @see DoomLinedefFlags
	 * @see BoomLinedefFlags
	 * @see HexenLinedefFlags
	 * @see StrifeLinedefFlags
	 * @see ZDoomLinedefFlags
	 */
	public void setFlag(int flagType, boolean set)
	{
		flags = set
			? flags | (1 << flagType)
			: flags & ~(1 << flagType)
		;
	}
	
}
