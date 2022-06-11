
class HXDDRandomWizard: CVarAltSpawnSelector {
    override void Bind() {
        self.CvarOption = "hxdd_random_wizard";
        self.PrimarySpawn = "Wizard";
        self.AltSpawn = "Bishop";
    }
}