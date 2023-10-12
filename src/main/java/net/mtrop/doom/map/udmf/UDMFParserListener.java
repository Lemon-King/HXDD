/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.map.udmf;

/**
 * A listener for each new parsed entry or field that gets parsed in a UDMF structure.
 * @author Matthew Tropiano
 */
public interface UDMFParserListener
{
	/**
	 * Called when reading a UDMF document starts.
	 */
	void onStart();

	/**
	 * Called when reading a UDMF document ends.
	 */
	void onEnd();

	/**
	 * Called when an attribute is read from a UDMF structure.
	 * @param name the name of the field.
	 * @param value the parsed value.
	 */
	void onAttribute(String name, Object value);

	/**
	 * Called when the start of an object is read from a UDMF structure.
	 * @param name the name (type) of the structure.
	 */
	void onObjectStart(String name);

	/**
	 * Called when an object is ended in a UDMF structure.
	 * @param name the name (type) of the structure.
	 */
	void onObjectEnd(String name);
	
	/**
	 * Called when a parsing error occurs.
	 * @param error the error message.
	 */
	void onParseError(String error);
}
