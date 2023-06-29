/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.map.udmf.attributes;

/**
 * Contains thing attributes for ZDoom namespaces.
 * @author Matthew Tropiano
 * @since 2.9.0
 */
public interface UDMFZDoomThingAttributes extends UDMFHexenThingAttributes
{
	/** Thing flag: Appears on skill 6. */
	public static final String ATTRIB_FLAG_SKILL6 = "skill6";
	/** Thing flag: Appears on skill 7. */
	public static final String ATTRIB_FLAG_SKILL7 = "skill7";
	/** Thing flag: Appears on skill 8. */
	public static final String ATTRIB_FLAG_SKILL8 = "skill8";
	/** Thing flag: Appears on skill 9. */
	public static final String ATTRIB_FLAG_SKILL9 = "skill9";
	/** Thing flag: Appears on skill 10. */
	public static final String ATTRIB_FLAG_SKILL10 = "skill10";
	/** Thing flag: Appears on skill 11. */
	public static final String ATTRIB_FLAG_SKILL11 = "skill11";
	/** Thing flag: Appears on skill 12. */
	public static final String ATTRIB_FLAG_SKILL12 = "skill12";
	/** Thing flag: Appears on skill 13. */
	public static final String ATTRIB_FLAG_SKILL13 = "skill13";
	/** Thing flag: Appears on skill 14. */
	public static final String ATTRIB_FLAG_SKILL14 = "skill14";
	/** Thing flag: Appears on skill 15. */
	public static final String ATTRIB_FLAG_SKILL15 = "skill15";
	/** Thing flag: Appears on skill 16. */
	public static final String ATTRIB_FLAG_SKILL16 = "skill16";

	/** Thing flag: Appears for class 4. */
	public static final String ATTRIB_FLAG_CLASS4 = "skill4";
	/** Thing flag: Appears for class 5. */
	public static final String ATTRIB_FLAG_CLASS5 = "skill5";
	/** Thing flag: Appears for class 6. */
	public static final String ATTRIB_FLAG_CLASS6 = "skill6";
	/** Thing flag: Appears for class 7. */
	public static final String ATTRIB_FLAG_CLASS7 = "skill7";
	/** Thing flag: Appears for class 8. */
	public static final String ATTRIB_FLAG_CLASS8 = "skill8";
	/** Thing flag: Appears for class 9. */
	public static final String ATTRIB_FLAG_CLASS9 = "skill9";
	/** Thing flag: Appears for class 10. */
	public static final String ATTRIB_FLAG_CLASS10 = "skill10";
	/** Thing flag: Appears for class 11. */
	public static final String ATTRIB_FLAG_CLASS11 = "skill11";
	/** Thing flag: Appears for class 12. */
	public static final String ATTRIB_FLAG_CLASS12 = "skill12";
	/** Thing flag: Appears for class 13. */
	public static final String ATTRIB_FLAG_CLASS13 = "skill13";
	/** Thing flag: Appears for class 14. */
	public static final String ATTRIB_FLAG_CLASS14 = "skill14";
	/** Thing flag: Appears for class 15. */
	public static final String ATTRIB_FLAG_CLASS15 = "skill15";
	/** Thing flag: Appears for class 16. */
	public static final String ATTRIB_FLAG_CLASS16 = "skill16";
	/** Thing flag: Count as secret. */
	public static final String ATTRIB_FLAG_SECRET = "countsecret";

	/** Thing uses a Conversation ID. */
	public static final String ATTRIB_CONVERSATION = "conversation";

	/** Thing special argument 0, string type. */
	public static final String ATTRIB_ARG0STR = "arg0str";

	/** Thing gravity scalar. */
	public static final String ATTRIB_GRAVITY = "gravity";
	/** Thing health (multiplicative). */
	public static final String ATTRIB_HEALTH = "health";
	/** Thing renderstyle. */
	public static final String ATTRIB_RENDERSTYLE = "renderstyle";
	/** Thing fill color for stencil renderstyle. */
	public static final String ATTRIB_FILLCOLOR = "fillcolor";
	/** Thing alpha component scalar for supported renderstyles. */
	public static final String ATTRIB_ALPHA = "alpha";
	/** Thing score value. */
	public static final String ATTRIB_SCORE = "score";
	/** Thing pitch (in degrees). */
	public static final String ATTRIB_PITCH = "pitch";
	/** Thing roll (in degrees). */
	public static final String ATTRIB_ROLL = "roll";
	/** Thing size scalar (both axes). */
	public static final String ATTRIB_SCALE = "scale";
	/** Thing size scalar, X. */
	public static final String ATTRIB_SCALE_X = "scalex";
	/** Thing size scalar, Y. */
	public static final String ATTRIB_SCALE_Y = "scaley";
	/** Thing float bob phase offset (for bobbing things). */
	public static final String ATTRIB_PHASE_FLOATBOB = "floatbobphase";
	
}
