class MultiClassMeshArmor : MultiSpawner {
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
            return "MeshArmor";
        }
    }
    override void Bind() {
        self.CvarSelect = true;
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "MeshArmor";
        self.Corvus = "EnchantedShield";
        self.Fighter = "MeshArmor";
        self.Cleric = "MeshArmor";
        self.Mage = "MeshArmor";
        self.Paladin = "MeshArmor";
        self.Crusader = "MeshArmor";
        self.Necromancer = "MeshArmor";
        self.Assassin = "MeshArmor";
        self.Succubus = "MeshArmor";
    }
}

class MultiClassPlatinumHelm : MultiSpawner {
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
            return "PlatinumHelm";
        }
    }
    override void Bind() {
        self.CvarSelect = true;
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "PlatinumHelm";
        self.Corvus = "SilverShield";
        self.Fighter = "PlatinumHelm";
        self.Cleric = "PlatinumHelm";
        self.Mage = "PlatinumHelm";
        self.Paladin = "PlatinumHelm";
        self.Crusader = "PlatinumHelm";
        self.Necromancer = "PlatinumHelm";
        self.Assassin = "PlatinumHelm";
        self.Succubus = "PlatinumHelm";
    }
}

class MultiClassAmuletOfWarding : MultiSpawner {
    override String CvarSelector() {
		int cvarArmorMode = LemonUtil.CVAR_GetInt("hxdd_armor_mode", PSAT_DEFAULT);
        PlayerInfo p = players[0];
        Progression prog = Progression(p.mo.FindInventory("Progression"));
		if (prog) {
			if (cvarArmorMode == PSAT_DEFAULT) {
				cvarArmorMode = prog.ArmorType;
			} else {
                return "Unknown";
                //cvarArmorMode = PSAT_ARMOR_AC;
            }
		} else if (cvarArmorMode == PSAT_DEFAULT) {
			cvarArmorMode = PSAT_ARMOR_AC;
		}
        if (cvarArmorMode == PSAT_ARMOR_SIMPLE) {
            return "SilverShield";
		} else {
            return "AmuletOfWarding";
        }
    }
    override void Bind() {
        self.CvarSelect = true;
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "AmuletOfWarding";
        self.Corvus = "SilverShield";
        self.Fighter = "AmuletOfWarding";
        self.Cleric = "AmuletOfWarding";
        self.Mage = "AmuletOfWarding";
        self.Paladin = "AmuletOfWarding";
        self.Crusader = "AmuletOfWarding";
        self.Necromancer = "AmuletOfWarding";
        self.Assassin = "AmuletOfWarding";
        self.Succubus = "AmuletOfWarding";
    }
}

class MultiClassFalconShield : MultiSpawner {
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
            return "FalconShield";
        }
    }
    override void Bind() {
        self.CvarSelect = true;
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "FalconShield";
        self.Corvus = "EnchantedShield";
        self.Fighter = "FalconShield";
        self.Cleric = "FalconShield";
        self.Mage = "FalconShield";
        self.Paladin = "FalconShield";
        self.Crusader = "FalconShield";
        self.Necromancer = "FalconShield";
        self.Assassin = "FalconShield";
        self.Succubus = "FalconShield";
    }
}