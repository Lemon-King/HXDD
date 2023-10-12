
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
        self.Paladin = "Mana3";
        self.Crusader = "Mana3";
        self.Necromancer = "Mana3";
        self.Assassin = "Mana3";
        self.Succubus = "Mana3";
    }
}

class MultiClassGoldWand : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "GoldWand";
        self.Corvus = "GoldWand";
        self.Fighter = "Mana1";
        self.Cleric = "Mana1";
        self.Mage = "Mana1";
        self.Paladin = "Mana1";
        self.Crusader = "Mana1";
        self.Necromancer = "Mana1";
        self.Assassin = "Mana1";
        self.Succubus = "Mana1";
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
        self.Paladin = "PWeapVorpalSword";
        self.Crusader = "CWeapIceMace";
        self.Necromancer = "NWeapMagicMissile";
        self.Assassin = "AWeapCrossbow";
        self.Succubus = "SWeapAcidRune";
    }
}

class MultiClassBlaster : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "Blaster";
        self.Corvus = "Blaster";
        self.Fighter = "FWeaponPiece1";
        self.Cleric = "CWeaponPiece1";
        self.Mage = "MWeaponPiece1";
    }
}

class MultiClassSkullRod : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "SkullRod";
        self.Corvus = "SkullRod";
        self.Fighter = "FWeapHammer";
        self.Cleric = "CWeapFlame";
        self.Mage = "MWeapLightning";
        self.Paladin = "PWeapAxe";
        self.Crusader = "CWeapMeteorStaff";
        self.Necromancer = "NWeapBoneShards";
        self.Assassin = "AWeapGrenades";
        self.Succubus = "SWeapFireStorm";
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
class MultiClassSpecialSpawnerFighter: MaceSpawner {
	States
	{
	Spawn:
		TNT1 A 1;
		TNT1 A -1 A_SpawnSingleItem("FWeaponPiece1", 64, 64, 0);
		Stop;
	}
}
class MultiClassSpecialSpawnerCleric: MaceSpawner {
	States
	{
	Spawn:
		TNT1 A 1;
		TNT1 A -1 A_SpawnSingleItem("CWeaponPiece1", 64, 64, 0);
		Stop;
	}
}
class MultiClassSpecialSpawnerMage: MaceSpawner {
	States
	{
	Spawn:
		TNT1 A 1;
		TNT1 A -1 A_SpawnSingleItem("MWeaponPiece1", 64, 64, 0);
		Stop;
	}
}