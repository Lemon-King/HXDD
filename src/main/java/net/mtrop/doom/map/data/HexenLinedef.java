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

import net.mtrop.doom.struct.io.SerialReader;
import net.mtrop.doom.struct.io.SerialWriter;
import net.mtrop.doom.util.RangeUtils;

/**
 * Hexen/ZDoom 16-byte format implementation of Linedef.
 * @author Matthew Tropiano
 */
public class HexenLinedef extends CommonLinedef 
{
	/** Byte length of this object. */
	public static final int LENGTH = 16;

	/** Special activation: player walks over. */
	public static final int ACTIVATION_PLAYER_CROSSES = 0;
	/** Special activation: player uses. */
	public static final int ACTIVATION_PLAYER_USES = 1;
	/** Special activation: monster walks over. */
	public static final int ACTIVATION_MONSTER_CROSSES = 2;
	/** Special activation: projectile hits. */
	public static final int ACTIVATION_PROJECTILE_HITS = 3;
	/** Special activation: player bumps. */
	public static final int ACTIVATION_PLAYER_BUMPS = 4;
	/** Special activation: projectile crosses. */
	public static final int ACTIVATION_PROJECTILE_CROSSES = 5;
	/** Special activation: player uses (with passthru). */
	public static final int ACTIVATION_PLAYER_USES_PASSTHRU = 6;
	
	public static final String[] ACTIVATION_NAME = new String[]{
		"PlayerCrosses",
		"PlayerUses",
		"MonsterCrosses",
		"ProjectileHits",
		"PlayerBumps",
		"ProjectileCrosses",
		"PlayerUsesPassthru"
	};

	public static final int[] ACTIVATION_FLAGS = new int[]{
		0x00000,
		0x00400,
		0x00800,
		0x00C00,
		0x01000,
		0x01400,
		0x01800
	};
	
	/** Thing action special arguments. */
	protected int[] arguments;

	/**
	 * Creates a new linedef.
	 */
	public HexenLinedef()
	{
		super();
		this.arguments = new int[5];
	}

	/**
	 * Gets the activation type of this line.
	 * @return the activation type of the line's special.
	 */
	public int getActivationType() 
	{
		return (flags & 0x01C00) >> 10;
	}
	
	/**
	 * Sets the activation type of this line.
	 * See the <code>ACTIVATION</code> constants. 
	 * @param activationType the new activation type of the line's special.
	 * @throws IllegalArgumentException if <code>activationType</code> is less than 0 or greater than 6.
	 */
	public void setActivationType(int activationType) 
	{
		RangeUtils.checkRange("Activation Type", ACTIVATION_PLAYER_CROSSES, ACTIVATION_PLAYER_USES_PASSTHRU, activationType);
		flags = (flags & ~0x01C00) | ACTIVATION_FLAGS[activationType];
	}
	
	/**
	 * Sets the linedef special type. 
	 * @param special the new special number.
	 * @throws IllegalArgumentException if special is outside the range 0 to 255.
	 */
	public void setSpecial(int special)
	{
		RangeUtils.checkByteUnsigned("Special", special);
		this.special = special;
	}

	/**
	 * Sets the special arguments.
	 * @param arguments the arguments to set (5 maximum)
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

	@Override
	public void readBytes(InputStream in) throws IOException
	{
		SerialReader sr = new SerialReader(SerialReader.LITTLE_ENDIAN);
		
		vertexStartIndex = sr.readUnsignedShort(in);
		vertexEndIndex = sr.readUnsignedShort(in);
		
		flags = 0x0ffff & sr.readUnsignedShort(in);
		
		special = sr.readUnsignedByte(in);
		arguments[0] = sr.readUnsignedByte(in);
		arguments[1] = sr.readUnsignedByte(in);
		arguments[2] = sr.readUnsignedByte(in);
		arguments[3] = sr.readUnsignedByte(in);
		arguments[4] = sr.readUnsignedByte(in);

		sidedefFrontIndex = sr.readShort(in);
		sidedefBackIndex = sr.readShort(in);
	}

	@Override
	public void writeBytes(OutputStream out) throws IOException 
	{
		SerialWriter sw = new SerialWriter(SerialWriter.LITTLE_ENDIAN);
		sw.writeUnsignedShort(out, vertexStartIndex);
		sw.writeUnsignedShort(out, vertexEndIndex);
		
		sw.writeUnsignedShort(out, flags);
		
		sw.writeByte(out, (byte)special);
		sw.writeByte(out, (byte)arguments[0]);
		sw.writeByte(out, (byte)arguments[1]);
		sw.writeByte(out, (byte)arguments[2]);
		sw.writeByte(out, (byte)arguments[3]);
		sw.writeByte(out, (byte)arguments[4]);

		sw.writeShort(out, (short)sidedefFrontIndex);
		sw.writeShort(out, (short)sidedefBackIndex);
	}
	
	@Override
	public String toString()
	{
		StringBuilder sb = new StringBuilder();
		sb.append("Linedef");
		sb.append(' ').append(vertexStartIndex).append(" to ").append(vertexEndIndex);
		sb.append(' ').append("Front Sidedef ").append(sidedefFrontIndex);
		sb.append(' ').append("Back Sidedef ").append(sidedefBackIndex);
		sb.append(' ').append("Flags 0x").append(String.format("%016x", flags & 0x0FFFF));
		sb.append(' ').append("Special ").append(special);
		sb.append(' ').append("Args ").append(Arrays.toString(arguments));
		sb.append(' ').append("Activation ").append(ACTIVATION_NAME[getActivationType()]);
		return sb.toString();
	}
	
}
