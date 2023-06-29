/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.map.data.flags;

/**
 * Thing flag constants for Strife things.
 * The constant value is how many places to bit shift 1 to equal the flag bit.  
 * @author Matthew Tropiano
 */
public interface StrifeThingFlags extends ThingFlags
{
	/** Thing flag: Thing starts in standing mode. */
	public static final int STANDING = 3;
	/** Thing flag: Appears in multiplayer only. */
	public static final int MULTIPLAYER = 4;
	/** Thing flag: Ambushes players. */
	public static final int AMBUSH = 5;
	/** Thing flag: Thing starts friendly to players. */
	public static final int ALLY = 6;
	/** Thing flag: Appears at 25% translucency. */
	public static final int TRANSLUCENT_25 = 7;
	/** Thing flag: Is invisible. */
	public static final int INVISIBLE = 8;

}
