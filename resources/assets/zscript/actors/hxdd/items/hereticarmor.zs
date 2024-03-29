

class SimpleHexenArmorSelectorTier1: RandomSpawner {
    Default {
        DropItem "MeshArmor";
        DropItem "PlatinumHelm";
    }
}

class SimpleHexenArmorSelectorTier2: RandomSpawner {
    Default {
        DropItem "AmuletOfWarding";
        DropItem "FalconShield";
    }
}

class MultiClassSilverShield : MultiSpawner {
    override String CvarSelector() {
		int cvarArmorMode = LemonUtil.CVAR_GetInt("hxdd_armor_mode", PSAT_DEFAULT);
        PlayerInfo p = players[0];
        Progression prog = Progression(p.mo.FindInventory("Progression"));
		if (prog) {
			if (cvarArmorMode == PSAT_DEFAULT) {
				cvarArmorMode = prog.ArmorType;
            }
		}
        if (cvarArmorMode == PSAT_ARMOR_SIMPLE) {
            return "SilverShield";
		} else {
            return "SimpleHexenArmorSelectorTier1";
        }
    }
    override void Bind() {
        self.CvarSelect = true;
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "SilverShield";
        self.Corvus = "SilverShield";
        self.Fighter = "SimpleHexenArmorSelectorTier1";
        self.Cleric = "SimpleHexenArmorSelectorTier1";
        self.Mage = "SimpleHexenArmorSelectorTier1";
        self.Paladin = "SimpleHexenArmorSelectorTier1";
        self.Crusader = "SimpleHexenArmorSelectorTier1";
        self.Necromancer = "SimpleHexenArmorSelectorTier1";
        self.Assassin = "SimpleHexenArmorSelectorTier1";
        self.Succubus = "SimpleHexenArmorSelectorTier1";
    }
}

class MultiClassEnchantedShield : MultiSpawner {
    override String CvarSelector() {
		int cvarArmorMode = LemonUtil.CVAR_GetInt("hxdd_armor_mode", PSAT_DEFAULT);
        PlayerInfo p = players[0];
        Progression prog = Progression(p.mo.FindInventory("Progression"));
		if (prog) {
			if (cvarArmorMode == PSAT_DEFAULT) {
				cvarArmorMode = prog.ArmorType;
            }
		}
        if (cvarArmorMode == PSAT_ARMOR_SIMPLE) {
            return "EnchantedShield";
		} else {
            return "SimpleHexenArmorSelectorTier2";
        }
    }
    override void Bind() {
        self.CvarSelect = true;
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "EnchantedShield";
        self.Corvus = "EnchantedShield";
        self.Fighter = "SimpleHexenArmorSelectorTier2";
        self.Cleric = "SimpleHexenArmorSelectorTier2";
        self.Mage = "SimpleHexenArmorSelectorTier2";
        self.Paladin = "SimpleHexenArmorSelectorTier2";
        self.Crusader = "SimpleHexenArmorSelectorTier2";
        self.Necromancer = "SimpleHexenArmorSelectorTier2";
        self.Assassin = "SimpleHexenArmorSelectorTier2";
        self.Succubus = "SimpleHexenArmorSelectorTier2";
    }
}

