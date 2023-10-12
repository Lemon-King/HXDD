/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.util;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

import net.mtrop.doom.Wad;
import net.mtrop.doom.WadBuffer;
import net.mtrop.doom.WadEntry;
import net.mtrop.doom.WadFile;
import net.mtrop.doom.struct.Sizable;

/**
 * WAD utility methods and functions.
 * @author Matthew Tropiano
 */
public final class WadUtils
{
	private WadUtils() {}

	/**
	 * A functional interface that describes a function that 
	 * takes a Wad and returns void, without handling any exceptions thrown by it. 
	 * @since 2.5.0
	 */
	@FunctionalInterface
	public static interface WadConsumer
	{
		/**
		 * Calls this function with a Wad file.
		 * @param wad the provided Wad to operate on.
		 * @throws IOException if any I/O exception occurs.
		 */
		void accept(Wad wad) throws IOException;
	}

	/**
	 * A functional interface that describes a function that 
	 * takes a Wad and returns data, without handling any exceptions thrown by it. 
	 * @param <R> the return type.
	 * @since 2.5.0
	 */
	@FunctionalInterface
	public static interface WadFunction<R>
	{
		/**
		 * Calls this function with a Wad file.
		 * @param wad the provided Wad to operate on.
		 * @return the data returned by the function.
		 * @throws IOException if any I/O exception occurs.
		 */
		R apply(Wad wad) throws IOException;
	}

	/**
	 * An accumulator for WadEntries.
	 * @since 2.5.0
	 */
	public static class WadEntryAccumulator implements Sizable
	{
		private List<WadEntry> list;
		
		private WadEntryAccumulator(WadEntry ... entries)
		{
			this.list = new ArrayList<>(64);
			if (entries != null)
				and(entries);
		}
		
		/**
		 * Adds a single entry to the list.
		 * If entry is null, this does nothing. 
		 * @param entry the entry to add. 
		 * @return itself.
		 */
		public WadEntryAccumulator and(WadEntry entry)
		{
			list.add(entry);
			return this;
		}
		
		/**
		 * Adds a set of entries to the list in the order that they are in the array. 
		 * If entries is null, this does nothing. 
		 * @param entries the entries to add. 
		 * @return itself.
		 */
		public WadEntryAccumulator and(WadEntry ... entries)
		{
			if (entries != null) for (int i = 0; i < entries.length; i++)
				list.add(entries[i]);
			return this;
		}
		
		@Override
		public int size()
		{
			return list.size();
		}
		
		@Override
		public boolean isEmpty()
		{
			return list.isEmpty();
		}

		/**
		 * Gets all of the entries in this accumulator, in the order that they were added to it.
		 * @return an array of all of the entries accumulated so far.
		 */
		public WadEntry[] get()
		{
			WadEntry[] out = new WadEntry[list.size()];
			list.toArray(out);
			return out;
		}
		
	}

	/**
	 * Creates a WadEntry accumulator with a set of entries.
	 * @param entries the entries to start the accumulator with.
	 * @return a new accumulator with the provided entries already added.
	 * @since 2.5.0
	 */
	public static WadEntryAccumulator withEntries(WadEntry ... entries)
	{
		return new WadEntryAccumulator(entries);
	}

	/**
	 * Creates a new WAD file by copying the contents of an existing WAD to another file,
	 * which discards all un-addressed data from the first. The source Wad must be an 
	 * implementation that supports retrieving data from it.
	 * @param source the source Wad.
	 * @param destination the destination file.
	 * @throws UnsupportedOperationException if the provided Wad is not an implementation that you can read data from.
	 * @throws SecurityException if the target file cannot be written to due to security reasons.
	 * @throws IOException if a read or write error occurs.
	 */
	public static void cleanEntries(Wad source, File destination) throws IOException
	{
		WadFile.extract(destination, source, 0, source.getEntryCount()).close();
	}

	/**
	 * Finds all entries within a WAD entry namespace.
	 * A namespace is marked by one or two characters and "_START" or "_END" as a suffix.
	 * All entries in between are considered part of the "namespace."
	 * <p>
	 * The returned entries are valid only to the provided WAD. Using entry information with unassociated WADs
	 * could create undesired results.
	 * @param prefix the namespace prefix to use (e.g. "F" or "FF" for flats, "P" or "PP" for patches, etc.).
	 * @param wad the WAD file to scan.
	 * @return an array of all entries in the namespace, or an empty array if none are found.
	 */
	public static WadEntry[] getEntriesInNamespace(Wad wad, String prefix)
	{
		return getEntriesInNamespace(wad, prefix, null);
	}

	/**
	 * Finds all entries within a WAD entry namespace.
	 * A namespace is marked by one or two characters and "_START" or "_END" as a suffix.
	 * All entries in between are considered part of the "namespace."
	 * <p>
	 * The returned entries are valid only to the provided WAD. Using entry information with unassociated WADs
	 * could create undesired results.
	 * @param prefix the namespace prefix to use (e.g. "F" or "FF" for flats, "P" or "PP" for texture patches, etc.).
	 * @param wad the WAD file to scan.
	 * @param ignorePattern the regex pattern to use for deciding which entries in the namespace to ignore.
	 * @return an array of all entries in the namespace, or an empty array if none are found.
	 */
	public static WadEntry[] getEntriesInNamespace(Wad wad, String prefix, Pattern ignorePattern)
	{
		List<WadEntry> entryList = new ArrayList<WadEntry>(100);
		
		int start = wad.indexOf(prefix+"_START");
		if (start > 0)
		{
			int end = wad.indexOf(prefix+"_END");
			if (end > 0)
			{
				for (int i = start + 1; i < end; i++)
				{
					WadEntry entry = wad.getEntry(i);
					if (ignorePattern != null && ignorePattern.matcher(entry.getName()).matches())
						continue;
					entryList.add(entry);
				}
			}
		}
		
		WadEntry[] entry = new WadEntry[entryList.size()];
		entryList.toArray(entry);
		return entry;
	}

	/**
	 * Creates a new WAD file, performs an action on it, and then closes it automatically afterward.
	 * The opened WAD is passed to the provided {@link WadConsumer}.
	 * @param path the path to the WAD file.
	 * @param wadConsumer a {@link WadConsumer} that takes the opened Wad as its only parameter.
	 * @throws IOException if any I/O exception occurs.
	 * @since 2.6.0
	 */
	public static void createWadAnd(String path, WadConsumer wadConsumer) throws IOException
	{
		createWadAnd(new File(path), wadConsumer);
	}
	
	/**
	 * Creates a new WAD file, performs an action on it, and then closes it automatically afterward.
	 * The opened WAD is passed to the provided {@link WadConsumer}.
	 * @param path the path to the WAD file.
	 * @param wadConsumer a {@link WadConsumer} that takes the opened Wad as its only parameter.
	 * @throws IOException if any I/O exception occurs.
	 * @since 2.6.0
	 */
	public static void createWadAnd(File path, WadConsumer wadConsumer) throws IOException
	{
		try (WadFile wad = WadFile.createWadFile(path)) {
			wadConsumer.accept(wad);
		} // auto-closed
	}
	
	/**
	 * Opens a WAD file, performs an action on it, and then closes it automatically afterward.
	 * The opened WAD is passed to the provided {@link WadConsumer}.
	 * @param path the path to the WAD file.
	 * @param wadConsumer a {@link WadConsumer} that takes the opened Wad as its only parameter.
	 * @throws IOException if any I/O exception occurs.
	 * @since 2.5.0
	 */
	public static void openWadAnd(String path, WadConsumer wadConsumer) throws IOException
	{
		openWadAnd(new File(path), wadConsumer);
	}
	
	/**
	 * Opens a WAD file, performs an action on it, and then closes it automatically afterward.
	 * The opened WAD is passed to the provided {@link WadConsumer}.
	 * <p>This method is intended for <i>pure convenience</i>, and will throw a {@link RuntimeException}
	 * if an exception occurs. Do not use this if you intend to handle errors explicitly.
	 * @param path the path to the WAD file.
	 * @param wadConsumer a {@link WadConsumer} that takes the opened Wad as its only parameter.
	 * @throws IOException if any I/O exception occurs.
	 * @since 2.5.0
	 */
	public static void openWadAnd(File path, WadConsumer wadConsumer) throws IOException
	{
		try (WadFile wad = new WadFile(path)) {
			wadConsumer.accept(wad);
		} // auto-closed
	}
	
	/**
	 * Opens a WAD file, retrieves information from it, and then closes it automatically afterward.
	 * The opened WAD is passed to the provided {@link WadFunction}.
	 * <p>This method is intended for <i>pure convenience</i>, and will throw a {@link RuntimeException}
	 * if an exception occurs. Do not use this if you intend to handle errors explicitly.
	 * @param <R> the return type.
	 * @param path the path to the WAD file.
	 * @param wadFunction a {@link WadFunction} that takes the opened Wad as its only parameter.
	 * @return the data returned from the provided function.
	 * @throws IOException if any I/O exception occurs.
	 * @since 2.5.0
	 */
	public static <R> R openWadAndGet(String path, WadFunction<R> wadFunction) throws IOException
	{
		return openWadAndGet(new File(path), wadFunction);
	}
	
	/**
	 * Opens a WAD file, retrieves information from it (which is returned), and then closes it automatically afterward.
	 * The opened WAD is passed to the provided {@link WadFunction}.
	 * <p>This method is intended for <i>pure convenience</i>, and will throw a {@link RuntimeException}
	 * if an exception occurs. Do not use this if you intend to handle errors explicitly.
	 * @param <R> the return type.
	 * @param path the path to the WAD file.
	 * @param wadFunction a {@link WadFunction} that takes the opened Wad as its only parameter.
	 * @return the data returned from the provided function.
	 * @throws IOException if any I/O exception occurs.
	 * @since 2.5.0
	 */
	public static <R> R openWadAndGet(File path, WadFunction<R> wadFunction) throws IOException
	{
		try (WadFile wad = new WadFile(path)) {
			return wadFunction.apply(wad);
		} // auto-closed
	}
	
	/**
	 * Opens a WAD file, exports a list of entries to a new WAD, and then closes both automatically afterward.
	 * The opened WAD is passed to the provided {@link WadFunction}.
	 * <p>This method is intended for <i>pure convenience</i>, and will throw a {@link RuntimeException}
	 * if an exception occurs. Do not use this if you intend to handle errors explicitly.
	 * @param path the path to the WAD file.
	 * @param outPath the output path for the new WAD file.
	 * @param wadFunction a {@link WadFunction} that takes the opened Wad as its only parameter.
	 * @throws IOException if any I/O exception occurs.
	 * @since 2.5.0
	 */
	public static void openWadAndExtractTo(String path, String outPath, WadFunction<WadEntry[]> wadFunction) throws IOException
	{
		openWadAndExtractTo(new File(path), new File(outPath), wadFunction);
	}

	/**
	 * Opens a WAD file, exports a list of entries to a new WAD, and then closes both automatically afterward.
	 * The opened WAD is passed to the provided {@link WadFunction}.
	 * <p>This method is intended for <i>pure convenience</i>, and will throw a {@link RuntimeException}
	 * if an exception occurs. Do not use this if you intend to handle errors explicitly.
	 * @param path the path to the WAD file.
	 * @param outPath the output path for the new WAD file.
	 * @param wadFunction a {@link WadFunction} that takes the opened Wad as its only parameter.
	 * @throws IOException if any I/O exception occurs.
	 * @since 2.5.0
	 */
	public static void openWadAndExtractTo(String path, File outPath, WadFunction<WadEntry[]> wadFunction) throws IOException
	{
		openWadAndExtractTo(new File(path), outPath, wadFunction);
	}

	/**
	 * Opens a WAD file, exports a list of entries to a new WAD, and then closes both automatically afterward.
	 * The opened WAD is passed to the provided {@link WadFunction}.
	 * <p>This method is intended for <i>pure convenience</i>, and will throw a {@link RuntimeException}
	 * if an exception occurs. Do not use this if you intend to handle errors explicitly.
	 * @param path the path to the WAD file.
	 * @param outPath the output path for the new WAD file.
	 * @param wadFunction a {@link WadFunction} that takes the opened Wad as its only parameter.
	 * @throws IOException if any I/O exception occurs.
	 * @since 2.5.0
	 */
	public static void openWadAndExtractTo(File path, String outPath, WadFunction<WadEntry[]> wadFunction) throws IOException
	{
		openWadAndExtractTo(path, new File(outPath), wadFunction);
	}

	/**
	 * Opens a WAD file, exports a list of entries to a new WAD, and then closes both automatically afterward.
	 * The opened WAD is passed to the provided {@link WadFunction}.
	 * <p>This method is intended for <i>pure convenience</i>, and will throw a {@link RuntimeException}
	 * if an exception occurs. Do not use this if you intend to handle errors explicitly.
	 * @param path the path to the WAD file.
	 * @param outPath the output path for the new WAD file.
	 * @param wadFunction a {@link WadFunction} that takes the opened Wad as its only parameter.
	 * @throws IOException if any I/O exception occurs.
	 * @since 2.5.0
	 */
	public static void openWadAndExtractTo(File path, File outPath, WadFunction<WadEntry[]> wadFunction) throws IOException 
	{
		try (WadFile source = new WadFile(path)) {
			WadFile.extract(outPath, source, wadFunction.apply(source)).close();
		} // auto-closed
	}

	/**
	 * Opens a WAD file, exports a list of entries to a new returned {@link WadBuffer}, and then closes it automatically afterward.
	 * The opened WAD is passed to the provided {@link WadFunction}.
	 * <p>This method is intended for <i>pure convenience</i>, and will throw a {@link RuntimeException}
	 * if an exception occurs. Do not use this if you intend to handle errors explicitly.
	 * @param path the path to the WAD file.
	 * @param wadFunction a {@link WadFunction} that takes the opened Wad as its only parameter.
	 * @return the WadBuffer with the desired entries.
	 * @throws IOException if any I/O exception occurs.
	 * @since 2.5.0
	 */
	public static WadBuffer openWadAndExtractBuffer(String path, WadFunction<WadEntry[]> wadFunction) throws IOException
	{
		return openWadAndExtractBuffer(new File(path), wadFunction);
	}

	/**
	 * Opens a WAD file, exports a list of entries to a new returned {@link WadBuffer}, and then closes it automatically afterward.
	 * The opened WAD is passed to the provided {@link WadFunction}.
	 * <p>This method is intended for <i>pure convenience</i>, and will throw a {@link RuntimeException}
	 * if an exception occurs. Do not use this if you intend to handle errors explicitly.
	 * @param path the path to the WAD file.
	 * @param wadFunction a {@link WadFunction} that takes the opened Wad as its only parameter.
	 * @return the WadBuffer with the desired entries.
	 * @throws IOException if any I/O exception occurs.
	 * @since 2.5.0
	 */
	public static WadBuffer openWadAndExtractBuffer(File path, WadFunction<WadEntry[]> wadFunction) throws IOException
	{
		try (WadFile source = new WadFile(path)) {
			return WadBuffer.extract(source, wadFunction.apply(source));
		} // auto-closed
	}
	
}
