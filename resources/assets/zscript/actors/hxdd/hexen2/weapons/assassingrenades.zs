// Assassin Weapon: Grenades
// It works, but feels extremely overpowered in its current state when using a tome

class AWeapGrenades : AssassinWeapon {
	Default {
		Weapon.SelectionOrder 1000;
		Weapon.KickBack 150;
		Weapon.YAdjust 0;
		Weapon.AmmoType1 "Mana2";
		Weapon.AmmoUse 3;
		Weapon.AmmoGive 100;
		+BLOODSPLATTER
		+FLOATBOB
		Obituary "$OB_MPAWEAPGRENADES";
		Tag "$TAG_AWEAPGRENADES";

		FloatBobStrength 0.25;
	}

    States {
        Spawn:
            PKUP A -1;
            Stop;
        Select:
            TNT1 A 0 Offset(0, 32);
            AGRS ABCDEF 2;
            AGRI A 0 A_Raise(100);
            Loop;
        Deselect:
            AGRI A 0;
            AGRS FEDCBA 2;
            TNT1 A 0 A_Lower(100);
            Loop;
        Ready:
            AGRI A 1 A_WeaponReady;
            Loop;
        Fire:
            AGRT A 2 A_ResetCharge;
            AGRT BC 2;
            Goto Charge;
        Charge:
            AGRT D 2 A_Charge;
            AGRT D 0 A_ReFire("Charge");
            Goto Throw;
        Throw:
            AGRT E 2;
            AGRT FGHI 2;
            AGRT J 2 A_Throw;
            AGRT KL 2;
            Goto Ready;
    }

    action void A_ResetCharge() {
        self.weaponspecial = 0;
    }

    action void A_Charge() {
        self.weaponspecial++;
    }

    action void A_Throw() {
		if (player == null) {
			return;
		}

		Weapon weapon = player.ReadyWeapon;
        bool hasTome = Player.mo.FindInventory("PowerWeaponLevel2", true);
        if (hasTome) {
            weapon.AmmoUse1 = 12;
        } else {
            weapon.AmmoUse1 = 3;
        }

        if (!weapon.DepleteAmmo(weapon.bAltFire)) {
            return;
        }

		A_StartSound("hexen2/misc/whoosh", CHAN_WEAPON, CHANF_OVERLAP);
        Actor proj;
        if (hasTome) {
		    proj = SpawnFirstPerson("AWeapGrenades_Grenade", 10, 10, 2, false, 0, 10);
            AWeapGrenades_Grenade(proj).isSuperGrenade = true;
            AWeapGrenades_Grenade(proj).isModified = true;
            proj.Scale = (2.0, 2.0);
        } else {
			proj = SpawnFirstPerson("AWeapGrenades_Grenade", 10, 10, 2, false, 0, 10);
		}
        if (proj) {
            AWeapGrenades_Grenade(proj).throwPower = self.weaponspecial;
        }
        self.weaponspecial = 0;
    }
}

class AWeapGrenades_Grenade_Explode: Actor {
	Default {
		+NOBLOCKMAP;
		+NOGRAVITY;
		+NOINTERACTION;
		+NOCLIP;
		+ZDOOMTRANS;
        +FORCEXYBILLBOARD;

		RenderStyle "Add";
		Alpha 1.0;

		Height 0;
		Radius 0;
	}

	States {
		Spawn:
            GENE ABCDEFGHIJKL 2 Bright;
			Stop;
	}
}
class AWeapGrenades_Grenade_ExplodeFloor: AWeapGrenades_Grenade_Explode {
	States {
		Spawn:
            FLEX ABCDEFGHIJKLMNOPQRST 3 Bright;
			Stop;
	}
}
class AWeapGrenades_Grenade_SM_Explode: AWeapGrenades_Grenade_Explode {
	States {
		Spawn:
            SMEX ABCDEFGHIJKL 3 Bright;
			Stop;
	}
}


class AWeapGrenades_Grenade: Hexen2Projectile {
    bool isSuperGrenade;            // original, will break gzdoom
    bool isModified;                // modified super grenade, won't break gzdoom

	double tickDuration;
	property tickDuration: tickDuration;

	double damageMulti;

	int bounces;
	property bounces: bounces;

    int throwPower;

	Vector3 avelocity;

	Default {
		// https://zdoom.org/wiki/Actor_properties#BounceType

		+HITTRACER;
		+SPAWNSOUNDSOURCE;
		+USEBOUNCESTATE;
		+BOUNCEONCEILINGS;
		+CANBOUNCEWATER;
		+DONTBOUNCEONSKY;
        -NOGRAVITY;
        +NOBLOCKMAP;
        +DROPOFF;
        +MISSILE;
        +ACTIVATEIMPACT;
        +ACTIVATEPCROSS;
        +NOTELEPORT;
        +FORCERADIUSDMG;
		
		DamageFunction 0;
		Bouncetype "Grenade";
        DamageType "Fire";

        Friction 0;
        BounceFactor 0.5;

        Health 3;
		Speed 15.625;
		Radius 5;
		Height 5;
        Gravity 1.0;
        Scale 0.77;
		BounceSound "hexen2/assassin/gbounce";
		WallBounceSound "hexen2/assassin/gbounce";
		DeathSound "hexen2/weapons/explode";
		Obituary "$OB_MPMWEAPFROST";

        AWeapGrenades_Grenade.tickDuration (2.0 * TICRATEF);
	}

	States {
		Spawn:
			GREN A 1;
			Loop;
		Bounce:
			GREN A 0 A_OnBounce();
			Goto Spawn;
		Death:
            TNT1 A 0 A_ExplodeAndDamage;
			Stop;

	}

    override void BeginPlay() {
        Super.BeginPlay();

        self.avelocity.x = frandom(-300.0,300.0) / 32.0;
        self.avelocity.y = frandom(-300.0,300.0) / 32.0;
        self.avelocity.z = frandom(-300.0,300.0) / 32.0;

        pg = ParticleGenerator(Spawn("ParticleGenerator"));
        pg.Attach(self);
        pg.color[0] = (224, 224, 224);
        pg.color[1] = (252, 252, 252);
        pg.origin[0] = (-3, -3, -3);
        pg.origin[1] = (3, 3, 3);
        pg.velocity[0] = (-1, -1, -1);
        pg.velocity[1] = (1, 1, 0);
        pg.amount = 4;
        pg.size = 5;
        pg.lifetime = 0.8;
        pg.startalpha = 0.5;
        pg.sizestep = 0.05;
    }

    override void PostBeginPlay() {
        Super.PostBeginPlay();
        self.Speed = (500.0f + (self.throwPower * 10.0)) / 32.0;

        self.A_ChangeVelocity(0, 0, 200.0 / 32.0, CVF_RELATIVE);
    }

	override void Tick() {
		Super.Tick();

        if (self.Speed != 0) {
            self.angle += avelocity.x;
            self.pitch += avelocity.y;
            self.roll += avelocity.z;
        }

        if (self.Speed != 0 && self.vel.z == 0) {
            self.Speed = 0;
            self.A_ScaleVelocity(0);
            if (pg) {
                pg.Remove();
            }
        }

		if (tickDuration <= 0) {
            A_ExplodeAndDamage();
            self.Destroy();
		}

		self.tickDuration -= 1.0;
	}

	void A_OnBounce() {
		if (self.tracer && (self.tracer.bIsMonster || self.tracer.bShootable)) {
            A_ExplodeAndDamage();
            self.Destroy();
		}
	}

    void A_ExplodeAndDamage() {
        double ex_damage = 100;
        // Super grenade
        // Rendering for explosions is set to RENDER_Normal for performance
        if (self.isSuperGrenade) {
            ex_damage = 250.0 * (0.7 + frandom(0.0, 0.2));

            int count_explosions;
            if (self.isModified) {
                count_explosions = random(3,6);
            } else {
                count_explosions = random(3,6);
            }
            for (int i = 0; i < count_explosions; i++) {
                AWeapGrenades_SuperGrenade gren = AWeapGrenades_SuperGrenade(Spawn("AWeapGrenades_SuperGrenade"));
                gren.SetOrigin(self.pos, false);
                gren.isModified = self.isModified;
                gren.ex_damage = ex_damage;
                gren.ticNextExplosion = frandom(0.1, 0.6) * TICRATEF;
                gren.isMulti = (i == 0);
                
                double x;
                double y;
                double z;
                if (gren.isMulti) {
                    x = frandom(-40.0, 40.0) / 24.0;
                    y = frandom(-40.0, 40.0) / 24.0;
                    z = frandom(150.0, 300.0) / 24.0;

                    // TODO: Spawn A_QuakeEx as Entity
                    // https://github.com/videogamepreservation/hexen2/blob/eac5fd50832ce2509226761b3b1a387c468e7a50/H2W/HCode/quake.hc#L10
                    if (frandom(0.0, 1.0) < 0.3) {
                        int z = random(3,5);
                        int xy = random(1,3);
                        gren.A_QuakeEx(xy,xy,z, 35 * 3, 0, 800, "world/quake", QF_RELATIVE | QF_SCALEUP | QF_SCALEDOWN, 1,1,1, 1200);
                    }
                } else {
                    x = frandom(-300.0, 300.0) / 24.0;
                    y = frandom(-300.0, 300.0) / 24.0;
                    z = frandom(50.0, 150.0) / 24.0;
                }
                gren.A_ChangeVelocity(x,y,z,CVF_REPLACE);
            }
        }
        if ((self.pos.z - self.floorz) <= 0.0 && frandom(0.0, 1.0) > 0.5) {
            Actor ex = Spawn("AWeapGrenades_Grenade_ExplodeFloor");
            ex.SetOrigin((self.pos.x, self.pos.y, self.floorz + 64.0), false);
            A_StartSound("hexen2/weapons/explode", CHAN_WEAPON, 1.0);
        } else {
            Actor ex = Spawn("AWeapGrenades_Grenade_Explode");
            ex.SetOrigin(self.pos, false);
            A_StartSound("hexen2/weapons/explode", CHAN_WEAPON, 0.5);
        }

        if (tracer) {
         	tracer.DamageMobj(self, self, ex_damage, "Fire");
        }
		self.A_Explode(ex_damage, ex_damage * 0.75, 0, true);

        if (pg) {
            pg.Remove();
        }
    }
}


class AWeapGrenades_SuperGrenade: Hexen2Projectile {
	bool isMulti;
    bool isModified;

    double ex_damage;

    double ticNextExplosion;

	Default {
        +FLOAT;
        +FORCERADIUSDMG;
	}

	States {
		Spawn:
			TNT1 A 1;
			Loop;
	}

	override void Tick() {
		Super.Tick();

        self.ticNextExplosion -= 1.0;
        if (self.ticNextExplosion <= 0) {
            self.ex_damage *= (0.7 + frandom(0.0, 0.2));
            if (self.ex_damage > 70.0) {
                // Spawn (weaker) super grenade;
                int count_explosions;
                if (self.isModified) {
                    count_explosions = random(2,3);
                } else {
                    count_explosions = random(3,6);
                }
                for (int i = 0; i < count_explosions; i++) {
                    // spawn next
                    AWeapGrenades_SuperGrenade gren = AWeapGrenades_SuperGrenade(Spawn("AWeapGrenades_SuperGrenade"));
                    gren.SetOrigin(self.pos, false);
                    gren.isMulti = self.isMulti;
                    gren.isModified = self.isModified;
                    gren.ex_damage = self.ex_damage;
                    gren.ticNextExplosion = frandom(0.1, 0.6) * TICRATEF;

                    double x;
                    double y;
                    double z;
                    if (self.isMulti) {
                        x = frandom(-40.0, 40.0) / 24.0;
                        y = frandom(-40.0, 40.0) / 24.0;
                        z = frandom(150.0, 300.0) / 24.0;

                        // TODO: Spawn A_QuakeEx as Entity
                        // https://github.com/videogamepreservation/hexen2/blob/eac5fd50832ce2509226761b3b1a387c468e7a50/H2W/HCode/quake.hc#L10
                        if (frandom(0.0, 1.0) < 0.3) {
                            int z = random(3,5);
                            int xy = random(1,3);
                            gren.A_QuakeEx(xy,xy,z, 35 * 3, 0, 800, "world/quake", QF_RELATIVE | QF_SCALEUP | QF_SCALEDOWN, 1,1,1, 1200);
                        }
                    } else {
                        x = frandom(-300.0, 300.0) / 24.0;
                        y = frandom(-300.0, 300.0) / 24.0;
                        z = frandom(50.0, 150.0) / 24.0;
                    }
                    gren.A_ChangeVelocity(x,y,z,CVF_REPLACE);

                    Actor ex;
                    if (self.isMulti) {
                        ex = Spawn("AWeapGrenades_Grenade_Explode");
                    } else {
                        ex = Spawn("AWeapGrenades_Grenade_SM_Explode");
                    }
                    ex.SetOrigin(self.pos, false);
                    A_StartSound("hexen2/weapons/explode", CHAN_WEAPON, 0.5);
                }
            } else {
                self.ex_damage = 70;
                if ((self.pos.z - self.floorz) == 0.0 && frandom(0.0, 1.0) > 0.25) {
                    Actor ex = Spawn("AWeapGrenades_Grenade_ExplodeFloor");
                    ex.SetOrigin((self.pos.x, self.pos.y, self.floorz + 64.0), false);
                    A_StartSound("hexen2/weapons/explode", CHAN_WEAPON, 1.0);
                } else {
                    Actor ex = Spawn("AWeapGrenades_Grenade_Explode");
                    ex.SetOrigin(self.pos, false);
                    A_StartSound("hexen2/weapons/explode", CHAN_WEAPON, 0.5);
                }
            }
		    self.A_Explode(self.ex_damage, self.ex_damage * 0.75, 0, true);
            self.Destroy();
        }
	}
}