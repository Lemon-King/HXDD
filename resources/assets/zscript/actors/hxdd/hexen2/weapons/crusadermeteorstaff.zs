
// https://github.com/videogamepreservation/hexen2/blob/master/H2W/HCode/meteor.hc

class CWeapMeteorStaff: CrusaderWeapon
{
	Default
	{
		RenderStyle "Translucent";
		Weapon.SelectionOrder 1000;
		Weapon.KickBack 150;
		Weapon.YAdjust 0;
		Weapon.AmmoType1 "Mana2";
		Weapon.AmmoUse 8;
		Weapon.AmmoGive 100;
		+BLOODSPLATTER
		+FLOATBOB
		Obituary "$OB_MPCWEAPMETEORSTAFF";
		Tag "$TAG_CWEAPMETEORSTAFF";

		FloatBobStrength 0.25;
	}

	States
	{
	Spawn:
		PKUP A -1;
		Stop;
	Select:		// defined as select1 - select16, adding select18 to ensure a smoother transition for interpolate
        TNT1 A 0 Offset(0, 32);
        CWMS ABCDEFGHIJKLMNOPR 2;
		CWMI A 0 A_Raise(100);
		Loop;
	Deselect:
		CWMI A 0;
        CWMS RPONMLKJIHGFEDCBA 2;
		TNT1 A 0 A_Lower(100);
		Loop;
	Ready:
		CWMI A 2 A_WeaponReady;
		Loop;
	Fire:
		CWMF A 2 A_MeteorShot;
		CWMF BCDEFGHI 2;
		Goto Ready;
	}

	action void A_MeteorShot() {
		if (player == null) {
			return;
		}

		Weapon weapon = player.ReadyWeapon;
		if (weapon != null)
		{
			if (!weapon.DepleteAmmo(weapon.bAltFire)) {
				return;
			}
		}

		// Spawn first then recoil
		SpawnPlayerMissile("CWeapMeteorStaff_Meteor", angle, 0, 0, 12);
		A_Recoil(300.0f / 32.0f);
	}
}

// TODO Add Puffs using WHT1 sprites
// Effects: https://github.com/videogamepreservation/hexen2/blob/eac5fd50832ce2509226761b3b1a387c468e7a50/H2W/Client/cl_effect.c#L738
class CWeapMeteorStaff_Meteor: Hexen2Projectile {
	// Rolling: https://github.com/videogamepreservation/hexen2/blob/eac5fd50832ce2509226761b3b1a387c468e7a50/H2MP/hcode/h3ents.txt#L1631
	// https://github.com/videogamepreservation/hexen2/blob/eac5fd50832ce2509226761b3b1a387c468e7a50/H2W/HCode/SUBS.hc#L144

	// Explode: https://github.com/videogamepreservation/hexen2/blob/eac5fd50832ce2509226761b3b1a387c468e7a50/H2MP/hcode/explode.hc

	double tickDuration;
	property tickDuration: tickDuration;

	Default {
		DamageFunction 0;
		+HITTRACER;
		+ZDOOMTRANS;
		+SPAWNSOUNDSOURCE;

		Speed (1000.0 / 32.0);
		Radius 6;
		Height 6;
		Damage 65;
		DamageType "Fire";
		Projectile;
        SeeSound "hexen2/crusader/metfire";
		DeathSound "hexen2/weapons/explode";
		Obituary "$OB_MPMWEAPFROST";

        CWeapMeteorStaff_Meteor.tickDuration (5.0 * TICRATEF);
	}

	States
	{
	Spawn:
		PROJ A -1 Bright;
		Loop;
	Death:
		BGEX A 2 Bright A_ExplodeRadius;
		BGEX BCDEFGHI 2 Bright;
		Stop;
	}

	override void Tick() {
		Super.Tick();

		if (InStateSequence(CurState, self.Findstate("Death"))) {
			return;
		}
		if (tickDuration <= 0) {
			Destroy();
		}

		tickDuration -= 1.0f;

		Vector3 avelocity = (0, 0, 1000.0f / 32.0f);	// value is unknown in source, guessed based on ftw
		angle += avelocity.x;
		pitch += avelocity.y;
		roll += avelocity.z;
	}

	void A_ExplodeRadius() {
        A_SetRenderStyle(1, STYLE_Add);

		double radius = (Damage + 40) * (100.0f / 32.0f);	// Damage + 40
		int bonus = GetPowerUpHolyStrengthMultiplier() * Damage;
		A_Explode(Damage + bonus, radius, alert:true);
	}
}
// Trail