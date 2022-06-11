
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
        String mapName = Level.MapName.MakeLower();
        bool isHexen = mapName.IndexOf("map") != -1 || mapName.IndexOf("&wt") != -1;
        if (gameType & GAME_Doom) {
        } else if (gameType & Game_Raven) {
            if (mapName.Left(1) == "e" && mapName.Mid(2, 1) == "m") {
                // Map follows E#M# format.
                //HereticReplacements();
            } else if (isHexen) {
                //HexenReplacements();
            }
        }
        UserOptions_TextureSwap();
    }
}

class ProgressionWorldEventHandler: EventHandler {
    override void PlayerSpawned(PlayerEvent e) {
        PlayerPawn pp = PlayerPawn(players[e.PlayerNumber].mo);
        if (pp) {
            Progression itemProgression = Progression(pp.FindInventory("Progression"));
            if (itemProgression == null) {
                pp.GiveInventory("Progression", 1);
                //if (prog != NULL) {
                //    console.printf("Progression activated for Player %d.", e.PlayerNumber);
                //}
            }
        }
    }

    override void WorldThingDied(WorldEvent e) {
        if (e.thing && e.thing.bIsMonster && e.thing.bCountKill && e.thing.target && e.thing.target.player) {
            if (e.thing.target.player.mo is "PlayerPawn") {
                PlayerPawn pt = PlayerPawn(e.thing.target.player.mo);
                if (pt.FindInventory("Progression")) {
                    Progression prog = Progression(pt.FindInventory("Progression"));
                    double exp = 0;
                    if (prog != NULL) {
                        exp = prog.GiveExperienceByTargetHealth(e.thing);
                    }
                    
                    if (e.thing.target.player.mo is "HXDDPlayerPawn") {
                        HXDDPlayerPawn player = HXDDPlayerPawn(e.thing.target.player.mo);
                        player.OnKill(e.thing, exp);
                    }
                }
            }
        }
    }
}