/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.object;

import java.io.BufferedInputStream;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.lang.reflect.Array;
import java.lang.reflect.InvocationTargetException;
import java.util.Iterator;
import java.util.NoSuchElementException;

import net.mtrop.doom.struct.io.IOUtils;

/**
 * Common elements of all objects that are loaded from binary data.
 * This provides a general interface for getting serialized object data.
 * @author Matthew Tropiano
 */
public interface BinaryObject
{
	/**
	 * Reads from an {@link InputStream} and sets this object's fields.
	 * Only reads the amount of bytes that it takes to read a single instance of the object.
	 * Note that not every object may have a consistent length!
	 * @param in the {@link InputStream} to read from. 
	 * @throws IOException if a read error occurs.
	 */
	void readBytes(InputStream in) throws IOException;

	/**
	 * Reads from a {@link File} and sets this object's fields.
	 * Only reads the amount of bytes that it takes to read a single instance of the object.
	 * Note that not every object may have a consistent length!
	 * @param file the {@link File} to read from. 
	 * @throws FileNotFoundException if the file could not be found.
	 * @throws IOException if a read error occurs.
	 * @throws SecurityException if the file could not be opened due to OS permissions.
	 * @since 2.13.0
	 */
	default void readFile(File file) throws IOException
	{
		try (InputStream fis = new BufferedInputStream(new FileInputStream(file), 8192))
		{
			readBytes(fis);
		}
	}

	/**
	 * Writes this object to an {@link OutputStream}.
	 * @param out the {@link OutputStream} to write to.
	 * @throws IOException if a write error occurs.
	 */
	void writeBytes(OutputStream out) throws IOException;

	/**
	 * Writes this object to a {@link File}.
	 * The file's contents are overwritten.
	 * @param file the {@link File} to write to.
	 * @throws FileNotFoundException if the file exists, but is a directory.
	 * @throws IOException if a write error occurs.
	 * @throws SecurityException if the file could not be written to due to OS permissions.
	 * @since 2.13.0
	 * @see #writeFile(File, boolean)
	 */
	default void writeFile(File file) throws IOException
	{
		writeFile(file, false);
	}

	/**
	 * Writes this object to a {@link File}.
	 * @param file the {@link File} to write to.
	 * @param append if true, the content is written to the end of the file.
	 * @throws FileNotFoundException if the file exists, but is a directory.
	 * @throws IOException if a write error occurs.
	 * @throws SecurityException if the file could not be written to due to OS permissions.
	 * @since 2.13.0
	 */
	default void writeFile(File file, boolean append) throws IOException
	{
		try (FileOutputStream fos = new FileOutputStream(file, append))
		{
			writeBytes(fos);
		}
	}

	/**
	 * Gets the byte representation of this object. 
	 * @return this object as a series of bytes.
	 */
	default byte[] toBytes()
	{
		ByteArrayOutputStream bos = new ByteArrayOutputStream(512);
		try { writeBytes(bos); } catch (IOException e) { /* Shouldn't happen. */ }
		return bos.toByteArray();
	}

	/**
	 * Reads in the byte representation of this object and sets its fields.
	 * @param data the byte array to read from. 
	 * @throws IOException if a read error occurs.
	 */
	default void fromBytes(byte[] data) throws IOException
	{
		readBytes(new ByteArrayInputStream(data));
	}

	/**
	 * Converts an array of BinaryObjects into bytes.
	 * @param <BO> the BinaryObject type.
	 * @param data the objects to convert.
	 * @return the data bytes.
	 * @since 2.4.0
	 */
	static <BO extends BinaryObject> byte[] toBytes(BO[] data)
	{
		ByteArrayOutputStream bos = Shared.CONVERSIONBUFFER.get();
		bos.reset();
		for (BO bo : data)
			try {bo.writeBytes(bos);} catch (IOException e) {/* Should not happen. */}
		return bos.toByteArray();
	}

	/**
	 * Creates a single object of a specific class from a serialized byte array.
	 * @param <BO> the object type, a subtype of {@link BinaryObject}.
	 * @param boClass the class to create.
	 * @param b the array of bytes.
	 * @return a single instance of the created object.
	 * @throws IOException if an error occurs during the read - most commonly "not enough bytes".
	 */
	static <BO extends BinaryObject> BO create(Class<BO> boClass, byte[] b) throws IOException
	{
		return read(boClass, new ByteArrayInputStream(b));
	}

	/**
	 * Creates a single object of a specific class from from an {@link InputStream}.
	 * @param <BO> the object type, a subtype of {@link BinaryObject}.
	 * @param boClass the class to create.
	 * @param in the input stream.
	 * @return a single instance of the created object.
	 * @throws IOException if an error occurs during the read - most commonly "not enough bytes".
	 */
	static <BO extends BinaryObject> BO read(Class<BO> boClass, InputStream in) throws IOException
	{
		BO out = (BO)Reflect.create(boClass);
		out.readBytes(in);
		return out;
	}

	/**
	 * Creates a single object of a specific class from from a {@link File}.
	 * @param <BO> the object type, a subtype of {@link BinaryObject}.
	 * @param boClass the class to create.
	 * @param file the source file.
	 * @return a single instance of the created object.
	 * @throws FileNotFoundException if the file could not be found.
	 * @throws IOException if an error occurs during the read - most commonly "not enough bytes".
	 * @throws SecurityException if the file could not be opened due to OS permissions.
	 * @since 2.13.0
	 */
	static <BO extends BinaryObject> BO read(Class<BO> boClass, File file) throws IOException
	{
		try (FileInputStream fis = new FileInputStream(file))
		{
			return read(boClass, fis);
		}
	}

	/**
	 * Creates an amount of objects of a specific class from a serialized byte array.
	 * @param <BO> the object type, a subtype of {@link BinaryObject}.
	 * @param boClass the class to create.
	 * @param b the array of bytes.
	 * @param count the (maximum) amount of objects to read. 
	 * @return an array of length <code>count</code> of the created objects.
	 * @throws IOException if an error occurs during the read - most commonly "not enough bytes".
	 */
	static <BO extends BinaryObject> BO[] create(Class<BO> boClass, byte[] b, int count) throws IOException
	{
		return read(boClass, new ByteArrayInputStream(b), count);
	}

	/**
	 * Creates an amount of objects of a specific class from an {@link InputStream}.
	 * @param <BO> the object type, a subtype of {@link BinaryObject}.
	 * @param boClass the class to create.
	 * @param in the input stream.
	 * @param count the (maximum) amount of objects to read. 
	 * @return an array of length <code>count</code> of the created objects.
	 * @throws IOException if an error occurs during the read - most commonly "not enough bytes".
	 */
	@SuppressWarnings("unchecked")
	static <BO extends BinaryObject> BO[] read(Class<BO> boClass, InputStream in, int count) throws IOException
	{
		BO[] out = (BO[])Array.newInstance(boClass, count);
		int i = 0;
		while (count-- > 0)
		{
			out[i] = Reflect.create(boClass);
			out[i].readBytes(in);
			i++;
		}
		return (BO[])out;
	}

	/**
	 * Creates an amount of objects of a specific class from a {@link File}.
	 * @param <BO> the object type, a subtype of {@link BinaryObject}.
	 * @param boClass the class to create.
	 * @param file the source file.
	 * @param count the (maximum) amount of objects to read. 
	 * @return an array of length <code>count</code> of the created objects.
	 * @throws FileNotFoundException if the file could not be found.
	 * @throws IOException if an error occurs during the read - most commonly "not enough bytes".
	 * @throws SecurityException if the file could not be opened due to OS permissions.
	 * @since 2.13.0
	 */
	static <BO extends BinaryObject> BO[] read(Class<BO> boClass, File file, int count) throws IOException
	{
		try (FileInputStream fis = new FileInputStream(file))
		{
			return read(boClass, fis, count);
		}
	}

	/**
	 * Creates a deserializing scanner iterator that returns independent instances of objects.
	 * <p><b>NOTE:</b> The InputStream is closed after the last object is read.
	 * @param <BO> the object type, a subtype of {@link BinaryObject}.
	 * @param boClass the class to create.
	 * @param in the input stream.
	 * @param length the length of each object to read. 
	 * @return a Scanner object for reading the objects.
	 * @throws IOException if an error occurs during the read - most commonly "not enough bytes".
	 */
	static <BO extends BinaryObject> Scanner<BO> scanner(Class<BO> boClass, InputStream in, int length) throws IOException
	{
		return new Scanner<>(boClass, in, length);
	}

	/**
	 * Creates a deserializing scanner iterator that returns the same object instance with its contents changed.
	 * This is useful for when you would want to quickly scan through a set of serialized objects while
	 * ensuring low memory use. Do NOT store the references returned by <code>next()</code> anywhere as the contents
	 * of that reference will be changed by the next call to <code>next()</code>.
	 * <p><b>NOTE:</b> The InputStream is closed after the last object is read.
	 * @param <BO> the object type, a subtype of {@link BinaryObject}.
	 * @param boClass the class to create.
	 * @param in the input stream.
	 * @param length the length of each object to read. 
	 * @return an InlineScanner object for reading the objects.
	 * @throws IOException if an error occurs during the read - most commonly "not enough bytes".
	 */
	static <BO extends BinaryObject> InlineScanner<BO> inlineScanner(Class<BO> boClass, InputStream in, int length) throws IOException
	{
		return new InlineScanner<>(boClass, in, length);
	}

	/**
	 * Transformer interface for transform calls. 
	 * @param <BO> the BinaryObject type.
	 * @since 2.1.0
	 */
	@FunctionalInterface
	interface Transformer<BO extends BinaryObject>
	{
		/**
		 * Transforms the provided object. 
		 * The provided object reference may not be distinct each call.
		 * Do not save the reference passed to this function anywhere.
		 * @param object the object to transform.
		 * @param index the sequence index of the object. 
		 */
		void transform(BO object, int index);
	}
	
	/**
	 * A deserializing scanner iterator that returns independent instances of objects.
	 * @param <BO> the BinaryObject type.
	 * @since 2.8.0, this class implements {@link AutoCloseable}.
	 */
	class Scanner<BO extends BinaryObject> implements Iterator<BO>, AutoCloseable
	{
		/** The input stream. */
		private InputStream in;
		/** Read next? */
		private boolean readNext;
		/** Has next? */
		private boolean hasNext;
		/** The byte buffer. */
		private byte[] buffer;
		/** The object class. */
		private Class<BO> objClass;
		
		private Scanner(Class<BO> clz, InputStream in, int len)
		{
			this.in = in;
			this.readNext = false;
			this.hasNext = false;
			this.buffer = new byte[len];
			this.objClass = clz;
		}
		
		private void loadNext() throws IOException
		{
			if (readNext)
				return;
			hasNext = in.read(buffer) == buffer.length;
			readNext = true;
		}
		
		@Override
		public boolean hasNext()
		{
			try {
				loadNext();
				return hasNext;
			} catch (IOException e) {
				throw new RuntimeException("Could not read bytes for " + objClass.getSimpleName(), e);
			}
		}

		@Override
		public BO next()
		{
			try {
				loadNext();
				if (!hasNext)
					throw new NoSuchElementException("No more objects.");
				BO out = create(objClass, buffer);
				readNext = false;
				return out;
			} catch (IOException e) {
				throw new RuntimeException("Could not deserialize " + objClass.getSimpleName(), e);
			}
		}

		@Override
		public void close()
		{
			IOUtils.close(in);
		}
		
	}
	
	/**
	 * A deserializing scanner iterator that returns the same object instance with its contents changed.
	 * @param <BO> the BinaryObject type.
	 * @since 2.8.0, this class implements {@link AutoCloseable}.
	 */
	class InlineScanner<BO extends BinaryObject> implements Iterator<BO>, AutoCloseable
	{
		/** The input stream. */
		private InputStream in;
		/** Read next? */
		private boolean readNext;
		/** Has next? */
		private boolean hasNext;
		/** The byte buffer. */
		private byte[] buffer;
		/** The object class. */
		private Class<BO> objClass;
		/** The object class. */
		private BO outObject;
		
		private InlineScanner(Class<BO> clz, InputStream in, int len)
		{
			this.in = in;
			this.readNext = false;
			this.hasNext = false;
			this.buffer = new byte[len];
			this.objClass = clz;
			this.outObject = Reflect.create(clz);
		}
		
		private void loadNext() throws IOException
		{
			if (readNext)
				return;
			hasNext = in.read(buffer) == buffer.length;
			readNext = true;
		}
		
		@Override
		public boolean hasNext()
		{
			try {
				loadNext();
				return hasNext;
			} catch (IOException e) {
				throw new RuntimeException("Could not read bytes for " + objClass.getSimpleName(), e);
			}
		}

		@Override
		public BO next()
		{
			try {
				loadNext();
				if (!hasNext)
					throw new NoSuchElementException("No more objects.");
				outObject.fromBytes(buffer);
				readNext = false;
				return outObject;
			} catch (IOException e) {
				throw new RuntimeException("Could not deserialize " + objClass.getSimpleName(), e);
			}
		}
		
		@Override
		public void close()
		{
			IOUtils.close(in);
		}
		
	}

	static class Shared
	{
		private static ThreadLocal<ByteArrayOutputStream> CONVERSIONBUFFER = 
			ThreadLocal.withInitial(()->new ByteArrayOutputStream(16384));
	}
	
	static class Reflect
	{
		/**
		 * Creates a new instance of a class from a class type.
		 * This essentially calls {@link Class#newInstance()}, but wraps the call
		 * in a try/catch block that only throws an exception if something goes wrong.
		 * @param <T> the return object type.
		 * @param clazz the class type to instantiate.
		 * @return a new instance of an object.
		 * @throws RuntimeException if instantiation cannot happen, either due to
		 * a non-existent constructor or a non-visible constructor.
		 */
		private static <T> T create(Class<T> clazz)
		{
			Object out = null;
			try {
				out = clazz.getDeclaredConstructor().newInstance();
			} catch (SecurityException ex) {
				throw new RuntimeException(ex);
			} catch (IllegalAccessException e) {
				throw new RuntimeException(e);
			} catch (InstantiationException e) {
				throw new RuntimeException(e);
			} catch (IllegalArgumentException e) {
				throw new RuntimeException(e);
			} catch (InvocationTargetException e) {
				throw new RuntimeException(e);
			} catch (NoSuchMethodException e) {
				throw new RuntimeException(e);
			}
			
			return clazz.cast(out);
		}
	}
	
}
