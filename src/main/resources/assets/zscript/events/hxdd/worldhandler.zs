
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
        Level.ReplaceTextures("F_SKY1", "F_SKY", 0);
    }
    
    override void WorldLoaded(WorldEvent e) {
        int gameType = gameinfo.gametype;
        if (gameType & GAME_Doom) {
        } else if (gameType & Game_Raven) {
            //PlayerInfo p = players[0];
            //String playerClass = p.mo.GetPrintableDisplayName(p.cls);
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
        XGameResponse resp = xgame.GetActorBySource(e.Replacee.GetClassName());
        if (resp.newActor == "none") {
            // Hack
            e.Replacement = "RandomSpawner";
        } else {
            e.Replacement = resp.newActor;
        }
        e.IsFinal = resp.IsFinal;
    }
}