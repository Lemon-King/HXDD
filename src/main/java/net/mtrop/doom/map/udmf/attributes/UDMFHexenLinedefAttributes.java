/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.map.udmf.attributes;

/**
 * Contains linedef attributes for Hexen namespaces.
 * @author Matthew Tropiano
 * @since 2.8.0
 */
public interface UDMFHexenLinedefAttributes extends UDMFDoomLinedefAttributes
{
	/** Linedef activation: Player Crosses. */
	public static final String ATTRIB_ACTIVATE_PLAYER_CROSS = "playercross";
	/** Linedef activation: Player Uses. */
	public static final String ATTRIB_ACTIVATE_PLAYER_USE = "playeruse";
	/** Linedef activation: Monster Crosses. */
	public static final String ATTRIB_ACTIVATE_MONSTER_CROSS = "monstercross";
	/** Linedef activation: Monster Crosses. */
	public static final String ATTRIB_ACTIVATE_MONSTER_USE = "monsteruse";
	/** Linedef activation: Projectile Impact. */
	public static final String ATTRIB_ACTIVATE_IMPACT = "impact";
	/** Linedef activation: Player Pushes (collide). */
	public static final String ATTRIB_ACTIVATE_PLAYER_PUSH = "playerpush";
	/** Linedef activation: Monster Pushes (collide). */
	public static final String ATTRIB_ACTIVATE_MONSTER_PUSH = "monsterpush";
	/** Linedef activation: Projectile Crosses. */
	public static final String ATTRIB_ACTIVATE_PROJECTILE_CROSS = "missilecross";

	/** Linedef flag: Special is repeatable. */
	public static final String ATTRIB_FLAG_REPEATABLE = "repeatspecial";

	/** Linedef special argument 0. */
	public static final String ATTRIB_ARG0 = "arg0";
	/** Linedef special argument 1. */
	public static final String ATTRIB_ARG1 = "arg1";
	/** Linedef special argument 2. */
	public static final String ATTRIB_ARG2 = "arg2";
	/** Linedef special argument 3. */
	public static final String ATTRIB_ARG3 = "arg3";
	/** Linedef special argument 4. */
	public static final String ATTRIB_ARG4 = "arg4";

}
