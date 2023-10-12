/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.map;

import net.mtrop.doom.map.data.DoomLinedef;
import net.mtrop.doom.map.data.DoomSector;
import net.mtrop.doom.map.data.DoomSidedef;
import net.mtrop.doom.map.data.DoomThing;
import net.mtrop.doom.map.data.DoomVertex;

/**
 * Doom map in Doom Format.
 * @author Matthew Tropiano
 */
public class DoomMap extends CommonMap<DoomVertex, DoomLinedef, DoomSidedef, DoomSector, DoomThing>
{
	/**
	 * Creates a blank map.
	 */
	public DoomMap()
	{
		super();
	}

}
