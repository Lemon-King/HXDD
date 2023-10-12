/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.map.udmf.attributes;

/**
 * Contains sector attributes for ZDoom namespaces.
 * @author Matthew Tropiano
 * @since 2.9.0
 */
public interface UDMFZDoomSectorAttributes extends UDMFDoomSectorAttributes
{
	/** Sector flag: Light adjustment for floor is absolute, not relative. */
	public static final String ATTRIB_FLAG_lIGHT_ABSOLUTE_FLOOR = "lightfloorabsolute";
	/** Sector flag: Light adjustment for ceiling is absolute, not relative. */
	public static final String ATTRIB_FLAG_lIGHT_ABSOLUTE_CEILING = "lightceilingabsolute";
	/** Sector flag: Actors are silent in the sector. */
	public static final String ATTRIB_FLAG_SILENT = "silent";
	/** Sector flag: No falling damage. */
	public static final String ATTRIB_FLAG_NO_FALLINGDAMAGE = "nofallingdamage";
	/** Sector flag: Actors drop instantly with moving floors (may not see explicit use). */
	public static final String ATTRIB_FLAG_DROPACTORS = "dropactors";
	/** Sector flag: Players cannot respawn in the sector. */
	public static final String ATTRIB_FLAG_NO_RESPAWN = "norespawn";
	/** Sector flag: Hidden on automap. */
	public static final String ATTRIB_FLAG_HIDDEN = "hidden";
	/** Sector flag: Is this considered underwater and swimmable? */
	public static final String ATTRIB_FLAG_WATERZONE = "waterzone";
	/** Sector flag: Upon damage, make a terrain splash. */
	public static final String ATTRIB_FLAG_DAMAGE_TERRAIN_EFFECT = "damageterraineffect";
	/** Sector flag: Use the Strife damage model for hazards (delayed effect). */
	public static final String ATTRIB_FLAG_DAMAGE_HAZARD = "damagehazard";
	/** Sector flag: Portal floor is disabled. */
	public static final String ATTRIB_FLAG_PORTAL_DISABLED_FLOOR = "portal_floor_disabled";
	/** Sector flag: Portal ceiling is disabled. */
	public static final String ATTRIB_FLAG_PORTAL_DISABLED_CEILING = "portal_ceil_disabled";
	/** Sector flag: Portal floor blocks sound. */
	public static final String ATTRIB_FLAG_PORTAL_BLOCKSOUND_FLOOR = "portal_floor_blocksound";
	/** Sector flag: Portal ceiling blocks sound. */
	public static final String ATTRIB_FLAG_PORTAL_BLOCKSOUND_CEILING = "portal_ceil_blocksound";
	/** Sector flag: Portal floor blocks movement. */
	public static final String ATTRIB_FLAG_PORTAL_NO_PASS_FLOOR = "portal_floor_nopass";
	/** Sector flag: Portal ceiling blocks movement. */
	public static final String ATTRIB_FLAG_PORTAL_NO_PASS_CEILING = "portal_ceil_nopass";
	/** Sector flag: Portal floor is not rendered. */
	public static final String ATTRIB_FLAG_PORTAL_NO_RENDER_FLOOR = "portal_floor_norender";
	/** Sector flag: Portal ceiling is not rendered. */
	public static final String ATTRIB_FLAG_PORTAL_NO_RENDER_CEILING = "portal_ceil_norender";

	/** Sector floor texture panning, X. */
	public static final String ATTRIB_PANNING_FLOOR_X = "xpanningfloor";
	/** Sector floor texture panning, Y. */
	public static final String ATTRIB_PANNING_FLOOR_Y = "ypanningfloor";
	/** Sector ceiling texture panning, X. */
	public static final String ATTRIB_PANNING_CEILING_X = "xpanningceiling";
	/** Sector ceiling texture panning, Y. */
	public static final String ATTRIB_PANNING_CEILING_Y = "ypanningceiling";
	/** Sector floor texture scale, X. */
	public static final String ATTRIB_SCALE_FLOOR_X = "xscalefloor";
	/** Sector floor texture scale, Y. */
	public static final String ATTRIB_SCALE_FLOOR_Y = "yscalefloor";
	/** Sector ceiling texture scale, X. */
	public static final String ATTRIB_SCALE_CEILING_X = "xscaleceiling";
	/** Sector ceiling texture scale, Y. */
	public static final String ATTRIB_SCALE_CEILING_Y = "yscaleceiling";
	/** Sector floor texture rotation (degrees). */
	public static final String ATTRIB_ROTATION_FLOOR = "rotationfloor";
	/** Sector ceiling texture rotation (degrees). */
	public static final String ATTRIB_ROTATION_CEILING = "rotationceiling";

	/** Sector floor plane equation, coefficient A (all floor coefficients must be specified). */
	public static final String ATTRIB_PLANE_FLOOR_A = "floorplane_a";
	/** Sector floor plane equation, coefficient B (all floor coefficients must be specified). */
	public static final String ATTRIB_PLANE_FLOOR_B = "floorplane_b";
	/** Sector floor plane equation, coefficient C (all floor coefficients must be specified). */
	public static final String ATTRIB_PLANE_FLOOR_C = "floorplane_c";
	/** Sector floor plane equation, coefficient D (all floor coefficients must be specified). */
	public static final String ATTRIB_PLANE_FLOOR_D = "floorplane_d";
	/** Sector ceiling plane equation, coefficient A (all ceiling coefficients must be specified). */
	public static final String ATTRIB_PLANE_CEILING_A = "ceilingplane_a";
	/** Sector ceiling plane equation, coefficient B (all ceiling coefficients must be specified). */
	public static final String ATTRIB_PLANE_CEILING_B = "ceilingplane_b";
	/** Sector ceiling plane equation, coefficient C (all ceiling coefficients must be specified). */
	public static final String ATTRIB_PLANE_CEILING_C = "ceilingplane_c";
	/** Sector ceiling plane equation, coefficient D (all ceiling coefficients must be specified). */
	public static final String ATTRIB_PLANE_CEILING_D = "ceilingplane_d";

	/** Sector relative floor light level. */
	public static final String ATTRIB_LIGHT_FLOOR = "lightfloor";
	/** Sector relative ceiling light level. */
	public static final String ATTRIB_LIGHT_CEILING = "lightceiling";

	/** Sector floor alpha (useful only with portals). */
	public static final String ATTRIB_ALPHA_FLOOR = "alphafloor";
	/** Sector ceiling alpha (useful only with portals). */
	public static final String ATTRIB_ALPHA_CEILING = "alphaceiling";

	/** Sector floor renderstyle (useful only with portals/alpha). */
	public static final String ATTRIB_RENDERSTYLE_FLOOR = "renderstylefloor";
	/** Sector ceiling renderstyle (useful only with portals/alpha). */
	public static final String ATTRIB_RENDERSTYLE_CEILING = "renderstyleceiling";

	/** Sector gravity scalar. */
	public static final String ATTRIB_GRAVITY = "gravity";

	/** Sector light color (hex string RRGGBB). */
	public static final String ATTRIB_COLOR_LIGHT = "lightcolor";
	/** Sector fade color (hex string RRGGBB). */
	public static final String ATTRIB_COLOR_FADE = "fadecolor";
	/** Sector color desaturation scalar. */
	public static final String ATTRIB_COLOR_DESATURATION = "desaturation";

	/** Sector sound sequence name. */
	public static final String ATTRIB_SOUNDSEQUENCE = "soundsequence";
	/** Additional Sector ids besides the first (space-separated). */
	public static final String ATTRIB_ID_MORE = "moreids";

	/** Sector damage per damage tic (can be negative). */
	public static final String ATTRIB_DAMAGE_AMOUNT = "damageamount";
	/** Sector damage tic interval. */
	public static final String ATTRIB_DAMAGE_INTERVAL = "damageinterval";
	/** Sector damage type. */
	public static final String ATTRIB_DAMAGE_TYPE = "damagetype";
	/** Sector damage "leak" chance (0 - 256). */
	public static final String ATTRIB_DAMAGE_LEAK_CHANCE = "leakiness";

	/** Sector floor terrain. */
	public static final String ATTRIB_TERRAIN_FLOOR = "floorterrain";
	/** Sector ceiling terrain. */
	public static final String ATTRIB_TERRAIN_CEILING = "ceilingterrain";

	/** Sector portal floor overlay type. */
	public static final String ATTRIB_PORTAL_OVERLAY_TYPE_FLOOR = "portal_floor_overlaytype";
	/** Sector portal ceiling overlay type. */
	public static final String ATTRIB_PORTAL_OVERLAY_TYPE_CEILING = "portal_ceil_overlaytype";
	
}
