/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.util;

import java.io.IOException;
import java.util.HashSet;
import java.util.Set;
import java.util.TreeSet;
import java.util.regex.Pattern;

import net.mtrop.doom.Wad;
import net.mtrop.doom.WadEntry;
import net.mtrop.doom.exception.TextureException;
import net.mtrop.doom.exception.WadException;
import net.mtrop.doom.object.BinaryObject;
import net.mtrop.doom.struct.io.SerializerUtils;
import net.mtrop.doom.texture.CommonTexture;
import net.mtrop.doom.texture.CommonTextureList;
import net.mtrop.doom.texture.DoomTextureList;
import net.mtrop.doom.texture.PatchNames;
import net.mtrop.doom.texture.StrifeTextureList;
import net.mtrop.doom.texture.TextureSet;
import net.mtrop.doom.texture.TextureSet.Patch;
import net.mtrop.doom.texture.TextureSet.Texture;

/**
 * Graphics utility methods for image types.
 * @author Matthew Tropiano
 */
public final class TextureUtils
{
	private TextureUtils() {}

	/**
	 * Imports a {@link TextureSet} from a WAD File.
	 * This searches for the TEXTURE1/2 lumps and the PNAMES entry, and builds a new TextureSet
	 * from them. If the WAD does NOT contain a TEXTUREx entry, the returned set will be empty.
	 * If TEXTURE1/2 is present, but NOT PNAMES, a {@link TextureException} will be thrown.
	 * @param wf the WAD file to read from containing the required entries.
	 * @return a new texture set equivalent to the parsed data.
	 * @throws TextureException if a texture lump was found, but not PNAMES.
	 * @throws WadException if the WAD itself cannot be read.
	 * @throws IOException if an entry in a WAD file cannot be read.
	 */
	public static TextureSet importTextureSet(Wad wf) throws WadException, IOException
	{
		return importTextureSet(wf, null, null);
	}
	
	/**
	 * This private method loads TEXTURE1/TEXTURE2.
	 */
	private static TextureSet importTextureSet(Wad wf, boolean[] strifeType, Set<String> texture1Names) throws WadException, IOException
	{
		PatchNames patchNames = null;
		CommonTextureList<?> textureList1 = null;
		CommonTextureList<?> textureList2 = null;
		
		byte[] textureData = wf.getData("TEXTURE1");
		boolean isStrife = false;
		
		if (textureData == null)
			throw new TextureException("Could not find TEXTURE1!\n");

		// figure out if Strife or Doom Texture Lump.
		if (TextureUtils.isStrifeTextureData(textureData))
		{
			textureList1 = BinaryObject.create(StrifeTextureList.class, textureData);
			isStrife = true;
		}
		else
		{
			textureList1 = BinaryObject.create(DoomTextureList.class, textureData);
			isStrife = false;
		}

		if (strifeType != null)
			strifeType[0] = isStrife;

		textureData = wf.getData("TEXTURE2");
		
		if (textureData != null)
		{
			if (isStrife)
				textureList2 = BinaryObject.create(StrifeTextureList.class, textureData);
			else
				textureList2 = BinaryObject.create(DoomTextureList.class, textureData);
		}
		
		textureData = wf.getData("PNAMES");
		if (textureData == null)
			throw new TextureException("Found TEXTUREx without PNAMES!\n");

		patchNames = BinaryObject.create(PatchNames.class, textureData);
		
		TextureSet out;
		
		if (textureList2 != null)
		{
			if (texture1Names != null)
				for (CommonTexture<?> t : textureList1)
					texture1Names.add(t.getName());
			out = new TextureSet(patchNames, textureList1, textureList2);
		}
		else
			out = new TextureSet(patchNames, textureList1);

		return out;
	}

	/**
	 * Scans through texture lump data in order to detect whether it is for Strife or not.
	 * @param b the texture lump data.
	 * @return true if it is Strife texture data, false if not.
	 */
	public static boolean isStrifeTextureData(byte[] b)
	{
		int ptr = 0;
		byte[] buf = new byte[4];
	
		System.arraycopy(b, ptr, buf, 0, 4);
		int textureCount = SerializerUtils.bytesToInt(buf, 0, SerializerUtils.LITTLE_ENDIAN);
		ptr = (textureCount * 4) + 20;
		
		boolean good = true;
		while (ptr < b.length && good)
		{
			System.arraycopy(b, ptr, buf, 0, 4);
			
			// test for unused texture data.
			if (SerializerUtils.bytesToInt(buf, 0, SerializerUtils.LITTLE_ENDIAN) != 0)
				good = false;
	
			// test for unused patch data.
			else
			{
				ptr += 4;
				System.arraycopy(b, ptr, buf, 0, 2);
				int patches = SerializerUtils.bytesToInt(buf, 0, SerializerUtils.LITTLE_ENDIAN);
				ptr += 2;
				while (patches > 0)
				{
					ptr += 6;
					System.arraycopy(b, ptr, buf, 0, 4);
					int x = SerializerUtils.bytesToInt(buf, 0, SerializerUtils.LITTLE_ENDIAN);
					if (x > 1 || x < 0)
						good = false;
					ptr += 4;
					patches--;
				}
				ptr += 16;
			}
		}
		
		return !good;
	}

	/**
	 * Creates a texture copier object for moving one or more textures (and associated data) to another Wad.
	 * <p>NOTE: Make sure you call {@link TextureCopier#close()} on the copier so that the TEXTUREx/PNAMES entries get written properly.
	 * @param sourceWad the source Wad.
	 * @param destinationWad the destination Wad.
	 * @return the new copier.
	 * @throws TextureException if the source or destination does not have TEXTUREx or a PNAMES lump. 
	 * @throws IOException if a read error happens.
	 */
	public static TextureCopier createTextureCopier(Wad sourceWad, Wad destinationWad) throws IOException
	{
		return new TextureCopier(sourceWad, destinationWad);
	}
	
	/**
	 * A texture copying context for copying one or more textures to another Wad.
	 * This does the copying of both flats and textures.
	 * @since 2.6.0
	 */
	public static class TextureCopier implements AutoCloseable
	{
		/** Source Wad */
		private Wad sourceWad;
		/** Source Texture Set */
		private TextureSet sourceTextureSet;
		/** Set of textures to add to TEXTURE1 */
		private Set<String> sourceTexture1Set;
		/** If Strife format, this is true. */
		private boolean sourceIsStrife;
		/** The index of the source "P[P]_START" index. */
		private Integer sourcePatchStartIndex;
		/** The index of the source "P[P]_END" index. */
		private Integer sourcePatchEndIndex;
		/** The index of the source "F[F]_START" index. */
		private Integer sourceFlatStartIndex;
		/** The index of the source "F[F]_END" index. */
		private Integer sourceFlatEndIndex;

		/** Destination Wad */
		private Wad destinationWad;
		/** Destination Texture Set */
		private TextureSet destinationTextureSet;
		/** Set of textures to add to TEXTURE1 */
		private Set<String> destinationTexture1Set;
		/** If Strife format, this is true. */
		private boolean destinationIsStrife;

		/** Set of patch entry names in destination. */
		private Set<String> destinationPatches;
		/** The index of the destination "PP_END" index. */
		private Integer destinationPatchStartIndex;
		/** The index of the destination "PP_END" index. */
		private Integer destinationPatchEndIndex;
		/** Set of patch entry names in destination. */
		private Set<String> destinationFlats;
		/** The index of the destination "FF_START" index. */
		private Integer destinationFlatStartIndex;
		/** The index of the destination "FF_END" index. */
		private Integer destinationFlatEndIndex;
		
		/**
		 * Creates the copier. 
		 */
		private TextureCopier(Wad sourceWad, Wad destinationWad) throws IOException
		{
			this.sourceWad = sourceWad;
			this.destinationWad = destinationWad;

			// defaults.
			this.sourceTextureSet = null;
			this.sourceTexture1Set = null;
			this.sourceIsStrife = false;
			
			this.sourcePatchStartIndex = -1;
			this.sourcePatchEndIndex = -1;
			
			this.sourceFlatStartIndex = -1;
			this.sourceFlatEndIndex = -1;
			
			this.destinationTextureSet = null;
			this.destinationTexture1Set = null;
			this.destinationIsStrife = false;
			
			this.destinationPatchStartIndex = null;
			this.destinationPatchEndIndex = null;
			this.destinationPatches = null;
			
			this.destinationFlatStartIndex = null;
			this.destinationFlatEndIndex = null;
			this.destinationFlats = null;
			
			int idx;
			boolean[] strife = new boolean[1];
			
			// ======== Get source patch namespace start and end.
			if ((idx = sourceWad.indexOf("P_START")) < 0)
				idx = sourceWad.indexOf("PP_START");
			if (idx >= 0)
				sourcePatchStartIndex = idx;
			
			if ((idx = sourceWad.indexOf("P_END")) < 0)
				idx = sourceWad.indexOf("PP_END");
			if (idx >= 0)
				sourcePatchEndIndex = idx;

			if (sourcePatchStartIndex == null ^ sourcePatchStartIndex == null)
				throw new TextureException("Source Wad does not have a complete patch namespace.");

			// ======== Get source flat namespace start and end.
			if ((idx = sourceWad.indexOf("F_START")) < 0)
				idx = sourceWad.indexOf("FF_START");
			if (idx >= 0)
				sourceFlatStartIndex = idx;
			
			if ((idx = sourceWad.indexOf("F_END")) < 0)
				idx = sourceWad.indexOf("FF_END");
			if (idx >= 0)
				sourceFlatEndIndex = idx;

			if (sourceFlatStartIndex == null ^ sourceFlatEndIndex == null)
				throw new TextureException("Source Wad does not have a complete flat namespace.");

			// ======== Get source texture set if it exists.
			if (sourceWad.contains("TEXTURE1"))
			{
				sourceTexture1Set = new HashSet<String>();
				sourceTextureSet = importTextureSet(sourceWad, strife, sourceTexture1Set);
				sourceIsStrife = strife[0];
			}

			// ======== Get destination patch namespace start and end.
			if ((idx = destinationWad.indexOf("P_START")) < 0)
				idx = destinationWad.indexOf("PP_START");
			if (idx >= 0)
				destinationPatchStartIndex = idx;
			
			if ((idx = destinationWad.indexOf("P_END")) < 0)
				idx = destinationWad.indexOf("PP_END");
			if (idx >= 0)
				destinationPatchEndIndex = idx;

			if (destinationPatchStartIndex == null ^ destinationPatchEndIndex == null)
				throw new TextureException("Destination Wad does not have a complete patch namespace.");

			destinationPatches = new TreeSet<String>(String.CASE_INSENSITIVE_ORDER);
			for (WadEntry e : WadUtils.getEntriesInNamespace(destinationWad, "P", Pattern.compile("P[1-9]_(START|END)")))
				destinationPatches.add(e.getName());
			for (WadEntry e : WadUtils.getEntriesInNamespace(destinationWad, "PP"))
				destinationPatches.add(e.getName());

			// ======== Get destination flat namespace start and end.
			if ((idx = destinationWad.indexOf("F_START")) < 0)
				idx = destinationWad.indexOf("FF_START");
			if (idx >= 0)
				destinationFlatStartIndex = idx;
			
			if ((idx = destinationWad.indexOf("F_END")) < 0)
				idx = destinationWad.indexOf("FF_END");
			if (idx >= 0)
				destinationFlatEndIndex = idx;

			if (destinationFlatStartIndex == null ^ destinationFlatEndIndex == null)
				throw new TextureException("Destination Wad does not have a complete flat namespace.");

			destinationFlats = new TreeSet<String>(String.CASE_INSENSITIVE_ORDER);
			for (WadEntry e : WadUtils.getEntriesInNamespace(destinationWad, "F", Pattern.compile("F[1-9]_(START|END)")))
				destinationFlats.add(e.getName());
			for (WadEntry e : WadUtils.getEntriesInNamespace(destinationWad, "FF"))
				destinationFlats.add(e.getName());

			// ======== Get destination texture set if it exists.

			if (destinationWad.contains("TEXTURE1"))
			{
				if (destinationWad.contains("TEXTURE2"))
					destinationTexture1Set = new HashSet<String>();
				destinationTextureSet = importTextureSet(destinationWad, strife, destinationTexture1Set);
				destinationIsStrife = strife[0];
			}
			
		}

		/**
		 * Copies one flat from the source Wad to the destination Wad.
		 * This will not re-copy flats that already exist (by name) in the destination Wad.
		 * <p>If the flat start/end namespace markers do not exist in the destination Wad, they will be created:
		 * <code>F_START</code> and <code>F_END</code> if IWAD, <code>FF_START</code> and <code>FF_END</code> if PWAD.
		 * <p>An error will occur if either Wad is closed (mostly WadFiles) when this is called.
		 * <p>This does not pay attention to ANIMATED entries! Those will have to be moved separately!
		 * <p>This is completely equivalent to <code>copyFlat(flatName, false)</code>
		 * @param flatName the name of the flat to copy over.
		 * @return true if the flat was copied over, 
		 * 		false if the flat name was not found in the source, or it already existed in the destination.
		 * @throws IOException if a read or write error occurs.
		 * @throws IllegalArgumentException if flatName is not a valid entry name.
		 */
		public boolean copyFlat(String flatName) throws IOException
		{
			return copyFlat(flatName, false);
		}
		
		/**
		 * Copies one flat from the source Wad to the destination Wad.
		 * This will not re-copy flats that already exist (by name) in the destination Wad.
		 * <p>If the flat start/end namespace markers do not exist in the destination Wad, they will be created:
		 * <code>F_START</code> and <code>F_END</code> if IWAD, <code>FF_START</code> and <code>FF_END</code> if PWAD.
		 * <p>An error will occur if either Wad is closed (mostly WadFiles) when this is called.
		 * <p>This does not pay attention to ANIMATED entries! Those will have to be moved separately!
		 * @param flatName the name of the flat to copy over.
		 * @param force if true, this will not check for flats that already exist (by name) in the destination Wad, and copy anyway.
		 * @return true if the flat was copied over, 
		 * 		false if the flat name was not found in the source, or it already existed in the destination.
		 * @throws IOException if a read or write error occurs.
		 * @throws IllegalArgumentException if flatName is not a valid entry name.
		 * @since 2.6.0
		 */
		public boolean copyFlat(String flatName, boolean force) throws IOException
		{
			if (sourceFlatStartIndex == null)
				return false;

			if (!force && destinationFlats.contains(flatName))
				return false;
			
			// if FF_END (and FF_START) does not exist in destination, add them to the destination.
			if (destinationFlatStartIndex == null)
			{
				if (destinationWad.isPWAD())
				{
					destinationWad.addMarker("FF_START");
					destinationWad.addMarker("FF_END");
				}
				else // is IWAD
				{
					destinationWad.addMarker("F_START");
					destinationWad.addMarker("F_END");
				}
				
				// they will be at the end, so get those positions.
				destinationFlatStartIndex = destinationWad.getEntryCount() - 2;
				destinationFlatEndIndex = destinationWad.getEntryCount() - 1;
			}
			
			int entryIndex = sourceWad.indexOf(flatName, sourceFlatStartIndex);
			// ensure flat namespace.
			if (entryIndex > sourceFlatStartIndex && entryIndex < sourceFlatEndIndex)
			{
				destinationWad.addDataAt(destinationFlatEndIndex++, flatName, sourceWad.getData(entryIndex));
				destinationFlats.add(flatName);
			}

			return true;
		}
		
		/**
		 * Adds a flat to the list of "already copied" flats, as though it already exists in the destination.
		 * @param flatName the name of the flat.
		 * @throws IllegalArgumentException if flatName is not a valid entry name.
		 * @since 2.10.0
		 */
		public void ignoreFlat(String flatName)
		{
			NameUtils.checkValidEntryName(flatName);
			destinationFlats.add(flatName);			
		}
		
		/**
		 * Copies one texture from the source Wad to the destination Wad, and copies 
		 * the associated patch entries from the source Wad to the destination Wad, if they exist in the source.
		 * This will not re-copy patches that already exist (by name) in the destination Wad.
		 * <p>If the TEXTUREx/PNAMES entries do not exist in the destination Wad, blank ones will be prepared (and written on close).
		 * <p>If the patch start/end namespace markers do not exist in the destination Wad, they will be created:
		 * <code>P_START</code> and <code>P_END</code> if IWAD, <code>PP_START</code> and <code>PP_END</code> if PWAD.
		 * <p>An error will occur if either Wad is closed (mostly WadFiles) when this is called.
		 * <p>This does not pay attention to ANIMATED or SWITCHES entries! Those will have to be moved separately!
		 * <p>This is completely equivalent to <code>copyTexture(textureName, false)</code>
		 * @param textureName the name of the texture to copy over.
		 * @throws IOException if a read or write error occurs.
		 * @return true if the texture was copied over, 
		 * 		false if the texture name was not found in the source, or it already existed in the destination.
		 */
		public boolean copyTexture(String textureName) throws IOException
		{
			return copyTexture(textureName, false, false);
		}

		/**
		 * Copies one texture from the source Wad to the destination Wad, and copies 
		 * the associated patch entries from the source Wad to the destination Wad, if they exist in the source.
		 * <p>If the TEXTUREx/PNAMES entries do not exist in the destination Wad, blank ones will be prepared (and written on close).
		 * <p>If the patch start/end namespace markers do not exist in the destination Wad, they will be created:
		 * <code>P_START</code> and <code>P_END</code> if IWAD, <code>PP_START</code> and <code>PP_END</code> if PWAD.
		 * <p>An error will occur if either Wad is closed (mostly WadFiles) when this is called.
		 * <p>This does not pay attention to ANIMATED or SWITCHES entries! Those will have to be moved separately!
		 * @param textureName the name of the texture to copy over.
		 * @param force if true, this will not check for textures that already exist (by name) in the destination Wad, and copy it and its patches anyway.
		 * @throws IOException if a read or write error occurs.
		 * @return true if the texture was copied over, 
		 * 		false if the texture name was not found in the source, or it already existed in the destination.
		 * @since 2.6.0
		 */
		public boolean copyTexture(String textureName, boolean force) throws IOException
		{
			return copyTexture(textureName, force, false);
		}

		/**
		 * Copies one texture from the source Wad to the destination Wad, and copies 
		 * the associated patch entries from the source Wad to the destination Wad, if they exist in the source.
		 * <p>If the TEXTUREx/PNAMES entries do not exist in the destination Wad, blank ones will be prepared (and written on close).
		 * <p>If the patch start/end namespace markers do not exist in the destination Wad, they will be created:
		 * <code>P_START</code> and <code>P_END</code> if IWAD, <code>PP_START</code> and <code>PP_END</code> if PWAD.
		 * <p>An error will occur if either Wad is closed (mostly WadFiles) when this is called.
		 * <p>This does not pay attention to ANIMATED or SWITCHES entries! Those will have to be moved separately!
		 * @param textureName the name of the texture to copy over.
		 * @param force if true, this will not check for textures that already exist (by name) in the destination Wad, and copy it and its patches anyway.
		 * @param replace if true, and <code>force</code> is true, then the texture of the same name in the destination is deleted first (BUT NOT PATCHES).
		 * @throws IOException if a read or write error occurs.
		 * @return true if the texture was copied over, 
		 * 		false if the texture name was not found in the source, or it already existed in the destination.
		 * @since 2.10.0
		 */
		public boolean copyTexture(String textureName, boolean force, boolean replace) throws IOException
		{
			if (sourceTextureSet == null)
				return false;
			
			if (!force && (!sourceTextureSet.contains(textureName) || (destinationTextureSet != null && destinationTextureSet.contains(textureName))))
				return false;

			// Make blank TEXTUREx/PNAMES if not present (add blank TEXTURE2 if the first has it). 
			if (destinationTextureSet == null)
			{
				destinationTextureSet = new TextureSet();
				destinationIsStrife = sourceIsStrife;
				if (sourceWad.contains("TEXTURE2"))
					destinationTexture1Set = sourceTexture1Set;
			}
			
			// copy texture definition
			Texture copied = destinationTextureSet.addTexture(sourceTextureSet.getTextureByName(textureName));
			
			// if there are patches to copy, attempt to copy.
			if (sourcePatchStartIndex != null && copied.getPatchCount() > 0)
			{
				// if PP_END (and PP_START) does not exist in destination, add them to the destination.
				if (destinationPatchStartIndex == null)
				{
					if (destinationWad.isPWAD())
					{
						destinationWad.addMarker("PP_START");
						destinationWad.addMarker("PP_END");
					}
					else // is IWAD
					{
						destinationWad.addMarker("P_START");
						destinationWad.addMarker("P_END");
					}
					
					// they will be at the end, so get those positions.
					destinationPatchStartIndex = destinationWad.getEntryCount() - 2;
					destinationPatchEndIndex = destinationWad.getEntryCount() - 1;
				}
				
				// Copy each patch if found.
				for (Patch p : copied)
				{
					String name = p.getName();
					
					if (destinationPatches.contains(name))
						continue;
					
					int entryIndex = sourceWad.indexOf(name, sourcePatchStartIndex);
					// ensure patch namespace.
					if (entryIndex > sourcePatchStartIndex && entryIndex < sourcePatchEndIndex)
					{
						destinationWad.addDataAt(destinationPatchEndIndex++, name, sourceWad.getData(entryIndex));
						destinationPatches.add(name);
					}
				}
			}
			
			return true;
		}
		
		/**
		 * Commits the destination texture set to the destination Wad.
		 * This will replace TEXTURE1/2 and PNAMES in the destination.
		 * @throws IOException if a write error occurs.
		 */
		public void close() throws IOException
		{
			// nothing to write?
			if (destinationTextureSet == null)
				return;
			
			int texture1Index = destinationWad.indexOf("TEXTURE1");
			int texture2Index = destinationWad.indexOf("TEXTURE2");
			int pnamesIndex = destinationWad.indexOf("PNAMES");
			
			PatchNames pnames = new PatchNames();
			CommonTextureList<?> texture1, texture2;
			
			if (texture2Index >= 0 || destinationTexture1Set != null)
			{
				if (destinationIsStrife)
					destinationTextureSet.export(
						pnames, 
						(StrifeTextureList)(texture1 = new StrifeTextureList(1024)), 
						(StrifeTextureList)(texture2 = new StrifeTextureList(1024)), 
						destinationTexture1Set
					);
				else
					destinationTextureSet.export(
						pnames, 
						(DoomTextureList)(texture1 = new DoomTextureList(1024)), 
						(DoomTextureList)(texture2 = new DoomTextureList(1024)), 
						destinationTexture1Set
					);
			}
			else
			{
				texture2 = null;
				if (destinationIsStrife)
					destinationTextureSet.export(pnames, (StrifeTextureList)(texture1 = new StrifeTextureList(1024)));
				else
					destinationTextureSet.export(pnames, (DoomTextureList)(texture1 = new DoomTextureList(1024)));
			}
			
			if (texture1Index >= 0)
				destinationWad.replaceEntry(texture1Index, texture1);
			else
				destinationWad.addData("TEXTURE1", texture1);

			if (texture2Index >= 0)
				destinationWad.replaceEntry(texture2Index, texture2);
			else if (texture2 != null)
				destinationWad.addData("TEXTURE2", texture2);
			
			if (pnamesIndex >= 0)
				destinationWad.replaceEntry(pnamesIndex, pnames);			
			else
				destinationWad.addData("PNAMES", pnames);			
		}
		
	}
	
}
