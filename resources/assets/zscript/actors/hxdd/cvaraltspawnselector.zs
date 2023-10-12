// Compatability Spawner for Heretic / Hexen between Classes and Map Types (E#M# & Map##).
// ref: https://forum.zdoom.org/viewtopic.php?t=67338&p=1136552
// ref: https://forum.zdoom.org/viewtopic.php?f=122&t=70725
// ref: https://github.com/coelckers/gzdoom/blob/master/wadsrc/static/zscript/actors/shared/randomspawner.zs

// Random spawner ----------------------------------------------------------

class CVarAltSpawnSelector : RandomSpawner
{
    // 0 = Default
    // 1 = Use Alt Spawn
    // 2 = Randomize
    String CvarOption;
    String HereticSpawn;
    String HexenSpawn;

    virtual void Bind() {
        self.CvarOption = "Unknown";
        self.HereticSpawn = "Unknown";
        self.HexenSpawn = "Unknown";
    }

    Name SpawnSelector() {
        int option = LemonUtil.CVAR_GetInt(self.CvarOption, 0);
        if (option == 0) {
            // game mode default
            int ogm = LemonUtil.GetOptionGameMode();
            if (ogm == GAME_Heretic) {
                option = 1;
            } else if (ogm == GAME_Hexen) {
                option = 2;
            }
        }
        if (option == 1) {
            return self.HereticSpawn;
        } else if (option == 2) {
            return self.HexenSpawn;
        } else if (option == 3) {
            String selector[2] = {self.HereticSpawn, self.HexenSpawn};
            return selector[Random[AltSpawner](0, 1)];
        }
        return "Unknown";
    }

    override void PostSpawn(Actor spawned) {
        // adjust health due to game mode
        int ogm = LemonUtil.GetOptionGameMode();
        if (ogm == GAME_Heretic) {

        } else if (ogm == GAME_Hexen) {
            
        }
    }

	// Override this to decide what to spawn in some other way.
	// Return the class name, or 'None' to spawn nothing, or 'Unknown' to spawn an error marker.
	override Name ChooseSpawn() {
        Bind();
        return SpawnSelector();
	}
}