/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.map.data.flags;

/**
 * Linedef flag constants for ZDoom (Hexen format).
 * The constant value is how many places to bit shift 1 to equal the flag bit.  
 * @author Matthew Tropiano
 */
public interface ZDoomLinedefFlags extends HexenLinedefFlags
{
	/** Linedef flag: Special can be activated by players and monsters. */
	public static final int ACTIVATED_BY_MONSTERS = 13;
	/** Linedef flag: Blocks players. */
	public static final int BLOCK_PLAYERS = 14;
	/** Linedef flag: Blocks everything (like a one-sided line). */
	public static final int BLOCK_EVERYTHING = 15;
	
}
