class HXDD_JsonElementOrError {}

class HXDD_JsonElement : HXDD_JsonElementOrError abstract
{
	abstract string Serialize();
	abstract string GetPrettyName();
}

class HXDD_JsonNumber : HXDD_JsonElement abstract
{
	abstract HXDD_JsonNumber Negate();
	abstract double  asDouble();
	abstract int asInt();
	
	override string GetPrettyName()
	{
		return "Number";
	}
}

class HXDD_JsonInt : HXDD_JsonNumber
{
	int i;
	
	static HXDD_JsonInt make(int i = 0)
	{
		let elem = new("HXDD_JsonInt");
		elem.i = i;
		return elem;
	}
	override HXDD_JsonNumber Negate()
	{
		i = -i;
		return self;
	}
	override string Serialize()
	{
		return ""..i;
	}
	
	override double asDouble()
	{
		return double(i);
	}
	
	override int asInt()
	{
		return i;
	}
}

class HXDD_JsonDouble : HXDD_JsonNumber
{
	double d;
	
	static HXDD_JsonDouble Make(double d = 0)
	{
		HXDD_JsonDouble elem = new("HXDD_JsonDouble");
		elem.d = d;
		return elem;
	}
	override HXDD_JsonNumber Negate()
	{
		d = -d;
		return self;
	}
	override string Serialize()
	{
		return ""..d;
	}
	
	override double asDouble()
	{
		return d;
	}
	
	override int asInt()
	{
		return int(d);
	}
}

class HXDD_JsonBool : HXDD_JsonElement
{
	bool b;
	
	static HXDD_JsonBool Make(bool b = false)
	{
		HXDD_JsonBool elem = new("HXDD_JsonBool");
		elem.b = b;
		return elem;
	}
	
	override string Serialize()
	{
		return b? "true" : "false";
	}
	
	override string GetPrettyName()
	{
		return "Bool";
	}
}

class HXDD_JsonString : HXDD_JsonElement
{
	string s;
	
	static HXDD_JsonString make(string s = "")
	{
		HXDD_JsonString elem = new("HXDD_JsonString");
		elem.s=s;
		return elem;
	}
	
	override string Serialize()
	{
		return HXDD_JSON.serialize_string(s);
	}
	
	override string GetPrettyName()
	{
		return "String";
	}
}

class HXDD_JsonNull : HXDD_JsonElement
{
	static HXDD_JsonNull Make()
	{
		return new("HXDD_JsonNull");
	}
	
	override string Serialize()
	{
		return "null";
	}
	
	override string GetPrettyName()
	{
		return "Null";
	}
}

class HXDD_JsonError : HXDD_JsonElementOrError
{
	String what;
	
	static HXDD_JsonError make(string s)
	{
		HXDD_JsonError err = new("HXDD_JsonError");
		err.what = s;
		return err;
	}
}