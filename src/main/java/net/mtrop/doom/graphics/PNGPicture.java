/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.graphics;

import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import javax.imageio.ImageIO;

import net.mtrop.doom.object.BinaryObject;
import net.mtrop.doom.object.GraphicObject;
import net.mtrop.doom.struct.io.IOUtils;
import net.mtrop.doom.struct.io.PNGContainerReader;
import net.mtrop.doom.struct.io.PNGContainerWriter;
import net.mtrop.doom.struct.io.SerialReader;
import net.mtrop.doom.struct.io.SerialWriter;

/**
 * Represents PNG-formatted data as a decompressed image, preserving offset information (grAb).
 * The export functions write this data back as PNG with offset information.
 * @author Matthew Tropiano
 */
public class PNGPicture implements BinaryObject, GraphicObject
{
	private static final String PNG_OFFSET_CHUNK = "grAb";
	
	/** The inner image. */
	private BufferedImage image;
	/** The offset from the center, horizontally, in pixels. */
	private int offsetX; 
	/** The offset from the center, vertically, in pixels. */
	private int offsetY; 

	/**
	 * Creates a new image with dimensions (1, 1).
	 */
	public PNGPicture()
	{
		this(1, 1);
	}

	/**
	 * Creates a new PNG data image.
	 * @param width	the width of the patch in pixels.
	 * @param height the height of the patch in pixels.
	 */
	public PNGPicture(int width, int height)
	{
		this.image = new BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB);
		this.offsetX = 0;
		this.offsetY = 0;
	}

	/**
	 * Creates a new PNG data image from another image.
	 * @param image	the source image.
	 */
	public PNGPicture(BufferedImage image)
	{
		this(image.getWidth(), image.getHeight());
		setImage(image);
	}

	@Override
	public int getWidth()
	{
		return image.getWidth();
	}

	@Override
	public int getHeight()
	{
		return image.getHeight();
	}

	@Override
	public int getOffsetX()
	{
		return offsetX;
	}

	/**
	 * Sets the offset from the center, horizontally, in pixels.
	 * @param offsetX the new X offset.
	 */
	public void setOffsetX(int offsetX)
	{
		this.offsetX = offsetX;
	}

	@Override
	public int getOffsetY()
	{
		return offsetY;
	}

	/**
	 * Sets the offset from the center, vertically, in pixels.
	 * @param offsetY the new Y offset.
	 */
	public void setOffsetY(int offsetY)
	{
		this.offsetY = offsetY;
	}

	@Override
	public int getPixel(int x, int y)
	{
		return image.getRGB(x, y);
	}

	@Override
	public void setPixel(int x, int y, int value) 
	{
		image.setRGB(x, y, value);
	}

	/**
	 * Sets the pixel data for this graphic using an Image.
	 * @param newImage the image to copy from. 
	 */
	public void setImage(BufferedImage newImage)
	{
		image = new BufferedImage(newImage.getWidth(), newImage.getHeight(), BufferedImage.TYPE_INT_ARGB);
		Graphics2D g2d = (Graphics2D)image.getGraphics();
		g2d.drawImage(newImage, 0, 0, image.getWidth(), image.getHeight(), null);
		g2d.dispose();
	}

	/**
	 * Gets the reference to this image's internal buffered image.
	 * @return the image that this contains.
	 */
	public BufferedImage getImage()
	{
		return image;
	}
	
	@Override
	public void readBytes(InputStream in) throws IOException
	{
		byte[] b = getBinaryContents(in);
		PNGContainerReader pr = new PNGContainerReader(new ByteArrayInputStream(b));
		PNGContainerReader.Chunk cin = null;
		while ((cin = pr.nextChunk()) != null)
		{
			if (cin.getName().equals(PNG_OFFSET_CHUNK))
			{
				ByteArrayInputStream bis = new ByteArrayInputStream(cin.getData());
				SerialReader sr = new SerialReader(SerialReader.BIG_ENDIAN);
				setOffsetX(sr.readInt(bis));
				setOffsetY(sr.readInt(bis));
				break;
			}
		}
		pr.close();
		setImage(ImageIO.read(new ByteArrayInputStream(b)));
	}

	@Override
	public void writeBytes(OutputStream out) throws IOException
	{
		ByteArrayOutputStream ibos = new ByteArrayOutputStream();
		ImageIO.write(image, "PNG", ibos);
		ByteArrayInputStream ibis = new ByteArrayInputStream(ibos.toByteArray());
		PNGContainerReader pr = new PNGContainerReader(ibis);
		PNGContainerReader.Chunk cin = null;

		PNGContainerWriter pw = new PNGContainerWriter(out);

		cin = pr.nextChunk(); // IHDR
		pw.writeChunk(cin.getName(), cin.getData());
		
		ByteArrayOutputStream obos = new ByteArrayOutputStream();
		SerialWriter sw = new SerialWriter(SerialWriter.BIG_ENDIAN);
		sw.writeInt(obos, getOffsetX());
		sw.writeInt(obos, getOffsetY());
		pw.writeChunk(PNG_OFFSET_CHUNK, obos.toByteArray());
		
		while ((cin = pr.nextChunk()) != null)
			pw.writeChunk(cin.getName(), cin.getData());
		pw.close();
		pr.close();
	}

	/**
	 * Retrieves the binary contents of a stream until it hits the end of the stream.
	 * @param in	the input stream to use.
	 * @return		an array of len bytes that make up the data in the stream.
	 * @throws IOException	if the read cannot be done.
	 */
	private byte[] getBinaryContents(InputStream in) throws IOException
	{
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		IOUtils.relay(in, bos);
		return bos.toByteArray();
	}

}
