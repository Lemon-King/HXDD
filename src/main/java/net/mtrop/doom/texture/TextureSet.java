/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.texture;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Queue;
import java.util.Set;

import net.mtrop.doom.exception.TextureException;
import net.mtrop.doom.struct.Sizable;
import net.mtrop.doom.struct.vector.AbstractMappedVector;
import net.mtrop.doom.util.NameUtils;

/**
 * A helper class for the TEXTUREx and PNAMES setup that Doom Texture definitions use.
 * @author Matthew Tropiano
 */
public class TextureSet implements Iterable<TextureSet.Texture>, Sizable
{
	/** The list of textures in this set, sorted. */
	private AbstractMappedVector<Texture, String> textureList;

	/**
	 * Creates a new blank TextureSet (no patches, no textures).
	 * @since 2.6.0
	 */
	public TextureSet()
	{
		this.textureList = new AbstractMappedVector<TextureSet.Texture, String>(256)
		{
			@Override
			protected String getMappingKey(Texture object)
			{
				return object.getName();
			}
		};		
	}
	
	/**
	 * Creates a new TextureSet using an existing Patch Name lump and a series of Texture Lumps.
	 * @param pnames the patch name lump.
	 * @param textureLists the list of texture lists.
	 * @throws TextureException if a texture references an invalid index in pnames.
	 */
	@SafeVarargs
	public TextureSet(PatchNames pnames, final CommonTextureList<?> ... textureLists)
	{
		this();
		
		for (CommonTextureList<?> lump : textureLists)
		{
			for (int i = 0; i < lump.size(); i++)
			{
				CommonTexture<?> t = lump.getTextureByIndex(i);
				
				Texture newtex = createTexture(t.getName());
				newtex.setWidth(t.getWidth());
				newtex.setHeight(t.getHeight());
				
				for (int j = 0; j < t.getPatchCount(); j++)
				{
					CommonPatch p = t.getPatch(j);
					String patchName = pnames.get(p.getNameIndex());
					if (patchName == null)
						throw new TextureException("Index "+j+" in PNAMES does not exist!");
					Patch newpatch = newtex.createPatch(patchName);
					newpatch.setOriginX(p.getOriginX());
					newpatch.setOriginY(p.getOriginY());
				}
			}
		}
	}
	
	/**
	 * Checks an entry for a texture exists.
	 * @param textureName the texture name to search for.
	 * @return true if it exists, false otherwise.
	 */
	public boolean contains(String textureName)
	{
		return textureList.containsKey(textureName);
	}
	
	/**
	 * Adds a texture.
	 * The texture being added is deep-copied, such that altering 
	 * the texture being added will not affect the one in this set.
	 * @param texture the texture to add.
	 * @return (since 2.6.0) the reference to the copy of the texture added to this set.
	 * @throws IllegalArgumentException if the texture to add is null. 
	 */
	public Texture addTexture(Texture texture)
	{
		if (texture == null)
			throw new IllegalArgumentException("texture cannot be null");
		Texture out = texture.copy();
		textureList.add(out);
		return out;
	}

	/**
	 * Creates a new entry for a texture, already added.
	 * @param textureName the name of the texture to add.
	 * @return a new, empty texture.
	 * @throws IllegalArgumentException if the texture name is empty or not a valid texture name.
	 * @see NameUtils#isValidTextureName(String)
	 */
	public Texture createTexture(String textureName)
	{
		NameUtils.checkValidTextureName(textureName);
		Texture out = new Texture(textureName);
		textureList.add(out);
		return out;
	}

	/**
	 * Returns a texture at a particular index.
	 * @param index the index of the texture to get.
	 * @return the corresponding removed texture, or <code>null</code> if not removed.
	 */
	public Texture getTexture(int index)
	{
		return textureList.get(index);
	}

	/**
	 * Returns an entry for a texture by name.
	 * @param textureName the texture name to search for.
	 * @return a texture with the composite information, or <code>null</code> if the texture could not be found.
	 */
	public Texture getTextureByName(String textureName)
	{
		return textureList.getUsingKey(textureName);
	}
	
	/**
	 * Returns a sequence of texture names. Order and list of entries
	 * are dependent on the order of all of the textures in this set.
	 * @param firstName the first texture name in the sequence. 
	 * @param lastName the last texture name in the sequence.
	 * @return an array of all of the textures in the sequence, including
	 * 		the provided textures, or null, if either texture does not exist.
	 */
	public String[] getSequence(String firstName, String lastName)
	{
		Queue<String> out = new LinkedList<String>();
		int index = textureList.getIndexUsingKey(firstName);
		if (index >= 0)
		{
			int index2 = textureList.getIndexUsingKey(lastName);
			if (index2 >= 0)
			{
				int min = Math.min(index, index2);
				int max = Math.max(index, index2);
				for (int i = min; i <= max; i++)
					out.add(textureList.get(i).getName());
			}
			else
				return null;
		}
		else
			return null;
		
		String[] outList = new String[out.size()];
		out.toArray(outList);
		return outList;
	}
	
	/**
	 * Removes a texture at a particular index.
	 * @param index the index of the texture to remove.
	 * @return the corresponding removed texture, or <code>null</code> if not removed.
	 */
	public Texture removeTexture(int index)
	{
		return textureList.removeIndex(index);
	}

	/**
	 * Removes a texture by name.
	 * @param textureName the name of the texture to remove.
	 * @return the corresponding removed texture, or <code>null</code> if not removed.
	 */
	public Texture removeTextureByName(String textureName)
	{
		return textureList.removeUsingKey(textureName);
	}

	/**
	 * Shifts the ordering of a texture.
	 * @param index the old index.
	 * @param newIndex the new index.
	 * @see AbstractMappedVector#shift(int, int)
	 */
	public void shiftTexture(int index, int newIndex)
	{
		textureList.shift(index, newIndex);
	}

	/**
	 * Sorts the texture lumps in this set.
	 */
	public void sort()
	{
		textureList.sort();
	}

	/**
	 * Sorts the texture lumps in this set using a comparator.
	 * @param comparator the comparator to use.
	 */
	public void sort(Comparator<Texture> comparator)
	{
		textureList.sort(comparator);
	}

	/**
	 * Exports this {@link TextureSet}'s contents into a PNAMES and TEXTUREx lump.
	 * This looks up patch indices as it exports - if a patch name does not exist in <code>pnames</code>,
	 * it is added.
	 * <p>
	 * In the end, <code>pnames</code> and <code>texture1</code> will be the objects whose contents will change.
	 * @param <P> the inferred patch type of the provided TextureLists.
	 * @param <T> the inferred texture type of the provided TextureLists.
	 * @param pnames the patch names lump to add names to.
	 * @param texture1 the first texture list to write to.
	 */
	public <P extends CommonPatch, T extends CommonTexture<P>> void export(PatchNames pnames, CommonTextureList<T> texture1)
	{
		export(pnames, texture1, null, null);
	}

	/**
	 * Exports this {@link TextureSet}'s contents into a PNAMES and TEXTUREx lump.
	 * This looks up patch indices as it exports - if a patch name does not exist in <code>pnames</code>,
	 * it is added.
	 * <p>
	 * In the end, <code>pnames</code> and <code>texture1</code>/<code>texture2</code> will be the objects whose contents will change.
	 * @param <P> the inferred patch type of the provided TextureLists.
	 * @param <T> the inferred texture type of the provided TextureLists.
	 * @param pnames the patch names lump to add names to.
	 * @param texture1 the first texture list to write to.
	 * @param texture2 the second texture list to write to. Can be null.
	 * @param texture1NameSet the set of texture names that will be written to the first texture list. Can be null (exports all names to <code>texture1</code>).
	 */
	public <P extends CommonPatch, T extends CommonTexture<P>> void export(PatchNames pnames, CommonTextureList<T> texture1, CommonTextureList<T> texture2, Set<String> texture1NameSet)
	{
		for (Texture texture : this)
		{
			CommonTexture<P> ndt;
			
			String tname = texture.getName();
			
			if (texture1NameSet == null || texture1NameSet.contains(tname))
				ndt = texture1.createTexture(tname);
			else
				ndt = texture2.createTexture(tname);
	
			ndt.setWidth(texture.getWidth());
			ndt.setHeight(texture.getHeight());
			
			int index = -1;
			for (int i = 0; i < texture.getPatchCount(); i++)
			{
				Patch patch = texture.getPatch(i);
				
				String pname = patch.getName();
				
				index = pnames.indexOf(pname);
				if (index == -1)
				{
					pnames.add(pname);
					index = pnames.indexOf(pname);
				}	
				
				P ndtp = ndt.createPatch();
				ndtp.setOriginX(patch.getOriginX());
				ndtp.setOriginY(patch.getOriginY());
				ndtp.setNameIndex(index);
			}
	
		}
	}

	@Override
	public int size()
	{
		return textureList.size();
	}

	@Override
	public boolean isEmpty()
	{
		return size() == 0;
	}

	@Override
	public Iterator<Texture> iterator()
	{
		return textureList.iterator();
	}

	/**
	 * A class that represents a single composite Texture entry.
	 */
	public static class Texture implements Iterable<TextureSet.Patch>, Sizable
	{
		/** Texture name. */
		private String name;
		/** Texture width. */
		private int width;
		/** Texture height. */
		private int height;
		
		/** Patch entry. */
		private List<TextureSet.Patch> patches;
		
		private Texture(String name)
		{
			this.name = name;
			width = 0;
			height = 0;
			patches = new ArrayList<TextureSet.Patch>(2);
		}
		
		private Texture(Texture texture)
		{
			this.name = texture.name;
			width = texture.width;
			height = texture.height;
			patches = new ArrayList<TextureSet.Patch>(texture.getPatchCount());
			for (Patch p : texture.patches)
				patches.add(new Patch(p));
		}
		
		/**
		 * @return a copy of this texture.
		 */
		public Texture copy()
		{
			return new Texture(this);
		}
		
		/** 
		 * @return the texture entry name. 
		 */
		public String getName()
		{
			return name;
		}
		
		/**
		 * @return the width of the texture in pixels.
		 */
		public int getWidth()
		{
			return width;
		}
		
		/**
		 * Sets the width of the texture in pixels.
		 * @param width the new width. 
		 */
		public void setWidth(int width)
		{
			this.width = width;
		}
		
		/**
		 * @return the height of the texture in pixels.
		 */
		public int getHeight()
		{
			return height;
		}
		
		/**
		 * Sets the height of the texture in pixels.
		 * @param height the new height. 
		 */
		public void setHeight(int height)
		{
			this.height = height;
		}
		
		/**
		 * Adds a patch to this entry.
		 * @param name the name of the patch. Must be valid.
		 * @return the created patch.
		 * @see NameUtils#checkValidEntryName(String)
		 * @throws IllegalArgumentException if the patch name is empty or not a valid entry name.
		 */
		public Patch createPatch(String name)
		{
			if (NameUtils.isStringEmpty(name))
				throw new IllegalArgumentException("patch name cannot be empty.");

			NameUtils.checkValidEntryName(name);
			
			Patch p = new Patch(name);
			patches.add(p);
			return p;
		}
		
		/**
		 * Removes a patch at a particular index.
		 * @param index the new index. 
		 * @return the corresponding removed patch, or <code>null</code> if no such patch at that index. 
		 */
		public Patch removePatch(int index)
		{
			return patches.remove(index);
		}

		/**
		 * Returns a patch at a particular index.
		 * @param index the index to use.
		 * @return the corresponding patch, or <code>null</code> if no such patch at that index. 
		 */
		public Patch getPatch(int index)
		{
			return patches.get(index);
		}
		
		/**
		 * Shifts the ordering of a patch.
		 * @param index the index to shift.
		 * @param newIndex the new index for the patch.
		 */
		public void shiftPatch(int index, int newIndex)
		{
			// move earlier
			if (newIndex < index)
			{
				Patch p = patches.get(index);
				for (int i = index; i > newIndex; i--)
					patches.set(i, patches.get(i - 1));
				patches.set(newIndex, p);
			}
			// move later
			else if (newIndex > index)
			{
				Patch p = patches.get(index);
				for (int i = index; i < newIndex; i++)
					patches.set(i, patches.get(i + 1));
				patches.set(newIndex, p);
			}
		}
		
		/**
		 * @return how many patches are on this texture entry.
		 */
		public int getPatchCount()
		{
			return patches.size();
		}

		@Override
		public Iterator<Patch> iterator()
		{
			return patches.iterator();
		}

		@Override
		public int size()
		{
			return patches.size();
		}

		@Override
		public boolean isEmpty()
		{
			return size() == 0;
		}

	}

	/**
	 * Texture patch.
	 */
	public static class Patch
	{
		/** Patch name. */
		private String name;
		/** Offset X. */
		private int originX;
		/** Offset Y. */
		private int originY;
		
		private Patch(String name)
		{
			this.name = name;
			this.originX = 0;
			this.originY = 0;
		}

		private Patch(Patch patch)
		{
			this.name = patch.name;
			this.originX = patch.originX;
			this.originY = patch.originY;
		}

		/** @return the patch name. */
		public String getName()
		{
			return name;
		}
	
		/** @return the patch offset X. */
		public int getOriginX()
		{
			return originX;
		}
		
		/** 
		 * Sets the patch offset X. 
		 * @param originX the new origin, x-coordinate. 
		 */
		public void setOriginX(int originX)
		{
			this.originX = originX;
		}
		
		/** @return the patch offset Y. */
		public int getOriginY()
		{
			return originY;
		}
		
		/** 
		 * Sets the patch offset Y.
		 * @param originY the new origin, y-coordinate. 
		 */
		public void setOriginY(int originY)
		{
			this.originY = originY;
		}
		
	}
	
}
