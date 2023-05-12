

class H2HolyStrength: HXDDPowerupSphere {
    ParticleGenerator pg;

	Default {
        Inventory.PickupMessage "$TXT_H2HOLYSTRENGTH";
        Tag "$TAG_H2HOLYSTRENGTH";

        HXDDPowerupSphere.alignmentType "Good";
	}

    override void PostBeginPlay() {
        Super.PostBeginPlay();

		Actor sphere = Spawn("H2PowerupSphere_GoodSphere", pos);
		Actor symbol = Spawn("H2PowerupSphere_Cross", pos);
        sphere.angle = self.angle;
        symbol.angle = self.angle;
        AttachedActorsAdd(sphere);
        AttachedActorsAdd(symbol);

        // NOT FINAL, NOT ACCURATE
        double ft = tickDuration / 32;
        pg = ParticleGenerator(Spawn("ParticleGenerator"));
        pg.Attach(self);
        pg.lifetime = 0.5;
        pg.color[0] = (156, 88, 8);  // can't ramp with basic gzdoom particles, use actor particles?
        pg.color[1] = (248, 220, 120);
        pg.origin[0] = (-ft, -ft, -25);
        pg.origin[1] = (ft, ft, -25);
        pg.velocity[0] = (-1.44 - ft, -1.44 - ft, -65);
        pg.velocity[1] = (-1.44 + ft, -1.44 + ft, -35);
        pg.startalpha = 1.0;
        pg.sizestep = 0.05;
		pg.flag_fullBright = true;
    }

    override void Tick() {
        Super.Tick();

        double scale = self.Scale.x;
        double ft = self.Default.tickDuration / 32;
        pg.origin[0] = (-ft * scale, -ft * scale, -20 * scale);
        pg.origin[1] = (ft * scale, ft * scale, -20 * scale);
    }

    override void OnGoodPickup(Actor toucher) {
        self.A_StartSound("hexen2/items/artpkup");
        PlayerPawn player = PlayerPawn(toucher);
        bool success = player.A_GiveInventory("PowerHolyStrength");
        if (!success) {
            return;
        }
        if (player.FindInventory("PowerHolyStrength")) {
            PowerHolyStrength powerup = PowerHolyStrength(player.FindInventory("PowerHolyStrength"));
            powerup.EffectTics += floor(self.tickDuration);    // Remaining time is added
            powerup.super_damage = 1;
        }
    }

    override void OnEvilPickup(Actor toucher) {
        toucher.DamageMobj(self, self, 5, "Fire", DMG_NO_ARMOR | DMG_THRUSTLESS);
    }

    override void OnNeutralPickup(Actor toucher) {
        self.A_StartSound("hexen2/items/artpkup");

        // Give Health
        int amountHealth = floor((1000.0 / 35.0) / tickDuration);
        HealThing(amountHealth);

        // Give Ammo
        int amount = floor((1000.0 / 35.0) / tickDuration);
        self.GiveAmmoAmount(toucher, amount);
    }
}


class H2SoulSphere: HXDDPowerupSphere {
    ParticleGenerator pg;

	Default {
        Inventory.PickupMessage "$TXT_H2SOULSPHERE";
        Tag "$TAG_H2SOULSPHERE";

        HXDDPowerupSphere.alignmentType "Evil";
	}

    override void PostBeginPlay() {
        Super.PostBeginPlay();

		Actor sphere = Spawn("H2PowerupSphere_EvilSphere", pos);
		Actor symbol = Spawn("H2PowerupSphere_Skull", pos);
        sphere.angle = self.angle;
        symbol.angle = self.angle;
        AttachedActorsAdd(sphere);
        AttachedActorsAdd(symbol);

        // NOT FINAL, NOT ACCURATE
        double ft = tickDuration / 32;
        pg = ParticleGenerator(Spawn("ParticleGenerator"));
        pg.Attach(self);
        pg.lifetime = 0.5;
        pg.color[0] = (100, 0, 0);  // can't ramp with basic gzdoom particles, use actor particles?
        pg.color[1] = (252, 0, 0);
        pg.origin[0] = (-ft, -ft, -20);
        pg.origin[1] = (ft, ft, -20);
        pg.velocity[0] = (-1.44 - ft, -1.44 - ft, -65);
        pg.velocity[1] = (-1.44 + ft, -1.44 + ft, -35);
        pg.startalpha = 1.0;
        pg.sizestep = 0.05;
		pg.flag_fullBright = true;
    }

    override void Tick() {
        Super.Tick();

        double scale = self.Scale.x;
        double ft = self.Default.tickDuration / 32;
        pg.origin[0] = (-ft * scale, -ft * scale, -20 * scale);
        pg.origin[1] = (ft * scale, ft * scale, -20 * scale);
    }

    override void OnGoodPickup(Actor toucher) {
        toucher.DamageMobj(self, self, 5, "Fire", DMG_NO_ARMOR | DMG_THRUSTLESS);
    }

    override void OnEvilPickup(Actor toucher) {
        self.A_StartSound("hexen2/items/artpkup");

        // Give Health
        int amountHealth = floor((1000.0 / 35.0) / tickDuration) * 2;
        HealThing(amountHealth);

        // Give Ammo
        int amount = 15 + floor((1000.0 / 35.0) / tickDuration);
        self.GiveAmmoAmount(toucher, amount);
    }

    override void OnNeutralPickup(Actor toucher) {
        self.A_StartSound("hexen2/items/artpkup");

        // Give Health
        int amountHealth = floor((1000.0 / 35.0) / tickDuration);
        HealThing(amountHealth);

        // Give Ammo
        int amount = floor((1000.0 / 35.0) / tickDuration);
        self.GiveAmmoAmount(toucher, amount);
    }
}

class H2PowerupSphere_GoodSphere: Actor {
    Default {
        +NOGRAVITY
		+ZDOOMTRANS

		RenderStyle "Translucent";

        Alpha 0.4;
    }
	States {
        Spawn:
		    BALL A 1 Bright;
            Loop;
	}
}
class H2PowerupSphere_Cross: Actor {
    Default {
        +NOGRAVITY
    }
	States {
        Spawn:
		    CRSS A 1 Bright;
            Loop;
	}

    override void Tick() {
        Super.Tick();
        self.angle += 200.0 / 32.0;
    }
}

class H2PowerupSphere_EvilSphere: Actor {
    Default {
        +NOGRAVITY
		+ZDOOMTRANS

		RenderStyle "Translucent";

        Alpha 0.4;
    }
	States {
        Spawn:
		    BALL A 1 Bright;
            Loop;
	}
}
class H2PowerupSphere_Skull: Actor {
    Default {
        +NOGRAVITY
    }
	States {
        Spawn:
		    SKLL A 1 Bright;
            Loop;
	}

    override void Tick() {
        Super.Tick();
        self.angle += 200.0 / 32.0;
    }
}

class HXDDPowerupSphere: Inventory {
    mixin AttachedActors;

	double tickDuration;
	property tickDuration: tickDuration;

    double floatDir;

    String alignmentType;
	property alignmentType: alignmentType;

	Default {
        +NOGRAVITY;
        +FLOAT;
        +DONTSPLASH;
        +CANNOTPUSH;
        +NOTELEPORT;

        Speed 5;

        Inventory.PickupSound "none";
        Inventory.PickupMessage "$TXT_ARTISUPERHEALTH"; // "MYSTIC URN"
        Tag "$TAG_ARTISUPERHEALTH";

        HXDDPowerupSphere.tickDuration 428.5714285714286; // ~15 seconds
	}

	States {
        Spawn:
		    TNT1 A 1 A_Tracer(16.875);
            Loop;
	}

    override void BeginPlay() {
        floatDir = 1 / 32.0;
        self.A_ChangeVelocity(0,0, floatDir, CVF_REPLACE);
    }

    override void PostBeginPlay() {
        Super.PostBeginPlay();
        if (self.pos.z == self.floorz) {
            Vector3 nextPos = self.pos;
            nextPos.z += 32;
            SetOrigin(nextPos, false);
        }
    }

	override void Tick() {
		Super.Tick();

		if (InStateSequence(CurState, self.Findstate("Death"))) {
			return;
		}
		if (tickDuration <= 0) {
            AttachedActorsRemoveAll();
			Destroy();
		}

		tickDuration -= 1.0f;

        // Why not +FLOATBOB?
        // This replicates Hexen II's own Velocity Float Bob.
        double maxVelocity = 0.5; //16.0 / 32.0;
        if (self.pos.z - self.floorz < 32.0) {
            if (self.vel.z < maxVelocity) {
                floatDir = 1 / 32.0;
            }
        } else if (self.pos.z - self.floorz > 48.0) {
            if (abs(self.vel.z) < maxVelocity / 3) {
                floatDir = -1 / 64.0;
            }
        } else if (self.vel.z > maxVelocity) {
            floatDir = -1 / 32.0;
        } else if (self.vel.z < -maxVelocity) {
            floatDir = 1 / 32.0;
        }

        self.A_ChangeVelocity(0,0, self.target ? floatDir : self.vel.z + floatDir, self.target ? CVF_RELATIVE : CVF_REPLACE);

        int radius = 128;
        if (!self.target) {
            BlockThingsIterator it = BlockThingsIterator.Create(self, radius);
            while (it.Next()) {
                Actor mo = it.thing;
                if (!mo || !mo.bSolid || Distance2D(mo) > radius) {
                    continue;
                }

                if (mo is "PlayerPawn") {
                    Progression prog = Progression(mo.FindInventory("Progression"));
                    if (prog) {
                        if (prog.Alignment == self.alignmentType) {
                            self.target = mo;
                            break;
                        }
                    }
                }
            }
        }

        if (self.target && Distance2D(self.target) > radius) {
            self.target = null;
        }

        if (tickDuration <= 45.0) {
            double nextScale = tickDuration / 45.0;
            self.Scale.x = nextScale;
            self.Scale.y = nextScale;
        }

        for (int i = 0; i < self.attActors.Size(); i++) {
            Actor attachedActor = self.attActors[i];
            //attachedActor.angle = self.angle;
            attachedActor.pitch = self.pitch;
            attachedActor.roll = self.roll;
            attachedActor.Scale.x = self.Scale.x;
            attachedActor.Scale.y = self.Scale.y;
            attachedActor.SetOrigin(self.pos, true);
        }
	}

    override bool TryPickup(in out Actor toucher) {
        Progression prog = Progression(toucher.FindInventory("Progression"));
        if (prog) {
            if (prog.Alignment == "Good") {
                OnGoodPickup(toucher);
            } else if (prog.Alignment == "Evil") {
                OnEvilPickup(toucher);
            } else {
                OnNeutralPickup(toucher);
            }
        } else {
            OnNeutralPickup(toucher);
        }
        AttachedActorsRemoveAll();
        GoAwayAndDie();
        return true;
    }

    virtual void OnGoodPickup(Actor toucher) {}
    virtual void OnEvilPickup(Actor toucher) {}
    virtual void OnNeutralPickup(Actor toucher) {}

    void GiveAmmoAmount(Actor player, int amount) {
        Inventory next;
        for (Inventory item = player.Inv; item != NULL; item = next) {
            next = item.Inv;

            let invItem = player.FindInventory(item.GetClass());
            if (invItem != NULL && invItem is "Ammo") {
                Ammo ammoItem = Ammo(invItem);
                if (ammoItem) {
                    player.A_GiveInventory(invItem.GetClassName(), amount);
                }
            }
        }
    }

    // Based on Rev A_Tracer2
	void A_Tracer(double traceang = 19.6875) {
        if (!self.target) {
            return;
        }

		double dist;
		double slope;
		
		if (!self.target || self.target.health <= 0 || Speed == 0 || !CanSeek(self.target))
			return;
	
		self.angle = AngleTo(self.target);
		VelFromAngle();

		if (!bFloorHugger && !bCeilingHugger) {
			dist = DistanceBySpeed(self.target, Speed);

			if (self.target.Height >= 56.) {
				slope = (self.target.pos.z + 40. - pos.z) / dist;
			} else {
				slope = (self.target.pos.z + Height*(2./3) - pos.z) / dist;
			}

			if (slope < Vel.Z)
				Vel.Z -= 1. / 8;
			else
				Vel.Z += 1. / 8;
		}
	}
}