// Compatability Spawner for Heretic / Hexen between Classes and Map Types (E#M# & Map##).
// ref: https://forum.zdoom.org/viewtopic.php?t=67338&p=1136552
// ref: https://forum.zdoom.org/viewtopic.php?f=122&t=70725
// ref: https://github.com/coelckers/gzdoom/blob/master/wadsrc/static/zscript/actors/shared/randomspawner.zs

// Random spawner ----------------------------------------------------------

class MultiSpawner : RandomSpawner
{
    String SpawnSelect;

    String GameSelect;
    String Heretic;
    String Hexen;

    String Fallback;
    String Corvus;
    String Fighter;
    String Cleric;
    String Mage;

    virtual void Bind() {
        self.SpawnSelect = "GameSelect";
        self.Heretic = "Unknown";
        self.Hexen = "Unknown";
        self.Fallback = "Unknown";
        self.Corvus = "Unknown";
        self.Fighter = "Unknown";
        self.Cleric = "Unknown";
        self.Mage = "Unknown";
    }

    Name SpawnSelector() {
        if (self.SpawnSelect == "GameSelect") {
            String environment = GetGameSpawnSelect();
            if (environment == "heretic") {
                return self.Heretic;
            } else if (environment == "hexen") {
                return self.Hexen;
            }
            return "Unknown";
        } else if (self.SpawnSelect == "ClassSelect") {
            String playerClass = CVar.FindCVar("hxdd_playerclass").GetString().MakeLower();
            if (playerClass == "") {
                playerClass = CVar.FindCVar("PlayerClass").GetString().MakeLower();
            }
            if (playerClass == "corvus") {
                return self.Corvus;
            } else if (playerClass == "fighter") {
                return self.Fighter;
            } else if (playerClass == "cleric") {
                return self.Cleric;
            } else if (playerClass == "mage") {
                return self.Mage;
            } else {
                // Spawn Fallback Item, should make things less weird with mods like Walpurgis
                return self.Fallback;
            }
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
        Bind();
        return SpawnSelector();
	}
}