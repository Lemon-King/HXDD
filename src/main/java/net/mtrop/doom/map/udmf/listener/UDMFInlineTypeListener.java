/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.map.udmf.listener;

import net.mtrop.doom.map.udmf.UDMFObject;
import net.mtrop.doom.map.udmf.UDMFParserListener;

/**
 * A parser listener that listens for specific structure/object types, however,
 * unlike {@link UDMFTypeListener}, this reuses the same UDMFObject per read. 
 * Do not store the reference to the read object anywhere because the next read will overwrite its contents! 
 * @author Matthew Tropiano
 */
public abstract class UDMFInlineTypeListener implements UDMFParserListener
{
	/** Current object being read. */
	private UDMFObject current;

	@Override
	public void onStart()
	{
		this.current = null;
	}

	@Override
	public void onEnd()
	{
		this.current = null;
	}

	@Override
	public void onAttribute(String name, Object value)
	{
		if (current != null)
			current.set(name, value);
		else
			onGlobalAttribute(name, value);
	}

	@Override
	public void onObjectStart(String name)
	{
		if (current == null)
			current = new UDMFObject();
		else
			current.clear();
	}

	@Override
	public void onObjectEnd(String name)
	{
		onType(name, current);
	}

	@Override
	public abstract void onParseError(String error);

	/**
	 * Called when a global attribute is encountered.
	 * @param name the name of the attribute.
	 * @param value the parsed value.
	 */
	public abstract void onGlobalAttribute(String name, Object value);
	
	/**
	 * Called when the parser has finished reading an object.
	 * @param type the object type.
	 * @param object the object itself.
	 */
	public abstract void onType(String type, UDMFObject object);
	
}

