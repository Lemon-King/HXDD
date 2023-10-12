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
 * This class represents the contents of a Boom Engine SWITCHES
 * lump. This lump contains extended information regarding textures
 * used for in-game switches.
 * @author Matthew Tropiano
 */
public class Switches implements BinaryObject, Iterable<Switches.Entry>, Sizable
{
	/** Enumeration of game types. */
	public static enum Game
	{
		/** No entry should contain this - internal use only. */
		TERMINAL_SPECIAL,
		SHAREWARE_DOOM,
		DOOM,
		ALL;
	}
	
	/** List of entries. */
	protected List<Entry> entryList;
	
	/**
	 * Creates a new SWITCHES lump.
	 */
	public Switches()
	{
		entryList = new ArrayList<Entry>(20);
	}
	
	/**
	 * Returns a switch entry at a specific index.
	 * @param i the index of the entry to return.
	 * @return the corresponding entry, or <code>null</code> if no corresponding entry for that index.
	 * @throws IndexOutOfBoundsException  if the index is out of range (less than 0 or greater than or equal to getFlatCount()).
	 */
	public Entry get(int i)
	{
		return entryList.get(i);
	}
	
	/**
	 * Removes a switch entry at a specific index.
	 * @param i the index of the entry to remove.
	 * @return the corresponding removed entry, or <code>null</code> if no corresponding entry for that index.
	 * @throws IndexOutOfBoundsException  if the index is out of range (less than 0 or greater than or equal to getSwitchCount()).
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
	
	/**
	 * Adds a switch entry to this lump.
	 * The names must be 8 characters or less.
	 * @param offName the "off" name for the switch.
	 * @param onName the "on" name for the switch.
	 * @param game the game type that this switch works with.
	 * @throws IllegalArgumentException if any of the texture names are invalid or game is null.
	 */
	public void addEntry(String offName, String onName, Game game)
	{
		entryList.add(new Entry(offName, onName, game));
	}
	
	@Override
	public void readBytes(InputStream in) throws IOException
	{
		entryList.clear();
		Entry e = null;
		do {
			e = new Entry();
			e.readBytes(in);
			if (e.game != Game.TERMINAL_SPECIAL)
				entryList.add(e);
		} while (e.game != Game.TERMINAL_SPECIAL);
	}

	@Override
	public void writeBytes(OutputStream out) throws IOException
	{
		for (Entry e : entryList) 
			e.writeBytes(out);
		(new Entry()).writeBytes(out); // write blank terminal.
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

	/** Entry for Switches. */
	public static class Entry implements BinaryObject
	{
		/** Length of a single entry in bytes. */
		public static final int LENGTH = 20;

		/** The "off" texture name. */
		protected String offName;
		/** The "on" texture name. */
		protected String onName;
		/** The game that this is used for. */
		protected Game game;
		
		/**
		 * Creates a new Entry.
		 */
		Entry()
		{
			offName = "";
			onName = "";
			game = Game.TERMINAL_SPECIAL;
		}

		/**
		 * Creates a new Entry.
		 * @param offName the name of the switch "off" texture.
		 * @param onName the name of the switch "on" texture.
		 * @param game the game type that this switch is used for.
		 */
		Entry(String offName, String onName, Game game)
		{
			NameUtils.checkValidTextureName(offName);
			NameUtils.checkValidTextureName(onName);
			if (game == null)
				throw new IllegalArgumentException("Game cannot be null.");

			this.offName = offName;
			this.onName = onName;
			this.game = game;
		}

		/**
		 * @return the switch "off" position texture.  
		 */
		public String getOffName()
		{
			return offName;
		}

		/**
		 * @return the switch "on" position texture.  
		 */
		public String getOnName()
		{
			return onName;
		}

		/**
		 * @return the active game type of the switch.  
		 */
		public Game getGame()
		{
			return game;
		}

		@Override
		public void readBytes(InputStream in) throws IOException
		{
			SerialReader sr = new SerialReader(SerialReader.LITTLE_ENDIAN);
			offName = NameUtils.toValidTextureName(NameUtils.nullTrim(sr.readString(in, 9, "ASCII")));
			onName = NameUtils.toValidTextureName(NameUtils.nullTrim(sr.readString(in, 9, "ASCII")));
			game = Game.values()[sr.readShort(in)];
		}

		@Override
		public void writeBytes(OutputStream out) throws IOException
		{
			SerialWriter sw = new SerialWriter(SerialWriter.LITTLE_ENDIAN);
			sw.writeBytes(out, NameUtils.toASCIIBytes(offName, 8));
			sw.writeBoolean(out, false);  // ensure null terminal
			sw.writeBytes(out, NameUtils.toASCIIBytes(onName, 8));
			sw.writeBoolean(out, false);  // ensure null terminal
			sw.writeShort(out, (short)game.ordinal());
		}
		
		@Override
		public String toString()
		{
			StringBuilder sb = new StringBuilder();
			sb.append("Switch "); 
			sb.append(offName);
			sb.append(' ');
			sb.append(onName);
			sb.append(' ');
			sb.append(game.name());
			return sb.toString();
		}
		
	}
	
}
