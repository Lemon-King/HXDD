
/*

    Replacement for zscript_generated actors
    Should result in less bugs in the long term

    TODO: Refactor to Map<string, XGT_GROUP>

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
                        Array<String> nClassItems;
                        valClassItem.Split(nClassItems, ",");
                        for (let n = 0; n < nClassItems.Size(); n++) {
                            nClassItems[n].Replace(" ", "");
                        }
                        self.xclass[i] = new ("XTranslationActors");
                        self.xclass[i].list.Copy(nClassItems);
                        self.xclass[i].key = key;
                    } else {
                        HXDD_JsonArray valClassItemList = FileJSON.GetArray(objClassItems, key);
                        if (valClassItemList) {
                            self.xclass[i] = new ("XTranslationActors");
                            self.xclass[i].key = key;
                            self.xclass[i].list.Resize(valClassItemList.Size());
                            for (int j = 0; j < valClassItemList.Size(); j++) {
                                String value = HXDD_JsonString(valClassItemList.get(j)).s;
                                self.xclass[i].list[j] = value;
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
				    console.printf("XGameTranslation.XClass.TrySwap Found: %s %d", replacee, choice);
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