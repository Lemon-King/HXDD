// Compatability Spawner for Heretic / Hexen between Classes and Map Types (E#M# & Map##).
// ref: https://forum.zdoom.org/viewtopic.php?t=67338&p=1136552
// ref: https://forum.zdoom.org/viewtopic.php?f=122&t=70725
// ref: https://github.com/coelckers/gzdoom/blob/master/wadsrc/static/zscript/actors/shared/randomspawner.zs

// Random spawner ----------------------------------------------------------

class MultiSpawner : RandomSpawner
{
    String SpawnSelect;

    String GameSelect;
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

    property GameSelect: GameSelect;
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

    int readyState;

    virtual void Bind() {
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

    Name SpawnSelector() {
        if (self.SpawnSelect == "GameSelect") {
            int gameType = gameinfo.gametype;
            if (gameType & GAME_Doom) {
                return self.Doom;
            } else if (gameType & GAME_Raven) {
                String environment = GetGameSpawnSelect();
                if (environment ~== "heretic") {
                    return self.Heretic;
                } else if (environment ~== "hexen") {
                    return self.Hexen;
                }
            }
            return "Unknown";
        } else if (self.SpawnSelect == "ClassSelect") {
            // Get player class name
            PlayerInfo p = players[0];
            //String playerClass = p.mo.GetPrintableDisplayName(p.cls);

            String spawn = "Unknown";
            /*
            if (playerClass ~== "marine") {
                spawn = self.DoomMarine;
            } else if (playerClass ~== "corvus") {
                spawn = self.Corvus;
            } else if (playerClass ~== "fighter") {
                spawn = self.Fighter;
            } else if (playerClass ~== "cleric") {
                spawn = self.Cleric;
            } else if (playerClass ~== "mage") {
                spawn = self.Mage;
            } else if (playerClass ~== "paladin") {
                spawn = self.Paladin;
            } else if (playerClass ~== "crusader") {
                spawn = self.Crusader;
            } else if (playerClass ~== "assassin") {
                spawn = self.Assassin;
            } else if (playerClass ~== "necromancer") {
                spawn = self.Necromancer;
            } else if (playerClass ~== "demoness") {
                spawn = self.succubus;
            }
            */
            if (p is "DoomPlayer") {
                spawn = self.DoomMarine;
            } else if (p is "HereticPlayer") {
                spawn = self.Corvus;
            } else if (p is "FighterPlayer") {
                spawn = self.Fighter;
            } else if (p is "ClericPlayer") {
                spawn = self.Cleric;
            } else if (p is "MagePlayer") {
                spawn = self.Mage;
            } else if (p is "PaladinPlayer") {
                spawn = self.Paladin;
            } else if (p is "CrusaderPlayer") {
                spawn = self.Crusader;
            } else if (p is "AssassinPlayer") {
                spawn = self.Assassin;
            } else if (p is "NecromancerPlayer") {
                spawn = self.Necromancer;
            } else if (p is "SuccubusPlayer") {
                spawn = self.succubus;
            }
            if (spawn == "Unknown") {
                // Spawn Fallback Item, should make things less weird with mods like Walpurgis
                spawn = self.Fallback;
            }
            return spawn;
        }
        return "Unknown";
    }

    String GetGameSpawnSelect() {
        String mapName = Level.MapName.MakeLower();
        int mapPrefix = mapName.IndexOf("map");
        if (mapName.Left(1) == "e" && mapName.Mid(2, 1) == "m") {
            // Map follows E#M# format.
            return "heretic";
        } else if (mapPrefix != -1) {
            // Map follow MAP## or **_MAP## format.
            return "hexen";
        } else {
            return "heretic";
        }
    }
	// Override this to decide what to spawn in some other way.
	// Return the class name, or 'None' to spawn nothing, or 'Unknown' to spawn an error marker.
	override Name ChooseSpawn() {
        return SpawnSelector();
	}

	override void BeginPlay() {
        Bind();

        PlayerInfo p = players[0];
        if (p.cls != null) {
            Super.BeginPlay();
            readyState = 1;
        } else {
            readyState = 2;
        }
	}

    override void PostBeginPlay()
    {
        PlayerInfo p = players[0];
        if (p.cls != null && readyState == 1) {
            Super.PostBeginPlay();
        }
    }

    override void Tick()
    {
        Super.Tick();
        if (readyState == 2) {
            BeginPlay();
            PostBeginPlay();
        }
    }
}