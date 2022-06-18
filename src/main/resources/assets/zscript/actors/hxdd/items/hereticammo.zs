
//
//  Bag of Holding
//
class MultiClassBagOfHolding : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "BagOfHolding";
        self.Corvus = "BagOfHolding";
        self.Fighter = "ArtiBoostMana";
        self.Cleric = "ArtiBoostMana";
        self.Mage = "ArtiBoostMana";
        self.Paladin = "ArtiBoostMana";
        self.Crusader = "ArtiBoostMana";
        self.Necromancer = "ArtiBoostMana";
        self.Assassin = "ArtiBoostMana";
        self.Succubus = "ArtiBoostMana";
    }
}

//
//  Gold Wand Ammo
//
// Only Corvus should receive ammo drops with the starter weapon
class MultiClassGoldWandAmmo : MultiPickup {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "HXDDGoldWandAmmo";
        self.Corvus = "HXDDGoldWandAmmo";
        self.Fighter = "none";
        self.Cleric = "none";
        self.Mage = "none";
        self.Paladin = "none";
        self.Crusader = "none";
        self.Necromancer = "none";
        self.Assassin = "none";
        self.Succubus = "none";
    }
}

// Rarer, should show up as Mana 1
class MultiClassGoldWandHefty : MultiPickup {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "HXDDGoldWandHefty";
        self.Corvus = "HXDDGoldWandHefty";
        self.Fighter = "HXDDMana1";
        self.Cleric = "HXDDMana1";
        self.Mage = "HXDDMana1";
        self.Paladin = "HXDDMana1";
        self.Crusader = "HXDDMana1";
        self.Necromancer = "HXDDMana1";
        self.Assassin = "HXDDMana1";
        self.Succubus = "HXDDMana1";
    }
}

//
//  Crossbow Ammo
//
class MultiClassCrossbowAmmo : MultiPickup {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "HXDDCrossbowAmmo";
        self.Corvus = "HXDDCrossbowAmmo";
        self.Fighter = "HXDDMana1";
        self.Cleric = "HXDDMana1";
        self.Mage = "HXDDMana1";
        self.Paladin = "HXDDMana1";
        self.Crusader = "HXDDMana1";
        self.Necromancer = "HXDDMana1";
        self.Assassin = "HXDDMana1";
        self.Succubus = "HXDDMana1";
    }
}

class MultiClassCrossbowHefty : MultiPickup {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "HXDDCrossbowHefty";
        self.Corvus = "HXDDCrossbowHefty";
        self.Fighter = "HXDDMana2";
        self.Cleric = "HXDDMana2";
        self.Mage = "HXDDMana2";
        self.Paladin = "HXDDMana2";
        self.Crusader = "HXDDMana2";
        self.Necromancer = "HXDDMana2";
        self.Assassin = "HXDDMana2";
        self.Succubus = "HXDDMana2";
    }
}

//
//  Blaster Ammo
//
class MultiClassBlasterAmmo : MultiPickup {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "HXDDBlasterAmmo";
        self.Corvus = "HXDDBlasterAmmo";
        self.Fighter = "HXDDMana1";
        self.Cleric = "HXDDMana1";
        self.Mage = "HXDDMana1";
        self.Paladin = "HXDDMana1";
        self.Crusader = "HXDDMana1";
        self.Necromancer = "HXDDMana1";
        self.Assassin = "HXDDMana1";
        self.Succubus = "HXDDMana1";
    }
}

class MultiClassBlasterHefty : MultiPickup {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "HXDDBlasterHefty";
        self.Corvus = "HXDDBlasterHefty";
        self.Fighter = "HXDDMana2";
        self.Cleric = "HXDDMana2";
        self.Mage = "HXDDMana2";
        self.Paladin = "HXDDMana2";
        self.Crusader = "HXDDMana2";
        self.Necromancer = "HXDDMana2";
        self.Assassin = "HXDDMana2";
        self.Succubus = "HXDDMana2";
    }
}

//
//  SkullRod Ammo
//
class MultiClassSkullRodAmmo : MultiPickup {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "HXDDSkullRodAmmo";
        self.Corvus = "HXDDSkullRodAmmo";
        self.Fighter = "HXDDMana2";
        self.Cleric = "HXDDMana2";
        self.Mage = "HXDDMana2";
        self.Paladin = "HXDDMana2";
        self.Crusader = "HXDDMana2";
        self.Necromancer = "HXDDMana2";
        self.Assassin = "HXDDMana2";
        self.Succubus = "HXDDMana2";
    }
}

class MultiClassSkullRodHefty : MultiPickup {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "HXDDSkullRodHefty";
        self.Corvus = "HXDDSkullRodHefty";
        self.Fighter = "HXDDMana3";
        self.Cleric = "HXDDMana3";
        self.Mage = "HXDDMana3";
        self.Paladin = "HXDDMana3";
        self.Crusader = "HXDDMana3";
        self.Necromancer = "HXDDMana3";
        self.Assassin = "HXDDMana3";
        self.Succubus = "HXDDMana3";
    }
}

//
//  PhoenixRod Ammo
//
class MultiClassPhoenixRodAmmo : MultiPickup {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "HXDDPhoenixRodAmmo";
        self.Corvus = "HXDDPhoenixRodAmmo";
        self.Fighter = "HXDDMana2";
        self.Cleric = "HXDDMana2";
        self.Mage = "HXDDMana2";
        self.Paladin = "HXDDMana2";
        self.Crusader = "HXDDMana2";
        self.Necromancer = "HXDDMana2";
        self.Assassin = "HXDDMana2";
        self.Succubus = "HXDDMana2";
    }
}

class MultiClassPhoenixRodHefty : MultiPickup {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "HXDDPhoenixRodHefty";
        self.Corvus = "HXDDPhoenixRodHefty";
        self.Fighter = "HXDDMana3";
        self.Cleric = "HXDDMana3";
        self.Mage = "HXDDMana3";
        self.Paladin = "HXDDMana3";
        self.Crusader = "HXDDMana3";
        self.Necromancer = "HXDDMana3";
        self.Assassin = "HXDDMana3";
        self.Succubus = "HXDDMana3";
    }
}

//
//  Mace Ammo
//
class MultiClassMaceAmmo : MultiPickup {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "HXDDMaceAmmo";
        self.Corvus = "HXDDMaceAmmo";
        self.Fighter = "HXDDMana3";
        self.Cleric = "HXDDMana3";
        self.Mage = "HXDDMana3";
        self.Paladin = "HXDDMana3";
        self.Crusader = "HXDDMana3";
        self.Necromancer = "HXDDMana3";
        self.Assassin = "HXDDMana3";
        self.Succubus = "HXDDMana3";
    }
}

class MultiClassMaceHefty : MultiPickup {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "HXDDMaceHefty";
        self.Corvus = "HXDDMaceHefty";
        self.Fighter = "HXDDMana3";
        self.Cleric = "HXDDMana3";
        self.Mage = "HXDDMana3";
        self.Paladin = "HXDDMana3";
        self.Crusader = "HXDDMana3";
        self.Necromancer = "HXDDMana3";
        self.Assassin = "HXDDMana3";
        self.Succubus = "HXDDMana3";
    }
}