/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.map.udmf.attributes;

/**
 * Contains common sidedef attributes on some UDMF structures.
 * @author Matthew Tropiano
 */
interface UDMFCommonSidedefAttributes extends UDMFCommonAttributes
{
	/** Sidedef base texture offset X. */
	public static final String ATTRIB_OFFSET_X = "offsetx";
	/** Sidedef base texture offset Y. */
	public static final String ATTRIB_OFFSET_Y = "offsety";
	/** Sidedef top texture. */
	public static final String ATTRIB_TEXTURE_TOP = "texturetop";
	/** Sidedef bottom texture. */
	public static final String ATTRIB_TEXTURE_BOTTOM = "texturebottom";
	/** Sidedef middle texture. */
	public static final String ATTRIB_TEXTURE_MIDDLE = "texturemiddle";
	/** Sidedef sector reference. */
	public static final String ATTRIB_SECTOR_INDEX = "sector";

}
