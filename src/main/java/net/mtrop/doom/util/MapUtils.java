/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.util;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import net.mtrop.doom.Wad;
import net.mtrop.doom.WadEntry;
import net.mtrop.doom.bsp.BSPTree;
import net.mtrop.doom.bsp.data.BSPNode;
import net.mtrop.doom.bsp.data.BSPSegment;
import net.mtrop.doom.bsp.data.BSPSubsector;
import net.mtrop.doom.exception.MapException;
import net.mtrop.doom.map.DoomMap;
import net.mtrop.doom.map.HexenMap;
import net.mtrop.doom.map.MapFormat;
import net.mtrop.doom.map.UDMFMap;
import net.mtrop.doom.map.data.DoomLinedef;
import net.mtrop.doom.map.data.DoomSector;
import net.mtrop.doom.map.data.DoomSidedef;
import net.mtrop.doom.map.data.DoomThing;
import net.mtrop.doom.map.data.DoomVertex;
import net.mtrop.doom.map.data.HexenLinedef;
import net.mtrop.doom.map.data.HexenThing;

/**
 * Map utility methods and functions.
 * @author Matthew Tropiano
 */
public final class MapUtils
{
	private static final WadEntry[] NO_ENTRIES = new WadEntry[0];

	public static final String LUMP_THINGS = "THINGS";
	public static final String LUMP_SECTORS = "SECTORS";
	public static final String LUMP_VERTICES = "VERTEXES";
	public static final String LUMP_SIDEDEFS = "SIDEDEFS";
	public static final String LUMP_LINEDEFS = "LINEDEFS";

	public static final String LUMP_TEXTMAP = "TEXTMAP";

	public static final String LUMP_SSECTORS = "SSECTORS";
	public static final String LUMP_NODES = "NODES";
	public static final String LUMP_SEGS = "SEGS";
	public static final String LUMP_REJECT = "REJECT";
	public static final String LUMP_BLOCKMAP = "BLOCKMAP";
	
	public static final String LUMP_ZNODES = "ZNODES";

	public static final String LUMP_GL_VERT = "GL_VERT";
	public static final String LUMP_GL_SEGS = "GL_SEGS";
	public static final String LUMP_GL_SSECT = "GL_SSECT";
	public static final String LUMP_GL_NODES = "GL_NODES";
	public static final String LUMP_GL_PVS = "GL_PVS";
	
	public static final String LUMP_BEHAVIOR = "BEHAVIOR";
	public static final String LUMP_SCRIPTS = "SCRIPTS";
	
	public static final String LUMP_DIALOGUE = "DIALOGUE";
	public static final String LUMP_PWADINFO = "PWADINFO";

	public static final String LUMP_ENDMAP = "ENDMAP";
	
	public static final Set<String> MAP_SPECIAL = new HashSet<String>(20) 
	{
		private static final long serialVersionUID = 1L;
	{
		add("THINGS");
		add("LINEDEFS");
		add("SIDEDEFS");
		add("VERTEXES");
		add("SECTORS");
		add("SSECTORS");
		add("NODES");
		add("SEGS");
		add("REJECT");
		add("BLOCKMAP");
		add("BEHAVIOR");
		add("SCRIPTS");
		add("TEXTMAP");
		add("ENDMAP");
		add("ZNODES");
		add("DIALOGUE");
		add("GL_VERT");
		add("GL_SEGS");
		add("GL_SSECT");
		add("GL_NODES");
		add("GL_PVS");
		add("PWADINFO");
	}};

	private MapUtils() {}

	/**
	 * Creates a {@link DoomMap} from an entry index in a {@link Wad} that denotes a map header.
	 * If there is more than one header in the WAD that matches the provided header, the last one is found.
	 * @param wad the WAD to read from.
	 * @param index the index of the map header entry.
	 * @return a DoomMap with all objects set.
	 * @throws MapException if map information is incomplete, or can't be found.
	 * @throws IOException if the WAD can't be read from.
	 * @throws UnsupportedOperationException if attempting to read from a {@link Wad} type that does not contain data.
	 */
	public static DoomMap createDoomMap(Wad wad, int index) throws MapException, IOException
	{
		int count = getMapEntryCount(wad, index);
		
		for (int i = 0; i < count; i++)
		{
			String name = wad.getEntry(i + index).getName();
			if (name.equals(LUMP_BEHAVIOR))
				throw new MapException("Map is not a Doom-formatted map.");
			else if (name.equals(LUMP_TEXTMAP))
				throw new MapException("Map is not a Doom-formatted map. Format is UDMF.");
			else if (name.equals(LUMP_ENDMAP))
				throw new MapException("Map is not a Doom-formatted map. Format is UDMF.");
		}

		DoomMap map = new DoomMap();

		for (int i = 0; i < count; i++)
		{
			WadEntry entry = wad.getEntry(i + index);
			String name = entry.getName();
			switch (name)
			{
				case LUMP_THINGS:
					map.setThings(wad.getDataAsList(entry, DoomThing.class, DoomThing.LENGTH));
					break;

				case LUMP_SECTORS:
					map.setSectors(wad.getDataAsList(entry, DoomSector.class, DoomSector.LENGTH));
					break;

				case LUMP_VERTICES:
					map.setVertices(wad.getDataAsList(entry, DoomVertex.class, DoomVertex.LENGTH));
					break;

				case LUMP_SIDEDEFS:
					map.setSidedefs(wad.getDataAsList(entry, DoomSidedef.class, DoomSidedef.LENGTH));
					break;

				case LUMP_LINEDEFS:
					map.setLinedefs(wad.getDataAsList(entry, DoomLinedef.class, DoomLinedef.LENGTH));
					break;
			}
		}
		
		return map;
	}
	
		/**
	 * Creates a {@link DoomMap} from a starting entry in a {@link Wad}.
	 * If there is more than one header in the WAD that matches the provided header, the last one is found.
	 * @param wad the WAD to read from.
	 * @param headerName the map header name to search for.
	 * @return a DoomMap with all objects set.
	 * @throws MapException if map information is incomplete, or can't be found.
	 * @throws IOException if the WAD can't be read from.
	 * @throws UnsupportedOperationException if attempting to read from a {@link Wad} type that does not contain data.
	 */
	public static DoomMap createDoomMap(Wad wad, String headerName) throws MapException, IOException
	{
		int index = wad.lastIndexOf(headerName);
		if (index < 0)
			throw new MapException("Cannot find map by header name "+headerName);
		
		return createDoomMap(wad, index);
	}
	
	/**
	 * Creates a {@link HexenMap} from an entry index in a {@link Wad} that denotes a map header.
	 * If there is more than one header in the WAD that matches the provided header, the last one is found.
	 * @param wad the WAD to read from.
	 * @param index the index of the map header entry.
	 * @return a HexenMap with all objects set.
	 * @throws MapException if map information is incomplete, or can't be found.
	 * @throws IOException if the WAD can't be read from.
	 * @throws UnsupportedOperationException if attempting to read from a {@link Wad} type that does not contain data.
	 */
	public static HexenMap createHexenMap(Wad wad, int index) throws MapException, IOException
	{
		int count = getMapEntryCount(wad, index);

		boolean hasBehavior = false;
		for (int i = 0; i < count; i++)
		{
			String name = wad.getEntry(i + index).getName();
			if (name.equals(LUMP_BEHAVIOR))
				hasBehavior = true;
			else if (name.equals(LUMP_TEXTMAP))
				throw new MapException("Map is not a Hexen-formatted map. Format is UDMF.");
			else if (name.equals(LUMP_ENDMAP))
				throw new MapException("Map is not a Hexen-formatted map. Format is UDMF.");
		}
		
		if (!hasBehavior)
			throw new MapException("Map is not a Hexen-formatted map. Format is Doom.");
		
		HexenMap map = new HexenMap();
		for (int i = 0; i < count; i++)
		{
			WadEntry entry = wad.getEntry(i + index);
			String name = entry.getName();
			switch (name)
			{
				case LUMP_THINGS:
					map.setThings(wad.getDataAsList(entry, HexenThing.class, HexenThing.LENGTH));
					break;
	
				case LUMP_SECTORS:
					map.setSectors(wad.getDataAsList(entry, DoomSector.class, DoomSector.LENGTH));
					break;
	
				case LUMP_VERTICES:
					map.setVertices(wad.getDataAsList(entry, DoomVertex.class, DoomVertex.LENGTH));
					break;
	
				case LUMP_SIDEDEFS:
					map.setSidedefs(wad.getDataAsList(entry, DoomSidedef.class, DoomSidedef.LENGTH));
					break;
	
				case LUMP_LINEDEFS:
					map.setLinedefs(wad.getDataAsList(entry, HexenLinedef.class, HexenLinedef.LENGTH));
					break;
			}
		}
		
		return map;
	}
	
	/**
	 * Creates a {@link HexenMap} from a starting entry in a {@link Wad}.
	 * If there is more than one header in the WAD that matches the provided header, the last one is found.
	 * @param wad the WAD to read from.
	 * @param headerName the map header name to search for.
	 * @return a HexenMap with all objects set.
	 * @throws MapException if map information is incomplete, or can't be found.
	 * @throws IOException if the WAD can't be read from.
	 * @throws UnsupportedOperationException if attempting to read from a {@link Wad} type that does not contain data.
	 */
	public static HexenMap createHexenMap(Wad wad, String headerName) throws MapException, IOException
	{
		int index = wad.lastIndexOf(headerName);
		if (index < 0)
			throw new MapException("Cannot find map by header name "+headerName);
		
		return createHexenMap(wad, index);
	}

	/**
	 * Creates a {@link UDMFMap} from an entry index in a {@link Wad} that denotes a map header.
	 * If there is more than one header in the WAD that matches the provided header, the last one is found.
	 * @param wad the WAD to read from.
	 * @param index the index of the map header entry.
	 * @return a UDMFMap with all objects set.
	 * @throws MapException if map information is incomplete, or can't be found.
	 * @throws IOException if the WAD can't be read from.
	 * @throws UnsupportedOperationException if attempting to read from a {@link Wad} type that does not contain data.
	 */
	public static UDMFMap createUDMFMap(Wad wad, int index) throws MapException, IOException
	{
		int count = getMapEntryCount(wad, index);

		boolean hasTextMap = false;
		boolean hasEndMap = false;
		for (int i = 0; i < count; i++)
		{
			String name = wad.getEntry(i + index).getName();
			if (name.equals(LUMP_TEXTMAP))
				hasTextMap = true;
			else if (name.equals(LUMP_ENDMAP))
				hasEndMap = true;
		}
		
		if (!hasTextMap)
			throw new MapException("Map is not a UDMF-formatted map. Missing TEXTMAP.");
		if (!hasEndMap)
			throw new MapException("Map is not a UDMF-formatted map. Missing ENDMAP.");
		
		UDMFMap map = new UDMFMap();
		for (int i = 0; i < count; i++)
		{
			WadEntry entry = wad.getEntry(i + index);
			String name = entry.getName();
			switch (name)
			{
				case LUMP_TEXTMAP:
					map = wad.getTextDataAs(entry, TextUtils.UTF8, UDMFMap.class);
					break;
			}
		}
		
		return map;
	}
	
	/**
	 * Creates a {@link UDMFMap} from a starting entry in a {@link Wad}.
	 * If there is more than one header in the WAD that matches the provided header, the last one is found.
	 * @param wad the WAD to read from.
	 * @param headerName the map header name to search for.
	 * @return a UDMFMap with all objects set.
	 * @throws MapException if map information is incomplete, or can't be found.
	 * @throws IOException if the WAD can't be read from.
	 * @throws UnsupportedOperationException if attempting to read from a {@link Wad} type that does not contain data.
	 */
	public static UDMFMap createUDMFMap(Wad wad, String headerName) throws MapException, IOException
	{
		int index = wad.lastIndexOf(headerName);
		if (index < 0)
			throw new MapException("Cannot find map by header name "+headerName);
		
		return createUDMFMap(wad, index);
	}

	/**
	 * Creates a {@link BSPTree} from a starting map entry in a {@link Wad}.
	 * If there is more than one header in the WAD that matches the provided header, the last one is found.
	 * @param wad the WAD to read from.
	 * @param headerName the map header name to search for.
	 * @return a BSPTree with all objects set.
	 * @throws MapException if map information is incomplete, or can't be found.
	 * @throws IOException if the WAD can't be read from.
	 * @throws UnsupportedOperationException if attempting to read from a {@link Wad} type that does not contain data.
	 */
	public static BSPTree createBSPTree(Wad wad, String headerName) throws MapException, IOException
	{
		int index = wad.lastIndexOf(headerName);
		if (index < 0)
			throw new MapException("Cannot find map by header name "+headerName);
		
		int count = getMapEntryCount(wad, index);
		
		WadEntry ssectors = null;
		WadEntry segs = null;
		WadEntry nodes = null;
		
		for (int i = 0; i < count; i++)
		{
			WadEntry entry = wad.getEntry(i + index);
			String name = entry.getName();
			if (name.equals(LUMP_SSECTORS))
				ssectors = entry;
			else if (name.equals(LUMP_SEGS))
				segs = entry;
			else if (name.equals(LUMP_NODES))
				nodes = entry;
		}
		
		if (segs == null)
			throw new MapException("BSP Tree information is incomplete. Missing SEGS.");
		if (ssectors == null)
			throw new MapException("BSP Tree information is incomplete. Missing SSECTORS.");
		if (nodes == null)
			throw new MapException("BSP Tree information is incomplete. Missing NODES.");
		
		BSPTree out = new BSPTree();
		out.setSegments(wad.getDataAsList(segs, BSPSegment.class, BSPSegment.LENGTH));
		out.setSubsectors(wad.getDataAsList(ssectors, BSPSubsector.class, BSPSubsector.LENGTH));
		out.setNodes(wad.getDataAsList(nodes, BSPNode.class, BSPNode.LENGTH));
		
		return out;
	}
	
	/**
	 * Returns all of the indices of every map in the wad.
	 * This algorithm scans for map entry names. If it finds one, the previous entry is the probably the header.
	 * This algorithm is not perfect, and may return false positives in case some outlying entries are named the same as some map entries.
	 * @param wad the {@link Wad} to search inside.
	 * @return an array of all of the entry indices of maps. 
	 */
	public static int[] getAllMapIndices(Wad wad)
	{
		List<Integer> indices = new ArrayList<Integer>(32);
		WadEntry e = null;
		int z = 0;
		boolean map = false;
		Iterator<WadEntry> it = wad.iterator();
		while (it.hasNext())
		{
			e = it.next();
			String name = e.getName();
			if (isMapDataLump(name) && z > 0)
			{
				if (!map)
				{
					indices.add(z - 1);
					map = true;
				}
			}
			else
			{
				map = false;
			}
			
			z++;
		}
		
		int[] out = new int[indices.size()];
		int x = 0;
		for (Integer i : indices)
			out[x++] = i;
		return out;
	}

	/**
	 * Returns all of the entry names of every map in the wad.
	 * This algorithm scans for map entry names. If it finds one, the previous entry is the probably the header.
	 * @param wad the Wad to search in.
	 * @return an array of all of the entry indices of maps. 
	 */
	public static String[] getAllMapHeaders(Wad wad)
	{
		int[] entryIndices = getAllMapIndices(wad);
		String[] out = new String[entryIndices.length];
		int i = 0;
		for (int index : entryIndices)
			out[i++] = wad.getEntry(index).getName();
		return out;
	}

	/**
	 * Figures out a map's format by its entry listing.
	 * @param wad the WAD to read from.
	 * @param index the index of the map header entry.
	 * @return a {@link MapFormat} that details the map format type, or null if it cannot be figured out.
	 */
	public static MapFormat getMapFormat(Wad wad, int index)
	{
		int count = getMapEntryCount(wad, index);

		if (count <= 1)
			return null;
		
		for (int i = 0; i < count; i++)
		{
			String name = wad.getEntry(i + index).getName();
			if (name.equals(LUMP_BEHAVIOR))
				return MapFormat.HEXEN;
			else if (name.equals(LUMP_TEXTMAP))
				return MapFormat.UDMF;
			else if (name.equals(LUMP_ENDMAP))
				return MapFormat.UDMF;
		}

		return MapFormat.DOOM;
	}

	/**
	 * Figures out a map's format by its entry listing.
	 * @param wad the WAD to read from.
	 * @param headerName the map header name to search for.
	 * @return a {@link MapFormat} that details the map format type, or null if it cannot be figured out, nor if the header can be found.
	 */
	public static MapFormat getMapFormat(Wad wad, String headerName)
	{
		int index = wad.lastIndexOf(headerName);
		if (index < 0)
			return null;
	
		return getMapFormat(wad, index);
	}

	/**
	 * Returns the amount of entries in a map, including the header.
	 * @param wad the WAD to inspect.
	 * @param headerName the map header name.
	 * @return the length, in entries, of the contiguous map data.
	 */
	public static int getMapEntryCount(Wad wad, String headerName)
	{
		int start = wad.indexOf(headerName);
		if (start < 0)
			return 0;
		else
			return getMapEntryCount(wad, start);
	}
	
	/**
	 * Returns the amount of entries in a map, including the header.
	 * @param wad the WAD to inspect.
	 * @param startIndex the starting index.
	 * @return the length, in entries, of the contiguous map data.
	 */
	public static int getMapEntryCount(Wad wad, int startIndex)
	{
		int i = startIndex + 1;
		while (i < wad.getEntryCount() && isMapDataLump(wad.getEntry(i).getName()))
			i++;
		return i - startIndex;
	}
	
	/**
	 * Returns the entries in a map, including the header.
	 * The entry at the index is assumed to be the header.
	 * @param wad the WAD to inspect.
	 * @param startIndex the starting index.
	 * @return the list of map entries for the map data.
	 * @since 2.1.0
	 */
	public static WadEntry[] getMapEntries(Wad wad, int startIndex)
	{
		return wad.mapEntries(startIndex, getMapEntryCount(wad, startIndex));
	}
	
	/**
	 * Returns the entries in a map, including the header, if the map is found.
	 * If there is more than one header in the WAD that matches the provided header, the last one is found.
	 * @param wad the WAD to inspect.
	 * @param header the starting entry name to find.
	 * @return the list of map entries for the map data, or an empty array if the map header is not found.
	 * @since 2.1.0
	 */
	public static WadEntry[] getMapEntries(Wad wad, String header)
	{
		int index = wad.lastIndexOf(header);
		return index >= 0 ? wad.mapEntries(index, getMapEntryCount(wad, index)) : NO_ENTRIES;
	}
	
	/**
	 * Tests if the entry name provided is a valid part of a map.
	 * @param name the lump name to test.
	 * @return if this is the name of a map data lump.
	 */
	public static boolean isMapDataLump(String name)
	{
		return NameUtils.isValidEntryName(name) 
			&& (
				name.startsWith("GX_") 
				|| name.startsWith("GL_") 
				|| name.startsWith("SCRIPT") 
				|| MAP_SPECIAL.contains(name.toUpperCase())
			);
	}
	
}
