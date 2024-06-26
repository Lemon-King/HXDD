
/*

    Replacement for zscript_generated actors
    Should result in less bugs in the long term

    TODO: Refactor to Map<string, XGT_GROUP>

*/

class XGameResponse {
    bool IsFinal;
    String newActor;
}

class XGameTranslation {
    XGT_Group DoomEdNums;     // For everything
    XGT_Group SpawnNums;      // For bIsMonster swap checks?

    void Init() {
        self.CreateDoomEdNums();
        self.CreateSpawnNums();
    }

    void CreateDoomEdNums() {
        self.LoadFromJSON("doomednums");
    }

    void CreateSpawnNums() {
        self.LoadFromJSON("spawnnums");
    }

    void LoadFromJSON(String group) {
        FileJSON fJSON = new("FileJSON");
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
        /*
        if (index == group.size) {
            String swapActor = self.TryXClass(source);
            //swapActor = self.TryXSwap(swapActor);
            XGameResponse resp = new("XGameResponse");
            if (swapActor != source) {
                resp.isFinal = true;
            }
            resp.newActor = ActorNoneFix(swapActor);
            return resp;
        }
        */
        // TESTING
        if (index == group.size) {
            XGameResponse resp = new("XGameResponse");
            resp.newActor = ActorNoneFix(source);
            return resp;
        }
        // TESTING
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
        /*
        String swapActor = self.TryXClass(newActor);
        //swapActor = self.TryXSwap(swapActor);
        XGameResponse resp = new("XGameResponse");
        if (swapActor != newActor) {
            resp.IsFinal = true;
        }
        resp.newActor = ActorNoneFix(swapActor);
        */
        // TESTING
        XGameResponse resp = new("XGameResponse");
        resp.newActor = ActorNoneFix(newActor);
        // TESTING
        return resp;
    }

    String ActorNoneFix(String source) {
        // hack
        if (source == "" || source == "none") {
            return "RandomSpawner";
        }
        return source;
    }
}