/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.map.udmf;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.io.StringReader;

import net.mtrop.doom.map.udmf.listener.UDMFFullTableListener;

/**
 * A method for reading UDMF data, element by element, in a <i>push-oriented</i> way,
 * pushing events to a listener. Compare this to {@link UDMFScanner}, which is pull-oriented.
 * @author Matthew Tropiano
 */
public final class UDMFReader
{
	/**
	 * Reads UDMF-formatted data into a UDMFTable from an {@link InputStream}.
	 * This will read until the end of the stream is reached.
	 * Does not close the InputStream at the end of the read.
	 * @param in the InputStream to read from.
	 * @return a UDMFTable containing the structures.
	 * @throws UDMFParseException if a parsing error occurs.
	 * @throws IOException if the data can't be read.
	 */
	public static UDMFTable readData(InputStream in) throws IOException
	{
		return readData(new InputStreamReader(in, "UTF8"));
	}
	
	/**
	 * Reads UDMF-formatted data into a UDMFTable from a String.
	 * This will read until the end of the stream is reached.
	 * @param data the String to read from.
	 * @return a UDMFTable containing the structures.
	 * @throws UDMFParseException if a parsing error occurs.
	 * @throws IOException if the data can't be read.
	 */
	public static UDMFTable readData(String data) throws IOException
	{
		return readData(new StringReader(data));
	}
	
	/**
	 * Reads UDMF-formatted data into a UDMFTable from a {@link Reader}.
	 * This will read until the end of the stream is reached.
	 * Does not close the Reader at the end of the read.
	 * @param reader the reader to read from.
	 * @return a UDMFTable containing the parsed structures.
	 * @throws UDMFParseException if a parsing error occurs.
	 * @throws IOException if the data can't be read.
	 */
	public static UDMFTable readData(Reader reader) throws IOException
	{
		UDMFFullTableListener listener = new UDMFFullTableListener();
		readData(reader, listener);
		String[] errors = listener.getErrorMessages();
		if (errors.length > 0)
		{
			StringBuilder sb = new StringBuilder();
			for (int i = 0; i < errors.length; i++)
			{
				sb.append(errors[i]);
				if (i < errors.length-1)
					sb.append('\n');
			}
			throw new UDMFParseException(sb.toString());
		}
		return listener.getTable();
	}
	
	/**
	 * Reads UDMF-formatted data into a UDMFTable from an {@link InputStream}.
	 * This will read until the end of the stream is reached.
	 * Does not close the InputStream at the end of the read.
	 * @param in the InputStream to read from.
	 * @param listener the listener to use for listening to parsed structure events.
	 * @throws IOException if the data can't be read.
	 */
	public static void readData(InputStream in, UDMFParserListener listener) throws IOException
	{
		readData(new InputStreamReader(in, "UTF8"), listener);
	}
	
	/**
	 * Reads UDMF-formatted data into a UDMFTable from a String.
	 * This will read until the end of the stream is reached.
	 * @param data the String to read from.
	 * @param listener the listener to use for listening to parsed structure events.
	 * @throws IOException if the data can't be read.
	 */
	public static void readData(String data, UDMFParserListener listener) throws IOException
	{
		readData(new StringReader(data), listener);
	}
	
	/**
	 * Reads UDMF-formatted data into a UDMFTable from a {@link Reader}.
	 * This will read until the end of the stream is reached.
	 * Does not close the InputStream at the end of the read.
	 * @param reader the reader to read from.
	 * @param listener the listener to use for listening to parsed structure events.
	 * @throws IOException if the data can't be read.
	 */
	public static void readData(Reader reader, UDMFParserListener listener) throws IOException
	{
		(new UDMFParser(reader)).readFull(listener);
	}
	
	private UDMFReader() {}

}
