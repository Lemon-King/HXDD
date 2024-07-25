
class HX2Mana1 : CustomInventory {
	Default {
		Radius 8;
		Height 8;
		+FLOATBOB
		Inventory.PickupMessage "$TXT_MANA_1";
	}
	States {
        Spawn:
            0000 A -1 Bright;
            Loop;
        Pickup:
            TNT1 A 0 A_GiveInventory("Mana1", 15);
            Stop;
	}

}
class HX2Mana2 : CustomInventory {
	Default {
		Radius 8;
		Height 8;
		+FLOATBOB
		Inventory.PickupMessage "$TXT_MANA_2";
	}
	States {
        Spawn:
            0000 A -1 Bright;
            Loop;
        Pickup:
            TNT1 A 0 A_GiveInventory("Mana2", 15);
            Stop;
	}
}
class HX2Mana3 : Mana3 {
	States {
        Spawn:
            0000 A -1 Bright;
            Loop;
        Pickup:
            TNT1 A 0 A_GiveInventory("Mana1", 20);
            TNT1 A 0 A_GiveInventory("Mana2", 20);
            Stop;
	}
}