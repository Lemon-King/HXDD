/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.map.udmf.attributes;

/**
 * Contains sidedef attributes for ZDoom namespaces.
 * @author Matthew Tropiano
 * @since 2.9.0
 */
public interface UDMFZDoomSidedefAttributes extends UDMFDoomSidedefAttributes
{
	/** Sidedef flag: Relative sidedef light level is instead absolute. */
	public static final String ATTRIB_FLAG_LIGHT_ABSOLUTE = "lightabsolute";
	/** Sidedef flag: Use light level in fog. */
	public static final String ATTRIB_FLAG_LIGHT_FOG = "lightfog";
	/** Sidedef flag: Disable the "fake contrast" on angled walls. */
	public static final String ATTRIB_FLAG_NO_FAKE_CONTRAST = "nofakecontrast";
	/** Sidedef flag: Disable the "fake contrast" on angled walls. */
	public static final String ATTRIB_FLAG_SMOOTH_LIGHTING = "smoothlighting";
	/** Sidedef flag: This side's middle texture is clipped by the floor. */
	public static final String ATTRIB_FLAG_CLIP_MIDTEX = "clipmidtex";
	/** Sidedef flag: This side's middle texture is wrapped vertically if there is more to draw. */
	public static final String ATTRIB_FLAG_WRAP_MIDTEX = "wrapmidtex";
	/** Sidedef flag: Disable decals on this wall. */
	public static final String ATTRIB_FLAG_NO_DECALS = "nodecals";

	/** Sidedef upper texture scaling, X. */
	public static final String ATTRIB_SCALE_TOP_X = "scalex_top";
	/** Sidedef upper texture scaling, Y. */
	public static final String ATTRIB_SCALE_TOP_Y = "scaley_top";
	/** Sidedef middle texture scaling, X. */
	public static final String ATTRIB_SCALE_MIDDLE_X = "scalex_mid";
	/** Sidedef middle texture scaling, Y. */
	public static final String ATTRIB_SCALE_MIDDLE_Y = "scaley_mid";
	/** Sidedef bottom texture scaling, X. */
	public static final String ATTRIB_SCALE_BOTTOM_X = "scalex_bottom";
	/** Sidedef bottom texture scaling, Y. */
	public static final String ATTRIB_SCALE_BOTTOM_Y = "scaley_bottom";

	/** Sidedef upper texture offset, X. */
	public static final String ATTRIB_OFFSET_TOP_X = "offsetx_top";
	/** Sidedef upper texture offset, Y. */
	public static final String ATTRIB_OFFSET_TOP_Y = "offsety_top";
	/** Sidedef middle texture offset, X. */
	public static final String ATTRIB_OFFSET_MIDDLE_X = "offsetx_mid";
	/** Sidedef middle texture offset, Y. */
	public static final String ATTRIB_OFFSET_MIDDLE_Y = "offsety_mid";
	/** Sidedef bottom texture offset, X. */
	public static final String ATTRIB_OFFSET_BOTTOM_X = "offsetx_bottom";
	/** Sidedef bottom texture offset, Y. */
	public static final String ATTRIB_OFFSET_BOTTOM_Y = "offsety_bottom";

	/** Sidedef relative light level. */
	public static final String ATTRIB_LIGHT = "light";

}
