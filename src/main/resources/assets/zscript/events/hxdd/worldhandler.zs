
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

    override void PlayerSpawned(PlayerEvent e) {
        PlayerPawn pp = PlayerPawn(players[e.PlayerNumber].mo);
        if (pp) {
            Progression prog = Progression(pp.FindInventory("Progression"));
            if (prog == null) {
                pp.GiveInventory("Progression", 1);
                prog = Progression(pp.FindInventory("Progression"));
                prog.CreatePlayerSheetItem();
            }
            GameModeCompat gmcompat = GameModeCompat(pp.FindInventory("GameModeCompat"));
            if (gmcompat == null) {
                pp.GiveInventory("GameModeCompat", 1);
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
                    
                    if (prog.sheet) {
                        //HXDDPlayerPawn player = HXDDPlayerPawn(e.thing.target.player.mo);
                        prog.sheet.OnKill(pt, e.thing, exp);
                    }
                }
            }
        }
    }

    override void WorldLinePreActivated(WorldEvent e) {
        // map transfer
        if (e.ActivatedLine.special == 74) {
            int mapNumber = LemonUtil.GetMapNumber();
            // Reserved Map Numbers > 41 for HEXDD
            if (mapNumber != -1 && mapNumber > 41) {
                if (e.ActivatedLine.args[0] != 0) {
                    // HXDD offsets for Deathkings Map numbers by 7 during packaging
                    e.ActivatedLine.args[0] += 7;
                }
            }
        }
    }
    }