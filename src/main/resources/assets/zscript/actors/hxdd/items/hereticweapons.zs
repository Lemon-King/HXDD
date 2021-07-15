
/*
class HXDDStaffPuff : HammerPuff replaces StaffPuff
{
	Default
	{
		+NOBLOCKMAP +NOGRAVITY
		+PUFFONACTORS
		RenderStyle "Translucent";
		Alpha 0.6;
		VSpeed 0.8;
		SeeSound "FighterHammerHitThing";
		AttackSound "weapons/staffhit";
	}
}
*/

class MultiClassGauntlets : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "Gauntlets";
        self.Corvus = "Gauntlets";
        self.Fighter = "Mana3";
        self.Cleric = "Mana3";
        self.Mage = "Mana3";
    }
}

class MultiClassCrossbow : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "Crossbow";
        self.Corvus = "Crossbow";
        self.Fighter = "FWeapAxe";
        self.Cleric = "CWeapStaff";
        self.Mage = "MWeapFrost";
    }
}

class MultiClassBlaster : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "Blaster";
        self.Corvus = "Blaster";
        self.Fighter = "FWeapHammer";
        self.Cleric = "CWeapFlame";
        self.Mage = "MWeapLightning";
    }
}

class MultiClassSkullRod : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "SkullRod";
        self.Corvus = "SkullRod";
        self.Fighter = "FWeaponPiece1";
        self.Cleric = "CWeaponPiece1";
        self.Mage = "MWeaponPiece1";
    }
}

class MultiClassPhoenixRod : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "PhoenixRod";
        self.Corvus = "PhoenixRod";
        self.Fighter = "FWeaponPiece2";
        self.Cleric = "CWeaponPiece2";
        self.Mage = "MWeaponPiece2";
    }
}

class MultiClassMaceSpawner : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "MaceSpawner";
        self.Corvus = "MaceSpawner";
        self.Fighter = "MultiClassSpecialSpawnerFighter";
        self.Cleric = "MultiClassSpecialSpawnerCleric";
        self.Mage = "MultiClassSpecialSpawnerMage";
    }
}

// Mace like spawner support
class MultiClassSpecialSpawnerFighter : MaceSpawner
{
	States
	{
	Spawn:
		TNT1 A 1;
		TNT1 A -1 A_SpawnSingleItem("FWeaponPiece3", 64, 64, 0);
		Stop;
	}
}
class MultiClassSpecialSpawnerCleric : MaceSpawner
{
	States
	{
	Spawn:
		TNT1 A 1;
		TNT1 A -1 A_SpawnSingleItem("CWeaponPiece3", 64, 64, 0);
		Stop;
	}
}
class MultiClassSpecialSpawnerMage : MaceSpawner
{
	States
	{
	Spawn:
		TNT1 A 1;
		TNT1 A -1 A_SpawnSingleItem("MWeaponPiece3", 64, 64, 0);
		Stop;
	}
}