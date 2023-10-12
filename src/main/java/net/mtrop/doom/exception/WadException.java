/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.exception;

import java.io.IOException;

/**
 * An exception thrown when an operation on a WAD file would violate its
 * structural integrity in some way.
 * @author Matthew Tropiano
 */
public class WadException extends IOException
{
	private static final long serialVersionUID = 7393763909497049387L;

	public WadException()
	{
		super();
	}

	public WadException(String message, Throwable cause)
	{
		super(message, cause);
	}

	public WadException(String message)
	{
		super(message);
	}

	public WadException(Throwable cause)
	{
		super(cause);
	}
	
}
