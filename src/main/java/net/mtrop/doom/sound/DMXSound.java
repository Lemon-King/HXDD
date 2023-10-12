/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.sound;

import java.io.*;
import java.util.Arrays;

import net.mtrop.doom.object.BinaryObject;
import net.mtrop.doom.struct.io.SerialReader;
import net.mtrop.doom.struct.io.SerialWriter;
import net.mtrop.doom.util.MathUtils;
import net.mtrop.doom.util.RangeUtils;

/**
 * This class holds digital sound information.
 * The format that this reads is the DMX PCM Format, by Digital Expressions, Inc.,
 * written by Paul Radek. Doom uses this format for storing sound data.
 * <p>NOTE: Even though this stores samples as doubles, DMX Sounds are serialized as mono, 8-bit PCM waveforms. 
 * Some sound information will be lost on conversion!
 * @author Matthew Tropiano
 */
public class DMXSound implements BinaryObject
{
	/** 8 kHz Sampling rate. */
	public static final int SAMPLERATE_8KHZ = 8000;
	/** 11 kHz Sampling rate. */
	public static final int SAMPLERATE_11KHZ = 11025;
	/** 22 kHz Sampling rate. */
	public static final int SAMPLERATE_22KHZ = 22050;
	/** 44 kHz Sampling rate. */
	public static final int SAMPLERATE_44KHZ = 44100;
	
	public static enum InterpolationType
	{
		/** Use no interpolation. */
		NONE,
		/** Use linear interpolation. */
		LINEAR,
		/** Use cosine interpolation. */
		COSINE,
		/** Use cubic interpolation. */
		CUBIC;
	}
	
	/** Sampling rate in Samples per Second. */
	private int sampleRate;
	/** The samples as doubles. */
	private double[] samples;
	/** The samples as doubles. */
	private int sampleCount;
	
	/**
	* Creates a new, blank DMXSound.
	*/	
	public DMXSound()
	{
		this(SAMPLERATE_11KHZ, SAMPLERATE_11KHZ); // one second of sound.
	}

	/**
	 * Creates a new DMXSound using a particular sampling rate.
	 * Capacity is initialized to one second worth of sound.
	 * @param sampleRate the sampling rate of this sound in samples per second.
	 */
	public DMXSound(int sampleRate)
	{
		this(sampleRate, sampleRate);
	}

	/**
	 * Creates a new DMXSound using a set of discrete samples at a particular sampling rate.
	 * @param sampleRate the sampling rate of this sound in samples per second.
	 * @param capacity the capacity of the sample vector in this DMXSound.
	 */
	public DMXSound(int sampleRate, int capacity)
	{
		if (capacity < 1)
			throw new IllegalArgumentException("initial capacity can't be less than 1.");
		this.sampleRate = sampleRate;
		this.sampleCount = 0;
		this.samples = new double[capacity];
	}
	
	/**
	 * Creates a new DMXSound using a set of discrete samples at a particular sampling rate.
	 * The source array is copied.
	 * @param sampleRate the sampling rate of this sound in samples per second.
	 * @param samples the discrete samples.
	 */
	public DMXSound(int sampleRate, double[] samples)
	{
		if (samples.length < 1)
			throw new IllegalArgumentException("sample capacity can't be less than 1.");
		this.sampleRate = sampleRate;
		this.sampleCount = samples.length;
		this.samples = Arrays.copyOf(samples, samples.length);
	}
	
	/**
	 * @return the sampling rate of this sound clip in samples per second.
	 */
	public int getSampleRate()
	{
		return sampleRate;
	}

	/**
	 * Sets the sampling rate of this sound clip in samples per second.
	 * This does NOT change the underlying waveform!
	 * @param sampleRate the new sampling rate.
	 * @throws IllegalArgumentException if the sample rate is outside the range of 0 to 65535.
	 */
	public void setSampleRate(int sampleRate)
	{
		RangeUtils.checkShortUnsigned("Sample Rate", sampleRate);
		this.sampleRate = sampleRate;
	}

	private void sampleBufferCheck(int newLength)
	{
		if (newLength > samples.length)
			this.samples = Arrays.copyOf(samples, samples.length * 2);
	}
	
	/**
	 * Sets a single sample, clamped between -1.0 and 1.0.
	 * @param index the sample index to set.
	 * @param sample the added sample.
	 */
	public void setSample(int index, double sample)
	{
		if (index < 0 || index >= sampleCount)
			throw new IndexOutOfBoundsException("Index out of range: " + index);
		samples[index] = Math.max(Math.min(sample, 1.0), -1.0);
	}

	/**
	 * Sets a single sample, clamped between 0 and 255 (-1.0 to 1.0).
	 * @param index the sample index to set.
	 * @param sample the added sample.
	 */
	public void setSampleUnsignedByte(int index, int sample)
	{
		setSample(index, (MathUtils.getInterpolationFactor((sample & 0x0ff), 0, 255) * 2.0) - 1.0);
	}

	/**
	 * Sets a set of samples from a sample index, clamped between -1.0 and 1.0.
	 * @param index the starting sample index to set.
	 * @param samples the samples to add.
	 */
	public void setSamples(int index, double[] samples)
	{
		setSamples(index, samples, 0, samples.length);
	}

	/**
	 * Sets a set of samples from a sample index, clamped between -1.0 and 1.0.
	 * @param index the starting sample index to set.
	 * @param samples the samples to add.
	 * @param offset the offset into the array.
	 * @param length the amount of samples to copy.
	 */
	public void setSamples(int index, double[] samples, int offset, int length)
	{
		for (int i = 0; i < length; i++)
			setSample(index, samples[offset + i]);
	}

	/**
	 * Adds a single sample, clamped between -1.0 and 1.0.
	 * @param sample the added sample.
	 */
	public void addSample(double sample)
	{
		sampleBufferCheck(sampleCount + 1);
		samples[sampleCount++] = Math.max(Math.min(sample, 1.0), -1.0);
	}

	/**
	 * Adds a set of samples, clamped between -1.0 and 1.0.
	 * @param samples the array of samples.
	 */
	public void addSamples(double[] samples)
	{
		addSamples(samples, 0, samples.length);
	}

	/**
	 * Adds a set of samples, clamped between -1.0 and 1.0.
	 * @param sample the array of samples.
	 * @param offset the offset into the array.
	 * @param length the amount of samples to copy.
	 */
	public void addSamples(double[] sample, int offset, int length)
	{
		for (int i = 0; i < length; i++)
			addSample(sample[offset + i]);
	}

	/**
	 * Deletes a chunk of samples.
	 * @param index the starting sample index.
	 * @param count the amount of samples to cut.
	 */
	public void deleteSamples(int index, int count)
	{
		System.arraycopy(samples, index + count, samples, index, count);
		sampleCount -= count;
	}
	
	/**
	 * @return the amount of samples in this sound.
	 */
	public int getSampleCount()
	{
		return sampleCount;
	}
	
	/**
	 * Gets a single sample from a specific sample index.
	 * @param index the index of the sample.
	 * @return the corresponding sample value.
	 */
	public double getSample(int index)
	{
		if (index < 0 || index >= sampleCount)
			throw new IndexOutOfBoundsException("Index out of range: " + index);
		return samples[index];
	}
	
	/**
	 * Gets a single sample from a specific sample index as an unsigned byte.
	 * @param index the index of the sample.
	 * @return the corresponding sample value.
	 */
	public int getSampleUnsignedByte(int index)
	{
		return (int)(((samples[index] + 1.0) / 2.0) * 255.0);
	}
	
	/**
	 * Gets a sampled value from along the full waveform.
	 * @param type the interpolation type. 
	 * @param periodScalar the offset along this wave's full period (0.0 is the beginning, 1.0 is the end).
	 * @return a sampled value.
	 */
	public double getWaveFormSample(InterpolationType type, double periodScalar)
	{
		periodScalar = MathUtils.wrapValue(periodScalar, 0.0, 1.0);
		double sampleIncrement = 1.0 / sampleCount;
		double spos = periodScalar / sampleIncrement;
		double v1 = samples[(int)Math.floor(spos)];
		switch (type)
		{
			default:
			case NONE:
				return v1;
			case LINEAR:
			{
				double v2 = samples[MathUtils.wrapValue((int)Math.ceil(spos), 0, samples.length)];
				double interp = (periodScalar % sampleIncrement) / sampleIncrement;
				return MathUtils.linearInterpolate(interp, v1, v2);
			}
			case COSINE:
			{
				double v2 = samples[MathUtils.wrapValue((int)Math.ceil(spos), 0, samples.length)];
				double interp = (periodScalar % sampleIncrement) / sampleIncrement;
				return MathUtils.cosineInterpolate(interp, v1, v2);
			}
			case CUBIC:
			{
				double v2 = samples[MathUtils.wrapValue((int)Math.ceil(spos), 0, samples.length)];
				double v0 = samples[MathUtils.wrapValue((int)Math.floor(spos - 1.0), 0, samples.length)];
				double v3 = samples[MathUtils.wrapValue((int)Math.ceil(spos + 1.0), 0, samples.length)];
				double interp = (periodScalar % sampleIncrement) / sampleIncrement;
				return MathUtils.cubicInterpolate(interp, v0, v1, v2, v3);
			}
		}
	}

	/**
	 * Gets a full copy of the contained audio resampled 
	 * at a new sampling rate using an interpolation type
	 * @param type the interpolation type for the resample.  
	 * @param newSamplingRate the new sampling rate.
	 * @return a new DMXSound that is the result of the resample.
	 */
	public DMXSound resample(InterpolationType type, int newSamplingRate)
	{
		double ratio = (double)newSamplingRate / sampleRate;
		int newSamples = (int)(sampleCount * ratio);
		
		DMXSound sound = new DMXSound(newSamplingRate, newSamples);
		sound.sampleCount = sound.samples.length;
		double incr = 1.0 / sound.sampleCount; 
		
		for (int i = 0; i < sound.sampleCount; i++)
			sound.samples[i] = getWaveFormSample(type, incr * i);
		sound.sampleCount = sound.samples.length;
		return sound;
	}

	@Override
	public void readBytes(InputStream in) throws IOException
	{
		SerialReader sr = new SerialReader(SerialReader.LITTLE_ENDIAN);
		int type = sr.readUnsignedShort(in);
		if (type != 3)
			throw new IOException("Not a sound clip.");
		
		sampleRate = sr.readUnsignedShort(in);
		int n = (int)sr.readUnsignedInt(in);
		sampleCount = n - 32;
		samples = new double[sampleCount];
		
		sr.readBytes(in, 16); // padding
		
		byte[] b = sr.readBytes(in, sampleCount);
		for (int i = 0; i < b.length; i++)
			setSampleUnsignedByte(i, b[i]);
		
		sr.readBytes(in, 16); // padding
	}

	@Override
	public void writeBytes(OutputStream out) throws IOException
	{
		final byte[] PADDING = new byte[]{
				0x7F, 0x7F, 0x7F, 0x7F,
				0x7F, 0x7F, 0x7F, 0x7F,
				0x7F, 0x7F, 0x7F, 0x7F,
				0x7F, 0x7F, 0x7F, 0x7F
			};
		SerialWriter sw = new SerialWriter(SerialWriter.LITTLE_ENDIAN);
		sw.writeUnsignedShort(out, 3); // format type
		sw.writeUnsignedShort(out, sampleRate);
		sw.writeUnsignedInteger(out, sampleCount + (PADDING.length * 2));
		
		sw.writeBytes(out, PADDING);
		for (int i = 0; i < sampleCount; i++)
			sw.writeUnsignedByte(out, getSampleUnsignedByte(i));
		sw.writeBytes(out, PADDING);
	}

	@Override
	public String toString()
	{
		return String.format("DMXSound Sample Rate: %d Hz, %d Samples, 8-bit", sampleRate, sampleCount);
	}
	
}
