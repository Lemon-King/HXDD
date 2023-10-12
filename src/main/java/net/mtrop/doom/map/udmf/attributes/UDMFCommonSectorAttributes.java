/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.map.udmf.attributes;

/**
 * Contains common sector attributes on some UDMF structures.
 * @author Matthew Tropiano
 */
interface UDMFCommonSectorAttributes extends UDMFCommonAttributes
{
	/** Sector floor height. */
	public static final String ATTRIB_HEIGHT_FLOOR = "heightfloor";
	/** Sector ceiling height. */
	public static final String ATTRIB_HEIGHT_CEILING = "heightceiling";
	/** Sector floor texture. */
	public static final String ATTRIB_TEXTURE_FLOOR = "texturefloor";
	/** Sector ceiling texture. */
	public static final String ATTRIB_TEXTURE_CEILING = "textureceiling";
	/** Sector light level. */
	public static final String ATTRIB_LIGHT_LEVEL = "lightlevel";
	/** Sector special. */
	public static final String ATTRIB_SPECIAL = "special";
	/** 
	 * Sector tag/id.
	 * @since 2.9.0 
	 */
	public static final String ATTRIB_ID = "id";
}
