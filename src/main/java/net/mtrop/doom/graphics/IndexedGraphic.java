/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.graphics;

/**
 * Interface for graphic data with indexed palettes.
 * @author Matthew Tropiano
 * @since 2.2.0
 * @deprecated Since 2.13.0 - made superfluous.
 */
public interface IndexedGraphic
{
	/**
	 * @return the width of this graphic in pixels.
	 */
	public int getWidth();
	
	/**
	 * @return the height of this graphic in pixels.
	 */
	public int getHeight();

	/**
	 * Gets the pixel data at a location in the graphic.
	 * May return -1 if this graphic has translucent pixels. 
	 * @param x	graphic x-coordinate.
	 * @param y	graphic y-coordinate.
	 * @return a palette index value from 0 to 255, or {@link Picture#PIXEL_TRANSLUCENT} if translucent.
	 * @throws ArrayIndexOutOfBoundsException if the provided coordinates is outside the graphic.
	 */
	public int getPixel(int x, int y);

}
