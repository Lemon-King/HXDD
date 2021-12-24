
// ref: https://forum.zdoom.org/viewtopic.php?f=122&t=67766

class HXDDWorldEventHandler : EventHandler {
    void HereticReplacements() {
        // Replace sky textures with F_SKY for gameinfo between both games
        Level.ReplaceTextures("F_SKY1", "F_SKY", 0);
        if (CVar.FindCVar("hxdd_waterstyle").GetInt() == 2) {
            Level.ReplaceTextures("FLTWAWA1", "X_005", 0);
            // TODO: Hexen simulated scrolling texture
        }
        if (CVar.FindCVar("hxdd_lavastyle").GetInt() == 2) {
            Level.ReplaceTextures("FLTLAVA1", "FLATHUH1", 0);
            // TODO: Hexen simulated scrolling texture
        }
        if (CVar.FindCVar("hxdd_sludgestyle").GetInt() == 2) {
            Level.ReplaceTextures("FLTSLUD1", "X_009", 0);
            // TODO: Hexen simulated scrolling texture
        }
        if (CVar.FindCVar("hxdd_icestyle").GetInt() == 2) {
            Level.ReplaceTextures("FLAT517", "F_033", 0);
        }
    }

    void HexenReplacements() {
        if (CVar.FindCVar("hxdd_waterstyle").GetInt() == 1) {
            Level.ReplaceTextures("X_005", "FLTWAWA1", 0);
            Level.ReplaceTextures("X_WATER1", "FLTWAWA1", 0);
        }
        if (CVar.FindCVar("hxdd_lavastyle").GetInt() == 1) {
            Level.ReplaceTextures("FLATHUH1", "FLTLAVA1", 0);
        }
        if (CVar.FindCVar("hxdd_sludgestyle").GetInt() == 1) {
            Level.ReplaceTextures("X_009", "FLTSLUD1", 0);
            Level.ReplaceTextures("X_SWMP1", "FLTSLUD1", 0);
        }
        if (CVar.FindCVar("hxdd_icestyle").GetInt() == 1) {
            Level.ReplaceTextures("F_033", "FLAT517", 0);
            Level.ReplaceTextures("ICE01", "FLAT517", 0);
        }
    }
    
    override void WorldLoaded(WorldEvent e) {
        int gameType = gameinfo.gametype;
        String mapName = Level.MapName.MakeLower();
        int mapPrefix = mapName.IndexOf("map");
        if (gameType & GAME_Doom) {
        } else if (gameType & Game_Raven) {
            if (mapName.Left(1) == "e" && mapName.Mid(2, 1) == "m") {
                // Map follows E#M# format.
                HereticReplacements();
            } else if (mapPrefix != -1) {
                HexenReplacements();
            }
        }
    }
    override void PlayerSpawned(PlayerEvent e) {
        PlayerPawn p = PlayerPawn(players[e.PlayerNumber].mo);
        Progression prog = Progression(p.FindInventory("Progression"));
        if (prog == NULL) {
            p.GiveInventory("Progression", 1);
            if (prog != NULL) {
                console.printf("Progression activated for Player %d.", e.PlayerNumber);
            }
        }
    }

    override void WorldThingDied (WorldEvent e) {
        if (e.thing && e.thing.bIsMonster && e.thing.bCOUNTKILL && e.thing.target && e.thing.target.player) {
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