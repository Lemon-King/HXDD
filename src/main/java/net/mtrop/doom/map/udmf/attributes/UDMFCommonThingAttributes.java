/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.map.udmf.attributes;

/**
 * Contains common thing attributes on some UDMF structures.
 * @author Matthew Tropiano
 */
interface UDMFCommonThingAttributes extends UDMFCommonAttributes
{
	/** Thing position: x-coordinate. */
	public static final String ATTRIB_POSITION_X = "x";
	/** Thing position: y-coordinate. */
	public static final String ATTRIB_POSITION_Y = "y";
	/** Thing angle in degrees. */
	public static final String ATTRIB_ANGLE = "angle";
	/** Thing type. */
	public static final String ATTRIB_TYPE = "type";
	
	/** Thing flag: Appears on skill 1. */
	public static final String ATTRIB_FLAG_SKILL1 = "skill1";
	/** Thing flag: Appears on skill 2. */
	public static final String ATTRIB_FLAG_SKILL2 = "skill2";
	/** Thing flag: Appears on skill 3. */
	public static final String ATTRIB_FLAG_SKILL3 = "skill3";
	/** Thing flag: Appears on skill 4. */
	public static final String ATTRIB_FLAG_SKILL4 = "skill4";
	/** Thing flag: Appears on skill 5. */
	public static final String ATTRIB_FLAG_SKILL5 = "skill5";
	/** Thing flag: Ambushes players ("deaf" flag). */
	public static final String ATTRIB_FLAG_AMBUSH = "ambush";
	/** Thing flag: Single player. */
	public static final String ATTRIB_FLAG_SINGLE_PLAYER = "single";
	/** Thing flag: Co-operative. */
	public static final String ATTRIB_FLAG_COOPERATIVE = "coop";
	/** Thing flag: Deathmatch. */
	public static final String ATTRIB_FLAG_DEATHMATCH = "dm";
	
}
