
class FileJSON {
	int index;
	HXDD_JsonElement json;

    static String GetString(HXDD_JsonObject jo, String key) {
        HXDD_JsonElement type_elem = jo.get(key);
        if (!type_elem) {
            return "";
        }
		HXDD_JsonString type_str = HXDD_JsonString(type_elem);
		return type_str.s;
    }
    static int GetInt(HXDD_JsonObject jo, String key) {
        HXDD_JsonElement type_elem = jo.get(key);
        if (!type_elem) {
            return -1;
        }
		HXDD_JsonInt type_int = HXDD_JsonInt(type_elem);
		return type_int.i;
    }
    static double GetDouble(HXDD_JsonObject jo, String key) {
        HXDD_JsonElement type_elem = jo.get(key);
        if (!type_elem) {
            return -1;
        }
		HXDD_JsonDouble type_double = HXDD_JsonDouble(type_elem);
		return type_double.d;
    }
    static HXDD_JsonArray GetArray(HXDD_JsonObject jo, String key) {
        HXDD_JsonElement type_elem = jo.get(key);
        if (!type_elem) {
            return null;
        }
		HXDD_JsonArray type_arr = HXDD_JsonArray(type_elem);
		return type_arr;
    }
    static bool GetBool(HXDD_JsonObject jo, String key) {
        HXDD_JsonElement type_elem = jo.get(key);
        if (!type_elem) {
            return false;
        }
		HXDD_JsonBool type_bool = HXDD_JsonBool(type_elem);
		return type_bool.b;
    }

	bool Open(String target) {
        int lumpIndex = Wads.CheckNumForFullName(target);
        if (lumpIndex != -1) {
            String lumpData = Wads.ReadLump(lumpIndex);
            let lumpJSON = HXDD_JSON.parse(lumpData, false);
            if (lumpJSON is "HXDD_JsonElement") {
				self.index = lumpIndex;
				self.json = (HXDD_JsonElement)(lumpJSON);
				return true;
			}
            console.printf("FileJSON: Failed to load data from file %s!", target);
		}
		return false;
	}
}