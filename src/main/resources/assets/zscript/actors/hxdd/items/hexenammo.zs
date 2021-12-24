
// Random Hexen Ammo for now
class MultiClassMana1 : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "Mana1";
        self.Corvus = "HXDDRandomMana1";
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

class MultiClassMana2: MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "Mana2";
        self.Corvus = "HXDDRandomMana2";
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

class MultiClassMana3: MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "Mana3";
        self.Corvus = "HXDDRandomMana3";
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
