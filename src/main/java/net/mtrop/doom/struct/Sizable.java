/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.struct;

/**
 * Describes a class that contains an amount of discrete objects.
 * @author Matthew Tropiano
 */
public interface Sizable
{
	/**
	 * @return the amount of individual objects that this object contains.
	 */
	public int size();
	
	/**
	 * Returns if this object contains no objects.
	 * The general policy of this method is that this returns true if
	 * and only if {@link #size()} returns 0.  
	 * @return true if so, false otherwise.
	 */
	public boolean isEmpty();
	
}