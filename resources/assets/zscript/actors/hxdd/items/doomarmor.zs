
class HXDDBodyArmorTest : HXDDArmor {
	Default {
		+NOGRAVITY
		Health 100;	// Armor class
		HXDDArmor.SavePercent 15;
		HXDDArmor.SaveAmount 25;
		HXDDArmor.Type "hexen2";

		Inventory.Amount 0;
		Inventory.PickupMessage "[PH] Body Armor";
	}
	States {
        Spawn:
            ARM1 A 6 A_SetTranslation("HXDD_ArmorMode_HX_Doom_Helm_Placeholder");
            ARM1 B 6 bright A_SetTranslation("none");
            loop;
	}
}

class HXDDBodyArmorTest2 : HXDDArmor {
	Default {
		+NOGRAVITY
		Health 100;	// Armor class
		HXDDArmor.SavePercent 15;
		HXDDArmor.SaveAmount 30;
		HXDDArmor.type "hexen2";

		Inventory.Amount 0;
		Inventory.PickupMessage "[PH] Body Armor";
	}
	States {
        Spawn:
            ARM1 A 6 A_SetTranslation("HXDD_ArmorMode_HX_Doom_Helm_Placeholder");
            ARM1 B 6 bright A_SetTranslation("none");
            loop;
	}
}

class HXDDBodyArmor : HexenArmor {
	Default {
		+NOGRAVITY
		Health 0;	// Armor class
		Inventory.Amount 0;
		Inventory.PickupMessage "[PH] Body Armor";
	}
	States {
        Spawn:
            ARM2 A 6;
            ARM2 B 6 bright;
            loop;
	}
}

class HXDDHeavyBoots : HexenArmor {
	Default {
		+NOGRAVITY
		Health 1;	// Armor class
		Inventory.Amount 0;
		Inventory.PickupMessage "[PH] Heavy Boots";
	}
	States {
        Spawn:
            BOOT A 6 A_SetTranslation("none");
            BOOT A 6 Bright A_SetTranslation("HXDD_ArmorMode_HX_Doom_Boots_Frame2");
            loop;
	}
}

class HXDDCombatHelm : HexenArmor {
	Default {
		+NOGRAVITY
		Health 2;	// Armor class
		Inventory.Amount 0;
		Inventory.PickupMessage "[PH] Combat Helm";
	}
	States {
        Spawn:
            AHLM A 6 A_SetTranslation("HXDD_ArmorMode_HX_Doom_Helm_Frame1");
            AHLM A 6 Bright A_SetTranslation("HXDD_ArmorMode_HX_Doom_Helm_Frame2");
            loop;
	}
}

class HXDDUnderArmor : HexenArmor {
	Default {
		+NOGRAVITY
		Health 3;	// Armor class
		Inventory.Amount 0;
		Inventory.PickupMessage "[PH] Underarmor";
	}
	States {
        Spawn:
            UNIF A 6 A_SetTranslation("none");
            UNIF A 6 Bright A_SetTranslation("HXDD_ArmorMode_HX_Doom_UnderArmor_Frame2");
            loop;
	}
}
