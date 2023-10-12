/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.map;

import net.mtrop.doom.map.data.DoomSector;
import net.mtrop.doom.map.data.DoomSidedef;
import net.mtrop.doom.map.data.DoomVertex;
import net.mtrop.doom.map.data.HexenLinedef;
import net.mtrop.doom.map.data.HexenThing;

/**
 * Hexen map in ZDoom/Hexen Format.
 * @author Matthew Tropiano
 */
public class HexenMap extends CommonMap<DoomVertex, HexenLinedef, DoomSidedef, DoomSector, HexenThing>
{
	/**
	 * Creates a blank map.
	 */
	public HexenMap()
	{
		super();
	}

}
