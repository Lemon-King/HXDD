/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.map.data;

import net.mtrop.doom.map.data.flags.BoomThingFlags;
import net.mtrop.doom.map.data.flags.DoomThingFlags;
import net.mtrop.doom.map.data.flags.HexenThingFlags;
import net.mtrop.doom.map.data.flags.MBFThingFlags;
import net.mtrop.doom.map.data.flags.StrifeThingFlags;
import net.mtrop.doom.map.data.flags.ZDoomThingFlags;
import net.mtrop.doom.object.BinaryObject;
import net.mtrop.doom.util.RangeUtils;

/**
 * Contains common elements of all binary things.
 * @author Matthew Tropiano
 */
abstract class CommonThing implements BinaryObject
{
	/** Thing X position. */
	protected int x;
	/** Thing Y position. */
	protected int y;
	/** Thing angle. */
	protected int angle;
	/** Thing type (editor number). */
	protected int type;

	/** Behavior bitflags. */
	protected int flags;
	
	/**
	 * Creates a new thing.
	 */
	public CommonThing()
	{
		this.x = 0;
		this.y = 0;
		this.angle = 0;
		this.type = 0;
		this.flags = 0;
	}

	/**
	 * Sets the coordinates of this thing.
	 * @param x the x-coordinate value.
	 * @param y the y-coordinate value.
	 */
	public void set(int x, int y)
	{
		setX(x);
		setY(y);
	}

	/**
	 * @return the position X-coordinate.
	 */
	public int getX()
	{
		return x;
	}

	/**
	 * Sets the position X-coordinate.
	 * @param x the new x-coordinate.
	 * @throws IllegalArgumentException if x is outside of the range -32768 to 32767.
	 */
	public void setX(int x)
	{
		RangeUtils.checkShort("Position X", x);
		this.x = x;
	}

	/**
	 * @return the position Y-coordinate.
	 */
	public int getY()
	{
		return y;
	}

	/**
	 * Sets the position Y-coordinate.
	 * @param y the new y-coordinate.
	 * @throws IllegalArgumentException if y is outside of the range -32768 to 32767.
	 */
	public void setY(int y)
	{
		RangeUtils.checkShort("Position Y", y);
		this.y = y;
	}

	/**
	 * @return the angle (in degrees).
	 */
	public int getAngle()
	{
		return angle;
	}

	/**
	 * Sets the angle (in degrees). 
	 * @param angle the new angle in degrees.
	 * @throws IllegalArgumentException if angle is outside of the range -32768 to 32767.
	 */
	public void setAngle(int angle)
	{
		RangeUtils.checkShort("Angle", angle);
		this.angle = angle;
	}

	/**
	 * @return thing type (a.k.a. editor number).
	 */
	public int getType()
	{
		return type;
	}

	/**
	 * Sets thing type (a.k.a. editor number). 
	 * @param type the new thing type.
	 * @throws IllegalArgumentException if type is outside of the range 0 to 65535.
	 */
	public void setType(int type)
	{
		RangeUtils.checkShortUnsigned("Type", type);
		this.type = type;
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
	 * @see DoomThingFlags
	 * @see BoomThingFlags
	 * @see MBFThingFlags
	 * @see HexenThingFlags
	 * @see StrifeThingFlags
	 * @see ZDoomThingFlags
	 */
	public boolean isFlagSet(int flagType)
	{
		return (flags & (1 << flagType)) != 0;
	}

	/**
	 * Sets/clears a bit flag.
	 * @param flagType the flag type (constant).
	 * @param set if true, set the bit. If false, clear it.
	 * @see DoomThingFlags
	 * @see BoomThingFlags
	 * @see MBFThingFlags
	 * @see HexenThingFlags
	 * @see StrifeThingFlags
	 * @see ZDoomThingFlags
	 */
	public void setFlag(int flagType, boolean set)
	{
		flags = set
			? flags | (1 << flagType)
			: flags & ~(1 << flagType)
		;
	}

}
