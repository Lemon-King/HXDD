/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.map.udmf.attributes;

/**
 * Contains linedef attributes for Doom namespaces.
 * @author Matthew Tropiano
 */
public interface UDMFDoomLinedefAttributes extends UDMFCommonLinedefAttributes
{
	/** Linedef flag: Linedef passes its activation through to another line. */
	public static final String ATTRIB_FLAG_PASSTHRU = "passuse";

}
