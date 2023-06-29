/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.map.udmf;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;

/**
 * Main descriptor for all UDMF objects.
 * @author Matthew Tropiano
 */
public class UDMFObject implements Iterable<Map.Entry<String, Object>>
{
	private Map<String, Object> attributes;
	
	/** Creates a new UDMFObject. */
	public UDMFObject()
	{
		this.attributes = new HashMap<>(8, 1.0f);
	}
	
	/**
	 * Clears all attributes from the structure. 
	 */
	public void clear()
	{
		attributes.clear();
	}
	
	/**
	 * Gets a corresponding attribute by name.
	 * @param attributeName the name of the attribute.
	 * @return the corresponding value, or null if no value.
	 */
	public Object get(String attributeName)
	{
		return attributes.get(attributeName.toLowerCase());
	}
	
	/**
	 * Removes a corresponding attribute by name.
	 * @param attributeName the name of the attribute.
	 * @return the removed value, or null if no value.
	 */
	public Object remove(String attributeName)
	{
		return attributes.remove(attributeName.toLowerCase());
	}
	
	/**
	 * Sets an attribute value by name.
	 * @param attributeName the name of the attribute.
	 * @param value the value of the attribute, null to remove.
	 */
	public void set(String attributeName, Object value)
	{
		attributeName = attributeName.toLowerCase();
		
		if (value == null)
			attributes.remove(attributeName);
		else if (value instanceof Boolean)
			attributes.put(attributeName.toLowerCase(), value);
		else if (value instanceof Integer)
			attributes.put(attributeName.toLowerCase(), value);
		else if (value instanceof Float)
			attributes.put(attributeName.toLowerCase(), value);
		else
			attributes.put(attributeName.toLowerCase(), String.valueOf(value));
	}
	
	/**
	 * Gets the boolean value of an arbitrary object attribute.
	 * Non-empty strings and non-zero numbers are <code>true</code>.
	 * 
	 * @param attributeName the attribute name (may be standardized, depending on implementation).
	 * @param value the attribute value.
	 * @throws NumberFormatException if the value was originally a String and can't be converted.
	 */
	public void setBoolean(String attributeName, Boolean value)
	{
		attributes.put(attributeName.toLowerCase(), value);
	}

	/**
	 * Gets the boolean value of an arbitrary object attribute.
	 * Non-empty strings and non-zero numbers are <code>true</code>.
	 * 
	 * @param attributeName the attribute name (may be standardized, depending on implementation).
	 * @return the integer value of an object attribute, or <code>null</code> if the attribute is not implemented nor exists.
	 * @throws NumberFormatException if the value was originally a String and can't be converted.
	 */
	public Boolean getBoolean(String attributeName)
	{
		return getBoolean(attributeName, null);
	}

	/**
	 * Gets the boolean value of an arbitrary object attribute.
	 * Non-empty strings and non-zero numbers are <code>true</code>.
	 * 
	 * @param attributeName the attribute name (may be standardized, depending on implementation).
	 * @param def the default value if one does not exist.
	 * @return the integer value of an object attribute, or <code>def</code> if the attribute is not implemented nor exists.
	 * @throws NumberFormatException if the value was originally a String and can't be converted.
	 */
	public Boolean getBoolean(String attributeName, Boolean def)
	{
		Object obj = attributes.get(attributeName.toLowerCase());
		if (obj == null)
			return def;
		return createForType(attributeName, obj, Boolean.class);
	}

	/**
	 * Gets the integer value of an arbitrary object attribute.
	 * If the value is castable to Integer, it is cast to an Integer.
	 * <p>
	 * Strings are attempted to be parsed as integers.
	 * Floating-point values are chopped.
	 * Booleans are 1 if true, 0 if false.
	 * @param attributeName the attribute name (may be standardized, depending on implementation).
	 * @param value the attribute value.
	 */
	public void setInteger(String attributeName, Integer value)
	{
		attributes.put(attributeName.toLowerCase(), value);
	}

	/**
	 * Gets the integer value of an arbitrary object attribute.
	 * If the value is castable to Integer, it is cast to an Integer.
	 * <p>
	 * Strings are attempted to be parsed as integers.
	 * Floating-point values are chopped.
	 * Booleans are 1 if true, 0 if false.
	 * @param attributeName the attribute name (may be standardized, depending on implementation).
	 * @return the integer value of an object attribute, or <code>null</code> if the attribute is not implemented nor exists.
	 * @throws NumberFormatException if the value was originally a String and can't be converted.
	 */
	public Integer getInteger(String attributeName)
	{
		return getInteger(attributeName, null);
	}

	/**
	 * Gets the integer value of an arbitrary object attribute.
	 * If the value is castable to Integer, it is cast to an Integer.
	 * <p>
	 * Strings are attempted to be parsed as integers.
	 * Floating-point values are chopped.
	 * Booleans are 1 if true, 0 if false.
	 * @param attributeName the attribute name (may be standardized, depending on implementation).
	 * @param def the default value if one does not exist.
	 * @return the integer value of an object attribute, or <code>def</code> if the attribute is not implemented nor exists.
	 * @throws NumberFormatException if the value was originally a String and can't be converted.
	 */
	public Integer getInteger(String attributeName, Integer def)
	{
		Object obj = attributes.get(attributeName.toLowerCase());
		if (obj == null)
			return def;
		return createForType(attributeName, obj, Integer.class);
	}

	/**
	 * Gets the integer value of an arbitrary object attribute.
	 * If the value is castable to Float, it is cast to a Float.
	 * <p>
	 * Strings are attempted to be parsed as floating point numbers. Integers are promoted.
	 * Booleans are 1.0 if true, 0.0 if false.
	 * @param attributeName the attribute name (may be standardized, depending on implementation).
	 * @param value the attribute value.
	 * @throws NumberFormatException if the value was originally a String and can't be converted.
	 */
	public void setFloat(String attributeName, Float value)
	{
		attributes.put(attributeName.toLowerCase(), value);
	}

	/**
	 * Gets the integer value of an arbitrary object attribute.
	 * If the value is castable to Float, it is cast to a Float.
	 * <p>
	 * Strings are attempted to be parsed as floating point numbers. Integers are promoted.
	 * Booleans are 1.0 if true, 0.0 if false.
	 * @param attributeName the attribute name (may be standardized, depending on implementation).
	 * @return the floating-point value of an object attribute, or <code>null</code> if the attribute is not implemented nor exists.
	 * @throws NumberFormatException if the value was originally a String and can't be converted.
	 */
	public Float getFloat(String attributeName)
	{
		return getFloat(attributeName, null);
	}

	/**
	 * Gets the integer value of an arbitrary object attribute.
	 * If the value is castable to Float, it is cast to a Float.
	 * <p>
	 * Strings are attempted to be parsed as floating point numbers. Integers are promoted.
	 * Booleans are 1.0 if true, 0.0 if false.
	 * @param attributeName the attribute name (may be standardized, depending on implementation).
	 * @param def the default value if one does not exist.
	 * @return the floating-point value of an object attribute, or <code>def</code> if the attribute is not implemented nor exists.
	 * @throws NumberFormatException if the value was originally a String and can't be converted.
	 */
	public Float getFloat(String attributeName, Float def)
	{
		Object obj = attributes.get(attributeName.toLowerCase());
		if (obj == null)
			return def;
		return createForType(attributeName, obj, Float.class);
	}

	/**
	 * Sets the string value of an arbitrary object attribute.
	 * If the value is promotable to String (integers/floats/booleans), it is promoted to a String.
	 * @param attributeName the attribute name (may be standardized, depending on implementation).
	 * @param value the attribute value.
	 */
	public void setString(String attributeName, String value)
	{
		attributes.put(attributeName.toLowerCase(), value);
	}

	/**
	 * Gets the string value of an arbitrary object attribute.
	 * If the value is promotable to String (integers/floats/booleans), it is promoted to a String.
	 * @param attributeName the attribute name (may be standardized, depending on implementation).
	 * @return the string value of an object attribute, or <code>null</code> if the attribute is not implemented nor exists.
	 */
	public String getString(String attributeName)
	{
		return getString(attributeName, null);
	}
	
	/**
	 * Gets the string value of an arbitrary object attribute.
	 * If the value is promotable to String (integers/floats/booleans), it is promoted to a String.
	 * @param attributeName the attribute name (may be standardized, depending on implementation).
	 * @param def the default value if one does not exist.
	 * @return the string value of an object attribute, or <code>def</code> if the attribute is not implemented nor exists.
	 */
	public String getString(String attributeName, String def)
	{
		Object obj = attributes.get(attributeName.toLowerCase());
		if (obj == null)
			return def;
		return String.valueOf(obj);
	}

	@Override
	public Iterator<Entry<String, Object>> iterator()
	{
		return attributes.entrySet().iterator();
	}

	@SuppressWarnings("unchecked")
	private <T> T createForType(String name, Object obj, Class<T> targetType)
	{
		if (obj instanceof Boolean)
		{
			if (targetType == Boolean.class)
				return (T)(Boolean)obj;
			else if (targetType == Integer.class)
				return (T)Integer.valueOf(((Boolean)obj) ? 1 : 0);
			else if (targetType == Float.class)
				return (T)Float.valueOf(((Boolean)obj) ? 1f : 0f);
			else
				throw new RuntimeException("Cannot convert "+name+". Bad type.");
		}
		else if (obj instanceof Integer)
		{
			if (targetType == Boolean.class)
				return (T)Boolean.valueOf((Integer)obj != 0);
			else if (targetType == Integer.class)
				return (T)(Integer)obj;
			else if (targetType == Float.class)
				return (T)Float.valueOf(((Integer)obj).floatValue());
			else
				throw new RuntimeException("Cannot convert "+name+". Bad type.");
		}
		else if (obj instanceof Float)
		{
			if (targetType == Boolean.class)
				return (T)Boolean.valueOf((Float)obj != 0);
			else if (targetType == Integer.class)
				return (T)Integer.valueOf(((Float)obj).intValue());
			else if (targetType == Float.class)
				return (T)(Float)obj;
			else
				throw new RuntimeException("Cannot convert "+name+". Bad type.");
		}
		else if (obj instanceof String)
		{
			if (targetType == Boolean.class)
				return (T)(Boolean)parseBoolean((String)obj, false);
			else if (targetType == Integer.class)
				return (T)(Integer)parseInt((String)obj, 0);
			else if (targetType == Float.class)
				return (T)(Float)parseFloat((String)obj, 0f);
			else
				throw new RuntimeException("Cannot convert "+name+". Bad type.");
		}
		else
		{
			throw new RuntimeException("Cannot convert "+name+". Bad type.");
		}
	}

	private boolean parseBoolean(String s, boolean def)
	{
		if (isStringEmpty(s))
			return def;
		else if (!s.equalsIgnoreCase("true"))
			return false;
		else
			return true;
	}

	private int parseInt(String s, int def)
	{
		if (isStringEmpty(s))
			return def;
		try {
			return Integer.parseInt(s);
		} catch (NumberFormatException e) {
			return 0;
		}
	}

	private float parseFloat(String s, float def)
	{
		if (isStringEmpty(s))
			return def;
		try {
			return Float.parseFloat(s);
		} catch (NumberFormatException e) {
			return 0f;
		}
	}

	private boolean isStringEmpty(Object obj)
	{
		if (obj == null)
			return true;
		else
			return ((String)obj).trim().length() == 0;
	}
	
}
