/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.map.udmf.listener;

import java.util.LinkedList;

import net.mtrop.doom.map.udmf.UDMFObject;
import net.mtrop.doom.map.udmf.UDMFParserListener;
import net.mtrop.doom.map.udmf.UDMFTable;

/**
 * A parser listener that generates full UDMF tables.
 * Can be fairly memory-intensive. Can be re-used.
 * @author Matthew Tropiano
 */
public class UDMFFullTableListener implements UDMFParserListener
{
	/** Struct table. */
	private UDMFTable table;
	/** Struct stack. */
	private LinkedList<UDMFObject> stack;
	/** Error list. */
	private LinkedList<String> errors;

	@Override
	public void onStart()
	{
		this.table = new UDMFTable();
		this.stack = new LinkedList<>();
		this.stack.push(table.getGlobalFields());
		this.errors = new LinkedList<>();
	}
	
	/**
	 * @return the parsed table.
	 */
	public UDMFTable getTable()
	{
		return table;
	}

	/**
	 * @return the list of error messages during parse.
	 */
	public String[] getErrorMessages()
	{
		String[] out = new String[errors.size()];
		errors.toArray(out);
		return out;
	}
	
	@Override
	public void onObjectStart(String name)
	{
		stack.push(table.addObject(name));
	}
	
	@Override
	public void onObjectEnd(String name)
	{
		stack.pop();
	}
	
	@Override
	public void onAttribute(String name, Object value)
	{
		stack.peek().set(name, value);
	}

	@Override
	public void onParseError(String error)
	{
		errors.add(error);
	}
	
	@Override
	public void onEnd()
	{
		stack.pop();
	}

};

