/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.util;

/**
 * Holds a series of helpful methods for testing data integrity for Doom map data export.
 * @author Matthew Tropiano
 */
public final class RangeUtils
{
	private RangeUtils() {}

	/**
	 * Checks if a value is not null.
	 * @param dataName the name of the data field (appears in exception text).
	 * @param value the value to check.
	 * @throws IllegalArgumentException if criteria not met.
	 */
	public static void checkNotNull(String dataName, Object value) throws IllegalArgumentException
	{
		if (value == null)
			throw new IllegalArgumentException(dataName + " value (" + value + ") is null.");
	}

	/**
	 * Checks if a value falls in an inclusive range.
	 * @param dataName the name of the data field (appears in exception text).
	 * @param min the minimum value.
	 * @param max the maximum value.
	 * @param value the value to check.
	 * @throws IllegalArgumentException if criteria not met.
	 */
	public static void checkRange(String dataName, int min, int max, int value) throws IllegalArgumentException
	{
		if (value < min || value > max)
			throw new IllegalArgumentException(dataName + " value (" + value + ") not between " + min + " and " + max + ", inclusively.");
	}

	/**
	 * Checks if a value equals a particular floating-point value.
	 * @param dataName the name of the data field (appears in exception text).
	 * @param equalVal the equality value.
	 * @param value the value to check.
	 * @throws IllegalArgumentException if criteria not met.
	 */
	public static void checkEqual(String dataName, float equalVal, float value) throws IllegalArgumentException
	{
		if (value != equalVal)
			throw new IllegalArgumentException(dataName + " value (" + value + ") not equal to " + equalVal + ".");
	}

	/**
	 * Checks if a value equals a particular String value.
	 * @param dataName the name of the data field (appears in exception text).
	 * @param equalVal the equality value.
	 * @param value the value to check.
	 * @throws IllegalArgumentException if criteria not met.
	 */
	public static void checkEqual(String dataName, String equalVal, String value) throws IllegalArgumentException
	{
		if (!value.equals(equalVal))
			throw new IllegalArgumentException(dataName + " value (" + value + ") not equal to \"" + equalVal + "\".");
	}

	/**
	 * Checks if a value is either true or false.
	 * @param dataName the name of the data field (appears in exception text).
	 * @param flag the flag value.
	 * @param value the value to check.
	 * @throws IllegalArgumentException if criteria not met.
	 */
	public static void checkBoolean(String dataName, boolean flag, boolean value) throws IllegalArgumentException
	{
		if (value != flag)
			throw new IllegalArgumentException(dataName + " value (" + value + ") is not " + flag + ".");
	}

	/**
	 * Checks if a value is a whole number, without a mantissa.
	 * @param dataName the name of the data field (appears in exception text).
	 * @param value the value to check.
	 * @throws IllegalArgumentException if criteria not met.
	 */
	public static void checkWhole(String dataName, float value) throws IllegalArgumentException
	{
		if (((float) ((int) value) - value) != 0.0f)
			throw new IllegalArgumentException(dataName + " value (" + value + ") is not a whole number.");
	}

	/**
	 * Checks if a value is zero.
	 * @param dataName the name of the data field (appears in exception text).
	 * @param value the value to check.
	 * @throws IllegalArgumentException if criteria not met.
	 */
	public static void checkZero(String dataName, int value) throws IllegalArgumentException
	{
		if (value != 0)
			throw new IllegalArgumentException(dataName + " value (" + value + ") is not zero.");
	}

	/**
	 * Checks if a value is negative one.
	 * @param dataName the name of the data field (appears in exception text).
	 * @param value the value to check.
	 * @throws IllegalArgumentException if criteria not met.
	 */
	public static void checkNegativeOne(String dataName, int value) throws IllegalArgumentException
	{
		if (value != 0)
			throw new IllegalArgumentException(dataName + " value (" + value + ") is not -1.");
	}

	/**
	 * Checks if a string's length is 8 or less or not null nor blank and convertible to ASCII.
	 * @param dataName the name of the data field (appears in exception text).
	 * @param value the value to check.
	 * @throws IllegalArgumentException if criteria not met.
	 */
	public static void checkASCIIString(String dataName, String value) throws IllegalArgumentException
	{
		if (value == null)
			throw new IllegalArgumentException(dataName + " value is null.");
		else if (value.trim().length() == 0)
			throw new IllegalArgumentException(dataName + " value is the empty string.");
		else if (value.getBytes(TextUtils.ASCII).length > 8)
			throw new IllegalArgumentException(dataName + " value (" + value + ") is not 8 characters or less in ASCII encoding.");
	}

	/**
	 * Checks if a value falls in the 0 to 255 range.
	 * @param dataName the name of the data field (appears in exception text).
	 * @param value the value to check.
	 * @throws IllegalArgumentException if criteria not met.
	 */
	public static void checkByteUnsigned(String dataName, int value) throws IllegalArgumentException
	{
		checkRange(dataName, 0, 255, value);
	}

	/**
	 * Checks if a value falls in the -128 to 127 range.
	 * @param dataName the name of the data field (appears in exception text).
	 * @param value the value to check.
	 * @throws IllegalArgumentException if criteria not met.
	 */
	public static void checkByte(String dataName, int value) throws IllegalArgumentException
	{
		checkRange(dataName, -128, 127, value);
	}

	/**
	 * Checks if a value falls in the -32767 to 32768 range.
	 * @param dataName the name of the data field (appears in exception text).
	 * @param value the value to check.
	 * @throws IllegalArgumentException if criteria not met.
	 */
	public static void checkShort(String dataName, int value) throws IllegalArgumentException
	{
		checkRange(dataName, -32767, 32768, value);
	}

	/**
	 * Checks if a value falls in the 0 to 65535 range.
	 * @param dataName the name of the data field (appears in exception text).
	 * @param value the value to check.
	 * @throws IllegalArgumentException if criteria not met.
	 */
	public static void checkShortUnsigned(String dataName, int value) throws IllegalArgumentException
	{
		checkRange(dataName, 0, 65535, value);
	}

	/**
	 * Checks if a value is true.
	 * @param dataName the name of the data field (appears in exception text).
	 * @param value the value to check.
	 * @throws IllegalArgumentException if criteria not met.
	 */
	public static void checkTrue(String dataName, boolean value) throws IllegalArgumentException
	{
		checkBoolean(dataName, true, value);
	}

	/**
	 * Checks if a value is false.
	 * @param dataName the name of the data field (appears in exception text).
	 * @param value the value to check.
	 * @throws IllegalArgumentException if criteria not met.
	 */
	public static void checkFalse(String dataName, boolean value) throws IllegalArgumentException
	{
		checkBoolean(dataName, false, value);
	}

}
