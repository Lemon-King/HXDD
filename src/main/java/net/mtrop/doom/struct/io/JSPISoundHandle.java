/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.struct.io;

import java.io.*;
import java.net.URL;
import java.nio.ByteOrder;

import javax.sound.sampled.AudioFileFormat;
import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.AudioInputStream;
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.UnsupportedAudioFileException;

/**
 * Sound resource abstraction.
 * Wraps Java Sound SPI structures for ease of creating handles to decodable sound.
 * @author Matthew Tropiano
 */
public class JSPISoundHandle
{
	/** Name of this data stream. */
	private String dataName;
	/** Audio file format. */
	private AudioFileFormat audioFileFormat;

	/** File resource. */
	private File dataFile;
	/** URL resource. */
	private URL dataURL;
	
	protected JSPISoundHandle()
	{
		this.dataName = null;
		this.dataFile = null;
		this.dataURL = null;
	}
	
	/**
	 * Opens a sound file for reading.
	 * @param filePath path to the file.
	 * @throws IOException if the resource can't be read.
	 * @throws UnsupportedAudioFileException if the audio format is not recognized.
	 */
	public JSPISoundHandle(String filePath) throws IOException, UnsupportedAudioFileException
	{
		dataFile = new File(filePath);
		dataName = dataFile.getPath();
		audioFileFormat = AudioSystem.getAudioFileFormat(dataFile);
	}

	/**
	 * Opens a sound file for reading.
	 * @param f the file.
	 * @throws IOException if the file can't be read.
	 * @throws UnsupportedAudioFileException if the audio format is not recognized.
	 */
	public JSPISoundHandle(File f) throws IOException, UnsupportedAudioFileException
	{
		dataName = f.getPath();
		dataFile = f;
		audioFileFormat = AudioSystem.getAudioFileFormat(dataFile);
	}
	
	/**
	 * Opens a URL for reading.
	 * @param url the URL.
	 * @throws IOException if the stream can't be read.
	 * @throws UnsupportedAudioFileException if the audio format is not recognized.
	 */
	public JSPISoundHandle(URL url) throws IOException, UnsupportedAudioFileException
	{
		dataName = url.toString();
		dataURL = url;
		audioFileFormat = AudioSystem.getAudioFileFormat(dataURL);
	}

	/**
	 * @return a {@link Decoder} that can decode this data into PCM data.
	 * @throws IOException if a decoder could not be opened.
	 */
	public Decoder getDecoder() throws IOException
	{
		try {
			return new Decoder();
		} catch (UnsupportedAudioFileException e) {
			throw new IOException("Could not decode audio (should have been prechecked).");
		}
	}
	
	/**
	 * @return the name of this handle.
	 */
	public String getName()	
	{
		return dataName;
	}

	@Override
	public String toString()
	{
		StringBuilder sb = new StringBuilder();
		sb.append(getName());
		sb.append(' ');
		sb.append(audioFileFormat.toString());
		return sb.toString();
	}

	/**
	 * @return the dataName
	 */
	public final String getDataName()
	{
		return dataName;
	}

	// Creates the stream for the decoder.
	private AudioInputStream startStream() throws IOException, UnsupportedAudioFileException
	{
		if (dataFile != null)
			return AudioSystem.getAudioInputStream(dataFile);
		else
			return AudioSystem.getAudioInputStream(dataURL);
	}
	
	/**
	 * Decoder class that decodes sound as PCM audio.
	 * @author Matthew Tropiano
	 */
	public class Decoder implements AutoCloseable
	{
		/** Audio format. */
		private AudioFormat audioFormat;
		/** Audio input stream. */
		private AudioInputStream audioStream;
		/** Audio format to decode to. */
		private AudioFormat decodedAudioFormat;
		/** Audio input stream to decode to. */
		private AudioInputStream decodedAudioStream;
		
		Decoder() throws IOException, UnsupportedAudioFileException
		{
			audioStream = startStream();
			audioFormat = audioStream.getFormat();
			decodedAudioFormat = new AudioFormat(
				audioFormat.getSampleSizeInBits() == 8 ? AudioFormat.Encoding.PCM_UNSIGNED : AudioFormat.Encoding.PCM_SIGNED, 
				audioFormat.getSampleRate(), 
				audioFormat.getSampleSizeInBits() != AudioSystem.NOT_SPECIFIED ? audioFormat.getSampleSizeInBits() : 16, 
				audioFormat.getChannels(),
				audioFormat.getChannels() * 2,
				audioFormat.getSampleRate(),
				ByteOrder.nativeOrder() == ByteOrder.BIG_ENDIAN
			);
			decodedAudioStream = AudioSystem.getAudioInputStream(decodedAudioFormat, audioStream);
		}
		
		/**
		 * Reads a bunch of decoded bytes into the byte array.
		 * @param b	the byte array.
		 * @return how many bytes were written.
		 * @throws IOException if the data can't be decompressed.
		 */
		public int readPCMBytes(byte[] b) throws IOException
		{
			int i = 0;
			int buf = 0;
			while (i != b.length)
			{
				buf = decodedAudioStream.read(b, i, b.length-i);
				if (buf != -1)
					i += buf;
				else 
					break;
			}

			return i;
		}

		/**
		 * @return the audio format specs.
		 * @see AudioFormat
		 */
		public final AudioFormat getFormat()
		{
			return audioFormat;
		}
		
		/**
		 * @return the audio file format specs.
		 * @see AudioFileFormat
		 */
		public final AudioFileFormat getFileFormat()
		{
			return audioFileFormat;
		}

		/**
		 * @return the decodedAudioFormat
		 */
		public final AudioFormat getDecodedAudioFormat()
		{
			return decodedAudioFormat;
		}
		
		/**
		 * Closes the decoder.
		 * @throws IOException if an error occurred during close.
		 */
		public void close() throws IOException
		{
			IOUtils.close(audioStream);
			IOUtils.close(decodedAudioStream);
		}

	}
	
}