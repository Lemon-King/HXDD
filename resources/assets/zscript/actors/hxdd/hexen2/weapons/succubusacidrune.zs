// Paladin Weapon: Acid Rune
// https://github.com/videogamepreservation/hexen2/blob/master/H2MP/hcode/acidorb.hc
// lighting: https://github.com/videogamepreservation/hexen2/blob/eac5fd50832ce2509226761b3b1a387c468e7a50/H2MP/code/CL_MAIN.C#L727

class SWeapAcidRune: SuccubusWeapon {
    bool lastPoweredState;

	Default {
		+BLOODSPLATTER;
		+FLOATBOB;

		Weapon.SelectionOrder 3500;
		Weapon.AmmoUse 3;
		Weapon.AmmoType1 "Mana1";
		Weapon.AmmoGive 150;
		Weapon.KickBack 150;
		//Weapon.YAdjust 10;
		Obituary "$OB_MPSWEAPACIDRUNE";
		Tag "$TAG_SWEAPACIDRUNE";
	}

	States {
		Spawn:
			PKUP A -1;
			Stop;
		Select:
			TNT1 A 0 A_Select;
			Loop;
		Deselect:
			TNT1 A 0 A_Deselect;
			Loop;
		Select_Normal:
			ARSN KJIHGFEDCBA 2 Offset(0, 32);
			TNT1 A 0 A_Raise(100);
			Goto Ready;
		Select_Power:
			ARSP ABCDEFGHIJK 2 Offset(0, 32);
			TNT1 A 0 A_Raise(100);
			Goto Ready_Power;
		Deselect_Normal:
			ARIA A 0;
			ARSN ABCDEFGHIJK 2;
			TNT1 A 0 A_Lower(100);
			Loop;
		Deselect_Power:
			ARIC A 0;
			ARSP KJIHGFEDCBA 2;
			TNT1 A 0 A_Lower(100);
			Loop;
		Ready:
			ARIA ABCDEFGHIJKLMNOPQRSTUVWX 2 A_FireReady;
			ARIA Y 2 A_FireReady(true);
			Loop;
		Ready_Jelly:
			ARIB ABCDEFGHIJKLMNOPQRSTUVWXY 2 A_FireReady;
			Goto Ready;
		Ready_Power:
			ARIC ABCDEFGHIJKLMNOPQRSTUVWX 2 A_FireReady;
			ARIC Y 2 A_FireReady(true);
			Loop;
		Ready_Power_Jelly:
			ARID ABCDEFGHIJKLMNOPQRSTUVWXY 2 A_FireReady;
			Goto Ready_Power;
		ToPoweredReady:
			ARTP ABCDEFGHIJKLMNOPQRST 2;
			Goto Ready_Power;
		ToNormalReady:
			ARTN ABCDEFGHIJKLMNOPQRST 2;
			Goto Ready;
		Fire:
			TNT1 A 0 A_SelectFire;
		Fire_Normal:
			ARFN ABCDEF 2;
			Goto Fire_ReFire;
		Fire_ReFire:
			ARFN H 2 A_Fire;
			ARFN G 2 A_Fire;
			ARFN G 0 A_ReFire("Fire_ReFire");
			Goto Fire_Finish;
		Fire_Finish:
			ARFN IJKLMN 2;
			ARIA A 0 A_ResetCooldown;
			Goto Ready;
		Fire_Power:
			ARFP ABCDEFG 2;
			Goto Fire_Power_ReFire;
		Fire_Power_ReFire:
			ARFP H 2 A_Fire;
			ARFP G 2 A_Fire;
			ARFP G 0 A_ReFire("Fire_Power_ReFire");
			Goto Fire_Power_Finish;
		Fire_Power_Finish:
			ARFP IJKLMN 2;
			ARIC A 0 A_ResetCooldown;
			Goto Ready_Power;
	}

	bool IsInReadySequence(bool inPower = false) {
		if (!Player) {
			return false;
		}
		SWeapAcidRune weapon = SWeapAcidRune(Player.ReadyWeapon);

		State animationStates[2];
		if (inPower) {
			animationStates[0] = weapon.FindState("Ready_Power");
			animationStates[1] = weapon.FindState("Ready_Power_Jelly");
		} else {
			animationStates[0] = weapon.FindState("Ready");
			animationStates[1] = weapon.FindState("Ready_Jelly");
		}

		for (int i = 0; i < 2; i++) {
			State iState = animationStates[i];
			if (weapon.InStateSequence(CurState, iState)) {
				return true;
			}
		}
		return false;
	}

	action void A_Select() {
        bool isPowered = Player.mo.FindInventory("PowerWeaponLevel2", true);

		SWeapAcidRune weapon = SWeapAcidRune(Player.ReadyWeapon);
		State nextState = weapon.FindState("Select_Normal");
		if (isPowered) {
			if (weapon.lastPoweredState != isPowered) {
				weapon.lastPoweredState = isPowered;
			}
			nextState = weapon.FindState("Select_Power");
		}
		Player.SetPsprite(PSP_WEAPON, nextState);
		A_ResetCooldown();
	}

	action void A_Deselect() {
        bool isPowered = Player.mo.FindInventory("PowerWeaponLevel2", true);

		SWeapAcidRune weapon = SWeapAcidRune(Player.ReadyWeapon);
		State nextState = weapon.FindState("Deselect_Normal");
		if (isPowered) {
			nextState = weapon.FindState("Deselect_Power");
		}
		Player.SetPsprite(PSP_WEAPON, nextState);
	}

	action void A_SelectFire() {
        bool isPowered = Player.mo.FindInventory("PowerWeaponLevel2", true);

		SWeapAcidRune weapon = SWeapAcidRune(Player.ReadyWeapon);
		State nextState = weapon.FindState("Fire_Normal");
		if (isPowered) {
			nextState = weapon.FindState("Fire_Power");
		}
		Player.SetPsprite(PSP_WEAPON, nextState);
	}

	action void A_FireReady(bool allowJellyState = false) {
		if (Player == null) {
			return;
		}

        bool isPowered = Player.mo.FindInventory("PowerWeaponLevel2", true);

		SWeapAcidRune weapon = SWeapAcidRune(Player.ReadyWeapon);
		if (isPowered && weapon.lastPoweredState != isPowered) {
			weapon.lastPoweredState = isPowered;
			State nextState = weapon.FindState("ToPoweredReady");
			Player.SetPsprite(PSP_WEAPON, nextState);
		} else if (!isPowered && weapon.lastPoweredState != isPowered) {
			weapon.lastPoweredState = isPowered;
			State nextState = weapon.FindState("ToNormalReady");
			Player.SetPsprite(PSP_WEAPON, nextState);
		} else if (allowJellyState && frandom(0.0, 1.0) < 0.1) {
			State nextState = weapon.FindState("Ready_Jelly");
			if (isPowered) {
				nextState = weapon.FindState("Ready_Power_Jelly");
			}
			Player.SetPsprite(PSP_WEAPON, nextState);
		} else {
			A_WeaponReady();
		}
	}

	action void A_Fire() {
		if (player == null) {
			return;
		}
		SWeapAcidRune weapon = SWeapAcidRune(Player.ReadyWeapon);
		if (weapon.Cooldown(Player.ReadyWeapon)) {
			return;
		}
		if (weapon && !weapon.DepleteAmmo(weapon.bAltFire)) {
			return;
		}
		double refire = 0.4;
        bool isPowered = Player.mo.FindInventory("PowerWeaponLevel2", true);
		if (weapon.lastPoweredState != isPowered) {
			// A_FireReady change
			A_FireReady();
			return;
		}
		String sfx = "hexen2/succubus/acidfire";
		Actor proj = SpawnFirstPerson("SWeapAcidRune_Missile", 45, -14, -7, true, 0, 0);
		if (isPowered) {
			// Do camera kickback if possible
			SWeapAcidRune_Missile(proj).isPowered = true;
			refire = 0.7;
			sfx = "hexen2/succubus/acidpfir";
		}
		A_StartSound(sfx, CHAN_WEAPON);
		SetCooldown(weapon, refire, 2);
	}

	action void A_ResetCooldown() {
		if (player == null) {
			return;
		}
		ResetCooldown(Player.ReadyWeapon);
	}
}

class SWeapAcidRune_Missile: Hexen2Projectile {
	bool isPowered;	// turns into blob

	double tickDuration;
	property tickDuration: tickDuration;

	double nextTrail;

	Vector3 avelocity;
	Vector3 avelocityr;

	Default {
		+HITTRACER;
        +ZDOOMTRANS;
        +SPAWNSOUNDSOURCE;

		DamageFunction 0;

		Speed (850.0/32.0);
		Radius 8;
		Height 8;
		Projectile;
		
		//SeeSound "hexen2/succubus/acidfire";
		DeathSound "hexen2/succubus/acidhit";
		Obituary "$OB_MPSWEAPACIDRUNE";

		SWeapAcidRune_Missile.tickDuration (35.0 * 1.5);
	}

	States {
		Spawn:
			AMIS A 1 Bright;
			Loop;
		Death:
			TNT1 A 0 A_GetDamage;
			Stop;
	}

	override void BeginPlay() {
		Super.BeginPlay();

		if (self.isPowered) {
			self.Speed = 1000.0 / 32.0;
		}
	}

	override void PostBeginPlay() {
		Super.PostBeginPlay();

		if (self.isPowered) {
			// TODO: make veer cvar value as dependant between modes
			self.veerAmount = 30;
			self.tickDuration = 35.0 * 5;
			self.Scale = (2.5, 2.5);

			double avecz = frandom(0.0, 1.0) * -360.0 - 100.0;
			if (random(0.0, 1.0) < 0.5) {
				avecz = frandom(0.0, 1.0) * 360.0 + 100.0;
			}
			self.avelocity = (0,0,avecz);
		} else {
			self.avelocity = (0,0,frandom(-400.0, 400.0));
		}

		pg = ParticleGenerator(Spawn("ParticleGenerator"));
		pg.Attach(self);
		pg.color[0] = (4, 84, 4);
		pg.color[1] = (0, 180, 0);
		pg.origin[0] = (-2, 0, -2);
		pg.origin[1] = (1, 3, 1);
		pg.velocity[0] = (-20, -20, -20);
		pg.velocity[1] = (20, 20, 20);
		pg.accel[0] = (0, -0.5, 0);
		pg.accel[1] = (0,0,0);
		pg.startalpha = 1.0;
		pg.sizestep = 0.00;
		pg.fadestep = 0.01;
		pg.lifetime = 0.7;
		pg.size = 3;
		pg.flag_fullBright = true;
	}

	override void Tick() {
		Super.Tick();

		if (InStateSequence(CurState, self.Findstate("Death"))) {
			return;
		}

		//self.tickDuration -= 1;
		//if (self.tickDuration <= 0) {
		//	self.Destroy();
		//}

		// TODO: Fix Rotation
		Vector3 facing = LemonUtil.GetEularFromVelocity(self.vel);
		self.angle = facing.x;
		self.pitch = facing.y;
		self.roll = facing.z;

		//self.avelocityr += self.avelocity;
		//self.avelocityr.x += self.avelocity.x;
		//self.avelocityr.y += self.avelocity.y;
		//self.avelocityr/z += self.avelocity.z;

		//Vector3 facing = LemonUtil.GetEularFromVelocityAndAngularVelocity(self.vel, self.avelocityr);
		//self.angle = facing.x + self.avelocityr.x;
		//self.pitch = facing.y + self.avelocityr.y;
		//self.roll = facing.z + self.avelocityr.z;

		if (self.isPowered) {
			if (self.nextTrail <= 0.0) {
				Actor sprfx = Spawn("AcidMuzzleFlash");
				sprfx.SetOrigin(self.pos, false);
				self.nextTrail = 0.1;
			} else {
				self.nextTrail -= (1.0 / 35.0);
			}
		}

		// spawn delayed shimmer
		SWeapAcidRune_PFX_Shimmer pgs = SWeapAcidRune_PFX_Shimmer(Spawn("SWeapAcidRune_PFX_Shimmer"));
		pgs.SetOrigin(self.pos, false);
		SWeapAcidRune_PFX_Shimmer(pgs).delay = 0.6;
	}

	void A_GetDamage() {
		self.Scale = (1.0, 1.0);
		int damage = random[acidmissile](27,33);
		if (self.isPowered) {
			damage = 75;
			// big boom

			int count = random(3,10);
			for (int i = 0; i < count; i++) {
				SWeapAcidRune_AcidDrop aciddrop = SWeapAcidRune_AcidDrop(Spawn("SWeapAcidRune_AcidDrop"));
				aciddrop.SetOrigin(self.pos, false);
				aciddrop.target = self.target;
			}

			// Rocket Explode Particles
			// Since Particle Generator does not support it, hard coded for now
			A_H2QuakeRocketExplode();
		} else {
			A_SetRenderStyle(0.7, STYLE_Translucent);
			if (tracer) {
				tracer.DamageMobj(self, target, damage, 'Normal');
			}
		}
		Actor sprfx = Spawn("AcidExplosion2");
		sprfx.SetOrigin(self.pos, false);
	}

	// Hardcoded Rocket Explosion
	void A_H2QuakeRocketExplode() {
		// TODO: make quake style rocket explode pfx cvar toggle
		double c_size;
		double c_angle;

		// Colors should be sourced from palette.lmp
		vector3 rgb;
		int color;

		vector3 c_origin;
		vector3 c_velocity;
		vector3 c_accel;

		vector3 c_aorigin;
		vector3 c_avelocity;
		vector3 c_aaccel;

		double c_startalpha;
		double c_fadestep;
		double c_sizestep;

		double ticksLifetime = 1 * 35;

		int count = 1024;
		for (let i = 0; i < count; i++) {
            int flags = SPF_FULLBRIGHT;

			c_size = 5.0;
			c_angle = 0;

			c_accel = (0,0,0);

			c_aorigin = (0,0,0);
			c_avelocity = (0,0,0);
			c_aaccel = (0,0,0);

			c_startalpha = 1;
			c_fadestep = -1;
			c_sizestep = frandom(-0.25, 0.0);

			c_origin = (
				frandom(-16.0, 16.0),
				frandom(-16.0, 16.0),
				frandom(-16.0, 16.0)
			);
			c_velocity = (
				((random(0, 2147483647) & 511) - 256) / 16.0,
				((random(0, 2147483647) & 511) - 256) / 16.0,
				((random(0, 2147483647) & 511) - 256) / 16.0
			);
			
			int red = 255;
			int green = 255;
			int blue = 255;
			if (i & 1) {
				red = frandom(52, 248);
				green = 0;
				blue = 0;
				c_aaccel = (
					(1/35) * 4.0,
					(1/35) * 4.0,
					320.0
				);
			} else {
				double rand = frandom(0.0, 1.0);
				Vector3 colLow = (80, 24, 4);
				Vector3 colHigh = (252, 220, 120);
				Vector3 color = LemonUtil.v3Lerp(colLow, colHigh, rand);
				red = int(color.x);
				green = int(color.y);
				blue = int(color.z);
				c_aaccel = (
					(1/35),
					(1/35),
					320.0
				);
			}
			
			int color = (red << 16) | (green << 8) | (blue);

			self.A_SpawnParticle(color, flags, ticksLifetime, c_size, c_angle, c_origin.x, c_origin.y, c_origin.z, c_velocity.x, c_velocity.y, c_velocity.z, c_accel.x, c_accel.y, c_accel.z, c_startalpha, c_fadestep, c_sizestep);
		}

	}
}

// hacky, but it emulates the acid blob effect nicely (TODO: Replace with SimParticles)
class SWeapAcidRune_PFX_Shimmer: Actor {
	double delay;
	bool remove;

	Default {
		+NOBLOCKMAP;
		+NOGRAVITY;
		+NOINTERACTION;
		+NOCLIP;
        +FORCEXYBILLBOARD;

		Height 0;
		Radius 0;
	}

	States {
		Spawn:
			TNT1 A 1;
			Loop;
	}

	override void Tick() {
		Super.Tick();
		if (self.remove) {
			self.Destroy();
		}
		self.delay -= (1.0 / 35.0);
		if (self.delay <= 0) {
			ParticleGenerator pg = ParticleGenerator(Spawn("ParticleGenerator"));
			pg.Attach(self);
			pg.color[0] = (220, 144, 16);
			pg.color[1] = (248, 200, 80);
			pg.origin[0] = (-10, -10, -10);
			pg.origin[1] = (10, 10, 10);
			pg.velocity[0] = (-20, -20, -20);
			pg.velocity[1] = (20, 20, 20);
			pg.accel[0] = (0, -0.5, 0);
			pg.accel[1] = (0,0,0);
			pg.startalpha = 1.0;
			pg.lifetime = 0.2;
			pg.size = 3;
			pg.flag_fullBright = true;

			self.remove = true;
		}
	}
}

class SWeapAcidRune_AcidDrop: Hexen2Projectile {
	double lifetime;
	property lifetime: lifetime;

	Vector3 avelocity;

	Default {
		Projectile;

		+HITTRACER;
		+SPAWNSOUNDSOURCE;
        -NOGRAVITY;
        +NOBLOCKMAP;
        +DROPOFF;
        +MISSILE;
        +ACTIVATEIMPACT;
        +ACTIVATEPCROSS;
        +NOTELEPORT;
        +FORCERADIUSDMG;
		
		DamageFunction 0;
        DamageType "Normal";

        Health 3;
		Speed 15.625;
		Radius 5;
		Height 5;
        Gravity 1.0;
        Scale 1.0;
		//BounceSound "hexen2/succubus/dropfizz";
		//WallBounceSound "hexen2/succubus/dropfizz";
		//DeathSound "hexen2/weapons/explode";
		Obituary "$OB_MPSWEAPACIDRUNE";

        SWeapAcidRune_AcidDrop.lifetime 1.5;
	}

	States {
		Spawn:
			AMIS A 1;
			Loop;
		//Bounce:
		//	AMIS A 0 A_OnBounce();
		//	Goto Spawn;
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
		pg.color[0] = (4, 84, 4);
		pg.color[1] = (0, 180, 0);
		pg.origin[0] = (-2, 0, -2);
		pg.origin[1] = (1, 3, 1);
		pg.velocity[0] = (-20, -20, -20);
		pg.velocity[1] = (20, 20, 20);
		pg.accel[0] = (0, -0.5, 0);
		pg.accel[1] = (0,0,0);
		pg.startalpha = 1.0;
		pg.sizestep = 0.00;
		pg.fadestep = 0.01;
		pg.lifetime = 0.7;
		pg.size = 2.5;
		pg.flag_fullBright = true;
    }

    override void PostBeginPlay() {
        Super.PostBeginPlay();

		Vector3 newVelocity = LemonUtil.RandomVector3(150.0 / 32.0,150.0 / 32.0,0);
		newVelocity.z = frandom(300.0 / 32.0, 500.0 / 32.0);
		self.A_ChangeVelocity(newVelocity.x, newVelocity.y, newVelocity.z, CVF_REPLACE);
    }

	override void Tick() {
		Super.Tick();

        if (self.Speed != 0) {
			Vector3 facing = LemonUtil.GetEularFromVelocity(self.vel);
			self.angle = facing.x;
			self.pitch = facing.y;
			self.roll = facing.z;

            //self.angle += avelocity.x;
            //self.pitch += avelocity.y;
            //self.roll += avelocity.z;
        }

        if (self.Speed != 0 && self.vel.z == 0) {
            self.Speed = 0;
            self.A_ScaleVelocity(0);
            if (pg) {
                pg.Remove();
            }
        }

		// spawn delayed shimmer
		SWeapAcidRune_PFX_Shimmer pgs = SWeapAcidRune_PFX_Shimmer(Spawn("SWeapAcidRune_PFX_Shimmer"));
		pgs.SetOrigin(self.pos, false);
		SWeapAcidRune_PFX_Shimmer(pgs).delay = 0.6;

		self.lifetime -= (1.0 / 35.0);
		if (self.lifetime <= 0) {
            A_ExplodeAndDamage();
            self.Destroy();
		}
	}

	void A_OnBounce() {
		if (self.tracer && (self.tracer.bIsMonster || self.tracer.bShootable)) {
            A_ExplodeAndDamage();
            self.Destroy();
		}
	}

    void A_ExplodeAndDamage() {
        double damage = 15;
		Actor spfx = Spawn("AcidExplosion1");
		spfx.SetOrigin(self.pos, false);

        if (tracer) {
         	tracer.DamageMobj(self, self, damage, "Normal");
			A_StartSound("hexen2/succubus/acidhit", CHAN_WEAPON);
        } else {
			A_StartSound("hexen2/succubus/dropfizz", CHAN_WEAPON);
		}

        if (pg) {
            pg.Remove();
        }
    }
}