/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.graphics;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import net.mtrop.doom.object.BinaryObject;
import net.mtrop.doom.object.GraphicObject;
import net.mtrop.doom.util.RangeUtils;

/**
 * Doom graphic data that has no header data for its dimensions/offsets.
 * <p>
 * Normally, flats are the floor/ceiling textures in the Doom engine that are
 * a set size (64x64) and thus have no need for header information, but fullscreen
 * pictures like Doom's TITLEPIC are also a straight mapping of pixels with assumed
 * dimensions (in this case, 320x200). This class can read both, and its dimensions can
 * be arbitrarily set by the programmer regardless of the amount of data inside.
 * <p>
 * NOTE: The {@link Flat#readBytes(InputStream)} method will only read as many bytes as possible to fill the
 * current dimensions of the flat, as this information is not found in the byte data.
 * @author Matthew Tropiano
 */
public class Flat implements BinaryObject, GraphicObject
{
	/** This flat's width. */
	private int width;
	/** This flat's height. */
	private int height;
	/** The pixel data. */
	private byte[] pixels;
	
	/**
	 * Creates a new flat.
	 * @param width	the width of the flat in pixels. Must be greater than 1.
	 * @param height the height of the flat in pixels. Must be greater than 1.
	 */
	public Flat(int width, int height)
	{
		if (width < 1 || height < 1)
			throw new IllegalArgumentException("Width or height cannot be less than 1.");
		setDimensions(width, height);
	}

	/**
	 * Reads and creates a new Flat object from an array of bytes.
	 * This reads until it reaches the end of the entry list.
	 * @param width	the width of the flat in pixels. Must be greater than 1.
	 * @param height the height of the flat in pixels. Must be greater than 1.
	 * @param bytes the byte array to read.
	 * @return a new Switches object.
	 * @throws IOException if the stream cannot be read.
	 */
	public static Flat create(int width, int height, byte[] bytes) throws IOException
	{
		Flat out = new Flat(width, height);
		out.fromBytes(bytes);
		return out;
	}
	
	/**
	 * Reads and creates a new Flat from an {@link InputStream} implementation.
	 * This reads from the stream until enough bytes for the full {@link Flat} are read.
	 * The stream is NOT closed at the end.
	 * @param width	the width of the flat in pixels. Must be greater than 1.
	 * @param height the height of the flat in pixels. Must be greater than 1.
	 * @param in the open {@link InputStream} to read from.
	 * @return a new Flat with its fields set.
	 * @throws IOException if the stream cannot be read.
	 */
	public static Flat read(int width, int height, InputStream in) throws IOException
	{
		Flat out = new Flat(width, height);
		out.readBytes(in);
		return out;
	}
	
	@Override
	public int getOffsetX()
	{
		return 0;
	}

	@Override
	public int getOffsetY()
	{
		return 0;
	}

	@Override
	public int getWidth()
	{
		return width;
	}
	
	@Override
	public int getHeight()
	{
		return height;
	}
	
	/**
	 * Clears the pixel data to zeroes.
	 */
	public void clear()
	{
		setDimensions(width, height);
	}

	/**
	 * Sets the dimensions of this flat.
	 * WARNING: This will clear all of the data in the flat.
	 * @param width	the width of the flat in pixels.
	 * @param height the height of the flat in pixels.
	 */
	public void setDimensions(int width, int height)
	{
		this.width = width;
		this.height = height;
		pixels = new byte[width*height];
	}

	/**
	 * Sets the pixel data at a location in the flat.
	 * Valid values are in the range of 0 to 255, with 0 to 255 being palette indexes.
	 * @param x	patch x-coordinate.
	 * @param y	patch y-coordinate.
	 * @param value	the value to set.
	 * @throws IllegalArgumentException if the value of the pixel is outside the range 0 to 255.
	 * @throws ArrayIndexOutOfBoundsException if the provided coordinates is outside the graphic.
	 */
	public void setPixel(int x, int y, int value)
	{
		RangeUtils.checkByteUnsigned("Pixel ("+x+", "+y+")", value);
		pixels[y*width + x] = (byte)value;
	}
	
	/**
	 * Gets the pixel data at a location in the flat.
	 * @param x	flat x-coordinate.
	 * @param y	flat y-coordinate.
	 * @return a palette index value from 0 to 255.
	 * @throws ArrayIndexOutOfBoundsException if the provided coordinates is outside the graphic.
	 */
	public int getPixel(int x, int y)
	{
		return pixels[y*width + x] & 0x0ff;
	}
	
	@Override
	public void readBytes(InputStream in) throws IOException
	{
		int len = width * height;
		for (int i = 0; i < len; i++)
		{
			int b = in.read();
			if (b == -1)
				throw new IOException("end of stream reached after index "+i);
			pixels[i] = (byte)(b & 0x0ff);
		}
	}

	@Override
	public void writeBytes(OutputStream out) throws IOException
	{
		for (byte pixel : pixels)
			out.write(pixel & 0x0ff);
	}

}
