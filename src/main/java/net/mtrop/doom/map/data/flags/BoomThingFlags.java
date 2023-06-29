/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.map.data.flags;

/**
 * Thing flag constants for Boom things.
 * The constant value is how many places to bit shift 1 to equal the flag bit.  
 * @author Matthew Tropiano
 */
public interface BoomThingFlags extends DoomThingFlags
{
	/** Thing flag: Does not appear in cooperative. */
	public static final int NOT_COOPERATIVE = 5;
	/** Thing flag: Does not appear in deathmatch. */
	public static final int NOT_DEATHMATCH = 6;
	
}
