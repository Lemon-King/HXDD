/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.map.data.flags;

/**
 * Linedef flag constants.
 * The constant value is how many places to bit shift 1 to equal the flag bit.  
 * @author Matthew Tropiano
 */
interface LinedefFlags
{
	/**
	 * Gets the bit value of the flag (shifted).
	 * @param flag the input flag constant.
	 * @return the resultant value.
	 */
	default int value(int flag)
	{
		return 1 << flag;
	}
	
}
