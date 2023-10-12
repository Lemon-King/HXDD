/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.exception;

/**
 * An exception thrown when Doom texture information is unavailable or malformed.
 * @author Matthew Tropiano
 */
public class TextureException extends RuntimeException
{
	private static final long serialVersionUID = 4553734950678544532L;

	public TextureException()
	{
		super();
	}

	public TextureException(String message, Throwable cause)
	{
		super(message, cause);
	}

	public TextureException(String message)
	{
		super(message);
	}

	public TextureException(Throwable cause)
	{
		super(cause);
	}
	
}
