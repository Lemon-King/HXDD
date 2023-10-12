/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.map.udmf.attributes;

/**
 * Contains vertex attributes for ZDoom namespaces.
 * @author Matthew Tropiano
 */
public interface UDMFZDoomVertexAttributes extends UDMFDoomVertexAttributes
{
	/** Vertex Z position (floor height). */
	public static final String ATTRIB_POSITION_Z_FLOOR = "zfloor";
	/** Vertex Z position (ceiling height). */
	public static final String ATTRIB_POSITION_Z_CEILING = "zceiling";
	
}
