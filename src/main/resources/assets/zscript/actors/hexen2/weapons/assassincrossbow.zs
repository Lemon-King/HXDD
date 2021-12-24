// Assassin Weapon: Crossbow

class AWeapCrossbow : AssassinWeapon
{
	Default
	{
		Weapon.SelectionOrder 3500;
		Weapon.KickBack 150;
		Weapon.YAdjust 0;
		Weapon.AmmoType1 "Mana1";
		Weapon.AmmoUse 3;
		Weapon.AmmoGive 100;
		+BLOODSPLATTER
		+FLOATBOB
		Obituary "$OB_MPCWEAPMACE";
		Tag "$TAG_CWEAPMACE";

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

	double traceDamage;

	Default {
		DamageFunction 0;
		+HITTRACER +ZDOOMTRANS +SPAWNSOUNDSOURCE

		Speed 10;
		Radius 4;
		Height 4;
		Damage 15;
		Projectile;
		ActiveSound "hexen2/assassin/arrowfly";
		DeathSound "hexen2/assassin/arrowbrk";
		Obituary "$OB_MPMWEAPFROST";

        AWeapCrossbow_Bolt.tickDuration 142.8571428571429; // ~5 seconds
	}

	States
	{
	Spawn:
		BOLT A -1;
		Loop;
	Death:
		TNT1 A 1;
	//	WHT1 ABCDE 2;
		Stop;
	}

    override void BeginPlay() {
        Super.BeginPlay();
        Speed = (800.0f + (frandom[BoltSpeed](0.0f, 1.0f) * 500.0f)) / 32.0f;
		traceDamage = 15.0f;
    }

	override void Tick() {
		Super.Tick();

		if (InStateSequence(CurState, self.Findstate("Death"))) {
			return;
		}
		if (tickDuration <= 0) {
		//	Destroy();
		}

		//tickDuration -= 1.0f;
	}

	void A_GetDamage() {
        //A_SetRenderStyle(0.5f, STYLE_Add);
		if (tracer) {
         	tracer.DamageMobj(self, target, traceDamage, "None");
			Spawn("AWeapCrossbow_BoltFlash", self.pos);
			// Spawn Particles
		} else {
			Spawn("AWeapCrossbow_BoltPuff", self.pos);
		}
	}
}

class AWeapCrossbow_FlamingBolt: AWeapCrossbow_Bolt {
    Default {
        Damage 40;
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
		//RenderStyle "Add";
		Alpha 1.0f;
		VSpeed 1.0f;
	}
	States {
		Spawn:
			WHT1 ABCDE 2;
			Stop;
	}
}

class AWeapCrossbow_BoltFlash: Actor {

	Default {
		+NOBLOCKMAP
		+NOGRAVITY
		+ALLOWPARTICLES
		+ZDOOMTRANS
		RenderStyle "Add";
		Alpha 0.4f;
	}
	States {
		Spawn:
			STON ABCDABCDABCD 2;
			Stop;
	}


	override void Tick() {
		Super.Tick();

		roll += 12.0f;
	}
}