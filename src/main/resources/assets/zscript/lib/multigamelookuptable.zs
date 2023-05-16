
/*

    Replacement for zscript_generated actors
    Should result in less bugs in the long term

*/

class MGLUT_Group {
    int size;
    Array<String> Doom;
    Array<String> Heretic;
    Array<String> Hexen;
}

class MultiGameLookupTable {
    MGLUT_Group DoomEdNums;     // For everything
    MGLUT_Group SpawnNums;      // For bIsMonster swap checks?

    String GetString(HXDD_JsonObject jo, String key) {
        HXDD_JsonElement type_elem = jo.get(key);
        if (!type_elem) {
            return "";
        }
        HXDD_JsonString type_str = HXDD_JsonString(type_elem);
        return type_str.s;
    }

    void Init() {
        self.LoadFromJSON("hxdd.doomednums.mglut", "doomednums");
        self.LoadFromJSON("hxdd.spawnnums.mglut", "spawnnums");
    }

    void LoadFromJSON(String file, String group) {
        int lumpIndex = Wads.CheckNumForFullName(file);
        if (lumpIndex != -1) {
            String lumpData = Wads.ReadLump(lumpIndex);
            let json = HXDD_JSON.parse(lumpData, false);
            if (json is "HXDD_JsonElement") {
                let jsonArray = HXDD_JsonArray(json);

                MGLUT_Group targetGroup;
                if (group == "doomednums") {
                    self.DoomEdNums = new("MGLUT_Group");
                    targetGroup = self.DoomEdNums;
                } else if (group == "spawnnums") {
                    self.SpawnNums = new("MGLUT_Group");
                    targetGroup = self.SpawnNums;
                } else {
                    console.printf("MultiGameLookupTable: Unknown group [%s]!", group);
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
                console.printf("MultiGameLookupTable: Failed to load actor groups from JSON!");
            }
        }
    }

    void Push(MGLUT_Group group, String strDoom, String strHeretic, String strHexen) {
        String actorDoom = strDoom;
        String actorHeretic = strHeretic;
        String actorHexen = strHexen;
        group.Doom.Push(actorDoom);
        group.Heretic.Push(actorHeretic);
        group.Hexen.Push(actorHexen);
    }

    // low effort, but should work
    Class<Actor> GetActorBySource(String source) {
        MGLUT_Group group = self.DoomEdNums;
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
            return source;
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
        return newActor;
    }
}