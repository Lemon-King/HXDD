class HX2Armor : HexenArmor {
    override void Tick() {
        Super.Tick();
        
        self.lightlevel = LemonActor.HX2RenderPickupGlow(self);
    }
}

// Breastplate (1) -----------------------------------------------------------

class HX2Breastplate : HX2Armor {
	Default {
		+FLOATBOB
		+NOGRAVITY
		Health 0;	// Armor class
		Inventory.Amount 0;
		Inventory.PickupMessage "$HXDD.HEXEN2.PICKUP.ARMOR.BREASTPLATE";
	}
	States {
		Spawn:
			0000 A -1;
			Stop;
	}
}
	
// Bracers (2) --------------------------------------------------------

class HX2Bracers : HX2Armor {
	Default {
		+FLOATBOB
		+NOGRAVITY
		Health 1;	// Armor class
		Inventory.Amount 0;
		Inventory.PickupMessage "$HXDD.HEXEN2.PICKUP.ARMOR.BRACERS";
	}
	States {
		Spawn:
			0000 A -1;
			Stop;
	}
}

// Helmet (3) --------------------------------------------------------

class HX2Helmet : HX2Armor {
	Default {
		+FLOATBOB
		+NOGRAVITY
		Health 2;	// Armor class
		Inventory.Amount 0;
		Inventory.PickupMessage "$HXDD.HEXEN2.PICKUP.ARMOR.HELMET";
	}
	States {
		Spawn:
			0000 A -1;
			Stop;
	}
}

// Amulet of Protection (4) ----------------------------------------------------

class HX2Amulet : HX2Armor {
	Default {
		+FLOATBOB
		+NOGRAVITY
		Health 3;	// Armor class
		Inventory.Amount 0;
		Inventory.PickupMessage "$HXDD.HEXEN2.PICKUP.ARMOR.AMULET";
	}
	States {
		Spawn:
			0000 A -1;
			Stop;
	}
}

