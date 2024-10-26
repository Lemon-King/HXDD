
mixin class PlayerSlotShared {
	static double stats_compute(double min, double max) {
		double value = (max-min+1) * frandom[Stats](0.0, 1.0) + min;
		if (value > max) {
			return max;
		}
		value = ceil(value);
		return value;
	}

	static int GetEnumFromArmorType(String type) {
		type = type.MakeLower();
		Array<string> keysHXArmor = {"ac", "armorclass", "hexen", "hx"};
		Array<string> keysHX2Armor = {"ac2", "armorclass2", "hexen2", "hx2"};
		if (keysHXArmor.Find(type) != keysHXArmor.Size()) {
			return PSAT_ARMOR_HXAC;
		} else if (keysHX2Armor.Find(type) != keysHX2Armor.Size()) {
			return PSAT_ARMOR_HX2AC;
		} else {
			return PSAT_ARMOR_BASIC;
		}
	}

	static int GetEnumFromProgressionType(String type) {
		type = type.MakeLower();
		Array<string> keys = {"levels", "level", "leveling", "hexen2", "hx2"};
		if (keys.Find(type) != keys.Size()) {
			return PSP_LEVELS;
		} else {
			return PSP_NONE;
		}
	}

	String GetPlayerClassName() {
		let player = self.GetPlayer();
		String playerClassName = player.mo.GetClassName();
		if (playerClassName.IndexOf("HXDD") != -1) {
			playerClassName = player.mo.GetParentClass().GetClassName();
		}
		return playerClassName.MakeLower();
	}
}