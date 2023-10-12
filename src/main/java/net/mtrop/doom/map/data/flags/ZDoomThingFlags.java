/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.map.data.flags;

/**
 * Thing flag constants for ZDoom things.
 * The constant value is how many places to bit shift 1 to equal the flag bit.  
 * @author Matthew Tropiano
 */
public interface ZDoomThingFlags extends HexenThingFlags
{
	/** Thing flag: Thing starts in standing mode. */
	public static final int STANDING = 11;
	/** Thing flag: Appears translucent. */
	public static final int TRANSLUCENT = 12;
	/** Thing flag: Appears invisible. */
	public static final int INVISIBLE = 13;
	/** Thing flag: Thing starts friendly to players. */
	public static final int FRIENDLY = 14;
	
}
