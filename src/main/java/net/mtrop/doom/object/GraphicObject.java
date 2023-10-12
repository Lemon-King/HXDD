/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.object;

import net.mtrop.doom.graphics.Flat;
import net.mtrop.doom.graphics.Picture;

/**
 * Interface for graphic data.
 * @author Matthew Tropiano
 */
public interface GraphicObject
{
	
	/**
	 * @return the offset from the center, horizontally, in pixels.
	 */
	public int getOffsetX();

	/**
	 * @return the offset from the center, vertically, in pixels.
	 */
	public int getOffsetY();

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
	 * <p>If this graphic is an indexed color graphic (i.e. {@link Flat} or {@link Picture}), this
	 * will return a palette index value from 0 to 255, or {@link Picture#PIXEL_TRANSLUCENT} if this graphic has translucent pixels.
	 * <p>For full-color graphics, this returns an ARGB integer value representing the pixel color in RGB space (with Alpha).  
	 * @param x	graphic x-coordinate.
	 * @param y	graphic y-coordinate.
	 * @return a palette index value from 0 to 255, {@link Picture#PIXEL_TRANSLUCENT} if translucent, or an ARGB value.
	 * @throws ArrayIndexOutOfBoundsException if the provided coordinates is outside the graphic.
	 */
	public int getPixel(int x, int y);

	/**
	 * Sets the pixel data at a location in the graphic.
	 * <p>For indexed color graphics, valid values are in the range of -1 to 255, 
	 * with 0 to 254 being palette indexes and {@link Picture#PIXEL_TRANSLUCENT} / 255 being translucent pixels (if supported).
	 * <p>For full-color graphics, the value is an ARGB integer value representing the pixel color in RGB space (with Alpha).
	 * @param x	picture x-coordinate.
	 * @param y	picture y-coordinate.
	 * @param value	the value to set.
	 * @throws IllegalArgumentException if the value is outside a valid range.
	 * @throws ArrayIndexOutOfBoundsException if the provided coordinates is outside the graphic.
	 */
	public void setPixel(int x, int y, int value);
	
}
