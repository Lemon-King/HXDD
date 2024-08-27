
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

    override void Tick() {
        Super.Tick();
        
        self.lightlevel = LemonActor.HX2RenderPickupGlow(self);
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

    override void Tick() {
        Super.Tick();
        
        self.lightlevel = LemonActor.HX2RenderPickupGlow(self);
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

    override void Tick() {
        Super.Tick();
        
        self.lightlevel = LemonActor.HX2RenderPickupGlow(self);
    }
}

// Big (2x Amount)
class HX2ManaBig1 : CustomInventory {
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
            TNT1 A 0 A_GiveInventory("Mana1", 30);
            Stop;
	}

    override void Tick() {
        Super.Tick();

        self.lightlevel = LemonActor.HX2RenderPickupGlow(self);
    }

}
class HX2ManaBig2 : CustomInventory {
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
            TNT1 A 0 A_GiveInventory("Mana2", 30);
            Stop;
	}

    override void Tick() {
        Super.Tick();

        self.lightlevel = LemonActor.HX2RenderPickupGlow(self);
    }
}
class HX2ManaBig3 : Mana3 {
	States {
        Spawn:
            0000 A -1 Bright;
            Loop;
        Pickup:
            TNT1 A 0 A_GiveInventory("Mana1", 40);
            TNT1 A 0 A_GiveInventory("Mana2", 40);
            Stop;
	}

    override void Tick() {
        Super.Tick();

        self.lightlevel = LemonActor.HX2RenderPickupGlow(self);
    }
}