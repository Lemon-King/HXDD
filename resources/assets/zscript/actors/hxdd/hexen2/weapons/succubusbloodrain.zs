// Demoness Weapon: Blood Rain
// ref: https://github.com/videogamepreservation/hexen2/blob/master/H2MP/hcode/bldrain.hc

class SWeapBloodRain : SuccubusWeapon {
	Default {
		+NOGRAVITY
		Weapon.SelectionOrder 3500;
		Weapon.AmmoUse 0;
		Weapon.AmmoGive 150;
		Weapon.KickBack 150;
		//Weapon.YAdjust 10;
		Obituary "$OB_MPSWEAPBLOODRAIN";
		Tag "$TAG_SWEAPBLOODRAIN";
	}

	States {
		Select:
			SWSE ABCDEFGHIJKLMNOPQRST 2 Offset(0, 32);
			TNT1 A 0 A_Raise(100);
			Loop;
		Deselect:
			SWSE TSRQPONMLKJIHGFEDCBA 2;
			TNT1 A 0 A_Lower(100);
			Loop;
		Ready:
			SWIB ABCDEFGHIJKLMNOPQRSTUVW 2 A_WeaponReady;
			SWIB X 2 A_WeaponReadyRngJellyFingers;
			Loop;
		Ready_Jelly:
			SWIJ ABCDEFGHIJKLMNOPQRSTUVWX 2 A_WeaponReady;
			Goto Ready;
		Fire:
			SWAA ABCDEF 1;
			SWAA G 1 A_BloodRain;
			SWAA HIJK 2;
			SWAA L 1 A_ReFire("Fire");
			Goto Ready;
	}

	action void A_WeaponReadyRngJellyFingers() {
		if (frandom(0.0, 1.0) < 0.1) {
			Player.SetPsprite(PSP_WEAPON, Player.ReadyWeapon.FindState("Ready_Jelly"));
		} else {
			A_WeaponReady();
		}
	}

	action void A_BloodRain() {
		if (player == null) {
			return;
		}

		Weapon weapon = player.ReadyWeapon;
		if (weapon != null)
		{
			if (!weapon.DepleteAmmo (weapon.bAltFire))
				return;
		}
		SpawnFirstPerson("SWeapBloodRain_Missile", 25, -5.75, -5, true);
		A_StartSound("hexen2/succubus/brnfire", CHAN_WEAPON);
	}
}

// Bounce Reference:
// https://forum.zdoom.org/viewtopic.php?f=2&t=65769
// https://forum.zdoom.org/viewtopic.php?f=7&t=65626&p=1115105

class SWeapBloodRain_Missile : Actor
{
	int Duration;

	property Duration: Duration;

   	//int DamageDealt;

	   Vector3 start;

	Default {
		RenderStyle "Add";
		
		+HITTRACER;
		+ZDOOMTRANS;
		+SPAWNSOUNDSOURCE;
		
		DamageFunction 0;

		Speed 25;
		Radius 8;
		Height 8;
		Projectile;
		
		//SeeSound "hexen2/succubus/brnfire";
		DeathSound "hexen2/succubus/brnwall";
		Obituary "$OB_MPSWEAPBLOODRAIN";

		SWeapBloodRain_Missile.Duration 90;
	}

	States
	{
	Spawn:
		BMIS ABCD 2 Bright;
		Loop;
	Death:
		XPL2 A 2 Bright A_GetDamage;
		XPL2 BCDEFG 2 Bright;
		Stop;
	}

	override void PostBeginPlay() {
		Super.PostBeginPlay();

		start = self.pos;
	}

	override void Tick() {
		Super.Tick();

		if (InStateSequence(CurState, self.Findstate("Death"))) {
			return;
		}
		
		Vector3 facing = LemonUtil.GetEularFromVelocity(self.vel);
		self.angle = facing.x;
		self.pitch = facing.y;
		self.roll = facing.z;

		Vector3 vecDiff = (start.x - self.pos.x, start.y - self.pos.y, start.z - self.pos.z);
		double distance = sqrt((vecDiff.x * vecDiff.x) + (vecDiff.y * vecDiff.y) + (vecDiff.z * vecDiff.z));
		if (distance > (8.0f * 32.0f)) {
			Destroy();
		}

		Duration -= 10;
	}

	void A_GetDamage() {
		A_SetRenderStyle(1, STYLE_Add);
		if (tracer) {
         	int damage = random[BloodMissile](15, 22);
         	tracer.DamageMobj(self, target, damage, 'Normal');
		}
	}
}
