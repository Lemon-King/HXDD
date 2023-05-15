
class HXDD_JsonObjectKeys
{
	Array<String> keys;
}


class HXDD_JsonObject : HXDD_JsonElement
{
	Map<String,HXDD_JsonElement> data;
	
	static HXDD_JsonObject make()
	{
		return new("HXDD_JsonObject");
	}
	
	HXDD_JsonElement Get(String key)
	{
		if(!data.CheckKey(key)) return null;
		return data.Get(key);
	}
	
	void Set(String key,HXDD_JsonElement e)
	{
		data.Insert(key,e);
	}
	
	bool Insert(String key, HXDD_JsonElement e)
	{ // only inserts if key doesn't exist, otherwise fails and returns false
		if(data.CheckKey(key)) return false;
		data.Insert(key,e);
		return true;
	}
	
	bool Delete(String key)
	{
		if(!data.CheckKey(key)) return false;
		data.Remove(key);
		return true;
	}
    
	void GetKeysInto(out Array<String> keys)
	{
		keys.Clear();
		MapIterator<String,HXDD_JsonElement> it;
		it.Init(data);
		while(it.Next()){
			keys.Push(it.GetKey());
		}
	}
    
	HXDD_JsonObjectKeys GetKeys()
	{
		HXDD_JsonObjectKeys keys = new("HXDD_JsonObjectKeys");
        GetKeysInto(keys.keys);
		return keys;
	}
    
    deprecated("0.0", "Use IsEmpty Instead") bool Empty()
	{
        return data.CountUsed() == 0;
    }

	bool IsEmpty()
	{
		return data.CountUsed() == 0;
	}
	
	void Clear()
	{
		data.Clear();
	}
	
	uint Size()
	{
		return data.CountUsed();
	}
	
	override string Serialize()
	{
		String s;
		s.AppendCharacter("{");
		bool first = true;
		
		MapIterator<String,HXDD_JsonElement> it;
		it.Init(data);
		
		while(it.Next()){
			if(!first){
				s.AppendCharacter(",");
			}
			s.AppendFormat("%s:%s", HXDD_JSON.serialize_string(it.GetKey()), it.GetValue().serialize());
			first = false;
		}
		
		s.AppendCharacter("}");
		return s;
	}
    
	override string GetPrettyName()
	{
		return "Object";
	}
}
