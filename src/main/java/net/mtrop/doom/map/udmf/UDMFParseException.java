/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.map.udmf;

/**
 * An exception thrown on UDMF parse errors.
 * @author Matthew Tropiano
 */
public class UDMFParseException extends RuntimeException
{
	private static final long serialVersionUID = 1102498826055072221L;
	
	public UDMFParseException()
	{
		super();
	}
	
	public UDMFParseException(String message)
	{
		super(message);
	}

}
