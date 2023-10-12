/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.map;

/**
 * This class provides a means for reading map data in a data- or implementation-agnostic way.
 * Each of the methods take an arbitrary field type enumeration. Each implementation of this view
 * should be clear as to what those valid values are.
 * @param <T> the type of element that this handles.
 * @author Matthew Tropiano
 * @since 2.6.0
 */
public interface MapElementView<T>
{
	/**
	 * Gets the corresponding value on the element.
	 * If the field type is not valid for this element, this returns <code>null</code>.
	 * @param source the source object.
	 * @param fieldType the field type to retrieve.
	 * @return the corresponding value or <code>null</code> if the field type is not valid.
	 */
	Object getValue(T source, int fieldType);

	/**
	 * Gets the corresponding value on the element as a boolean.
	 * If the field type is not valid for this element, this returns <code>null</code>.
	 * Numeric values return <code>true</code> if nonzero, and String values are <code>true</code> if they are not blank.
	 * @param source the source object.
	 * @param fieldType the field type to retrieve.
	 * @return the corresponding value or <code>null</code> if the field type is not valid.
	 */
	default Boolean getBoolean(T source, int fieldType) 
	{
		Object obj;
		if ((obj = getValue(source, fieldType)) != null)
		{
			if (obj instanceof Boolean)
			{
				return ((Boolean)obj);
			}
			else if (obj instanceof Number)
			{
				double d = ((Number)obj).doubleValue();
				return !Double.isNaN(d) && d != 0.0;
			}
			else if (obj instanceof String)
			{
				return !((String)obj).trim().isEmpty();
			}
			return null;
		}
		return null;
	}

	/**
	 * Gets the corresponding value on the element as a boolean.
	 * If the field type is not valid for this element, this returns <code>def</code>.
	 * Numeric values return <code>true</code> if nonzero, and String values are <code>true</code> if they are not blank.
	 * @param source the source object.
	 * @param fieldType the field type to retrieve.
	 * @param def the default value to return if the field type is not valid.
	 * @return the corresponding value or <code>def</code> if the field type is not valid.
	 */
	default boolean getBoolean(T source, int fieldType, boolean def) 
	{
		Boolean out;
		if ((out = getBoolean(source, fieldType)) == null)
			return def;
		return out;
	}

	/**
	 * Gets the corresponding value on the element as an integer.
	 * If the field type is not valid for this element, this returns <code>null</code>.
	 * Boolean values return <code>1</code> if true, and String values are converted to integer (or <code>null</code> if not convertible).
	 * @param source the source object.
	 * @param fieldType the field type to retrieve.
	 * @return the corresponding value or <code>null</code> if the field type is not valid.
	 */
	default Integer getInteger(T source, int fieldType)
	{
		Object obj;
		if ((obj = getValue(source, fieldType)) != null)
		{
			if (obj instanceof Boolean)
			{
				return ((Boolean)obj) ? 1 : 0;
			}
			else if (obj instanceof Number)
			{
				return ((Number)obj).intValue();
			}
			else if (obj instanceof String)
			{
				try {
					return Integer.parseInt((String)obj);
				} catch (NumberFormatException e) {
					return null;
				}
			}
			return null;
		}
		return null;
	}

	/**
	 * Gets the corresponding value on the element as an integer.
	 * If the field type is not valid for this element, this returns <code>def</code>.
	 * Boolean values return <code>1</code> if true <code>0</code> if false, and String values 
	 * are converted to integer (or <code>def</code> if not convertible).
	 * @param source the source object.
	 * @param fieldType the field type to retrieve.
	 * @param def the default value to return if the field type is not valid.
	 * @return the corresponding value or <code>def</code> if the field type is not valid.
	 */
	default int getInteger(T source, int fieldType, int def)
	{
		Integer out;
		if ((out = getInteger(source, fieldType)) == null)
			return def;
		return out;
	}

	/**
	 * Gets the corresponding value on the element as a float.
	 * If the field type is not valid for this element, this returns <code>null</code>.
	 * Boolean values return <code>1f</code> if true, <code>0f</code> if false, and String values 
	 * are converted to float (or <code>null</code> if not convertible).
	 * @param source the source object.
	 * @param fieldType the field type to retrieve.
	 * @return the corresponding value or <code>null</code> if the field type is not valid.
	 */
	default Float getFloat(T source, int fieldType)
	{
		Object obj;
		if ((obj = getValue(source, fieldType)) != null)
		{
			if (obj instanceof Boolean)
			{
				return ((Boolean)obj) ? 1f : 0f;
			}
			else if (obj instanceof Number)
			{
				return ((Number)obj).floatValue();
			}
			else if (obj instanceof String)
			{
				try {
					return Float.parseFloat((String)obj);
				} catch (NumberFormatException e) {
					return null;
				}
			}
			return null;
		}
		return null;
	}

	/**
	 * Gets the corresponding value on the element as a float.
	 * If the field type is not valid for this element, this returns <code>def</code>.
	 * Boolean values return <code>1f</code> if true, <code>0f</code> if false, and String values 
	 * are converted to float (or <code>def</code> if not convertible).
	 * @param source the source object.
	 * @param fieldType the field type to retrieve.
	 * @param def the default value to return if the field type is not valid.
	 * @return the corresponding value or <code>def</code> if the field type is not valid.
	 */
	default float getFloat(T source, int fieldType, float def) 
	{
		Float out;
		if ((out = getFloat(source, fieldType)) == null)
			return def;
		return out;
	}

	/**
	 * Gets the corresponding value on the element as a long.
	 * If the field type is not valid for this element, this returns <code>null</code>.
	 * Boolean values return <code>1L</code> if true, <code>0L</code> if false, and String values 
	 * are converted to long (or <code>null</code> if not convertible).
	 * @param source the source object.
	 * @param fieldType the field type to retrieve.
	 * @return the corresponding value or <code>null</code> if the field type is not valid.
	 */
	default Long getLong(T source, int fieldType)
	{
		Object obj;
		if ((obj = getValue(source, fieldType)) != null)
		{
			if (obj instanceof Boolean)
			{
				return ((Boolean)obj) ? 1L : 0L;
			}
			else if (obj instanceof Number)
			{
				return ((Number)obj).longValue();
			}
			else if (obj instanceof String)
			{
				try {
					return Long.parseLong((String)obj);
				} catch (NumberFormatException e) {
					return null;
				}
			}
			return null;
		}
		return null;
	}

	/**
	 * Gets the corresponding value on the element as a double.
	 * If the field type is not valid for this element, this returns <code>def</code>.
	 * Boolean values return <code>1L</code> if true, <code>0L</code> if false, and String values 
	 * are converted to long (or <code>def</code> if not convertible).
	 * @param source the source object.
	 * @param fieldType the field type to retrieve.
	 * @param def the default value to return if the field type is not valid.
	 * @return the corresponding value or <code>def</code> if the field type is not valid.
	 */
	default long getLong(T source, int fieldType, long def)
	{
		Long out;
		if ((out = getLong(source, fieldType)) == null)
			return def;
		return out;
	}

	/**
	 * Gets the corresponding value on the element as a double.
	 * If the field type is not valid for this element, this returns <code>null</code>.
	 * Boolean values return <code>1.0</code> if true, <code>0.0</code> if false, and String values 
	 * are converted to double (or <code>null</code> if not convertible).
	 * @param source the source object.
	 * @param fieldType the field type to retrieve.
	 * @return the corresponding value or <code>null</code> if the field type is not valid.
	 */
	default Double getDouble(T source, int fieldType)
	{
		Object obj;
		if ((obj = getValue(source, fieldType)) != null)
		{
			if (obj instanceof Boolean)
			{
				return ((Boolean)obj) ? 1.0 : 0.0;
			}
			else if (obj instanceof Number)
			{
				return ((Number)obj).doubleValue();
			}
			else if (obj instanceof String)
			{
				try {
					return Double.parseDouble((String)obj);
				} catch (NumberFormatException e) {
					return null;
				}
			}
			return null;
		}
		return null;
	}

	/**
	 * Gets the corresponding value on the element as a double.
	 * If the field type is not valid for this element, this returns <code>null</code>.
	 * Boolean values return <code>1.0</code> if true, <code>0.0</code> if false, and String values 
	 * are converted to double (or <code>null</code> if not convertible).
	 * @param source the source object.
	 * @param fieldType the field type to retrieve.
	 * @param def the default value to return if the field type is not valid.
	 * @return the corresponding value or <code>def</code> if the field type is not valid.
	 */
	default double getDouble(T source, int fieldType, double def)
	{
		Double out;
		if ((out = getDouble(source, fieldType)) == null)
			return def;
		return out;
	}

	/**
	 * Gets the corresponding value on the element as a String.
	 * If the field type is not valid for this element, this returns <code>null</code>.
	 * If the value is not a String, it will be converted to one.
	 * @param source the source object.
	 * @param fieldType the field type to retrieve.
	 * @return the corresponding value or <code>null</code> if the field type is not valid.
	 */
	default String getString(T source, int fieldType)
	{
		Object obj;
		if ((obj = getValue(source, fieldType)) != null)
			return obj.toString();
		return null;
	}

	/**
	 * Gets the corresponding value on the element as a String.
	 * If the field type is not valid for this element, this returns <code>def</code>.
	 * If the value is not a String, it will be converted to one.
	 * @param source the source object.
	 * @param fieldType the field type to retrieve.
	 * @param def the default value to return if the field type is not valid.
	 * @return the corresponding value or <code>def</code> if the field type is not valid.
	 */
	default String getString(T source, int fieldType, String def) 
	{
		String out;
		if ((out = getString(source, fieldType)) == null)
			return def;
		return out;
	}

}
