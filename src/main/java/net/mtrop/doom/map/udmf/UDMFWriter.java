/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.map.udmf;

import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.nio.charset.Charset;
import java.util.Map.Entry;

/**
 * Writes UDMF data.
 * @author Matthew Tropiano
 */
public final class UDMFWriter
{
	private UDMFWriter() {}
	
	/**
	 * Writes UDMF-formatted data into an {@link OutputStream}.
	 * Does not close the OutputStream at the end of the write.
	 * @param table the table to write.
	 * @param out the OutputStream to write to.
	 * @param charset the 
	 * @throws IOException if the output stream cannot be written to.
	 */
	public static void writeTable(UDMFTable table, OutputStream out, Charset charset) throws IOException
	{
		writeTable(table, new OutputStreamWriter(out, "UTF8"));
	}
	
	/**
	 * Writes UDMF-formatted data into a {@link Writer}.
	 * @param table the table to write.
	 * @param writer the Writer to write to.
	 * @throws IOException if the output stream cannot be written to.
	 */
	public static void writeTable(UDMFTable table, Writer writer) throws IOException
	{
		writeFields(table.getGlobalFields(), writer, "");
		for (String typeName : table.getAllObjectNames())
		{
			int x = 0;
			for (UDMFObject struct : table.getObjects(typeName))
			{
				writeObject(struct, writer, typeName, x);
				x++;
			}
		}
	}

	/**
	 * Writes UDMF-formatted data into a {@link Writer}.
	 * @param object the object to write.
	 * @param writer the Writer to write to.
	 * @param type the object type.
	 * @throws IOException if the output stream cannot be written to.
	 * @since 2.9.1
	 */
	public static void writeObject(UDMFObject object, Writer writer, String type) throws IOException
	{
		writeObject(object, writer, type, null);
	}

	/**
	 * Writes UDMF-formatted data into a {@link Writer}.
	 * @param object the object to write.
	 * @param writer the Writer to write to.
	 * @param type the object type.
	 * @param count the index of the written object (can be null - not required).
	 * @throws IOException if the output stream cannot be written to.
	 * @since 2.9.1, count is actually nullable.
	 */
	public static void writeObject(UDMFObject object, Writer writer, String type, Integer count) throws IOException
	{
		writeStructStart(type, writer, count, "");
		writeFields(object, writer, "\t");
		writeStructEnd(type, writer, "");
	}

	/**
	 * Writes the fields out to a {@link Writer}.
	 * @param object the object to write.
	 * @param writer the Writer to write to.
	 * @throws IOException if the output stream cannot be written to.
	 * @since 2.9.1
	 */
	public static void writeFields(UDMFObject object, Writer writer) throws IOException
	{
		writeFields(object, writer, "");
	}
	
	/**
	 * Writes the fields out to a {@link Writer}.
	 * @param object the object to write.
	 * @param writer the Writer to write to.
	 * @param lineprefix a string to prepend to each line.
	 * @throws IOException if the output stream cannot be written to.
	 */
	public static void writeFields(UDMFObject object, Writer writer, String lineprefix) throws IOException
	{
		for (Entry<String, Object> entry : object)
			writeField(entry.getKey(), entry.getValue(), writer, lineprefix);
	}
	
	/**
	 * Writes the fields out to a {@link Writer}.
	 * @param fieldName the field name.
	 * @param value the field's value.
	 * @param writer the Writer to write to.
	 * @throws IOException if the output stream cannot be written to.
	 * @since 2.9.1
	 */
	public static void writeField(String fieldName, Object value, Writer writer) throws IOException
	{
		writeField(fieldName, value, writer, "");
	}
	
	/**
	 * Writes the fields out to a {@link Writer}.
	 * @param fieldName the field name.
	 * @param value the field's value.
	 * @param writer the Writer to write to.
	 * @param lineprefix a string to prepend to each line.
	 * @throws IOException if the output stream cannot be written to.
	 */
	public static void writeField(String fieldName, Object value, Writer writer, String lineprefix) throws IOException
	{
		writer.append(lineprefix)
			.append(fieldName)
			.append(" = ")
			.append(renderFieldData(value))
			.append(';')
			.append('\n')
		;
	}
	
	/**
	 * Starts the structure.
	 */
	private static void writeStructStart(String name, Writer writer, Integer count, String lineprefix) throws IOException
	{
		writer.append(lineprefix)
			.append(name);
		if (count != null)
		{
			writer.append(" // ")
				.append(String.valueOf(count))
				.append('\n');
		}
		writer.append(lineprefix)
			.append('{')
			.append('\n')
		;
	}
	
	/**
	 * Ends the structure.
	 */
	private static void writeStructEnd(String name, Writer writer, String lineprefix) throws IOException
	{
		writer.append(lineprefix)
			.append('}')
			.append('\n')
		;
	}
	
	private static String renderFieldData(Object data)
	{
		if (data instanceof Boolean || data instanceof Number)
			return String.valueOf(data);
		else
			return '\"' + String.valueOf(data) + '\"';
	}
	
}
