
class HX2ArtiHealth : ArtiHealth {
    Default {
        Inventory.Icon "graphics/hexen2/arti01.png";
    }
	States {
        Spawn:
            0000 A -1;
            Loop;
	}
}

// Needs HX2 Matching Implementation
class HX2ArtiSuperHealth : ArtiSuperHealth  {
    Default {
        Inventory.Icon "graphics/hexen2/arti02.png";
    }
	States {
        Spawn:
            0000 A 350;
            Loop;
	}
}

// Needs HX2 Matching Implementation
class HX2ArtiFly : ArtiFly {
    Default {
        Inventory.PickupSound "hexen2/items/ringpkup";
        Inventory.Icon "graphics/hexen2/arti12.png";
    }
    States {
        Spawn:
            0000 A -1;
            Stop;
    }

    override bool Use(bool pickup) {
        let result = Super.Use(pickup);
        if (result) {
            Powerup power = Powerup(self.owner.FindInventory("PowerFlight"));
            if (power) {
                TextureID tex = TexMan.CheckForTexture("graphics/hexen2/rngfly1.png");
                if (tex.IsValid()) {
                    power.Icon = tex;
                }
            }
        }
        return result;
    }
}

class HX2ArtiInvulnerability : ArtiInvulnerability2 {
    Default {
        Inventory.Icon "graphics/hexen2/arti14.png";
    }
    States {
        Spawn:
            0000 A -1;
            Stop;
    }

    override bool Use(bool pickup) {
        let result = Super.Use(pickup);
        if (result) {
            Powerup power = Powerup(self.owner.FindInventory("PowerInvulnerable"));
            if (power) {
                TextureID tex = TexMan.CheckForTexture("graphics/hexen2/durshd1.png");
                if (tex.IsValid()) {
                    power.Icon = tex;
                }
            }
        }
        return result;
    }
}

class HX2ArtiTomeOfPower : ArtiTomeOfPower {
    Default {
        Inventory.Icon "graphics/hexen2/arti05.png";
    }
    States {
        Spawn:
            0000 A -1;
            Stop;
    }

    override bool Use(bool pickup) {
        let result = Super.Use(pickup);
        if (result) {
            Powerup power = Powerup(self.owner.FindInventory("PowerWeaponLevel2"));
            if (power) {
                TextureID tex = TexMan.CheckForTexture("graphics/hexen2/pwrbook1.png");
                if (tex.IsValid()) {
                    power.Icon = tex;
                }
            }
        }
        return result;
    }
}

class HX2ArtiSpeedBoots : ArtiSpeedBoots {
    Default {
        Inventory.Icon "graphics/hexen2/arti09.png";
    }
    States {
        Spawn:
            0000 A -1;
            Stop;
    }

    override bool Use(bool pickup) {
        let result = Super.Use(pickup);
        if (result) {
            Powerup power = Powerup(self.owner.FindInventory("PowerSpeed"));
            if (power) {
                TextureID tex = TexMan.CheckForTexture("graphics/hexen2/durhst1.png");
                if (tex.IsValid()) {
                    power.Icon = tex;
                }
            }
        }
        return result;
    }
}

class HX2ArtiBlastRadius : ArtiBlastRadius {
    Default {
        Inventory.Icon "graphics/hexen2/arti10.png";
    }
    States {
        Spawn:
            0000 A -1;
            Stop;
    }
}

class HX2ArtiBoostMana : ArtiBoostMana {
    Default {
        Inventory.Icon "graphics/hexen2/arti03.png";
    }
    States {
        Spawn:
            0000 A -1;
            Stop;
    }
}

// Needs HX2 Matching Implementation
class HX2ArtiTorch : ArtiTorch {
    Default {
        Inventory.Icon "graphics/hexen2/arti00.png";
        Powerup.Type "HX2PowerTorch";
    }
    States {
        Spawn:
            0000 A -1;
            Stop;
    }
    override bool Use(bool pickup) {
        if (CurSector.MoreFlags & Sector.SECMF_UNDERWATERMASK) {
            return false;
        }
        let result = Super.Use(pickup);
        return result;
    }
}

class HX2ArtiInvisibility : ArtiInvisibility {
    Default {
        Inventory.Icon "graphics/hexen2/arti07.png";
    }
    States {
        Spawn:
            0000 A -1;
            Stop;
    }
}

class HX2ArtiTeleport : ArtiTeleport {
    Default {
        Inventory.Icon "graphics/hexen2/arti04.png";
    }
    States {
        Spawn:
            0000 A -1;
            Stop;
    }
}