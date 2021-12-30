class CWeapIceMace : CrusaderWeapon
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
        CWIS ABCDEFGHI 2;
		CWII A 0 A_Raise(100);
		Loop;
	Deselect:
		CWII A 0;
        CWIS IHGFEDCBA 2;
		TNT1 A 0 A_Lower(100);
		Loop;
	Ready:
		CWII ABCDEFGHIJKLMNOP 2 A_WeaponReady;
		Loop;
	Fire:
		CWIA ABC 0 A_DecideAttack;
		Loop;
	Fire1:
		CWIA AB 2;
        CWIE C 2 A_IceShot;
		Goto Ready;
	Fire2:
		CWIB AB 2;
        CWIE C 2 A_IceShot;
		Goto Ready;
	Fire3:
		CWIC AB 2;
        CWIE C 2 A_IceShot;
		Goto Ready;
	Fire4:
		CWID AB 2;
        CWIE C 2 A_IceShot;
		Goto Ready;
	Fire5:
		CWIE AB 2;
        CWIE C 2 A_IceShot;
		Goto Ready;
	Power:
		CWIP ABCDEFGHI 2;
		Loop;
	}

	action void A_DecideAttack() {
        // TODO: if tome is active, throw weapon
        int rnd = random[WpnAnimation](0,4);
		if (rnd == 0) {
			Player.SetPsprite(PSP_WEAPON, Player.ReadyWeapon.FindState("Fire1"));
		} else if (rnd == 1) {
			Player.SetPsprite(PSP_WEAPON, Player.ReadyWeapon.FindState("Fire2"));
		} else if (rnd == 2) {
			Player.SetPsprite(PSP_WEAPON, Player.ReadyWeapon.FindState("Fire3"));
        } else if (rnd == 3) {
			Player.SetPsprite(PSP_WEAPON, Player.ReadyWeapon.FindState("Fire4"));
        } else if (rnd == 4) {
			Player.SetPsprite(PSP_WEAPON, Player.ReadyWeapon.FindState("Fire5"));
        }
        weaponspecial = ++weaponspecial % 5;
	}

	action void A_IceShot() {
		if (player == null) {
			return;
		}

		Weapon weapon = player.ReadyWeapon;
		if (weapon != null)
		{
			if (!weapon.DepleteAmmo (weapon.bAltFire))
				return;
		}

		SpawnPlayerMissile("CWeapIceMace_IceShot1", angle, 0, 0, 12);
	}
}

// Effects: https://github.com/videogamepreservation/hexen2/blob/eac5fd50832ce2509226761b3b1a387c468e7a50/H2W/Client/cl_effect.c#L738
class CWeapIceMace_IceShot1 : Actor {
	// Rolling: https://github.com/videogamepreservation/hexen2/blob/eac5fd50832ce2509226761b3b1a387c468e7a50/H2MP/hcode/h3ents.txt#L1631
	// https://github.com/videogamepreservation/hexen2/blob/eac5fd50832ce2509226761b3b1a387c468e7a50/H2W/HCode/SUBS.hc#L144

	double tickDuration;

	property tickDuration: tickDuration;

	Vector3 avelocity;


	Default {
		DamageFunction 0;
		+HITTRACER +ZDOOMTRANS +SPAWNSOUNDSOURCE

		Speed 37.5;	//(1200 / 32) = ~1200 Quake Engine Velocity
		Radius 4;
		Height 4;
		DamageType "Ice";
		Projectile;
        SeeSound "hexen2/crusader/icefire";
		DeathSound "hexen2/crusader/icewall";
		Obituary "$OB_MPMWEAPFROST";
        Scale 1.5;

        CWeapIceMace_IceShot1.tickDuration 114.2857142857143; // ~4 seconds (35ms => 4 seconds)
	}

	States
	{
	Spawn:
		ICE1 A 2 Bright;
		Loop;
	Death:
		ICEH A 2 Bright A_GetDamage;
		ICEH BCDE 2 Bright;
        ICEH F 2 Bright;
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

		Vector3 avelocity = (-6.25, 6.25, -6.25);
		angle += avelocity.x;
		pitch += avelocity.y;
		roll += avelocity.z;
	}

	override int DoSpecialDamage (Actor victim, int damage, Name damagetype)
	{
		if (special2 > 0)
		{
			damage <<= special2;
		}
		return damage;
	}


	void A_GetDamage() {
		angle = 0;
		pitch = 0;
		roll = 0;
        Scale.x = 2.0f/3.0f;
        Scale.y = 2.0f/3.0f;
        A_SetRenderStyle(1, STYLE_Add);
		if (tracer) {
            // https://github.com/videogamepreservation/hexen2/blob/master/H2W/HCode/icemace.hc#L213
         	int damage = random[IceShot1](20, 20);
         	tracer.DamageMobj(self, target, damage, 'Ice');
		}
	}
}