/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.map;

/**
 * Enumeration of internal map format types.
 * @author Matthew Tropiano
 */
public enum MapFormat
{
	/** Format commonly used by Doom, Boom, and MBF/SMMU ports, plus Heretic and Strife. */
	DOOM,
	/** Format commonly used by Hexen and ZDoom-derivative ports. */
	HEXEN,
	/** Format commonly used by all extensible ports. */
	UDMF;
}
