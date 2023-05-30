
// ref: https://forum.zdoom.org/viewtopic.php?f=122&t=67766

class HXDDWorldEventHandler : EventHandler {
    void UserOptions_TextureSwap() {
		int hxdd_waterstyle = LemonUtil.CVAR_GetInt("hxdd_waterstyle", 0);
		int hxdd_lavastyle = LemonUtil.CVAR_GetInt("hxdd_lavastyle", 0);
		int hxdd_sludgestyle = LemonUtil.CVAR_GetInt("hxdd_sludgestyle", 0);
		int hxdd_icestyle = LemonUtil.CVAR_GetInt("hxdd_icestyle", 0);

        if (hxdd_waterstyle == 1) {
            Level.ReplaceTextures("X_005", "FLTWAWA1", 0);
            Level.ReplaceTextures("X_WATER1", "FLTWAWA1", 0);
        } else if (hxdd_waterstyle == 2) {
            Level.ReplaceTextures("FLTWAWA1", "X_005", 0);
        }
        if (hxdd_lavastyle == 1) {
            Level.ReplaceTextures("FLATHUH1", "FLTLAVA1", 0);
        } else if (hxdd_lavastyle == 2) {
            Level.ReplaceTextures("FLTLAVA1", "FLATHUH1", 0);
        }
        if (hxdd_sludgestyle == 1) {
            Level.ReplaceTextures("X_009", "FLTSLUD1", 0);
            Level.ReplaceTextures("X_SWMP1", "FLTSLUD1", 0);
        } else if (hxdd_sludgestyle == 2) {
            Level.ReplaceTextures("FLTSLUD1", "X_009", 0);
        }
        if (hxdd_icestyle == 1) {
            Level.ReplaceTextures("F_033", "FLAT517", 0);
            Level.ReplaceTextures("ICE01", "FLAT517", 0);
        } else if (hxdd_icestyle == 2) {
            Level.ReplaceTextures("FLAT517", "F_033", 0);
        }
    }

    void HexenFixes() {
        // Hack for Hexen Maps
        if (LemonUtil.IsMapLinear()) {
            // https://github.com/ZDoom/gzdoom/blob/677b08406405693ab53c281c4d71c19b9b078030/src/gamedata/g_mapinfo.cpp#L1049
            Level.SkySpeed1 /= 256.0;
            Level.SkySpeed2 /= 256.0;

            string infoSky[2] = {Level.Info.SkyPic1, Level.Info.SkyPic2};
            TextureID replacementSky[2] = {TexMan.CheckForTexture(Level.Info.SkyPic1,TexMan.Type_Any), TexMan.CheckForTexture(Level.Info.SkyPic2,TexMan.Type_Any)};

            int numLumps = Wads.GetNumLumps();

            int count_WALL501;
            Array<int> skyAssets;
            for (int i = 0; i < numLumps; i++) {
                // Wads.CheckNumForName(string name, int ns, int wadnum = -1, bool exact = false);
                // CheckNumForName does not work when attempting to target a wadnum.
                // Stepping through all lumps is the current workaround.
                String name = Wads.GetLumpName(i);
                if (name.Length() == 4 && name.IndexOf("SKY") != -1) {
                    int skyNameNum = name.Mid(3, 1).ToInt();
                    if (skyAssets.Size() < skyNameNum) {
                        skyAssets.Resize(skyNameNum + 1);
                    }
                    skyAssets[skyNameNum - 1]++;
                } else if ("WALL501".Length() == name.Length() && name.IndexOf("WALL501") != -1) {
                    count_WALL501++;
                }
            }

            if (count_WALL501 < 2) {
                Level.ReplaceTextures("WALL501", "WALL501X", 0);
            }
            for (int i = 0; i < infoSky.Size(); i++) {
                string pic = infoSky[i];
                if (pic.Length() == 4 && pic.IndexOf("SKY") != -1) {
                    // Use Hexen Swaps
                    console.printf("TEX %s", pic);
                    string picNum = pic.Mid(3, 1);
                    int num = picNum.ToInt();
                    if (skyAssets[num - 1] < 2) {
                        replacementSky[i] = TexMan.CheckForTexture(String.format("SKY%dX", num),TexMan.Type_Any);
                    }
                }
            }
            Level.ChangeSky(replacementSky[0], replacementSky[1]);
        }
    }
    
    override void WorldLoaded(WorldEvent e) {
        int gameType = gameinfo.gametype;
        if (gameType & GAME_Doom) {
        } else if (gameType & Game_Raven) {
            Level.ReplaceTextures("F_SKY1", "F_SKY", 0);
            HexenFixes();
        }
        UserOptions_TextureSwap();
    }

    override void WorldLinePreActivated(WorldEvent e) {
        // map transfer
        if (e.ActivatedLine.special == 74) {
            int mapNumber = LemonUtil.GetMapNumber();
            // Reserved Map Numbers > 41 for HexDD
            if (mapNumber != -1 && mapNumber > 41) {
                if (e.ActivatedLine.args[0] != 0) {
                    // HXDD offsets Deathkings Map numbers by 9 during packaging
                    e.ActivatedLine.args[0] += 9;
                }
            }
        }
    }

    XGameTranslation xgame;
    override void CheckReplacement(ReplaceEvent e) {
        if (!xgame) {
            xgame = new("XGameTranslation");
            xgame.Init();
        }
        if (e.IsFinal) {
            return;
        }
        XGameResponse resp = xgame.GetReplacementActorBySource(e.Replacee.GetClassName());
        e.Replacement = resp.newActor;
        e.IsFinal = resp.IsFinal;
    }
}