/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.texture;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import net.mtrop.doom.object.BinaryObject;
import net.mtrop.doom.struct.io.SerialReader;
import net.mtrop.doom.struct.io.SerialWriter;
import net.mtrop.doom.util.NameUtils;

/**
 * This is the lump that contains a collection of Doom-formatted textures.
 * All textures are stored in here, usually named TEXTURE1 or TEXTURE2 in the WAD.
 * @author Matthew Tropiano
 */
public class DoomTextureList extends CommonTextureList<DoomTextureList.Texture> implements BinaryObject
{
	/**
	 * Creates a new TextureList with a default starting capacity.
	 */
	public DoomTextureList()
	{
		super();
	}

	/**
	 * Creates a new TextureList with a specific starting capacity.
	 * @param capacity the starting capacity.
	 */
	public DoomTextureList(int capacity)
	{
		super(capacity);
	}

	@Override
	public Texture createTexture(String texture) 
	{
		Texture out = new Texture(texture);
		addCreatedTexture(out);
		return out;
	}

	@Override
	public void readBytes(InputStream in) throws IOException
	{
		clear();
		SerialReader sr = new SerialReader(SerialReader.LITTLE_ENDIAN);
		int n = sr.readInt(in);
		
		in.skip(n*4);
		
		while(n-- > 0)
		{
			Texture t = new Texture();
			t.readBytes(in);
			addCreatedTexture(t);
		}
	}

	/**
	 * This class represents a single texture entry in a TEXTURE1/TEXTURE2 lump.
	 * Doom Textures have the same binary representation in Heretic and Hexen. 
	 * @author Matthew Tropiano
	 */
	public static class Texture extends CommonTexture<Texture.Patch>
	{
		private Texture()
		{
			super();
		}
		
		/**
		 * Creates a new texture.
		 * @param name the new texture name.
		 * @throws IllegalArgumentException if the texture name is invalid.
		 */
		private Texture(String name)
		{
			super(name);
		}

		@Override
		public Patch createPatch() 
		{
			Patch out = new Patch();
			patches.add(out);
			return out;
		}

		@Override
		public void readBytes(InputStream in) throws IOException
		{
			SerialReader sr = new SerialReader(SerialReader.LITTLE_ENDIAN);
			name = NameUtils.toValidTextureName(NameUtils.nullTrim(sr.readString(in, 8, "ASCII")));
			sr.readShort(in);
			sr.readShort(in);
			width = sr.readUnsignedShort(in);
			height = sr.readUnsignedShort(in);
			sr.readShort(in);
			sr.readShort(in);
			
			patches.clear();
			
			int n = sr.readUnsignedShort(in);
			while (n-- > 0)
			{
				Patch p = new Patch();
				p.readBytes(in);
				patches.add(p);
			}
		}
		
		@Override
		public void writeBytes(OutputStream out) throws IOException
		{
			SerialWriter sw = new SerialWriter(SerialWriter.LITTLE_ENDIAN);
			sw.writeBytes(out, NameUtils.toASCIIBytes(name, 8));
			sw.writeUnsignedShort(out, 0);
			sw.writeUnsignedShort(out, 0);
			sw.writeUnsignedShort(out, width);
			sw.writeUnsignedShort(out, height);
			sw.writeUnsignedShort(out, 0);
			sw.writeUnsignedShort(out, 0);
			sw.writeUnsignedShort(out, patches.size());
			for (Patch p : patches)
				p.writeBytes(out);
		}
		
		/**
		 * Singular patch entry for a texture.
		 */
		public static class Patch extends CommonPatch
		{
			/** The length of a single patch. */
			public static final int LENGTH = 10;
			
			@Override
			public void readBytes(InputStream in) throws IOException
			{
				SerialReader sr = new SerialReader(SerialReader.LITTLE_ENDIAN);
				originX = sr.readShort(in);
				originY = sr.readShort(in);
				patchIndex = sr.readUnsignedShort(in);
				sr.readShort(in);
				sr.readShort(in);
			}
			
			@Override
			public void writeBytes(OutputStream out) throws IOException
			{
				SerialWriter sw = new SerialWriter(SerialWriter.LITTLE_ENDIAN);
				sw.writeShort(out, (short)originX);
				sw.writeShort(out, (short)originY);
				sw.writeUnsignedShort(out, patchIndex);
				sw.writeUnsignedShort(out, 1);
				sw.writeUnsignedShort(out, 0);
			}

		}
		
	}

}
