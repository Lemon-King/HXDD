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
    String PrimarySpawn;
    String AltSpawn;

    virtual void Bind() {
        self.CvarOption = "unknown";
        self.PrimarySpawn = "Unknown";
        self.AltSpawn = "Unknown";
    }

    Name SpawnSelector() {
        int option = CVar.FindCVar(self.CvarOption).GetInt();
        if (option == 0) {
            return self.PrimarySpawn;
        } else if (option == 1) {
            return self.AltSpawn;
        } else {
            String selector[2] = {self.PrimarySpawn, self.AltSpawn};
            return selector[Random(0, 1)];
        }
        return "Unknown";
    }

	// Override this to decide what to spawn in some other way.
	// Return the class name, or 'None' to spawn nothing, or 'Unknown' to spawn an error marker.
	override Name ChooseSpawn() {
        Bind();
        return SpawnSelector();
	}
}