/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.map.udmf.attributes;

/**
 * Contains MBF thing attributes on some UDMF structures.
 * @author Matthew Tropiano
 * @since 2.8.0
 */
public interface UDMFMBFThingAttributes extends UDMFDoomThingAttributes
{
	/** Thing flag: Friendly (Marine's Best Friend-style). */
	public static final String ATTRIB_FLAG_FRIENDLY = "friend";
	
}
