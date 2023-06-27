//
//  Gold Wand Ammo
//
// Only Corvus should receive ammo drops with the starter weapon
class MultiClassGoldWandAmmo : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "GoldWandAmmo";
        self.Corvus = "GoldWandAmmo";
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
class MultiClassGoldWandHefty : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "GoldWandHefty";
        self.Corvus = "GoldWandHefty";
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

//
//  Crossbow Ammo
//
class MultiClassCrossbowAmmo : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "CrossbowAmmo";
        self.Corvus = "CrossbowAmmo";
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

class MultiClassCrossbowHefty : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "CrossbowHefty";
        self.Corvus = "CrossbowHefty";
        self.Fighter = "Mana2";
        self.Cleric = "Mana2";
        self.Mage = "Mana2";
        self.Paladin = "Mana2";
        self.Crusader = "Mana2";
        self.Necromancer = "Mana2";
        self.Assassin = "Mana2";
        self.Succubus = "Mana2";
    }
}

//
//  Blaster Ammo
//
class MultiClassBlasterAmmo : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "BlasterAmmo";
        self.Corvus = "BlasterAmmo";
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

class MultiClassBlasterHefty : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "BlasterHefty";
        self.Corvus = "BlasterHefty";
        self.Fighter = "Mana2";
        self.Cleric = "Mana2";
        self.Mage = "Mana2";
        self.Paladin = "Mana2";
        self.Crusader = "Mana2";
        self.Necromancer = "Mana2";
        self.Assassin = "Mana2";
        self.Succubus = "Mana2";
    }
}

//
//  SkullRod Ammo
//
class MultiClassSkullRodAmmo : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "SkullRodAmmo";
        self.Corvus = "SkullRodAmmo";
        self.Fighter = "Mana2";
        self.Cleric = "Mana2";
        self.Mage = "Mana2";
        self.Paladin = "Mana2";
        self.Crusader = "Mana2";
        self.Necromancer = "Mana2";
        self.Assassin = "Mana2";
        self.Succubus = "Mana2";
    }
}

class MultiClassSkullRodHefty : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "SkullRodHefty";
        self.Corvus = "SkullRodHefty";
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

//
//  PhoenixRod Ammo
//
class MultiClassPhoenixRodAmmo : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "PhoenixRodAmmo";
        self.Corvus = "PhoenixRodAmmo";
        self.Fighter = "Mana2";
        self.Cleric = "Mana2";
        self.Mage = "Mana2";
        self.Paladin = "Mana2";
        self.Crusader = "Mana2";
        self.Necromancer = "Mana2";
        self.Assassin = "Mana2";
        self.Succubus = "Mana2";
    }
}

class MultiClassPhoenixRodHefty : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "PhoenixRodHefty";
        self.Corvus = "PhoenixRodHefty";
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

//
//  Mace Ammo
//
class MultiClassMaceAmmo : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "MaceAmmo";
        self.Corvus = "MaceAmmo";
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

class MultiClassMaceHefty : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "MaceHefty";
        self.Corvus = "MaceHefty";
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