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
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import net.mtrop.doom.object.BinaryObject;
import net.mtrop.doom.struct.Sizable;
import net.mtrop.doom.struct.io.SerialReader;
import net.mtrop.doom.struct.io.SerialWriter;
import net.mtrop.doom.util.NameUtils;

/**
 * This class represents the contents of a Boom Engine ANIMATED
 * lump. This lump contains extended information regarding animated
 * flats and textures.
 * @author Matthew Tropiano
 */
public class Animated implements BinaryObject, Iterable<Animated.Entry>, Sizable
{
	/**
	 * Enumeration of Animated Entry Texture types. 
	 */
	public static enum TextureType
	{
		FLAT,
		TEXTURE;
	}
	
	/** List of entries. */
	protected List<Entry> entryList;
	
	/**
	 * Creates a new ANIMATED lump.
	 */
	public Animated()
	{
		entryList = new ArrayList<Entry>(20);
	}
	
	/**
	 * Creates a flat entry.
	 * @param lastName	the last name in the sequence.
	 * @param firstName the first name in the sequence.
	 * @param ticks the amount of ticks between each frame.
	 * @return a new entry detailing an animated texture.
	 * @throws IllegalArgumentException if <code>lastName</code> or <code>firstName</code> is not a valid texture name, or frame ticks is less than 1.
	 */
	public static Entry flat(String lastName, String firstName, int ticks)
	{
		NameUtils.checkValidTextureName(lastName);
		NameUtils.checkValidTextureName(firstName);
		if (ticks < 1 || ticks > Integer.MAX_VALUE)
			throw new IllegalArgumentException("Frame ticks must be between 1 and 2^31 - 1.");
		
		return new Entry(false, lastName, firstName, ticks);
	}

	/**
	 * Creates a texture entry.
	 * @param lastName	the last name in the sequence.
	 * @param firstName the first name in the sequence.
	 * @param ticks the amount of ticks between each frame.
	 * @return a new entry detailing an animated texture.
	 * @throws IllegalArgumentException if <code>lastName</code> or <code>firstName</code> is not a valid texture name, or frame ticks is less than 1.
	 */
	public static Entry texture(String lastName, String firstName, int ticks)
	{
		return new Entry(true, false, lastName, firstName, ticks);
	}

	/**
	 * Creates a texture entry.
	 * @param lastName	the last name in the sequence.
	 * @param firstName the first name in the sequence.
	 * @param ticks the amount of ticks between each frame.
	 * @param decals if true, allows decals to be placed on this texture, false if not.
	 * @return a new entry detailing an animated texture.
	 * @throws IllegalArgumentException if <code>lastName</code> or <code>firstName</code> is not a valid texture name, or frame ticks is less than 1.
	 */
	public static Entry texture(String lastName, String firstName, int ticks, boolean decals)
	{
		NameUtils.checkValidTextureName(lastName);
		NameUtils.checkValidTextureName(firstName);
		if (ticks < 1 || ticks > Integer.MAX_VALUE)
			throw new IllegalArgumentException("Frame ticks must be between 1 and 2^31 - 1.");
		
		return new Entry(true, decals, lastName, firstName, ticks);
	}

	/**
	 * Adds an entry to this Animated lump.
	 * @param entry the entry to add.
	 * @see #flat(String, String, int)
	 * @see #texture(String, String, int)
	 * @see #texture(String, String, int, boolean)
	 */
	public void addEntry(Entry entry)
	{
		entryList.add(entry);
	}
	
	/**
	 * Returns an Animated entry at a specific index.
	 * @param i the index of the entry to return.
	 * @return the corresponding entry, or <code>null</code> if no corresponding entry for that index.
	 * @throws IndexOutOfBoundsException if the index is out of range (less than 0 or greater than or equal to getFlatCount()).
	 */
	public Entry get(int i)
	{
		return entryList.get(i);
	}

	/**
	 * Removes an Animated entry at a specific index.
	 * @param i the index of the entry to remove.
	 * @return the corresponding removed entry, or <code>null</code> if no corresponding entry for that index.
	 * @throws IndexOutOfBoundsException if the index is out of range (less than 0 or greater than or equal to getSwitchCount()).
	 */
	public Entry removeEntry(int i)
	{
		return entryList.remove(i);
	}

	/**
	 * @return the amount of switch entries in this lump.
	 */
	public int getEntryCount()
	{
		return entryList.size();
	}

	@Override
	public void readBytes(InputStream in) throws IOException
	{
		entryList.clear();
		Entry e = null;
		do {
			e = new Entry();
			e.readBytes(in);
			if (e.type != null)
				entryList.add(e);
		} while (e.type != null);
	}

	@Override
	public void writeBytes(OutputStream out) throws IOException
	{
		for (Entry e : entryList) 
			e.writeBytes(out);
		(new Entry()).writeBytes(out);
	}

	@Override
	public Iterator<Entry> iterator()
	{
		return entryList.iterator();
	}
	
	@Override
	public int size() 
	{
		return entryList.size();
	}

	@Override
	public boolean isEmpty() 
	{
		return entryList.isEmpty();
	}

	/** Flat entry for ANIMATED. */
	public static class Entry implements BinaryObject
	{
		/** Length of a single entry in bytes. */
		public static final int LENGTH = 23;
		
		/** Is this a texture entry? If not, it's a flat. */
		protected TextureType type;
		/** The last texture name. */
		protected String lastName;
		/** The first texture name. */
		protected String firstName;
		/** Allows decals. */
		protected boolean allowsDecals;
		/** The amount of ticks between each frame. */
		protected int ticks;
		
		/**
		 * Creates a new Entry (terminal type).
		 */
		private Entry()
		{
			this(null, "\0\0\0\0\0\0\0\0", "\0\0\0\0\0\0\0\0", 1);
		}
		
		/**
		 * Creates a new Entry.
		 * @param texture	is this a texture entry (as opposed to a flat)?
		 * @param lastName	the last name in the sequence.
		 * @param firstName the first name in the sequence.
		 * @param ticks the amount of ticks between each frame.
		 */
		private Entry(boolean texture, String lastName, String firstName, int ticks)
		{
			this(texture ? TextureType.TEXTURE : TextureType.FLAT, false, lastName, firstName, ticks);
		}

		/**
		 * Creates a new Entry.
		 * @param texture	is this a texture entry (as opposed to a flat)?
		 * @param allowsDecals if true, this texture allows decals.
		 * @param lastName	the last name in the sequence.
		 * @param firstName the first name in the sequence.
		 * @param ticks the amount of ticks between each frame.
		 */
		private Entry(boolean texture, boolean allowsDecals, String lastName, String firstName, int ticks)
		{
			this(texture ? TextureType.TEXTURE : TextureType.FLAT, lastName, firstName, ticks);
		}

		/**
		 * Creates a new Entry.
		 * @param type		what is the type of this animated entry (TEXTURE/FLAT)?
		 * @param lastName	the last name in the sequence.
		 * @param firstName the first name in the sequence.
		 * @param ticks the amount of ticks between each frame.
		 */
		Entry(TextureType type, String lastName, String firstName, int ticks)
		{
			this(type, false, lastName, firstName, ticks);
		}

		/**
		 * Creates a new Entry.
		 * @param type what is the type of this animated entry (TEXTURE/FLAT)?
		 * @param allowsDecals if true, this texture allows decals.
		 * @param lastName	the last name in the sequence.
		 * @param firstName the first name in the sequence.
		 * @param ticks the amount of ticks between each frame.
		 */
		Entry(TextureType type, boolean allowsDecals, String lastName, String firstName, int ticks)
		{
			this.type = type;
			this.allowsDecals = allowsDecals;
			this.lastName = lastName;
			this.firstName = firstName;
			this.ticks = ticks;
		}

		/**
		 * Is this a texture entry?
		 * @return true if it is, false if not (it's a flat, then).
		 */
		public boolean isTexture()
		{
			return type == TextureType.TEXTURE;
		}

		/**
		 * @return the texture type of the entry (for FLAT or TEXTURE? null if terminal entry).
		 */
		public TextureType getType()
		{
			return type;
		}

		/**
		 * Returns if this texture allows decals on it, despite it being animated.
		 * @return true if so, false if not.
		 */
		public boolean getAllowsDecals()
		{
			return allowsDecals;
		}

		/**
		 * @return the last texture/flat name in the animation sequence.
		 */
		public String getLastName()
		{
			return lastName;
		}

		/**
		 * @return the first texture/flat name in the animation sequence.
		 */
		public String getFirstName()
		{
			return firstName;
		}

		/**
		 * @return the amount of ticks between each frame.
		 */
		public int getTicks()
		{
			return ticks;
		}

		@Override
		public void readBytes(InputStream in) throws IOException
		{
			SerialReader sr = new SerialReader(SerialReader.LITTLE_ENDIAN);
			byte b = sr.readByte(in);
			if (b != -1)
			{
				if ((b & 0x01) == 0)
					type = TextureType.FLAT;
				else if ((b & 0x01) != 0)
					type = TextureType.TEXTURE;
				
				if ((b & 0x02) != 0)
					allowsDecals = true;
			}
			else
			{
				type = null;
				return;
			}
			lastName = NameUtils.toValidTextureName(NameUtils.nullTrim(sr.readString(in, 9, "ASCII")));
			firstName = NameUtils.toValidTextureName(NameUtils.nullTrim(sr.readString(in, 9, "ASCII")));
			ticks = sr.readInt(in);
		}

		@Override
		public void writeBytes(OutputStream out) throws IOException
		{
			SerialWriter sw = new SerialWriter(SerialWriter.LITTLE_ENDIAN);
			if (type != null) 
			{
				byte b = (byte)type.ordinal();
				b |= allowsDecals ? 0x02 : 0x00;
				sw.writeByte(out, b);
			}
			else
				sw.writeByte(out, (byte)-1);
			
			sw.writeBytes(out, NameUtils.toASCIIBytes(lastName, 8));
			sw.writeBoolean(out, false); // ensure null terminal
			sw.writeBytes(out, NameUtils.toASCIIBytes(firstName, 8));
			sw.writeBoolean(out, false); // ensure null terminal
			sw.writeInt(out, ticks);
		}
		
		@Override
		public String toString()
		{
			StringBuilder sb = new StringBuilder();
			sb.append("Animated "); 
			sb.append(type != null ? TextureType.values()[type.ordinal()] : "[TERMINAL]");
			sb.append(' ');
			sb.append(lastName);
			sb.append(' ');
			sb.append(firstName);
			sb.append(' ');
			sb.append(ticks);
			sb.append(' ');
			sb.append(allowsDecals ? "DECALS" : "");
			return sb.toString();
		}
		
	}
	
}
