/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.map.udmf.attributes;

/**
 * Contains linedef attributes for ZDoom namespaces.
 * @author Matthew Tropiano
 */
public interface UDMFZDoomLinedefAttributes extends UDMFHexenLinedefAttributes, UDMFStrifeLinedefAttributes
{
	/** Linedef activation: Anything Crosses. */
	public static final String ATTRIB_ACTIVATE_ANY_CROSS = "anycross";

	/** Linedef flag: Player can use the back of the linedef for specials. */
	public static final String ATTRIB_FLAG_USEBACK = "playeruseback";
	/** Linedef flag: Activates front-side only. */
	public static final String ATTRIB_FLAG_FIRST_SIDE_ONLY = "firstsideonly";
	/** Linedef flag: Blocks players. */
	public static final String ATTRIB_FLAG_BLOCK_PLAYERS = "blockplayers";
	/** Linedef flag: Blocks everything. */
	public static final String ATTRIB_FLAG_BLOCK_EVERYTHING = "blockeverything";
	/** Linedef flag: Blocks sound environment propagation. */
	public static final String ATTRIB_FLAG_ZONE_BOUNDARY = "zoneboundary";
	/** Linedef flag: Blocks projectiles. */
	public static final String ATTRIB_FLAG_BLOCK_PROJECTILES = "blockprojectiles";
	/** Linedef flag: Blocks line use. */
	public static final String ATTRIB_FLAG_BLOCK_USE = "blockuse";
	/** Linedef flag: Blocks monster sight. */
	public static final String ATTRIB_FLAG_BLOCK_SIGHT = "blocksight";
	/** Linedef flag: Blocks hitscan. */
	public static final String ATTRIB_FLAG_BLOCK_HITSCAN = "blockhitscan";
	/** Linedef flag: Clips the rendering of the middle texture. */
	public static final String ATTRIB_FLAG_MIDTEX_CLIP = "clipmidtex";
	/** Linedef flag: Wraps/tiles the rendering of the middle texture. */
	public static final String ATTRIB_FLAG_MIDTEX_WRAP = "wrapmidtex";
	/** Linedef flag: 3D middle texture collision. */
	public static final String ATTRIB_FLAG_MIDTEX_3D = "midtex3d";
	/** Linedef flag: 3D middle texture collision acts only blocks creatures. */
	public static final String ATTRIB_FLAG_MIDTEX_3D_IMPASSABLE = "midtex3dimpassable";
	/** Linedef flag: Switch activation checks activator height. */
	public static final String ATTRIB_FLAG_CHECK_SWITCH_RANGE = "checkswitchrange";
	/** Linedef flag: Strife Transparent (25% opaque) */
	public static final String ATTRIB_TRANSPARENT = "transparent";

	/** Linedef special argument 0, string type. */
	public static final String ATTRIB_ARG0STR = "arg0str";

	/** Linedef alpha component value. */
	public static final String ATTRIB_ALPHA = "alpha";
	/** Linedef rendering style. */
	public static final String ATTRIB_RENDERSTYLE = "renderstyle";
	/** Linedef special lock type. */
	public static final String ATTRIB_LOCKNUMBER = "locknumber";

}
