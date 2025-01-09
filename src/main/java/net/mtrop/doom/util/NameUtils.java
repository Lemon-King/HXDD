/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.util;

import java.io.UnsupportedEncodingException;
import java.text.Normalizer;
import java.text.Normalizer.Form;
import java.util.regex.Pattern;

/**
 * Name utility methods.
 * @author Matthew Tropiano
 */
public final class NameUtils
{
	/** A regex pattern that matches valid entry names. */
	public static final Pattern ENTRY_NAME = Pattern.compile("[A-Z0-9@#%&=\\{\\}\\(\\)\\$\\*\\!\\[\\]\\-\\_\\^+\\\\]{1,8}");
	/** A regex pattern that matches valid texture names. */
	public static final Pattern TEXTURE_NAME = ENTRY_NAME;

	/** The name of the "blank" texture. */
	public static final String EMPTY_TEXTURE_NAME = "-";

	private NameUtils() {}

	/**
	 * Cuts a string at the first null character.
	 * @param s the input string.
	 * @return the resultant string, after the trim.
	 */
	public static String nullTrim(String s)
	{
		int n = s.indexOf('\0');
		return n >= 0 ? s.substring(0, n) : s;
	}

	/**
	 * Converts a String to an ASCII-encoded, byte-length-aligned vector.
	 * If the string length is less than <code>bytelen</code> it is null-byte padded to the length.
	 * @param s the input string.
	 * @param bytelen the output byte array length.
	 * @return the resultant byte array.
	 */
	public static byte[] toASCIIBytes(String s, int bytelen)
	{
		byte[] out = new byte[bytelen];
		byte[] source = null;
		try {source = s.getBytes("ASCII");} catch (UnsupportedEncodingException e) { /* Shouldn't happen. */ }
		System.arraycopy(source, 0, out, 0, Math.min(out.length, source.length));
		return out;
	}

	/**
	 * Tests if an input string is a valid entry name.
	 * <p>
	 * A WadEntry must have a name that is up to 8 characters long, and can only contain
	 * A-Z (uppercase only), 0-9, and most symbols plus the backslash ("\"). 
	 * @param name the input name to test.
	 * @return true if so, false if not.
	 */
	public static boolean isValidEntryName(String name)
	{
		return !isStringEmpty(name) && ENTRY_NAME.matcher(name).matches();
	}

	/**
	 * Tests if an input string is a valid entry name, and if not, converts it into a valid one.
	 * <p>
	 * In a valid entry, all characters must be A-Z (uppercase only), 0-9, and most symbols plus the backslash ("\").
	 * <p>
	 * Lowercase letters are made uppercase and unknown characters are converted to dashes.
	 * Latin characters with diacritical marks are converted to their normalized forms.
	 * Names are truncated to 8 characters.
	 * The entry will also be cut at the first null character, if any.
	 * <p>
	 * An empty string (see {@link #isStringEmpty(Object)} is converted to "-".
	 * @param name the input name to test.
	 * @return true if so, false if not.
	 */
	public static String toValidEntryName(String name)
	{
		if (isValidEntryName(name))
			return name;
		
		if (isStringEmpty(name))
			return "-";
			
		// remove diacritics
		name = Normalizer.normalize(name, Form.NFC);
		
		StringBuilder sb = new StringBuilder();
		for (int i = 0; i < 8 && i < name.length(); i++)
		{
			char c = name.charAt(i);
			if (c == '\0')
				break;
			else if (Character.isLetter(c))
			{
				if (Character.isLowerCase(c))
					sb.append(Character.toUpperCase(c));
				else
					sb.append(c);
			}
			else if (Character.isDigit(c))
				sb.append(c);
			else if (c == '[')
				sb.append(c);
			else if (c == ']')
				sb.append(c);
			else if (c == '-')
				sb.append(c);
			else if (c == '_')
				sb.append(c);
			else if (c == '+')
				sb.append(c);
			else if (c == '\\')
				sb.append(c);
			else if (c == '^')
				sb.append(c);
			else if (c == '@')
				sb.append(c);
			else if (c == '#')
				sb.append(c);
			else if (c == '%')
				sb.append(c);
			else if (c == '&')
				sb.append(c);
			else if (c == '=')
				sb.append(c);
			else if (c == '{')
				sb.append(c);
			else if (c == '}')
				sb.append(c);
			else if (c == '(')
				sb.append(c);
			else if (c == ')')
				sb.append(c);
			else if (c == '$')
				sb.append(c);
			else if (c == '*')
				sb.append(c);
			else if (c == '!')
				sb.append(c);
			else
				sb.append('-');
		}
		
		return sb.toString();
	}
	
	/**
	 * Tests if an input string is a valid entry name, and if not, throws an exception.
	 * @param name the input name to test.
	 * @throws IllegalArgumentException if the entry name is invalid.
	 * @see NameUtils#isValidEntryName(String)
	 */
	public static void checkValidEntryName(String name)
	{
		if (!isValidEntryName(name))
			throw new IllegalArgumentException("The provided entry name, \""+name+"\", is invalid. It must be up to 8 characters long; all characters must be A-Z (uppercase only), 0-9, and [ ] - _ ^ plus the backslash \\.");
	}

	/**
	 * Tests if an input string is a valid texture name.
	 * <p>
	 * A Texture must have an alphanumeric name that is up to 8 characters long, and can only contain
	 * A-Z (uppercase only), 0-9, and most symbols plus the backslash ("\") or just "-". 
	 * @param name the input name to test.
	 * @return true if so, false if not.
	 */
	public static boolean isValidTextureName(String name)
	{
		return "-".equals(name) || isValidEntryName(name);
	}

	/**
	 * Tests if an input string is a valid entry name, and if not, converts it into a valid one.
	 * <p>
	 * In a valid texture, all characters must be A-Z (uppercase only), 0-9, and most symbols plus the backslash ("\").
	 * <p>
	 * Blank/null names are changed to "-".
	 * <p>
	 * Lowercase letters are made uppercase and unknown characters are converted to dashes.
	 * Latin characters with diacritical marks are converted to their normalized forms.
	 * Names are truncated to 8 characters.
	 * The entry will also be cut at the first null character, if any.
	 * @param name the input name to test.
	 * @return true if so, false if not.
	 */
	public static String toValidTextureName(String name)
	{
		if (isValidTextureName(name))
			return name;
		
		if (isStringEmpty(name))
			return EMPTY_TEXTURE_NAME;

		return toValidEntryName(name);
	}

	/**
	 * Tests if an input string is a valid entry name, and if not, throws an exception.
	 * @param name the input name to test.
	 * @throws IllegalArgumentException if the entry name is invalid.
	 * @see #isValidTextureName(String)
	 */
	public static void checkValidTextureName(String name)
	{
		if (!isValidTextureName(name))
			throw new IllegalArgumentException("The provided texture name, \""+name+"\", is invalid. It must be up to 8 characters long; all characters must be A-Z (uppercase only), 0-9, and [ ] - _ ^ + plus the backslash \\.");
	}

	/**
	 * Checks if a string is "empty."
	 * A string is considered "empty" if the string the empty string, or are {@link String#trim()}'ed down to the empty string.
	 * @param obj the object to check.
	 * @return true if the provided object is considered "empty", false otherwise.
	 */
	public static boolean isStringEmpty(Object obj)
	{
		if (obj == null)
			return true;
		else if (obj instanceof String)
			return ((String)obj).trim().length() == 0;
		else
			return false;
	}

}
