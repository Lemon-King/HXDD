
/*

    Replacement for zscript_generated actors
    Should result in less bugs in the long term

*/

class XGT_Group {
    int size;
    Array<String> Doom;
    Array<String> Heretic;
    Array<String> Hexen;
}

class XTranslationActors {
	String key;
	Array<String> list;
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

    String GetString(HXDD_JsonObject jo, String key) {
        HXDD_JsonElement type_elem = jo.get(key);
        if (!type_elem) {
            return "";
        }
        HXDD_JsonString type_str = HXDD_JsonString(type_elem);
        return type_str.s;
    }
    HXDD_JsonArray GetArray(HXDD_JsonObject jo, String key) {
        HXDD_JsonElement type_elem = jo.get(key);
        if (!type_elem) {
            return null;
        }
		HXDD_JsonArray type_arr = HXDD_JsonArray(type_elem);
		return type_arr;
    }

    void Init() {
        self.LoadFromJSON("doomednums");
        self.LoadFromJSON("spawnnums");

        CreateXClassTranslation();
        CreateXSwapTranslation();
    }

    void LoadFromJSON(String group) {
        int lumpIndex = Wads.CheckNumForFullName(String.format("xgt/%s.xgt", group));
        if (lumpIndex == -1) {
            // try json
            lumpIndex = Wads.CheckNumForFullName(String.format("xgt/%s.json", group));
        }
        if (lumpIndex != -1) {
            String lumpData = Wads.ReadLump(lumpIndex);
            let json = HXDD_JSON.parse(lumpData, false);
            if (json is "HXDD_JsonElement") {
                let jsonArray = HXDD_JsonArray(json);

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
                for (let i = 0; i < jsonArray.Size(); i++) {
                    HXDD_JsonObject jo = HXDD_JsonObject(jsonArray.arr[i]);
                    if (jo) {
                        String valDoom = "";
                        String valHeretic = "";
                        String valHexen = "";

                        valDoom = GetString(jo, "Doom");
                        valHeretic = GetString(jo, "Heretic");
                        valHexen = GetString(jo, "Hexen");
                        targetGroup.Doom.Push(valDoom);
                        targetGroup.Heretic.Push(valHeretic);
                        targetGroup.Hexen.Push(valHexen);
                    }
                }
                targetGroup.size = targetGroup.Doom.Size();
            } else {
                console.printf("XGameTranslation: Failed to load actor groups from JSON!");
            }
        }
    }

    void Push(XGT_Group group, String strDoom, String strHeretic, String strHexen) {
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
        if (gameType & GAME_Doom) {
            String nActor = group.Doom[index];
            if (nActor != "") {
                newActor = nActor;
            }
        } else if (gameType & GAME_Raven) {
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
        int lumpIndex = Wads.CheckNumForFullName(String.format("playersheets/%s.playersheet", playerClassName));
        if (lumpIndex == -1) {
            // try json
            lumpIndex = Wads.CheckNumForFullName(String.format("playersheets/%s.json", playerClassName));
        }
        //console.printf("XGameTranslation.XClass: Load playersheets/%s.playersheet %d", playerClassName, lumpIndex);
		
        if (lumpIndex != -1) {
            String lumpData = Wads.ReadLump(lumpIndex);
            let json = HXDD_JSON.parse(lumpData, false);
            if (json is "HXDD_JsonElement") {
                HXDD_JsonObject jsonObject = HXDD_JsonObject(json);
				if (jsonObject) {
					
					// Class Item Swap List Generation
					HXDD_JsonObject objClassItems = HXDD_JsonObject(jsonObject.get("xgame"));
					if (objClassItems) {
						Array<String> keys;
						objClassItems.GetKeysInto(keys);

						self.xclass.Resize(keys.Size());
						for (let i = 0; i < keys.Size(); i++) {
							String key = keys[i];
							String valClassItem = GetString(objClassItems, key);
							if (valClassItem) {
								Array<String> nClassItems;
								valClassItem.Split(nClassItems, ",");
                                for (let n = 0; n < nClassItems.Size(); n++) {
                                    nClassItems[n].Replace(" ", "");
                                }
								self.xclass[i] = new ("XTranslationActors");
								self.xclass[i].list.Copy(nClassItems);
                                //for (let j = 0; j < self.xclass[i].list.Size(); j++) {
								//    console.printf("XGameTranslation %s", self.xclass[i].list[j]);
                                //}
								self.xclass[i].key = key;
								//console.printf("XGameTranslation.XClass Lookup: %s, Class Item: %s", key, valClassItem);
							}
						}
					}
				}
			}
		}
	}

	String TryXClass(String replacee) {
		for (let i = 0; i < self.xclass.Size(); i++) {
			if (self.xclass[i].key.MakeLower() == replacee.MakeLower()) {
				String replacement;
				if (self.xclass[i].list.Size() > 1) {
					// choose randomly
					int size = self.xclass[i].list.Size() - 1;
					int choice = random[xclass](0, size);
					replacement = self.xclass[i].list[choice];
				} else {
					replacement = self.xclass[i].list[0];
				}
				//console.printf("XGameTranslation.XClass.TrySwap Found: %s, Replacement: %s", replacee, replacement);

				return replacement;
			}
		}
		return replacee;
	}

    void CreateXSwapTranslation() {
        int lumpIndex = Wads.CheckNumForFullName("xgt/xswap.xgt");
        if (lumpIndex == -1) {
            // try json
            lumpIndex = Wads.CheckNumForFullName("xgt/xswap.json");
        }

        if (lumpIndex != -1) {
            String lumpData = Wads.ReadLump(lumpIndex);
            let json = HXDD_JSON.parse(lumpData, false);
            if (json is "HXDD_JsonElement") {
                HXDD_JsonObject jsonObject = HXDD_JsonObject(json);
                if (jsonObject) {
                    String ver = GetString(jsonObject, "version");
                    //if (ver) {
                    //    console.printf("XGameTranslation.CreateXSwapTranslation: Target Version %s", ver);
                    //}
                    HXDD_JsonArray arrListItems = HXDD_JsonArray(jsonObject.get("list"));
                    if (arrListItems) {
                        int size = arrListItems.Size();
						self.xswap.Resize(size);
						for (let i = 0; i < size; i++) {
					        HXDD_JsonObject objListItem = HXDD_JsonObject(arrListItems.Get(i));
                            if (objListItem) {
                                String valKey = GetString(objListItem, "key");
                                //String valCategory = GetString(objListItem, "category");
                                //HXDD_JsonArray valLabels = GetArray(objListItem, "labels");
                                HXDD_JsonArray valActors = GetArray(objListItem, "actors");
                                if (valKey && valActors) {
                                    let newXSwap = new ("XTranslationActors"); 
                                    newXSwap.key = valKey;
                                    newXSwap.list.Resize(valActors.Size());
                                    for (int j = 0; j < valActors.Size(); j++) {
                                        newXSwap.list[j] = HXDD_JsonString(valActors.get(j)).s;
                                    }
                                    self.xswap[i] = newXSwap;
                                }
                            }
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
                if (option == 0 || option > xtaSwap.list.Size() + 2) {
                    return replacee;
                }
                int select = option - 1;
                if (option == 1) {
                    select = random[xswap](0, xtaSwap.list.Size() - 1);
                }
                String replacement = xtaSwap.list[select];
				//console.printf("XGameTranslation.XSwap.TryXSwap %s %d Found: %s, Replacement: %s", cvarKey, i, replacee, replacement);
                return replacement;
            }
        }
        return replacee;
    }
}