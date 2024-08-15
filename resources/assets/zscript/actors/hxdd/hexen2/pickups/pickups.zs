// Hexen II Pickups
// Some may be simple model swaps

class HX2CrystalVial : CrystalVial {
	States {
        Spawn:
            0000 A -1;
            Loop;
        Pickup:
            TNT1 A 0 A_GiveInventory("CrystalVial", 1);
            Stop;
	}
}