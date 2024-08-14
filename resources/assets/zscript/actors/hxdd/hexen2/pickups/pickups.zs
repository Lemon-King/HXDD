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


class HX2ArtiHealth : ArtiHealth {
	States {
        Spawn:
            0000 A -1;
            Loop;
        Pickup:
            TNT1 A 0 A_GiveInventory("ArtiHealth", 1);
            Stop;
	}
}

class HX2ArtiSuperHealth : ArtiSuperHealth  {
	States {
        Spawn:
            0000 A 350;
            Loop;
        Pickup:
            TNT1 A 0 A_GiveInventory("ArtiSuperHealth", 1);
            Stop;
	}
}

class HX2ArtiFly : ArtiFly {
    States {
        Spawn:
            0000 A -1;
            Stop;
    }
}

class HX2ArtiInvulnerability : ArtiInvulnerability2 {
    States {
        Spawn:
            0000 A -1;
            Stop;
    }
}

class HX2ArtiTomeOfPower : ArtiTomeOfPower {
    States {
        Spawn:
            0000 A -1;
            Stop;
    }
}

class HX2ArtiSpeedBoots : ArtiSpeedBoots {
    States {
        Spawn:
            0000 A -1;
            Stop;
    }
}

class HX2ArtiBlastRadius : ArtiBlastRadius {
    States {
        Spawn:
            0000 A -1;
            Stop;
    }
}

class HX2ArtiBoostMana : ArtiBoostMana {
    States {
        Spawn:
            0000 A -1;
            Stop;
    }
}

class HX2ArtiTorch : ArtiTorch {
    States {
        Spawn:
            0000 A -1;
            Stop;
    }
}

class HX2ArtiInvisibility : ArtiInvisibility {
    States {
        Spawn:
            0000 A -1;
            Stop;
    }
}

class HX2ArtiTeleport : ArtiTeleport {
    States {
        Spawn:
            0000 A -1;
            Stop;
    }
}