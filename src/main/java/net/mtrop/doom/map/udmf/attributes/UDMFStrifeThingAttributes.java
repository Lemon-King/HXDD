/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.map.udmf.attributes;

/**
 * Contains thing attributes for Strife namespaces.
 * @author Matthew Tropiano
 * @since 2.8.0
 */
public interface UDMFStrifeThingAttributes extends UDMFDoomThingAttributes
{
	/** Thing flag: Thing is in a standing mode. */
	public static final String ATTRIB_FLAG_STANDING = "standing";
	/** Thing flag: Thing is an ally. */
	public static final String ATTRIB_FLAG_ALLY = "strifeally";
	/** Thing flag: Thing is translucent. */
	public static final String ATTRIB_FLAG_TRANSLUCENT = "translucent";
	/** Thing flag: Thing is invisible. */
	public static final String ATTRIB_FLAG_INVISIBLE = "invisible";

}
