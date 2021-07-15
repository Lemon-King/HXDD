
// Random Hexen Ammo for now
class MultiClassMana1 : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "Mana1";
        self.Corvus = "HXDDRandomMana1";
        self.Fighter = "Mana1";
        self.Cleric = "Mana1";
        self.Mage = "Mana1";
    }
}

class MultiClassMana2: MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "Mana2";
        self.Corvus = "HXDDRandomMana2";
        self.Fighter = "Mana2";
        self.Cleric = "Mana2";
        self.Mage = "Mana2";
    }
}

class MultiClassMana3: MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "Mana3";
        self.Corvus = "HXDDRandomMana3";
        self.Fighter = "Mana3";
        self.Cleric = "Mana3";
        self.Mage = "Mana3";
    }
}

class HXDDRandomMana1 : RandomSpawner {
    Default {
        DropItem "GoldWandAmmo";
        DropItem "GoldWandHefty";
        DropItem "CrossbowAmmo";
        DropItem "CrossbowHefty";
    }
}

class HXDDRandomMana2 : RandomSpawner {
    Default {
        DropItem "BlasterAmmo";
        DropItem "BlasterHefty";
        DropItem "SkullRodAmmo";
        DropItem "SkullRodHefty";
    }
}

class HXDDRandomMana3 : RandomSpawner {
    Default {
        DropItem "PhoenixRodAmmo";
        DropItem "PhoenixRodHefty";
        DropItem "MaceAmmo";
        DropItem "MaceHefty";
    }
}
