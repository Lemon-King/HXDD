
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

class XClassTranslationActors {
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

	Array<XClassTranslationActors> xclass;  // player class actor swaps

    String GetString(HXDD_JsonObject jo, String key) {
        HXDD_JsonElement type_elem = jo.get(key);
        if (!type_elem) {
            return "";
        }
        HXDD_JsonString type_str = HXDD_JsonString(type_elem);
        return type_str.s;
    }

    void Init() {
        self.LoadFromJSON("hxdd.doomednums.xgt", "doomednums");
        self.LoadFromJSON("hxdd.spawnnums.xgt", "spawnnums");

        CreateXClassTranslation();
    }

    void LoadFromJSON(String file, String group) {
        int lumpIndex = Wads.CheckNumForFullName(file);
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
    XGameResponse GetActorBySource(String source) {
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
            String newActor = self.TrySwap(source);
            XGameResponse resp = new ("XGameResponse");
            if (newActor != source) {
                resp.isFinal = true;
            }
            resp.newActor = newActor;
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
        String swapped = self.TrySwap(newActor);
        XGameResponse resp = new ("XGameResponse");
        if (swapped != newActor) {
            resp.IsFinal = true;
        }
        resp.newActor = swapped;
        return resp;
    }

	void CreateXClassTranslation() {
        String playerClassName = LemonUtil.GetPlayerClassName();
        int lumpIndex = Wads.CheckNumForFullName(String.format("playersheets/%s.playersheet", playerClassName));
        console.printf("XGameTranslation.XClass: Load playersheets/%s.playersheet %d", playerClassName, lumpIndex);
		
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
								self.xclass[i] = new ("XClassTranslationActors");
								self.xclass[i].list.Copy(nClassItems);
                                for (let j = 0; j < self.xclass[i].list.Size(); j++) {
								    console.printf("XGameTranslation %s", self.xclass[i].list[j]);
                                }
								self.xclass[i].key = key;
								console.printf("XGameTranslation.XClass Lookup: %s, Class Item: %s", key, valClassItem);
							}
						}
					}
				}
			}
		}
	}

	String TrySwap(String replacee) {
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
				console.printf("XGameTranslation.XClass.TrySwap Found: %s, Replacement: %s", replacee, replacement);

				return replacement;
			}
		}
		return replacee;
	}
}