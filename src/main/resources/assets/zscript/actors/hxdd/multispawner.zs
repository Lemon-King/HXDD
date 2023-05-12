// Shared Spawner for Heretic / Hexen between Classes and Map Types (E#M# & Map##).
// ref: https://forum.zdoom.org/viewtopic.php?t=67338&p=1136552
// ref: https://forum.zdoom.org/viewtopic.php?f=122&t=70725
// ref: https://github.com/coelckers/gzdoom/blob/master/wadsrc/static/zscript/actors/shared/randomspawner.zs

// Multi Spawner ----------------------------------------------------------

enum EMultiSpawnerState {
	MSS_NOTREADY = 0,
	MSS_PENDING = 1,
	MSS_READY = 2,
};

class MultiSpawner: RandomSpawner {
    bool CvarSelect;
    String SpawnSelect;

    String Doom;
    String Heretic;
    String Hexen;

    String Fallback;
    String DoomMarine;
    String Corvus;
    String Fighter;
    String Cleric;
    String Mage;
    String Paladin;
    String Crusader;
    String Assassin;
    String Necromancer;
    String Succubus;

    property CvarSelect: CvarSelect;
    property SpawnSelect: SpawnSelect;
    property Doom: Doom;
    property Heretic: Heretic;
    property Hexen: Hexen;
    property Fallback: Fallback;
    property DoomMarine: DoomMarine;
    property Corvus: Corvus;
    property Fighter: Fighter;
    property Cleric: Cleric;
    property Mage: Mage;
    property Paladin: Paladin;
    property Crusader: Crusader;
    property Assassin: Assassin;
    property Necromancer: Necromancer;
    property Succubus: Succubus;

    EMultiSpawnerState readyState;

    virtual void Bind() {
        self.CvarSelect = false;
        self.SpawnSelect = "GameSelect";
        self.Doom = "Unknown";
        self.Heretic = "Unknown";
        self.Hexen = "Unknown";

        self.Fallback = "Unknown";
        self.DoomMarine = "Unknown";
        self.Corvus = "Unknown";
        self.Fighter = "Unknown";
        self.Cleric = "Unknown";
        self.Mage = "Unknown";
        self.Paladin = "Unknown";
        self.Crusader = "Unknown";
        self.Assassin = "Unknown";
        self.Necromancer = "Unknown";
        self.Succubus = "Unknown";
    }
    virtual String CvarSelector() {
        return "Unknown";
    }

    Name SpawnSelector() {
        if (self.CvarSelect) {
            String spawn = CvarSelector();
            if (spawn != "Unknown") {
                return spawn;
            }
        }
        if (self.SpawnSelect == "GameSelect") {
            int gameType = gameinfo.gametype;
            if (gameType & GAME_Doom) {
                return self.Doom;
            } else if (gameType & GAME_Raven) {
                int gameType = LemonUtil.GetOptionGameMode();
                if (gameType == GAME_Heretic) {
                    return self.Heretic;
                } else if (gameType == GAME_Hexen) {
                    return self.Hexen;
                }
            }
            return "Unknown";
        } else if (self.SpawnSelect == "ClassSelect") {
            PlayerInfo p = players[0];
            PlayerPawn player = PlayerPawn(p.mo);

            String spawn = "Unknown";
            if (player is "DoomPlayer") {
                spawn = self.DoomMarine;
            } else if (player is "HereticPlayer") {
                spawn = self.Corvus;
            } else if (player is "FighterPlayer") {
                spawn = self.Fighter;
            } else if (player is "ClericPlayer") {
                spawn = self.Cleric;
            } else if (player is "MagePlayer") {
                spawn = self.Mage;
            } else if (player is "PaladinPlayer") {
                spawn = self.Paladin;
            } else if (player is "CrusaderPlayer") {
                spawn = self.Crusader;
            } else if (player is "AssassinPlayer") {
                spawn = self.Assassin;
            } else if (player is "NecromancerPlayer") {
                spawn = self.Necromancer;
            } else if (player is "SuccubusPlayer") {
                spawn = self.Succubus;
            }
            if (spawn == "Unknown") {
                // Spawn Fallback Item, should make things less weird with mods like Walpurgis
                spawn = self.Fallback;
            }
            return spawn;
        }
        return "Unknown";
    }

    int GetGameType() {
        if (LemonUtil.IsMapHeretic()) {
            return GAME_Heretic;
        } else if (LemonUtil.IsMapHexen()) {
            return GAME_Hexen;
        } else {
            return GAME_Heretic;
        }
    }
	// Override this to decide what to spawn in some other way.
	// Return the class name, or 'None' to spawn nothing, or 'Unknown' to spawn an error marker.
	override Name ChooseSpawn() {
        return SpawnSelector();
	}

	override void BeginPlay() {
        if (self.SpawnSelect == "GameSelect" || readyState == MSS_READY) {
            Bind();
            Super.BeginPlay();
        }
	}

    override void PostBeginPlay() {
        PlayerInfo p = players[0];
        if (self.SpawnSelect == "GameSelect") {
            Super.PostBeginPlay();
        } else if (!self.CvarSelect || readyState == MSS_NOTREADY) {
            readyState = MSS_READY;
            BeginPlay();
            Super.PostBeginPlay();
        }
    }

    override void Tick() {
        Super.Tick();

        PlayerInfo p = players[0];
        if (self.CvarSelect && readyState == MSS_NOTREADY) {
            if (p) {
                Progression prog = Progression(p.mo.FindInventory("Progression"));
                if (prog) {
                    PostBeginPlay();
                }
            }
        }
    }
}