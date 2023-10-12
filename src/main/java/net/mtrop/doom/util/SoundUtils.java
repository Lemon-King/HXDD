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
import java.io.InputStream;
import java.io.OutputStream;

import javax.sound.sampled.AudioFileFormat;
import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.AudioInputStream;
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.UnsupportedAudioFileException;

import net.mtrop.doom.sound.DMXSound;
import net.mtrop.doom.struct.io.IOUtils;
import net.mtrop.doom.struct.io.JSPISoundHandle;
import net.mtrop.doom.struct.io.SerializerUtils;
import net.mtrop.doom.struct.io.JSPISoundHandle.Decoder;

/**
 * Sound utility methods for sound types.
 * @author Matthew Tropiano
 */
public final class SoundUtils
{
	private SoundUtils() {}
	
	/**
	 * Imports a file as a DMXSound.
	 * This is dependent on the drivers in the Java SPI to read supported files.
	 * If the input has multiple channels, they are lazily muxed into a single channel.
	 * <p>NOTE: DMX Sounds are stored as mono, 8-bit PCM waveforms. Some sound information will be lost on conversion!
	 * @param file the input audio stream.
	 * @return the resultant DMX Sound object.
	 * @throws IOException if an error occurs on write.
	 * @throws UnsupportedAudioFileException if the file is an unrecognized audio type.
	 */
	public static DMXSound createSound(File file) throws IOException, UnsupportedAudioFileException
	{
		JSPISoundHandle handle = new JSPISoundHandle(file);
		Decoder decoder = handle.getDecoder();
		AudioFormat format = decoder.getDecodedAudioFormat();
		
		int bps = format.getSampleSizeInBits() / 8;
		int sampleRate = (int)format.getSampleRate();
		
		DMXSound out = new DMXSound(sampleRate);
		
		double[] channelSamples = new double[format.getChannels()];
		byte[] pcmData = new byte[sampleRate * bps];
		boolean endian = !format.isBigEndian();
		int buf = 0;
		
		while ((buf = decoder.readPCMBytes(pcmData)) > 0)
		{
			int i = 0;
			while (i < buf)
			{
				for (int s = 0; s < channelSamples.length; s++)
				{
					if (bps == 2)
						channelSamples[s] = MathUtils.getInterpolationFactor(SerializerUtils.bytesToShort(pcmData, i, endian), -32768, 32767) * 2.0 - 1.0;
					else
						channelSamples[s] = MathUtils.getInterpolationFactor((pcmData[i] & 0x0ff), 0, 255) * 2.0 - 1.0;
					i += bps;
				}
				out.addSample(muxSamples(channelSamples));
			}
		}
		IOUtils.close(decoder);
		
		return out;
	}
	
	/**
	 * Writes a DMXSound out to an audio file.
	 * The destination file will be overwritten!
	 * @param sound the input DMX Sound.
	 * @param fileType the file format type.
	 * @param outFile the output file.
	 * @throws IOException if an error occurred during the write. 
	 * @throws UnsupportedAudioFileException if the output type is unsupported.
	 */
	public static void writeSoundToFile(DMXSound sound, AudioFileFormat.Type fileType, File outFile) throws IOException, UnsupportedAudioFileException
	{
		AudioSystem.write(getAudioInputStream(sound), fileType, outFile);
	}
	
	/**
	 * Writes a DMXSound out to an output stream.
	 * @param sound the input DMX Sound.
	 * @param fileType the file format type.
	 * @param out the output stream.
	 * @throws IOException if an error occurred during the write. 
	 * @throws UnsupportedAudioFileException if the output type is unsupported.
	 */
	public static void writeSoundToOutputStream(DMXSound sound, AudioFileFormat.Type fileType, OutputStream out) throws IOException, UnsupportedAudioFileException
	{
		AudioSystem.write(getAudioInputStream(sound), fileType, out);
	}
	
	/**
	 * Creates an AudioInputStream for a DMX Sound.
	 * @param sound the DMX Sound to get an audio stream for.
	 * @return an {@link AudioInputStream} for reading audio data from this sound.
	 */
	public static AudioInputStream getAudioInputStream(final DMXSound sound)
	{
		return new AudioInputStream(
			new InputStream() 
			{
				private int cur = 0;
				
				@Override
				public int read() throws IOException
				{
					if (cur >= sound.getSampleCount())
						return -1;
					else
						return sound.getSampleUnsignedByte(cur++);
				}
			},
			new AudioFormat(sound.getSampleRate(), 8, 1, false, false),
			sound.getSampleCount()
		);
	}
	
	private static double muxSamples(double... d)
	{
		double factor = 1.0 / d.length;
		double accum = 0.0;
		for (int i = 0; i < d.length; i++)
			accum += d[i] * factor;
		return accum; 
	}
	
}
