
// https://github.com/videogamepreservation/hexen2/blob/master/H2W/HCode/crossbow.hc

// Damage may need tuning

class AWeapCrossbow : AssassinWeapon
{
	Default
	{
		Weapon.SelectionOrder 1600;
		Weapon.KickBack 150;
		Weapon.YAdjust 0;
		Weapon.AmmoType1 "Mana1";
		Weapon.AmmoUse 3;
		Weapon.AmmoGive 100;
		+BLOODSPLATTER
		+FLOATBOB
		Obituary "$OB_MPAWEAPXBOW";
		Tag "$TAG_AWEAPXBOW";

		FloatBobStrength 0.25;
	}

	States
	{
	Spawn:
		PKUP A -1;
		Stop;
	Select:
        TNT1 A 0 Offset(0, 32);
        AXBS ONMLKJIHGFEDCBA 2;
		AXBA A 0 A_Raise(100);
		Loop;
	Deselect:
        AXBS ABCDEFGHIJKLMNO 2;
		TNT1 A 0 A_Lower(100);
		Loop;
	Ready:
		AXBA S 1 A_WeaponReady;
		Loop;
	Fire:
        AXBA A 2;
        AXBA B 2 A_FireBolt;
        AXBA CDEFGHIJKLMNOPQRS 2;
		Goto Ready;
	}

	action void A_FireBolt() {
		if (player == null) {
			return;
		}
		Weapon weapon = Player.ReadyWeapon;
        bool hasTome = Player.mo.FindInventory("PowerWeaponLevel2", true);
        String boltType = "AWeapCrossbow_Bolt";
		String soundFire = "hexen2/assassin/firebolt";

        if (hasTome) {
            boltType = "AWeapCrossbow_FlamingBolt";
			soundFire = "hexen2/assassin/firefblt";
            weapon.AmmoUse1 = 10;
        } else {
            weapon.AmmoUse1 = 3;
        }

		if (weapon != null) {
			if (!weapon.DepleteAmmo(weapon.bAltFire)) {
				return;
            }
		}

        double offset = (100.0f / 12.8f);
		double angleOffset = offset - 6.4f;

        // Center
		SpawnPlayerMissile(boltType, angle, 0, 0, 12);

        // Left + Right
		SpawnPlayerMissile(boltType, angle - (offset + (frandom[xbowoffset](0.0f, 10.0f))), -angleOffset * sin(angle), angleOffset * cos(angle), 12);
		SpawnPlayerMissile(boltType, angle + (offset + (frandom[xbowoffset](0.0f, 10.0f))), angleOffset * sin(angle), -angleOffset * cos(angle), 12);

        // Tome Activated Left + Right
        if (hasTome) {
            offset = (200.0f / 12.8f);
			angleOffset = offset - 12.8f;
			SpawnPlayerMissile(boltType, angle - (offset + (frandom[xbowoffset](0.0f, 10.0f))), -angleOffset * sin(angle), angleOffset * cos(angle), 12);
			SpawnPlayerMissile(boltType, angle + (offset + (frandom[xbowoffset](0.0f, 10.0f))), angleOffset * sin(angle), -angleOffset * cos(angle), 12);
		}
		A_StartSound(soundFire, CHAN_WEAPON);
	}
}

class AWeapCrossbow_Bolt: Actor {
	double tickDuration;
	property tickDuration: tickDuration;

	bool isFalling;

	vector3 avelocity;

	Default {
		DamageFunction 0;
		+HITTRACER
		+ZDOOMTRANS
		+SPAWNSOUNDSOURCE

		Speed 10;
		Radius 4;
		Height 4;
		//Damage 15;
		Projectile;
		ActiveSound "hexen2/assassin/arrowfly";
		DeathSound "hexen2/assassin/arrowbrk";
		Obituary "$OB_MPMWEAPFROST";

        AWeapCrossbow_Bolt.tickDuration 2.0; // ~2 seconds
	}

	States
	{
	Spawn:
		BOLT A -1;
		Loop;
	Death:
		TNT1 A 1 A_GetDamage;
		Stop;
	}

    override void BeginPlay() {
        Super.BeginPlay();
        Speed = (800.0f + (frandom[BoltSpeed](0.0f, 1.0f) * 500.0f)) / 32.0f;
    }

	override void Tick() {
		Super.Tick();

		if (InStateSequence(CurState, self.Findstate("Death"))) {
			return;
		}

		self.angle += avelocity.x;
		self.pitch += avelocity.y;
		self.roll += avelocity.z;

		if (tickDuration <= 0 && !isFalling) {
			isFalling = true;
			avelocity = (50.0 / 32.0, 50.0 / 32.0, 50.0 / 32.0);

			double zFall = frandom[boltzfall](-60.0 / 32.0,-150.0 / 32.0);
			A_ChangeVelocity(0, 0, zFall, CVF_RELATIVE, AAPTR_DEFAULT);
		}

		tickDuration -= 32.0 / 1000.0;
	}

	action void A_GetDamage() {
		if (self is "AWeapCrossbow_FlamingBolt") {
			A_Explode(40, 64, XF_HURTSOURCE, true, 0, 0, 0, "None", "Fire");
			return;
		}
		if (tracer) {
			Actor fxDamage = Actor(Spawn("AWeapCrossbow_BoltFlash"));
			fxDamage.angle = self.angle;
			fxDamage.pitch = self.pitch;
			fxDamage.roll = self.roll;
			fxDamage.SetOrigin(self.pos, false);

         	tracer.DamageMobj(self, target, 10, "None");
		} else {
			Actor fxPuff = Actor(Spawn("AWeapCrossbow_BoltPuff"));
			fxPuff.SetOrigin(self.pos, false);
		}
	}
}

class AWeapCrossbow_FlamingBolt: AWeapCrossbow_Bolt {
    Default {
        //Damage 40;
        //SeeSound "hexen2/assassin/firefblt";
    }
	States
	{
	Spawn:
		BOLT ABCDEFGHI 2 Bright;
		Loop;
	Death:
		BGEX A 2 Bright;
		BGEX BCDEFGHI 2 Bright;
		Stop;
	}
}

class AWeapCrossbow_BoltPuff: Actor {
	Default {
		+NOBLOCKMAP
		+NOGRAVITY
		RenderStyle "Translucent";
		Alpha 0.8;
		VSpeed 1.0;
	}
	States {
		Spawn:
			WHT1 ABCDE 2;
			Stop;
	}
}

class AWeapCrossbow_BoltFlash: Actor {
	double tickDuration;
	property tickDuration: tickDuration;
	vector3 avelocity;

	Default {
		+NOBLOCKMAP
		+NOGRAVITY
		+ALLOWPARTICLES
		+ZDOOMTRANS
		RenderStyle "Add";
		Alpha 0.9;
		Scale 0.1;

		AWeapCrossbow_BoltFlash.tickDuration 0.3;
	}
	States {
		Spawn:
			FLSH A 1 Bright;
			Loop;
	}

    override void BeginPlay() {
        Super.BeginPlay();
		double zvelz = frandom(200.0/32.0, 700.0/32.0);
		avelocity = (0,0, zvelz);
    }

	override void Tick() {
		Super.Tick();

		self.angle += avelocity.x;
		self.pitch += avelocity.y;
		self.roll += avelocity.z;

		Scale.x += 0.05;
		Scale.y += 0.05;

		if (tickDuration <= 0 ) {
			self.Destroy();
		}

		tickDuration -= 32.0 / 1000.0;
	}
}