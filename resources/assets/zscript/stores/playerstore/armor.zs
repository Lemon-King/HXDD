mixin class PlayerSlotArmor {
	String GetActiveArmorType() {
		if (self.armortype == PSAT_ARMOR_HXAC || self.armortype == PSAT_ARMOR_HXAC_RANDOM) {
			return "ac,armorclass,hexen,hx";
		} else if (self.armortype == PSAT_ARMOR_HX2AC || self.armortype == PSAT_ARMOR_HX2AC_RANDOM) {
			return "ac2,armorclass2,hexen2,hx2";
		}
		return "basic,doom,heretic";
	}

	void ArmorModeSelection() {
		if (ArmorSelected) {
			return;
		}
		let player = PlayerPawn(self.GetPlayer().mo);
		if (player == NULL) {
			return;
		}
		int optionArmorMode = LemonUtil.CVAR_GetInt("hxdd_armor_mode", PSAT_DEFAULT);
		if (optionArmorMode == PSAT_DEFAULT) {
			optionArmorMode = self.ArmorType;
		}
		
		if (optionArmorMode == PSAT_ARMOR_BASIC) {
			ArmorModeSelection_Basic(player);
		} else if (optionArmorMode == PSAT_ARMOR_HXAC) {
			ArmorModeSelection_HXAC(player);
		} else if (optionArmorMode == PSAT_ARMOR_HX2AC) {
			ArmorModeSelection_HX2AC(player);
		} else if (optionArmorMode == PSAT_ARMOR_HXAC_RANDOM) {
			ArmorModeSelection_HXAC_Random(player);
		} else if (optionArmorMode == PSAT_ARMOR_USER) {
			ArmorModeSelection_User(player);
		}

		self.ActiveArmorType = self.GetActiveArmorType();
		
		ArmorSelected = true;
	}

	HexenArmor FindOrGivePlayerHexenArmor(PlayerPawn player) {
		Array<int> defaultHexenArmorTable = {10, 15, 15, 15, 15};
		let hasHexenArmor = true;
		let itemHexenArmor = HexenArmor(player.FindInventory("HexenArmor"));
		if (itemHexenArmor == null) {
			self.GetPlayer().mo.GiveInventory("HexenArmor", 1);
			itemHexenArmor = HexenArmor(player.FindInventory("HexenArmor"));
			hasHexenArmor = false;
		}
		if (!hasHexenArmor || hexenArmorTable.Size() == 5) {
			if (hexenArmorTable.Size() == 5) {
				itemHexenArmor.Slots[4] = hexenArmorTable[0];
			} else {
				itemHexenArmor.Slots[4] = defaultHexenArmorTable[0];
			}
			for (int i = 0; i < 4; i++) {
				itemHexenArmor.SlotsIncrement[i] = hexenArmorTable.Size() == 5 ? hexenArmorTable[i+1] : defaultHexenArmorTable[i+1];
			}
		}
		return itemHexenArmor;
	}

	void ArmorModeSelection_Basic(PlayerPawn player) {
		// Remove Hexen AC armor Values to force basic armor mechanics
		let itemHexenArmor = FindOrGivePlayerHexenArmor(player);
		if (itemHexenArmor) {
			for (int i = 0; i < 5; i++) {
				itemHexenArmor.Slots[i] = 0;
			}
			for (int i = 0; i < 4; i++) {
				itemHexenArmor.SlotsIncrement[i] = 0;
			}
			self.ArmorType = PSAT_ARMOR_BASIC;
		}
	}
	void ArmorModeSelection_HXAC(PlayerPawn player) {
		// ensure the class has hexen armor values, if not fill with defaults
		let itemHexenArmor = FindOrGivePlayerHexenArmor(player);
		if (itemHexenArmor) {
			int totalArmor = itemHexenArmor.Slots[4];
			for (int i = 0; i < 4; i++) {
				totalArmor += itemHexenArmor.SlotsIncrement[i];
			}
			if (totalArmor == 0) {
				// no armor, use random instead
				ArmorModeSelection_HXAC_Random(player);
			}
			self.ArmorType = PSAT_ARMOR_HXAC;
		}
	}
	void ArmorModeSelection_HX2AC(PlayerPawn player) {
		// ensure the class has hexen armor values, if not fill with defaults
		let itemHexenArmor = FindOrGivePlayerHexenArmor(player);
		if (itemHexenArmor) {
			int totalArmor = itemHexenArmor.Slots[4];
			for (int i = 0; i < 4; i++) {
				totalArmor += itemHexenArmor.SlotsIncrement[i];
			}
			if (totalArmor == 0) {
				// no armor, use random instead
				ArmorModeSelection_HXAC_Random(player);
			}
			self.ArmorType = PSAT_ARMOR_HX2AC;
		}
	}
	void ArmorModeSelection_HXAC_Random(PlayerPawn player) {
		// ensure the class has hexen armor values, if not fill with defaults
		let itemHexenArmor = FindOrGivePlayerHexenArmor(player);
		if (itemHexenArmor) {
			itemHexenArmor.Slots[4] = random(0,3) * 5;
			for (int i = 0; i < 4; i++) {
				int amount = random(1,4) * 5;
				itemHexenArmor.SlotsIncrement[i] = amount;
			}
			self.ArmorType = PSAT_ARMOR_HXAC;
		}
	}
	void ArmorModeSelection_HX2AC_Random(PlayerPawn player) {
		// TODO
	}
	void ArmorModeSelection_User(PlayerPawn player) {
		let itemHexenArmor = FindOrGivePlayerHexenArmor(player);
		if (itemHexenArmor) {
			// unset all
			for (int i = 0; i < 5; i++) {
				itemHexenArmor.Slots[i] = 0;
			}
			itemHexenArmor.Slots[4] = LemonUtil.CVAR_GetInt("hxdd_armor_user_4", 10);
			for (int i = 0; i < 4; i++) {
				String cvarHexenArmorSlot = String.format("hxdd_armor_user_%d", i);
				itemHexenArmor.SlotsIncrement[i] = LemonUtil.CVAR_GetInt(cvarHexenArmorSlot, 20);
			}
		}
		self.ArmorType = PSAT_ARMOR_HXAC;
	}
}