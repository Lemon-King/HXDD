
class MultiClassBagOfHolding : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "BagOfHolding";
        self.Corvus = "BagOfHolding";
        self.Fighter = "ArtiBoostMana";
        self.Cleric = "ArtiBoostMana";
        self.Mage = "ArtiBoostMana";
    }
}

//
//  Gold Wand Ammo
//
// Only Corvus should receive ammo drops on the starter weapon level
class MultiClassGoldWandAmmo : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "GoldWandAmmo";
        self.Corvus = "GoldWandAmmo";
        self.Fighter = "none";
        self.Cleric = "none";
        self.Mage = "none";
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
    }
}