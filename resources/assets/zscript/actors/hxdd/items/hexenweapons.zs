
// Tier 1
class MultiClassFWeapAxe : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "FWeapAxe";
        self.Corvus = "CrossbowHefty";
        self.Fighter = "FWeapAxe";
        self.Cleric = "FWeapAxe";
        self.Mage = "FWeapAxe";
        self.Paladin = "PWeapVorpalSword";
        self.Crusader = "CWeapIceMace";
        self.Necromancer = "NWeapMagicMissile";
        self.Assassin = "AWeapCrossbow";
        self.Succubus = "SWeapAcidRune";
    }
}

class MultiClassCWeapStaff : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "CWeapStaff";
        self.Corvus = "Crossbow";
        self.Fighter = "CWeapStaff";
        self.Cleric = "CWeapStaff";
        self.Mage = "CWeapStaff";
        self.Paladin = "PWeapVorpalSword";
        self.Crusader = "CWeapIceMace";
        self.Necromancer = "NWeapMagicMissile";
        self.Assassin = "AWeapCrossbow";
        self.Succubus = "SWeapAcidRune";
    }
}

class MultiClassMWeapFrost : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "MWeapFrost";
        self.Corvus = "CrossbowHefty";
        self.Fighter = "MWeapFrost";
        self.Cleric = "MWeapFrost";
        self.Mage = "MWeapFrost";
        self.Paladin = "PWeapVorpalSword";
        self.Crusader = "CWeapIceMace";
        self.Necromancer = "NWeapMagicMissile";
        self.Assassin = "AWeapCrossbow";
        self.Succubus = "SWeapAcidRune";
    }
}

// Tier 2
class MultiClassFWeapHammer : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "FWeapHammer";
        self.Corvus = "Blaster";
        self.Fighter = "FWeapHammer";
        self.Cleric = "FWeapHammer";
        self.Mage = "FWeapHammer";
    }
}

class MultiClassCWeapFlame : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "CWeapFlame";
        self.Corvus = "SkullRod";
        self.Fighter = "CWeapFlame";
        self.Cleric = "CWeapFlame";
        self.Mage = "CWeapFlame";
    }
}

class MultiClassMWeapLightning : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "MWeapLightning";
        self.Corvus = "PhoenixRod";
        self.Fighter = "MWeapLightning";
        self.Cleric = "MWeapLightning";
        self.Mage = "MWeapLightning";
    }
}

// Tier 3 (Fighter)
class MultiClassFWeaponPiece1 : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "FWeaponPiece1";
        self.Corvus = "Gauntlets";
        self.Fighter = "FWeaponPiece1";
        self.Cleric = "FWeaponPiece1";
        self.Mage = "FWeaponPiece1";
    }
}

class MultiClassFWeaponPiece2 : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "FWeaponPiece2";
        self.Corvus = "MaceSpawner";
        self.Fighter = "FWeaponPiece2";
        self.Cleric = "FWeaponPiece2";
        self.Mage = "FWeaponPiece2";
    }
}

class MultiClassFWeaponPiece3 : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "FWeaponPiece3";
        self.Corvus = "ArtiTomeOfPower";
        self.Fighter = "FWeaponPiece3";
        self.Cleric = "FWeaponPiece3";
        self.Mage = "FWeaponPiece3";
    }
}

// Tier 3 (Cleric)
class MultiClassCWeaponPiece1 : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "CWeaponPiece1";
        self.Corvus = "Gauntlets";
        self.Fighter = "CWeaponPiece1";
        self.Cleric = "CWeaponPiece1";
        self.Mage = "CWeaponPiece1";
    }
}

class MultiClassCWeaponPiece2 : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "CWeaponPiece2";
        self.Corvus = "ArtiTomeOfPower";
        self.Fighter = "CWeaponPiece2";
        self.Cleric = "CWeaponPiece2";
        self.Mage = "CWeaponPiece2";
    }
}

class MultiClassCWeaponPiece3 : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "CWeaponPiece3";
        self.Corvus = "MaceSpawner";
        self.Fighter = "CWeaponPiece3";
        self.Cleric = "CWeaponPiece3";
        self.Mage = "CWeaponPiece3";
    }
}

// Tier 3 (Mage)
class MultiClassMWeaponPiece1 : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "MWeaponPiece1";
        self.Corvus = "ArtiTomeOfPower";
        self.Fighter = "MWeaponPiece1";
        self.Cleric = "MWeaponPiece1";
        self.Mage = "MWeaponPiece1";
    }
}

class MultiClassMWeaponPiece2 : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "MWeaponPiece2";
        self.Corvus = "MaceSpawner";
        self.Fighter = "MWeaponPiece2";
        self.Cleric = "MWeaponPiece2";
        self.Mage = "MWeaponPiece2";
    }
}

class MultiClassMWeaponPiece3 : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "MWeaponPiece3";
        self.Corvus = "ArtiTomeOfPower";
        self.Fighter = "MWeaponPiece3";
        self.Cleric = "MWeaponPiece3";
        self.Mage = "MWeaponPiece3";
    }
}