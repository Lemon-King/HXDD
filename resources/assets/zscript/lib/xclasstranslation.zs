
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

class XTACompare {
    String command;
    String cvar;
    int i_value;
    String s_value;
    ECVARCompareMethod method;
    ECVARCompareType type;
}

class XTranslationActors {
	String key;
    XTACompare compare;
	Array<String> defaults;
    Array<String> alternates;

    bool hasCVARCompare() {
        return (self.compare != null);
    }

    //bool canReadCommand() {
    //    let probe = new("XGTPlayerProbe");
    //    return probe.GetPlayer().CanReadPlayer();
    //}
}

class XGameArrayStringResult {
    Array<String> list;
}

class XClassTranslation {
	//Array<XTranslationActors> xclass;  // player class actor swaps
    Map<String, XTranslationActors> xcls;

    String ActorNoneFix(String source) {
        // hack
        if (source == "" || source == "none") {
            return "RandomSpawner";
        }
        return source;
    }

	void CreateXClassTranslation(HXDD_JsonObject json) {
        /*
        FileJSON fJSON = new("FileJSON");
        let success = fJSON.Open(String.format("playersheets/%s.playersheet", playerClassName));
        if (!success) {
            success = fJSON.Open(String.format("playersheets/%s.json", playerClassName));
        }
        */
        //if (success) {
            // Class Item Swap List Generation
            //HXDD_JsonObject json = HXDD_JsonObject(fJSON.json);
            HXDD_JsonObject objClassItems = HXDD_JsonObject(json.get("xgame"));
            if (!objClassItems) {
                objClassItems = HXDD_JsonObject(json.get("inventory"));
            }
            if (objClassItems) {
                Array<String> keys;
                objClassItems.GetKeysInto(keys);

                //self.xclass.Resize(keys.Size());
                for (let i = 0; i < keys.Size(); i++) {
                    String key = keys[i];
                    String valClassItem = FileJSON.GetString(objClassItems, key);
                    if (valClassItem != "") {
                        XGameArrayStringResult result = self.GetKeysFromCombinedKey(key);
                        for (let i = 0; i < result.list.Size(); i++) {
                            XTranslationActors xta = CreateXTAFromString(result.list[i], valClassItem);
                            self.xcls.Insert(result.list[i], xta);
                        }
                        continue;
                    }
                    HXDD_JsonArray valClassItemList = FileJSON.GetArray(objClassItems, key);
                    if (valClassItemList) {
                        XGameArrayStringResult result = self.GetKeysFromCombinedKey(key);
                        for (let i = 0; i < result.list.Size(); i++) {
                            XTranslationActors xta = CreateXTAFromArray(result.list[i], valClassItemList);
                            self.xcls.Insert(result.list[i], xta);
                        }
                        continue;
                    }
                    HXDD_JsonObject valClassItemObject = HXDD_JsonObject(objClassItems.Get(key));
                    if (valClassItemObject) {
                        XGameArrayStringResult result = self.GetKeysFromCombinedKey(key);
                        for (let i = 0; i < result.list.Size(); i++) {
                            XTranslationActors xta = CreateXTAFromObject(result.list[i], valClassItemObject);
                            self.xcls.Insert(result.list[i], xta);
                        }
                        continue;
                    }
                }
            }
		//}
	}

    XGameArrayStringResult GetKeysFromCombinedKey(String combined) {
        XGameArrayStringResult result = new("XGameArrayStringResult");
        combined.Substitute(" ", "");
        combined.Split(result.list, ",");
        return result;
    }

    XTranslationActors CreateXTAFromString(String key, String js) {
        XTranslationActors xta = new("XTranslationActors");
        Array<String> nClassItems;
        js.Substitute(" ", "");
        js.Split(xta.defaults, ",");
        xta.key = key;
        return xta;
    }

    XTranslationActors CreateXTAFromArray(String key, HXDD_JsonArray ja) {
        XTranslationActors xta = new("XTranslationActors");
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
        XTranslationActors xta = new("XTranslationActors");
        xta.key = key;
        xta.compare = new("XTACompare");

        String sCVAR = FileJSON.GetString(jo, "cvar");
        if (sCVAR != "") {
            xta.compare.cvar = sCVAR;
        }

        // Probe Progression Values from the Player
        String sCommand = FileJSON.GetString(jo, "command");
        if (sCommand != "") {
            xta.compare.command = sCommand;
        }

        if (xta.compare.cvar || xta.compare.command) {
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
                    val.Split(xta.alternates, ",");
                }
            }
            HXDD_JsonArray arrDefaults = FileJSON.GetArray(jo, "false");
            if (arrDefaults) {
                for (int j = 0; j < arrDefaults.Size(); j++) {
                    String entry = HXDD_JsonString(arrDefaults.get(j)).s;
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
            if (xta.defaults.Size() == 0) {
                xta.defaults.push(key);
            }
        }

        return xta;
    }

	String TryXClass(int index, String replacee) {
        String replacement = replacee;
        if (replacement.MakeLower().Mid(0,14) == "dehackedpickup") {
            // Dehacked is weird, breaks naming to where you need to capture the class name via the defaults
            replacement = GetDefaultByType((class<Inventory>)(replacement)).GetClassName();
        }
        XTranslationActors xta = self.xcls.GetIfExists(replacement);
        if (!xta) {
            // Try parent?
            replacement = GetDefaultByType((class<Inventory>)(replacement)).GetParentClass().GetClassName();
            xta = self.xcls.GetIfExists(replacement);
        }
        if (xta && xta.key.MakeLower() == replacement.MakeLower()) {
            Array<string> list;
            list.copy(xta.defaults);
            String replacement;
            if (xta.hasCVARCompare()) {
                bool useAlts = false;
                XTACompare xcvar = xta.compare;
                if (xcvar.type == ECVARCompareType_INT) {
                    int val;
                    if (xcvar.cvar) {
                        val = LemonUtil.CVAR_GetInt(xcvar.cvar, -1);
                    } else if (xcvar.command) {
                        XGTPlayerProbe probe = new("XGTPlayerProbe").GetPlayer(index);
                        if (probe.Command(xcvar.command)) {
                            val = probe.i_result;
                        }
                    }
                    if (val) {
                        if (xcvar.method == ECVARCompareMethod_EQUALS) {
                            useAlts = (val == xcvar.i_value);
                        } else if (xcvar.method == ECVARCompareMethod_LESSER) {
                            useAlts = (val < xcvar.i_value);
                        } else if (xcvar.method == ECVARCompareMethod_GREATER) {
                            useAlts = (val > xcvar.i_value);
                        }
                    }
                } else if (xcvar.type == ECVARCompareType_STRING) {
                    String val;
                    if (xcvar.cvar) {
                        val = LemonUtil.CVAR_GetString(xcvar.cvar, "");
                    } else if (xcvar.command) {
                        XGTPlayerProbe probe = new("XGTPlayerProbe").GetPlayer(index);
                        if (probe.Command(xcvar.command)) {
                            val = probe.s_result;
                        }
                    }
                    if (val != "") {
                        useAlts = (val == xcvar.s_value);
                    }
                }
                if (useAlts && xta.alternates.Size() > 0) {
                    list.copy(xta.alternates);
                }
            }

            if (list.Size() == 0) {
                return replacee;
            }

            // select random
            int size = list.Size() - 1;
            int choice = random[xclass](0, size);
            replacement = list[choice];

            return replacement;
        }
		return replacee;
	}
}

// Grabs Player stats in real time
// TODO: Move into Progression for command responses
class XGTPlayerProbe {
    Progression invProgression;
    int i_result;
    String s_result;
    XGTPlayerProbe GetPlayer(int index) {
        PlayerPawn player = PlayerPawn(players[index].mo);
        if (player) {
            let invProg = player.FindInventory("Progression");
            if (invProg) {
                self.invProgression = Progression(invProg);
            }
        }
        return self;
    }

    bool CanReadPlayer() {
        return self.invProgression != null;
    }

    bool Command(String cmd) {
        if (!CanReadPlayer()) {
            return false;
        }
        let sCmd = cmd.MakeLower();
        if (sCmd == "armortype") {
            self.i_result = self.GetArmorType();
            return true;
        }
        return false;
    }

    int GetArmorType() {
        return self.invProgression.ArmorType;
    }
}