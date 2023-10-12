/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.util;

import java.nio.charset.Charset;

/**
 * Text utilities and constants.
 * @author Matthew Tropiano
 * @since 2.13.0
 */
public final class TextUtils 
{
	/** ASCII encoding. */
	public static final Charset ASCII = Charset.forName("ASCII");
	/** CP437 encoding (the extended MS-DOS charset). */
	public static final Charset CP437 = Charset.forName("CP437");
	/** UTF-8 encoding. */
	public static final Charset UTF8 = Charset.forName("UTF-8");

	private TextUtils() {}

}
