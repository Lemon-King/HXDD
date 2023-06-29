/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.map.data;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Arrays;

import net.mtrop.doom.object.BinaryObject;
import net.mtrop.doom.struct.io.SerialReader;
import net.mtrop.doom.struct.io.SerialWriter;
import net.mtrop.doom.util.RangeUtils;

/**
 * Hexen 20-byte format implementation of Thing.
 * @author Matthew Tropiano
 */
public class HexenThing extends CommonThing implements BinaryObject
{
	/** Byte length of this object. */
	public static final int LENGTH = 20;

	/** Thing ID. */
	protected int id;
	/** Thing Z position relative to sector plane. */
	protected int height;
	/** Thing action special. */
	protected int special;
	/** Thing action special arguments. */
	protected int[] arguments;
	
	/**
	 * Creates a new thing.
	 */
	public HexenThing()
	{
		super();
		this.id = 0;
		this.height = 0;
		this.special = 0;
		this.arguments = new int[5];
	}

	/**
	 * @return the Z position relative to sector plane.
	 * @since 2.9.0, for naming clarity/uniformity.
	 */
	public int getHeight()
	{
		return height;
	}

	/**
	 * Sets the Z position relative to sector plane.
	 * @param height the new height.
	 * @throws IllegalArgumentException if <code>z</code> is not between -32768 and 32767.
	 * @since 2.9.0, for naming clarity/uniformity.
	 */
	public void setHeight(int height)
	{
		RangeUtils.checkShort("Height", height);
		this.height = height;
	}

	/**
	 * @return the thing's id (for tagged specials).
	 */
	public int getId()
	{
		return id;
	}

	/**
	 * Sets the thing's id. 
	 * @param id the new id.
	 * @throws IllegalArgumentException if <code>id</code> is not between 0 and 65535.
	 */
	public void setId(int id)
	{
		RangeUtils.checkShortUnsigned("Thing ID", id);
		this.id = id;
	}

	/**
	 * @return the special action for this thing.
	 */
	public int getSpecial()
	{
		return special;
	}

	/**
	 * Sets the special action for this thing.
	 * @param special the thing special to call on activation.
	 * @throws IllegalArgumentException if special is outside the range 0 to 255.
	 */
	public void setSpecial(int special)
	{
		RangeUtils.checkByteUnsigned("Special", special);
		this.special = special;
	}
	
	/**
	 * Gets the special arguments copied into a new array. 
	 * @return gets the array of special arguments.
	 */
	public int[] getArguments()
	{
		int[] out = new int[5];
		System.arraycopy(arguments, 0, out, 0, 5);
		return out;
	}

	/**
	 * Gets a special argument.
	 * @param n the argument index (up to 4) 
	 * @return the argument value.
	 * @throws ArrayIndexOutOfBoundsException if <code>n</code> is less than 0 or greater than 4. 
	 */
	public int getArgument(int n)
	{
		return arguments[n];
	}

	/**
	 * Sets the special arguments.
	 * @param arguments the argument values to set.
	 * @throws IllegalArgumentException if length of arguments is greater than 5, or any argument is less than 0 or greater than 255. 
	 */
	public void setArguments(int ... arguments)
	{
		if (arguments.length > 5)
			 throw new IllegalArgumentException("Length of arguments is greater than 5.");

		int i;
		for (i = 0; i < arguments.length; i++)
		{
			RangeUtils.checkByteUnsigned("Argument " + i, arguments[i]);
			this.arguments[i] = arguments[i];
		}
		for (; i < 5; i++)
		{
			this.arguments[i] = 0;
		}
		
	}
	
	@Override
	public void readBytes(InputStream in) throws IOException
	{
		SerialReader sr = new SerialReader(SerialReader.LITTLE_ENDIAN);
		id = sr.readUnsignedShort(in);
		x = sr.readShort(in);
		y = sr.readShort(in);
		height = sr.readShort(in);
		angle = sr.readShort(in);
		type = sr.readShort(in);
		flags = sr.readUnsignedShort(in);
		special = sr.readUnsignedByte(in);
		arguments[0] = sr.readUnsignedByte(in);
		arguments[1] = sr.readUnsignedByte(in);
		arguments[2] = sr.readUnsignedByte(in);
		arguments[3] = sr.readUnsignedByte(in);
		arguments[4] = sr.readUnsignedByte(in);
		
	}

	@Override
	public void writeBytes(OutputStream out) throws IOException
	{
		SerialWriter sw = new SerialWriter(SerialWriter.LITTLE_ENDIAN);
		sw.writeUnsignedShort(out, id);
		sw.writeShort(out, (short)x);
		sw.writeShort(out, (short)y);
		sw.writeShort(out, (short)height);
		sw.writeShort(out, (short)angle);
		sw.writeShort(out, (short)type);
		sw.writeUnsignedShort(out, flags & 0x0FFFF);
		sw.writeByte(out, (byte)special);
		sw.writeByte(out, (byte)arguments[0]);
		sw.writeByte(out, (byte)arguments[1]);
		sw.writeByte(out, (byte)arguments[2]);
		sw.writeByte(out, (byte)arguments[3]);
		sw.writeByte(out, (byte)arguments[4]);
	}
	
	@Override
	public String toString()
	{
		StringBuilder sb = new StringBuilder();
		sb.append("Thing");
		sb.append(" (").append(x).append(", ").append(y).append(")");
		sb.append(" Z:").append(height);
		sb.append(" Type:").append(type);
		sb.append(" Angle:").append(angle);
		sb.append(" ID:").append(id);
		sb.append(' ').append("Flags 0x").append(String.format("%016x", flags & 0x0FFFF));
		sb.append(" Special ").append(special);
		sb.append(" Args ").append(Arrays.toString(arguments));
		return sb.toString();
	}

}
