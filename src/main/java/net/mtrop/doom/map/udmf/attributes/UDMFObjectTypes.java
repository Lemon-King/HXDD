/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.map.udmf.attributes;

/**
 * Contains common UDMF structure type names.
 * @author Matthew Tropiano
 * @since 2.4.0
 */
public interface UDMFObjectTypes
{
	/** Object type: Vertex. */
	public static final String TYPE_VERTEX = "vertex";
	/** Object type: Linedef. */
	public static final String TYPE_LINEDEF = "linedef";
	/** Object type: Vertex. */
	public static final String TYPE_SIDEDEF = "sidedef";
	/** Object type: Sector. */
	public static final String TYPE_SECTOR = "sector";
	/** Object type: Thing. */
	public static final String TYPE_THING = "thing";
}
