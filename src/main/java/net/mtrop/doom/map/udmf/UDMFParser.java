/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.map.udmf;

import java.io.Reader;

import net.mtrop.doom.struct.Lexer;
import net.mtrop.doom.struct.Lexer.Parser;

/**
 * Parser for UDMF data.
 * This is NOT a thread safe object - if read is called by more
 * than one thread at once, undefined behavior may occur.
 * @author Matthew Tropiano
 */
class UDMFParser extends Parser
{
	// Lexer kernel.
	private static final ULexerKernel KERNEL = new ULexerKernel();

	UDMFParser(Reader reader)
	{
		super(new ULexer(reader));
		nextToken();
	}
	
	private void emitError(UDMFParserListener listener, String message)
	{
		listener.onParseError(getTokenInfoLine(message));
	}
	
	/**
	 * Reads in UDMF text and returns a UDMFTable representing the structure.
	 * @param listener the listener to emit events to.
	 */
	public void readFull(UDMFParserListener listener)
	{
		listener.onStart();
		while (currentToken() != null && StructureList(listener));
		listener.onEnd();
	}

	private boolean StructureList(UDMFParserListener listener)
	{
		if (currentType(ULexerKernel.TYPE_IDENTIFIER))
		{
			String currentId = currentToken().getLexeme();
			nextToken();
			
			return AttributeOrObjectPredicate(listener, currentId);
		}
		else if (currentType(ULexerKernel.TYPE_END_OF_STREAM))
			return true;

		emitError(listener, "Expected global value or structure.");
		return false;
		
	}

	/**
	 * Seeks to and returns the next id (for attributes or objects).
	 * @param listener the listener interface to emit to.
	 * @return the next id or null if the end of the stream.
	 */
	public String NextId(UDMFParserListener listener)
	{
		if (currentType(ULexerKernel.TYPE_IDENTIFIER))
		{
			String currentId = currentToken().getLexeme();
			nextToken();
			return currentId;
		}
		else if (currentType(ULexerKernel.TYPE_END_OF_STREAM))
			return null;

		emitError(listener, "Expected global value or structure.");
		return null;
	}
	
	/**
	 * Reads an attribute or an object.
	 * Expects the parser to have read an id.
	 * @param listener the parser listener.
	 * @param currentId the id: an attribute name or an object type.
	 * @return true if parse was successful, false if not.
	 */
	public boolean AttributeOrObjectPredicate(UDMFParserListener listener, String currentId)
	{
		if (matchType(ULexerKernel.TYPE_EQUALS))
		{
			Object currentValue;
			if ((currentValue = Value()) == null)
			{
				emitError(listener, "Expected valid value.");
				return false;
			}
			
			if (!matchType(ULexerKernel.TYPE_SEMICOLON))
			{
				emitError(listener, "Expected \";\" to terminate field statement.");
				return false;
			}
			
			listener.onAttribute(currentId, currentValue);
			return true;
		}
		else if (matchType(ULexerKernel.TYPE_LBRACE))
		{
			listener.onObjectStart(currentId);

			if (!FieldExpressionList(listener))
				return false;

			if (!matchType(ULexerKernel.TYPE_RBRACE))
			{
				emitError(listener, "Expected \"}\" to terminate object.");
				return false;
			}

			listener.onObjectEnd(currentId);
			return true;
		}
		else
		{
			emitError(listener, "Expected field expression or start of structure.");
			return false;
		}
	}
	
	private Object FieldPredicate(UDMFParserListener listener)
	{
		Object currentValue;
		
		if (!matchType(ULexerKernel.TYPE_EQUALS))
		{
			emitError(listener, "Expected \"=\" after field.");
			return null;
		}
		
		if ((currentValue = Value()) == null)
		{
			emitError(listener, "Expected valid value.");
			return null;
		}
		
		if (!matchType(ULexerKernel.TYPE_SEMICOLON))
		{
			emitError(listener, "Expected \";\" to terminate field statement.");
			return null;
		}
		
		return currentValue;
	}

	/*
	 * FieldExpressionList := IDENTIFIER = Value ; FieldExpressionList | [e]
	 */
	private boolean FieldExpressionList(UDMFParserListener listener)
	{
		while (currentType(ULexerKernel.TYPE_IDENTIFIER))
		{
			String currentId = currentToken().getLexeme();
			nextToken();
			Object currentValue;
			if ((currentValue = FieldPredicate(listener)) == null)
				return false;
			
			listener.onAttribute(currentId, currentValue);
		}
		
		return true; 
	}

	/*
	 * Number := STRING | TRUE | FALSE | IntegerValue | FloatValue
	 */
	private Object Value()
	{
		Object currentValue;
		if (currentType(ULexerKernel.TYPE_STRING))
		{
			currentValue = currentToken().getLexeme();
			nextToken();
			return currentValue;
		}
		else if (currentType(ULexerKernel.TYPE_TRUE))
		{
			currentValue = true;
			nextToken();
			return currentValue;
		}
		else if (currentType(ULexerKernel.TYPE_FALSE))
		{
			currentValue = false;
			nextToken();
			return currentValue;
		}
		else if ((currentValue = NumericValue()) != null)
			return currentValue;

		return null; 
	}
	
	/*
	 * NumericValue := PLUS NUMBER | MINUS NUMBER | NUMBER 
	 */
	private Object NumericValue()
	{
		Object currentValue;
		if (matchType(ULexerKernel.TYPE_MINUS))
		{
			if (currentType(ULexerKernel.TYPE_NUMBER))
			{
				String lexeme = currentToken().getLexeme();
				if (lexeme.startsWith("0X") || lexeme.startsWith("0x"))
				{
					currentValue = Integer.parseInt(lexeme.substring(2), 16);
					nextToken();
					return currentValue;
				}
				else if (lexeme.contains("."))
				{
					currentValue = Float.parseFloat(lexeme);
					nextToken();
					return currentValue;
				}
				else
				{
					currentValue = Integer.parseInt(lexeme);
					nextToken();
					return currentValue;
				}
			}
		}
		else if (matchType(ULexerKernel.TYPE_PLUS))
		{
			if (currentType(ULexerKernel.TYPE_NUMBER))
			{
				String lexeme = currentToken().getLexeme();
				if (lexeme.startsWith("0X") || lexeme.startsWith("0x"))
				{
					currentValue = Integer.parseInt(lexeme.substring(2), 16);
					nextToken();
					return currentValue;
				}
				else if (lexeme.contains("."))
				{
					currentValue = Float.parseFloat(lexeme);
					nextToken();
					return currentValue;
				}
				else
				{
					currentValue = Integer.parseInt(lexeme);
					nextToken();
					return currentValue;
				}
			}
		}
		else if (currentType(ULexerKernel.TYPE_NUMBER))
		{
			String lexeme = currentToken().getLexeme();
			if (lexeme.startsWith("0X") || lexeme.startsWith("0x"))
			{
				currentValue = Integer.parseInt(lexeme.substring(2), 16);
				nextToken();
				return currentValue;
			}
			else if (lexeme.contains("."))
			{
				currentValue = Float.parseFloat(lexeme);
				nextToken();
				return currentValue;
			}
			else
			{
				currentValue = Integer.parseInt(lexeme);
				nextToken();
				return currentValue;
			}
		}
		
		return null;
	}
	
	/**
	 * Kernel for UDMF parser.
	 */
	private static class ULexerKernel extends Lexer.Kernel
	{
		public static final int TYPE_COMMENT =		0;
		public static final int TYPE_TRUE = 		1;
		public static final int TYPE_FALSE = 		2;
		public static final int TYPE_EQUALS = 		3;
		public static final int TYPE_LBRACE = 		4;
		public static final int TYPE_RBRACE = 		5;
		public static final int TYPE_SEMICOLON = 	6;
		public static final int TYPE_PLUS = 		7;
		public static final int TYPE_MINUS = 		8;
	
		private ULexerKernel()
		{
			addCommentStartDelimiter("/*", TYPE_COMMENT);
			addCommentLineDelimiter("//", TYPE_COMMENT);
			addCommentEndDelimiter("*/", TYPE_COMMENT);
			
			addCaseInsensitiveKeyword("true", TYPE_TRUE);
			addCaseInsensitiveKeyword("false", TYPE_FALSE);
	
			addStringDelimiter('"', '"');
			
			addDelimiter(";", TYPE_SEMICOLON);
			addDelimiter("=", TYPE_EQUALS);
			addDelimiter("{", TYPE_LBRACE);
			addDelimiter("}", TYPE_RBRACE);
			addDelimiter("+", TYPE_PLUS);
			addDelimiter("-", TYPE_MINUS);
			
			setDecimalSeparator('.');
		}
		
	}

	/**
	 * Lexer for the UDMFParser.
	 * @author Matthew Tropiano
	 */
	private static class ULexer extends Lexer
	{
		public ULexer(Reader reader)
		{
			super(KERNEL, "UDMFLexer", reader);
		}
	}
	
}

