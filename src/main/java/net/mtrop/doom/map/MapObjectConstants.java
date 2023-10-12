/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.map;

/**
 * Common elements of all map objects.
 * This provides a general interface for getting map object data.
 * @author Matthew Tropiano
 */
public interface MapObjectConstants
{
	/** Value used for null references to other map objects. */
	public static final int NULL_REFERENCE = -1;
	/** Value used for no special. */
	public static final int SPECIAL_NONE = 0;
	/** Value used for blank texture. */
	public static final String TEXTURE_BLANK = "-";

	/** Degree Angle for EAST. */
	public static final int ANGLE_EAST = 0;
	/** Degree Angle for NORTHEAST. */
	public static final int ANGLE_NORTHEAST = 45;
	/** Degree Angle for NORTH. */
	public static final int ANGLE_NORTH = 90;
	/** Degree Angle for NORTHWEST. */
	public static final int ANGLE_NORTHWEST = 135;
	/** Degree Angle for WEST. */
	public static final int ANGLE_WEST = 180;
	/** Degree Angle for SOUTHWEST. */
	public static final int ANGLE_SOUTHWEST = 225;
	/** Degree Angle for SOUTH. */
	public static final int ANGLE_SOUTH = 270;
	/** Degree Angle for SOUTHEAST. */
	public static final int ANGLE_SOUTHEAST = 315;
	
	/** Byte Angle for EAST. */
	public static final int BYTE_ANGLE_EAST = 0;
	/** Byte Angle for NORTHEAST. */
	public static final int BYTE_ANGLE_NORTHEAST = 32;
	/** Byte Angle for NORTH. */
	public static final int BYTE_ANGLE_NORTH = 64;
	/** Byte Angle for NORTHWEST. */
	public static final int BYTE_ANGLE_NORTHWEST = 96;
	/** Byte Angle for WEST. */
	public static final int BYTE_ANGLE_WEST = 128;
	/** Byte Angle for SOUTHWEST. */
	public static final int BYTE_ANGLE_SOUTHWEST = 160;
	/** Byte Angle for SOUTH. */
	public static final int BYTE_ANGLE_SOUTH = 192;
	/** Byte Angle for SOUTHEAST. */
	public static final int BYTE_ANGLE_SOUTHEAST = 224;
	
}
