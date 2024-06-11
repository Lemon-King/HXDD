
/*

    Replacement for zscript_generated actors
    Should result in less bugs in the long term

    TODO: Refactor to Map<string, XGT_GROUP>

*/

enum ECVARCompareMethod {
	ECVARCompareMethod_NONE,
    ECVARCompareMethod_EQUALS,
    ECVARCompareMethod_LESSER,
    ECVARCompareMethod_GREATER
}
enum ECVARCompareType {
	ECVARCompareType_NONE,
    ECVARCompareType_INT,
    ECVARCompareType_STRING
}

class XGT_Group {
    int size;
    Array<String> Doom;
    Array<String> Heretic;
    Array<String> Hexen;
}

class XCVARCompare {
    String cvar;
    int i_value;
    String s_value;
    ECVARCompareMethod method;
    ECVARCompareType type;
}

class XTranslationActors {
	String key;
    XCVARCompare compare;
	Array<String> defaults;
    Array<String> alternates;

    bool hasCVARCompare() {
        return (self.compare != null);
    }
}

class XGameResponse {
    bool IsFinal;
    String newActor;
}

class XGameTranslation {
    


    XGT_Group DoomEdNums;     // For everything
    XGT_Group SpawnNums;      // For bIsMonster swap checks?

	Array<XTranslationActors> xclass;  // player class actor swaps
    Array<XTranslationActors> xswap;

    void Init() {
        self.CreateDoomEdNums();
        self.CreateSpawnNums();

        self.CreateXClassTranslation();
        self.CreateXSwapTranslation();
    }

    void CreateDoomEdNums() {
        self.LoadFromJSON("doomednums");
    }

    void CreateSpawnNums() {
        self.LoadFromJSON("spawnnums");
    }

    void LoadFromJSON(String group) {
        FileJSON fJSON = new ("FileJSON");
        let success = fJSON.Open(String.format("xgt/%s.xgt", group));
        if (!success) {
            success = fJSON.Open(String.format("xgt/%s.json", group));
        }
        if (success) {
            let jsonArray = HXDD_JsonArray(fJSON.json);

            XGT_Group targetGroup;
            if (group == "doomednums") {
                self.DoomEdNums = new("XGT_Group");
                targetGroup = self.DoomEdNums;
            } else if (group == "spawnnums") {
                self.SpawnNums = new("XGT_Group");
                targetGroup = self.SpawnNums;
            } else {
                console.printf("XGameTranslation: Unknown group [%s]!", group);
                return;
            }
            for (int i = 0; i < jsonArray.Size(); i++) {
                HXDD_JsonObject jo = HXDD_JsonObject(jsonArray.arr[i]);
                if (jo) {
                    String valDoom = "";
                    String valHeretic = "";
                    String valHexen = "";

                    valDoom = FileJSON.GetString(jo, "Doom");
                    valHeretic = FileJSON.GetString(jo, "Heretic");
                    valHexen = FileJSON.GetString(jo, "Hexen");
                    Add(targetGroup, valDoom, valHeretic, valHexen);
                }
            }
            targetGroup.size = targetGroup.Doom.Size();
        } else {
            console.printf("XGameTranslation Error: Group [%s] could not be found!", group);
        }
    }

    void Add(XGT_Group group, String strDoom, String strHeretic, String strHexen) {
        String actorDoom = strDoom;
        String actorHeretic = strHeretic;
        String actorHexen = strHexen;
        group.Doom.Push(actorDoom);
        group.Heretic.Push(actorHeretic);
        group.Hexen.Push(actorHexen);
    }

    // low effort, but should work
    XGameResponse GetReplacementActorBySource(String source) {
        XGT_Group group = self.DoomEdNums;
        int index = group.Heretic.Find(source);
        if (index == group.size) {
            int newIndex = group.Hexen.Find(source);
            if (newIndex != group.size) {
                index = newIndex;
            }
        }
        if (index == group.size) {
            int newIndex = group.Doom.Find(source);
            if (newIndex != group.size) {
                index = newIndex;
            }
        }
        if (index == group.size) {
            String swapActor = self.TryXClass(source);
            swapActor = self.TryXSwap(swapActor);
            XGameResponse resp = new ("XGameResponse");
            if (swapActor != source) {
                resp.isFinal = true;
            }
            resp.newActor = ActorNoneFix(swapActor);
            return resp;
        }
        int optGameMode = LemonUtil.GetOptionGameMode();
        String newActor = source;
        int gameType = gameinfo.gametype;
        if (LemonUtil.IsGameType(GAME_Doom)) {
            String nActor = group.Doom[index];
            if (nActor != "") {
                newActor = nActor;
            }
        } else if (LemonUtil.IsGameType(GAME_Raven)) {
            int optGameMode = LemonUtil.GetOptionGameMode();
            if (optGameMode == GAME_Heretic) {
                String nActor = group.Heretic[index];
                if (nActor != "") {
                    newActor = nActor;
                }
            } else if (optGameMode == GAME_Hexen) {
                String nActor = group.Hexen[index];
                if (nActor != "") {
                    newActor = nActor;
                }
            }
        }
        String swapActor = self.TryXClass(newActor);
        swapActor = self.TryXSwap(swapActor);
        XGameResponse resp = new ("XGameResponse");
        if (swapActor != newActor) {
            resp.IsFinal = true;
        }
        resp.newActor = ActorNoneFix(swapActor);
        return resp;
    }

    String ActorNoneFix(String source) {
        // hack
        if (source == "" || source == "none") {
            return "RandomSpawner";
        }
        return source;
    }

	void CreateXClassTranslation() {
        String playerClassName = LemonUtil.GetPlayerClassName();
		
        FileJSON fJSON = new ("FileJSON");
        let success = fJSON.Open(String.format("playersheets/%s.playersheet", playerClassName));
        if (!success) {
            success = fJSON.Open(String.format("playersheets/%s.json", playerClassName));
        }
        if (success) {
            console.printf("XGameTranslation.XClass: Load playersheets/%s.playersheet %d", playerClassName, fJSON.index);
            // Class Item Swap List Generation
            HXDD_JsonObject json = HXDD_JsonObject(fJSON.json);
            String ver = FileJSON.GetString(json, "version");
            HXDD_JsonObject objClassItems = HXDD_JsonObject(json.get("xgame"));
            if (objClassItems) {
                Array<String> keys;
                objClassItems.GetKeysInto(keys);

                self.xclass.Resize(keys.Size());
                for (let i = 0; i < keys.Size(); i++) {
                    String key = keys[i];
                    String valClassItem = FileJSON.GetString(objClassItems, key);
                    if (valClassItem != "") {
                        XTranslationActors xta = CreateXTAFromString(key, valClassItem);
                        self.xclass.push(xta);
                        continue;
                    }
                    HXDD_JsonArray valClassItemList = FileJSON.GetArray(objClassItems, key);
                    if (valClassItemList) {
                        XTranslationActors xta = CreateXTAFromArray(key, valClassItemList);
                        self.xclass.push(xta);
                        continue;
                    }
                    HXDD_JsonObject valClassItemObject = HXDD_JsonObject(objClassItems.Get(key));
                    if (valClassItemObject) {
                        XTranslationActors xta = CreateXTAFromObject(key, valClassItemObject);
                        self.xclass.push(xta);
                        continue;
                    }
                }
            }
		}
	}

    XTranslationActors CreateXTAFromString(String key, String js) {
        XTranslationActors xta = new ("XTranslationActors");
        Array<String> nClassItems;
        js.Substitute(" ", "");
        js.Split(xta.defaults, ",");
        xta.key = key;
        return xta;
    }

    XTranslationActors CreateXTAFromArray(String key, HXDD_JsonArray ja) {
        XTranslationActors xta = new ("XTranslationActors"); 
        xta.key = key;
        xta.defaults.Resize(ja.Size());
        for (int j = 0; j < ja.Size(); j++) {
            String value = HXDD_JsonString(ja.get(j)).s;
            if (value) {
                xta.defaults.push(value);
            }
        }
        return xta;
    }

    XTranslationActors CreateXTAFromObject(String key, HXDD_JsonObject jo) {
        XTranslationActors xta = new ("XTranslationActors"); 
        xta.key = key;
        xta.compare = new ("XCVARCompare");

        String sCVAR = FileJSON.GetString(jo, "cvar");
        if (sCVAR != "") {
            xta.compare.cvar = sCVAR;
        }

        if (xta.compare.cvar) {
            xta.compare.method = ECVARCompareMethod_NONE;
            xta.compare.type = ECVARCompareType_NONE;

            String sValue_Lesser = FileJSON.GetString(jo, "lesser");
            if (sValue_Lesser != "") {
                xta.compare.method = ECVARCompareMethod_LESSER;
                xta.compare.type = ECVARCompareType_STRING;
                xta.compare.s_value = sValue_Lesser;
            } else {
                int iValue_Lesser = FileJSON.GetInt(jo, "lesser");
                if (iValue_Lesser) {
                    xta.compare.method = ECVARCompareMethod_LESSER;
                    xta.compare.type = ECVARCompareType_INT;
                    xta.compare.i_value = iValue_Lesser;
                }
            }

            String sValue_Greater = FileJSON.GetString(jo, "greater");
            if (sValue_Greater != "") {
                xta.compare.method = ECVARCompareMethod_GREATER;
                xta.compare.type = ECVARCompareType_STRING;
                xta.compare.s_value = sValue_Greater;
            } else {
                int iValue_Greater = FileJSON.GetInt(jo, "greater");
                if (iValue_Greater) {
                    xta.compare.method = ECVARCompareMethod_GREATER;
                    xta.compare.type = ECVARCompareType_INT;
                    xta.compare.i_value = iValue_Greater;
                }
            }
            
            String sValue_Equals = FileJSON.GetString(jo, "equals");
            if (sValue_Equals != "") {
                xta.compare.method = ECVARCompareMethod_EQUALS;
                xta.compare.type = ECVARCompareType_STRING;
                xta.compare.s_value = sValue_Equals;
            } else {
                int iValue_Equals = FileJSON.GetInt(jo, "equals");
                if (iValue_Equals) {
                    xta.compare.method = ECVARCompareMethod_EQUALS;
                    xta.compare.type = ECVARCompareType_INT;
                    xta.compare.i_value = iValue_Equals;
                }
            }

            HXDD_JsonArray arrAlternates = FileJSON.GetArray(jo, "true");
            if (arrAlternates) {
                for (int j = 0; j < arrAlternates.Size(); j++) {
                    String entry = HXDD_JsonString(arrAlternates.get(j)).s;
                    if (entry) {
                        xta.alternates.push(entry);
                    }
                }
            } else {
                String val = FileJSON.GetString(jo, "true");
                if (val) {
                    val.Substitute(" ", "");
                    val.Split(xta.defaults, ",");
                }
            }
            HXDD_JsonArray arrDefaults = FileJSON.GetArray(jo, "false");
            if (arrDefaults) {
                for (int j = 0; j < arrDefaults.Size(); j++) {
                    String entry = HXDD_JsonString(arrAlternates.get(j)).s;
                    if (entry) {
                        xta.defaults.push(entry);
                    }
                }
            } else {
                String val = FileJSON.GetString(jo, "false");
                if (val) {
                    val.Substitute(" ", "");
                    val.Split(xta.defaults, ",");
                }
            }
        }

        return xta;
    }

	String TryXClass(String replacee) {
		for (let i = 0; i < self.xclass.Size(); i++) {
            XTranslationActors xta = self.xclass[i];
			if (xta && xta.key.MakeLower() == replacee.MakeLower()) {
                Array<string> list;
                list.copy(xta.defaults);
				String replacement;
                if (xta.hasCVARCompare()) {
                    bool useAlts = false;
                    XCVARCompare xcvar = xta.compare;
                    if (xcvar.method == ECVARCompareType_INT) {
                        int cval = LemonUtil.CVAR_GetInt(xcvar.cvar, 2147483647);
                        if (ECVARCompareMethod_EQUALS) {
                            useAlts = (cval == xcvar.i_value);
                        } else if (ECVARCompareMethod_LESSER) {
                            useAlts = (cval < xcvar.i_value);
                        } else if (ECVARCompareMethod_GREATER) {
                            useAlts = (cval > xcvar.i_value);
                        }
                    } else if (xcvar.method == ECVARCompareType_STRING) {
                        String cval = LemonUtil.CVAR_GetString(xcvar.cvar, "");
                        if (cval != "") {
                            useAlts = (cval == xcvar.s_value);
                        }
                    }
                    if (useAlts) {
                        list.copy(xta.alternates);
                    }
                }

                replacement = list[0];
                if (list.Size() > 1) {
                    // choose randomly
                    int size = list.Size() - 1;
                    int choice = random[xclass](0, size);
                    console.printf("XGameTranslation.XClass.TrySwap Found: %s %d", replacee, choice);
                    replacement = list[choice];
                }
				//console.printf("XGameTranslation.XClass.TrySwap Found: %s, Replacement: %s", replacee, replacement);

				return replacement;
			}
		}
		return replacee;
	}

    void CreateXSwapTranslation() {
        FileJSON fJSON = new ("FileJSON");
        let success = fJSON.Open("xgt/xswap.xgt");
        if (!success) {
            success = fJSON.Open("xgt/xswap.json");
        }
        if (success) {
            HXDD_JsonObject json = HXDD_JsonObject(fJSON.json);
            String ver = FileJSON.GetString(json, "version");
            //if (ver) {
            //    console.printf("XGameTranslation.CreateXSwapTranslation: Target Version %s", ver);
            //}
            HXDD_JsonArray arrListItems = HXDD_JsonArray(json.get("list"));
            if (arrListItems) {
                int size = arrListItems.Size();
                self.xswap.Resize(size);
                for (let i = 0; i < size; i++) {
                    HXDD_JsonObject objListItem = HXDD_JsonObject(arrListItems.Get(i));
                    if (objListItem) {
                        String valKey = FileJSON.GetString(objListItem, "key");
                        //String valCategory = GetString(objListItem, "category");
                        //HXDD_JsonArray valLabels = GetArray(objListItem, "labels");
                        HXDD_JsonArray valActors = FileJSON.GetArray(objListItem, "actors");
                        if (valKey && valActors) {
                            let newXSwap = new ("XTranslationActors"); 
                            newXSwap.key = valKey;
                            newXSwap.defaults.Resize(valActors.Size());
                            for (int j = 0; j < valActors.Size(); j++) {
                                newXSwap.defaults[j] = HXDD_JsonString(valActors.get(j)).s;
                            }
                            self.xswap[i] = newXSwap;
                        }
                    }
                }
            }
        }
    }

    String TryXSwap(String replacee) {
        bool isDev = LemonUtil.CVAR_GetBool("hxdd_isdev_environment", false);
        if (!isDev) {
            // not ready for general use
            return replacee;
        }
		for (let i = 0; i < self.xswap.Size(); i++) {
            XTranslationActors xtaSwap = self.xswap[i];
			if (xtaSwap.key.MakeLower().IndexOf(replacee.MakeLower()) != -1) {
                String key = xtaSwap.key;
                String cvarKey = String.format("hxdd_xswap_%s", key);
                int option = LemonUtil.CVAR_GetInt(cvarKey, 0);
                option = 1;
                if (option == 0 || option > xtaSwap.defaults.Size() + 2) {
                    return replacee;
                }
                int select = option - 1;
                if (option == 1) {
                    select = random[xswap](0, xtaSwap.defaults.Size() - 1);
                }
                String replacement = xtaSwap.defaults[select];
				//console.printf("XGameTranslation.XSwap.TryXSwap %s %d Found: %s, Replacement: %s", cvarKey, i, replacee, replacement);
                return replacement;
            }
        }
        return replacee;
    }
}