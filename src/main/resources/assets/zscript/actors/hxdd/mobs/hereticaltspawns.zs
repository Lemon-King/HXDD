
class HXDDRandomWizard: CVarAltSpawnSelector {
    override void Bind() {
        self.CvarOption = "hxdd_random_wizard";
        self.HereticSpawn = "Wizard";
        self.HexenSpawn = "Bishop";
    }
}