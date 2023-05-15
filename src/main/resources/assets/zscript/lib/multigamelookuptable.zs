
/*

    Replacement for zscript_generated actors
    Should result in less bugs in the long term

*/

class MultiGameLookupTable {
    int size;
    Array<String> Doom;
    Array<String> Heretic;
    Array<String> Hexen;

    String GetString(HXDD_JsonObject jo, String key) {
        HXDD_JsonElement type_elem = jo.get(key);
        if (!type_elem) {
            return "";
        }
        HXDD_JsonString type_str = HXDD_JsonString(type_elem);
        return type_str.s;
    }

    void LoadData() {
        int lumpIndex = Wads.CheckNumForFullName("hxdd.all.mglut");
        if (lumpIndex != -1) {
            String lumpData = Wads.ReadLump(lumpIndex);
            let json = HXDD_JSON.parse(lumpData, false);
            if (json is "HXDD_JsonElement") {
                let jsonArray = HXDD_JsonArray(json);

                for (let i = 0; i < jsonArray.Size(); i++) {
                    HXDD_JsonObject jo = HXDD_JsonObject(jsonArray.arr[i]);
                    if (jo) {
                        String valDoom = "";
                        String valHeretic = "";
                        String valHexen = "";

                        valDoom = GetString(jo, "Doom");
                        valHeretic = GetString(jo, "Heretic");
                        valHexen = GetString(jo, "Hexen");
                        self.Doom.Push(valDoom);
                        self.Heretic.Push(valHeretic);
                        self.Hexen.Push(valHexen);
                    }
                }
                self.size = self.Doom.Size();
            } else {
                console.printf("MultiGameLookupTable: Failed to load actor groups from JSON!");
            }
        }
    }

    void Push(String strDoom, String strHeretic, String strHexen) {
        String actorDoom = strDoom;
        String actorHeretic = strHeretic;
        String actorHexen = strHexen;
        self.Doom.Push(actorDoom);
        self.Heretic.Push(actorHeretic);
        self.Hexen.Push(actorHexen);
    }

    // low effort, but should work
    Class<Actor> GetActorBySource(String source) {
        int index = self.Heretic.Find(source);
        if (index == self.size) {
            int newIndex = self.Hexen.Find(source);
            if (newIndex != self.size) {
                index = newIndex;
            }
        }
        if (index == self.size) {
            int newIndex = self.Doom.Find(source);
            if (newIndex != self.size) {
                index = newIndex;
            }
        }
        if (index == self.size) {
            //console.printf("MultiGameLookupTable: Could not find %s in LUT!", source);
            return source;
        }
        int optGameMode = LemonUtil.GetOptionGameMode();
        String newActor = source;
        int gameType = gameinfo.gametype;
        if (gameType & GAME_Doom) {
            String nActor = self.Doom[index];
            if (nActor != "") {
                newActor = nActor;
            }
        } else if (gameType & GAME_Raven) {
            int optGameMode = LemonUtil.GetOptionGameMode();
            if (optGameMode == GAME_Heretic) {
                String nActor = self.Heretic[index];
                if (nActor != "") {
                    newActor = nActor;
                }
            } else if (optGameMode == GAME_Hexen) {
                String nActor = self.Hexen[index];
                if (nActor != "") {
                    newActor = nActor;
                }
            }
        }
        console.printf("MultiGameLookupTable: Found source %s in LUT, replacing with %s!", source, newActor);
        return newActor;
    }
}