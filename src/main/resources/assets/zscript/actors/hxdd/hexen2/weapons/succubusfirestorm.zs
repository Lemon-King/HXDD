
// https://github.com/videogamepreservation/hexen2/blob/master/H2MP/hcode/flameorb.hc

class SWeapFireStorm: SuccubusWeapon {
    bool lastPoweredState;

	Default {
		+BLOODSPLATTER;
		+FLOATBOB;

		Weapon.SelectionOrder 1000;
		Weapon.AmmoType1 "Mana2";
		Weapon.AmmoUse1 4;
		Weapon.AmmoType2 "Mana2";
		Weapon.AmmoUse2 8;
		Weapon.AmmoGive 150;
		Weapon.KickBack 150;
		//Weapon.YAdjust 10;
		Obituary "$OB_MPSWEAPFIRESTORM";
		Tag "$TAG_SWEAPFIRESTORM";
	}

	States {
		Select:
			TNT1 A 0 A_Select;
			Loop;
		Deselect:
			TNT1 A 0 A_Deselect;
			Loop;
		Select_Normal:
			FSSN KJIHGFEDCBA 2 Offset(0, 32);
			TNT1 A 0 A_Raise(100);
			Goto Ready;
		Select_Power:
			FSSP ABCDEFGHIJK 2 Offset(0, 32);
			TNT1 A 0 A_Raise(100);
			Goto Ready_Power;
		Deselect_Normal:
			FSIA A 0;
			FSSN ABCDEFGHIJK 2;
			TNT1 A 0 A_Lower(100);
			Loop;
		Deselect_Power:
			FSIC A 0;
			FSSP KJIHGFEDCBA 2;
			TNT1 A 0 A_Lower(100);
			Loop;
		Ready:
			FSIA ABCDEFGHIJKLMNOPQRSTUVWX 2 A_FireStormReady;
			FSIA Y 2 A_FireStormReady(true);
			Loop;
		Ready_Jelly:
			FSIB ABCDEFGHIJKLMNOPQRSTUVWXY 2 A_FireStormReady;
			Goto Ready;
		Ready_Power:
			FSIC ABCDEFGHIJKLMNOPQRSTUVWX 2 A_FireStormReady;
			FSIC Y 2 A_FireStormReady(true);
			Loop;
		Ready_Power_Jelly:
			FSID ABCDEFGHIJKLMNOPQRSTUVWXY 2 A_FireStormReady;
			Goto Ready_Power;
		ToPoweredReady:
			FSTP ABCDEFGHIJKLMNOPQRST 2;
			Goto Ready_Power;
		ToNormalReady:
			FSTN ABCDEFGHIJKLMNOPQRST 2;
			Goto Ready;
		Fire:
			TNT1 A 0 A_SelectFire;
			Goto Ready;	// Fallback
		Fire_Normal:
			FSFN ABCDEF 2;
			FSFN H 2 A_TryFire;
			FSFN GIJKLMN 2 A_FireStormReady;
			Goto Ready;
		Fire_Power:
			FSFP ABCDEFG 2;
			FSFP H 2 A_TryFire;
			FSFP GIJKLMN 2 A_FireStormReady;
			Goto Ready_Power;
	}

	bool IsInReadySequence(bool inPower = false) {
		if (!Player) {
			return false;
		}
		SWeapFireStorm weapon = SWeapFireStorm(Player.ReadyWeapon);

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

		SWeapFireStorm weapon = SWeapFireStorm(Player.ReadyWeapon);
		State nextState = weapon.FindState("Select_Normal");
		if (isPowered) {
			if (isPowered && weapon.lastPoweredState != isPowered) {
				weapon.lastPoweredState = isPowered;
			}
			nextState = weapon.FindState("Select_Power");
		}
		Player.SetPsprite(PSP_WEAPON, nextState);
		A_ResetCooldown();

		weapon.CreateRecoilController();
	}

	action void A_Deselect() {
        bool haveTome = Player.mo.FindInventory("PowerWeaponLevel2", true);

		SWeapFireStorm weapon = SWeapFireStorm(Player.ReadyWeapon);
		State nextState = weapon.FindState("Deselect_Normal");
		if (haveTome) {
			nextState = weapon.FindState("Deselect_Power");
		}
		Player.SetPsprite(PSP_WEAPON, nextState);
	}

	action void A_SelectFire() {
        bool haveTome = Player.mo.FindInventory("PowerWeaponLevel2", true);

		SWeapFireStorm weapon = SWeapFireStorm(Player.ReadyWeapon);
		State nextState = weapon.FindState("Fire_Normal");
		if (haveTome) {
			nextState = weapon.FindState("Fire_Power");
		}
		Player.SetPsprite(PSP_WEAPON, nextState);
	}

	action void A_FireStormReady(bool allowJellyState = false) {
		if (Player == null) {
			return;
		}

        bool isPowered = Player.mo.FindInventory("PowerWeaponLevel2", true);

		SWeapFireStorm weapon = SWeapFireStorm(Player.ReadyWeapon);
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
		} else if (!weapon.Cooldown(Player.ReadyWeapon)) {
			A_WeaponReady();
		}
	}

	action void A_TryFire() {
		if (player == null) {
			return;
		}
		SWeapFireStorm weapon = SWeapFireStorm(Player.ReadyWeapon);
		if (weapon.Cooldown(Player.ReadyWeapon)) {
			return;
		}
        bool isPowered = Player.mo.FindInventory("PowerWeaponLevel2", true);
		//weapon.AmmoUse1 = isPowered ? 8 : 4;
		if (weapon && !weapon.DepleteAmmo(weapon.bAltFire)) {
			return;
		}

		double refire = 0.2;
		vector2 recoil = (-2, 0);
		String sfx = "hexen2/succubus/flamstrt";

		Actor proj = SpawnFirstPerson("SWeapFireStorm_FlameStream", 45, -14, -7, true, 0, 0);
		if (isPowered) {
			// Do camera kickback if possible
			refire = 1.0;
			recoil = (-6, 0);
			sfx = "hexen2/succubus/flamstrt";

			SWeapFireStorm_FlameStream(proj).isPowered = true;
		}
		weapon.AddRecoil(recoil);
		A_PlaySound(sfx, CHAN_WEAPON, 0.5);
		SetCooldown(weapon, refire, 2);
	}

	action void A_ResetCooldown() {
		if (player == null) {
			return;
		}
		ResetCooldown(Player.ReadyWeapon);
	}
}

class SWeapFireStorm_FlameStream: Hexen2Projectile {
	bool isPowered;

	double tickDuration;
	property tickDuration: tickDuration;

	double nextTrail;
	double nextFlameWall;

	Vector3 avelocity;

	Default {
		+HITTRACER;
        +ZDOOMTRANS;

		DamageFunction 0;

		Speed (1500.0/32.0);
		Radius 12;
		Height 12;
		Projectile;
		Scale 1;
		
		//SeeSound "hexen2/succubus/acidfire";
		DeathSound "hexen2/succubus/flampow";
		Obituary "$OB_MPSWEAPFIRESTORM";

		SWeapFireStorm_FlameStream.tickDuration (2.0 * 35.0);
	}

	States {
		Spawn:
			FBAL A 1 Bright;
			Loop;
		Death:
			TNT1 A 0 A_GetDamage;
			Stop;
	}

	override void BeginPlay() {
		Super.BeginPlay();

		float speedBase = 1500.0;
		float speedRand = 50.0;
		if (self.isPowered) {
			speedBase = 800.0;
			speedRand = 100.0;
		} else {
			self.A_SetRenderStyle(1, STYLE_None);
		}
		self.Speed = (speedBase + (random(0.0, 1.0) * speedRand)) / 32.0;
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
		pg.velocity[0] = (-20, -20, -15);
		pg.velocity[1] = (20, 20, 10);
		pg.amount = 1;	// 2 per 0.05 seconds is base rate, altered to 1 per ~0.028 for gzdoom
		pg.rate = 1;
		pg.startalpha = 1.0;
		pg.sizestep = 0.00;
		pg.size = 5;
		pg.actorParticleTypes.push("FlameStreamParticle");
	}

	override void Tick() {
		Super.Tick();

		if (InStateSequence(CurState, self.Findstate("Death"))) {
			return;
		}

		self.tickDuration -= 1;
		if (self.tickDuration <= 0) {
			self.Destroy();
		}

		//self.angle += self.avelocity.x;
		//self.pitch += self.avelocity.y;
		//self.roll += self.avelocity.z;

		if (self.isPowered) {
			self.nextTrail -= (1.0 / 35.0);
			if (self.nextTrail <= 0.0) {
				Actor sprfx = Spawn("AcidMuzzleFlash");
				sprfx.SetOrigin(self.pos, false);
				self.nextTrail = 0.1;
			}
		} else {
			FLineTraceData trace;
			bool success = self.LineTrace(0, 256, 90, TRF_NOSKY, data: trace);
			if (success) {
				if (trace.HitType & TRACE_HitFloor) {
					// Spawn Fire Entity
					String fireType = "firewall5";
					double rng = frandom[swfs_firewall](0.0, 100.0);
					if (rng < 33) {
						fireType = "firewall1";
					} else if (rng < 66) {
						fireType = "firewall4";
					}
					Actor fw = Spawn(fireType);
					fw.SetOrigin(trace.HitLocation + (0, 0, 24), false);
				}
			}
		}
	}

	void A_GetDamage() {
		int damage = 40;
		if (self.isPowered) {
			if (tracer) {
				SWeapFireStorm_Boom aoe = SWeapFireStorm_Boom(Spawn("SWeapFireStorm_Boom"));
				aoe.SetOwner(self.target);
				aoe.AttachToActor(tracer);
			}
		}
		A_SetRenderStyle(0.7, STYLE_Translucent);
		if (tracer) {
			tracer.DamageMobj(self, target, damage, 'Fire');

			// Add burn damage
			SWeapFireStorm_Burner burner = SWeapFireStorm_Burner(Spawn("SWeapFireStorm_Burner"));
			burner.AttachToActor(tracer);
			burner.SetOwner(self.target);
		}
		Actor sprfx = Spawn("FireBoom");
		sprfx.SetOrigin(self.pos, false);
	}
}

class SWeapFireStorm_Burner: Actor {
	Actor burnTarget;

	double tickDuration;
	property tickDuration: tickDuration;

	double nextDamage;

	ParticleGenerator pg;

	Default {
		+NOBLOCKMAP;
		+NOGRAVITY;
		+NOINTERACTION;
		+NOCLIP;

		Height 0;
		Radius 0;

		SWeapFireStorm_Burner.tickDuration (5.0 * 35.0);
	}

	States {
		Spawn:
			TNT1 A 1 Bright;
			Loop;
	}

	override void PostBeginPlay() {
		Super.PostBeginPlay();

		self.tickDuration = (5 + random[swfs_burner](0, 5) * 35.0);
	}

	void AttachToActor(Actor nextTarget) {
		if (!nextTarget) {
			self.Destroy();
			return;
		}
		self.burnTarget = nextTarget;
		self.SetOrigin(self.burnTarget.pos, false);
		
		Vector3 bounds = (self.burnTarget.radius, self.burnTarget.radius, self.burnTarget.height);
		Vector3 bounds_low = (bounds.x * -0.5, bounds.y * -0.5, 0);
		Vector3 bounds_high = (bounds.x * 0.5, bounds.y * 0.5, bounds.z);
		bounds_low.x += (bounds.x * -0.25);
		bounds_low.y += (bounds.y * -0.25);
		bounds_high += bounds * 0.25;

		pg = ParticleGenerator(Spawn("ParticleGenerator"));
		pg.Attach(self);
		pg.origin[0] = bounds_low;
		pg.origin[1] = bounds_high;
		pg.velocity[0] = (-15, -15, 0);
		pg.velocity[1] = (15, 15, 21);
		pg.amount = 1;
		pg.rate = 35 * 0.5;
		pg.startalpha = 1.0;
		pg.sizestep = 0.00;
		pg.size = 5;
		pg.actorParticleTypes.push("FireWall1Particle");
		pg.actorParticleTypes.push("FireWall2Particle");
		pg.actorParticleTypes.push("FireWall3Particle");

		self.nextDamage = frandom(0.0, 0.5) * 35.0;
	}

	void SetOwner(Actor owner) {
		self.target = owner;
	}

	override void Tick() {
		Super.Tick();

		if (InStateSequence(CurState, self.Findstate("Death"))) {
			return;
		}

		self.tickDuration--;
		if (self.tickDuration <= 0 || (self.burnTarget && self.burnTarget.health <= 0) || !self.burnTarget) {
			self.Destroy();
		}

		self.SetOrigin(self.burnTarget.pos, true);

		self.nextDamage--;
		if (self.nextDamage <= 0) {
			self.burnTarget.DamageMobj(self, self.target, random[swfs_burndmg](2,3), 'Fire');
			self.A_PlaySound("hexen2/raven/fire1", CHAN_WEAPON, 1);

			self.nextDamage = frandom(0.0, 0.5) * 35.0;
		}
	}
}

class SWeapFireStorm_Boom: Actor {
	double attackCount;
	property attackCount: attackCount;

	Actor attackTarget;

	Default {
		+NOBLOCKMAP;
		+NOGRAVITY;
		+NOINTERACTION;
		+NOCLIP;

		Height 0;
		Radius 0;

		SWeapFireStorm_Boom.attackCount (1.5 / 0.1);
	}

	States {
		Spawn:
			TNT1 A 1 Bright;
			Loop;
	}


	override void PostBeginPlay() {
		Super.PostBeginPlay();
	}

	void AttachToActor(Actor nextTarget) {
		if (!nextTarget) {
			self.Destroy();
			return;
		}
		self.attackTarget = nextTarget;
		self.SetOrigin(self.attackTarget.pos, false);
	}

	void SetOwner(Actor owner) {
		self.target = owner;
	}

	override void Tick() {
		Super.Tick();

		if (InStateSequence(CurState, self.Findstate("Death"))) {
			return;
		}

		if (self.attackTarget) {
			self.SetOrigin(self.attackTarget.pos, true);
		}

		Vector3 from = self.pos;
		Vector3 to = self.pos + (0, 0, 200.0) + LemonUtil.GetRandVector3((-140, -140, -140), (140, 140, 140));
		double pointAngle = LemonUtil.v3Angle(from, to);
		double pointDistance = LemonUtil.v3Distance(from, to);
		vector3 pointDir = LemonUtil.v3Direction(from, to);

		
		let tracer = new("SWeapFireStormTrace");
		if (!tracer) {
			return;
		}

		tracer.Trace(from, self.CurSector, pointDir, pointDistance, TRACE_PortalRestrict | TRACE_HitSky);
		if (tracer.bFinished) {
			vector3 velDir = pointDir * -1;


			Vector3 spawnPos = tracer.results.HitPos - (pointDir * 12);	// We slightly lower the spawn point to prevent any collisions
			Actor spawnFX = Spawn("FlameStream");
			spawnFX.SetOrigin(spawnPos, false);

			SWeapFireStorm_FlameBall proj = SWeapFireStorm_FlameBall(Spawn("SWeapFireStorm_FlameBall"));	// angles on this are poor
			proj.SetOrigin(spawnPos, false);
			
			/*
			HXDD_GM_Quaternion quat = new("HXDD_GM_Quaternion");
			quat.initFromAxisAngle(velDir, pointAngle);
			double c_yaw;
			double c_pitch;
			double c_roll;
			[c_yaw, c_pitch, c_roll] = quat.toAngles();
			proj.angle = c_yaw;
			proj.pitch = c_pitch;
			proj.roll = c_roll;
			*/

			vector3 newVel = (velDir * (800 + frandom(0.0, 100.0))) / 32.0;
			proj.A_ChangeVelocity(newVel.x, newVel.y, newVel.z, CVF_REPLACE, AAPTR_DEFAULT);
		}

		//FLineTraceData trace;
		//bool success = self.LineTrace(0, distance, angle, TRF_THRUACTORS, data: trace);

		self.attackCount--;
		if (self.attackCount <= 0.0) {
			self.A_PlaySound("hexen2/succubus/flamend", CHAN_WEAPON, 0.5);
			self.Destroy();
		}
	}
}

// https://github.com/coelckers/gzdoom/blob/421c40e929e6fea65c8cdcf3c748070669243c1a/wadsrc/static/zscript/doombase.zs#L271
class SWeapFireStormTrace: LineTracer {
    bool bFinished;
    override ETraceStatus TraceCallback()  {
        if (results.HitType == TRACE_HitNone || results.HitType == TRACE_HitFloor || results.HitType == TRACE_HitCeiling || results.HitType == TRACE_HitWall) {
            bFinished = true;
            return TRACE_Stop;
        }
        return TRACE_Skip;
    }
}


class SWeapFireStorm_FlameBall: Hexen2Projectile {
	bool isPowered;

	double tickDuration;
	property tickDuration: tickDuration;

	double nextTrail;
	double nextFlameWall;

	Vector3 avelocity;

	Default {
		+HITTRACER;
        +ZDOOMTRANS;

		Projectile;

		DamageFunction 0;

		Speed (1500.0/32.0);
		Radius 6;
		Height 6;
		Scale 1;
		
		//SeeSound "hexen2/succubus/acidfire";
		DeathSound "hexen2/succubus/flampow";
		Obituary "$OB_MPSWEAPFIRESTORM";

		//SWeapFireStorm_FlameBall.tickDuration (2.0 * 35.0);
	}

	States {
		Spawn:
			FBAL ABCD 1 Bright;
			Loop;
		Death:
			TNT1 A 0 A_GetDamage;
			Stop;
	}

	void A_GetDamage() {
		int damage = 10;
		if (tracer) {
			tracer.DamageMobj(self, target, damage, 'Fire');
		}
		String fxType = "Pow";
		double rng = frandom[swfs_fireballfx](0.0, 100.0);
		if (rng < 20) {
			fxType = "SmallExplosion";
		} else if (rng < 30) {
			fxType = "FireBoom";
		}
		Actor sprfx = Spawn(fxType);
		sprfx.SetOrigin(self.pos, false);
	}
}