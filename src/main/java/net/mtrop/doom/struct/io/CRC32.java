/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.struct.io;

/**
 * This is an implementation of the CRC32 algorithm,
 * used for CRC checksumming of byte arrays and streams.
 * @author Matthew Tropiano
 */
public class CRC32
{
	/** Default often-used CRC polynomial. */
	public static final int POLYNOMIAL_DEFAULT = 0x04C11DB7;
	/** Known polynomials: IEEE CRC polynomial (used in Ethernet and PNG and a bunch of other things). */
	public static final int POLYNOMIAL_IEEE = 0xEDB88320;
	/** Known polynomials: Castagnioli (iSCSI). */
	public static final int POLYNOMIAL_CASTAGNIOLI = 0x82F63B78;
	/** Known polynomials: Koopman. */
	public static final int POLYNOMIAL_KOOPMAN = 0xEB31D82E;
	
	/** The CRC polynomial used. */
	private int polynomial;
	/** The cached array for CRC32 calculation. */
	private int[] crcCache;
	
	/**
	 * Creates a new CRC32 calculator using the POLYNOMIAL_DEFAULT CRC32 polynomial.
	 */
	public CRC32()
	{
		this(POLYNOMIAL_DEFAULT);
	}
	
	/**
	 * Creates a new CRC32 calculator using a
	 * specific CRC32 polynomial.
	 * @param polynomial the polynomial to use.
	 */
	public CRC32(int polynomial)
	{
		this.polynomial = polynomial;
		crcCache = new int[256];
		int c;
		
		for (int n = 0; n < 256; n++)
		{
			c = n;
			for (int k = 0; k < 8; k++)
			{
				if ((c & 1) == 1)
					c = polynomial ^ (c >>> 1);
				else
					c >>>= 1;
			}
			crcCache[n] = c;
		}
	}
	
	/**
	 * Generates a CRC32 checksum for a set of bytes.
	 * This will generate a checksum for all of the bytes in the array.
	 * @param startCRC the starting checksum value.
	 * @param buf the bytes to generate the checksum for.
	 * @return a CRC32 checksum of the desired bytes.
	 */
	public int createCRC32(int startCRC, byte[] buf)
	{
		return createCRC32(startCRC, buf, buf.length);
	}

	/**
	 * Generates a CRC32 checksum for a set of bytes.
	 * Uses a starting checksum value of -1 (0xffffffff).
	 * This will generate a checksum for all of the bytes in the array.
	 * @param buf the bytes to generate the checksum for.
	 * @return a CRC32 checksum of the desired bytes.
	 */
	public int createCRC32(byte[] buf)
	{
		return createCRC32(buf, buf.length);
	}

	/**
	 * Generates a CRC32 checksum for a set of bytes.
	 * Uses a starting checksum value of -1 (0xffffffff).
	 * @param buf the bytes to generate the checksum for.
	 * @param len the amount of bytes in the array to use.
	 * @return a CRC32 checksum of the desired bytes.
	 */
	public int createCRC32(byte[] buf, int len)
	{
		return createCRC32(0xffffffff, buf, buf.length);
	}

	/**
	 * Generates a CRC32 checksum for a set of bytes.
	 * @param startCRC the starting checksum value.
	 * @param buf the bytes to generate the checksum for.
	 * @param len the amount of bytes in the array to use.
	 * @return a CRC32 checksum of the desired bytes.
	 */
	public int createCRC32(int startCRC, byte[] buf, int len)
	{
		return ~updateCRC(startCRC, buf, len);
	}

	// CRC adding function.
	private int updateCRC(int crc, byte[] buf, int len)
	{
		int c = crc;
		for (int n = 0; n < len; n++)
			c = (c >>> 8) ^ crcCache[(buf[n] & 0x0FF) ^ (c & 0x000000FF)];
		return c;
	}

	/**
	 * @return the polynomial used for this CRC object.
	 */
	public int getPolynomial()
	{
		return polynomial;
	}
	

}