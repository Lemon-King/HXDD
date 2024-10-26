// Crusader Weapon: Warhammer
// ref: https://github.com/videogamepreservation/hexen2/blob/master/H2W/HCode/warhamer.hc

class CWeapWarhammer : CrusaderWeapon {
	const RANGE							= 64;
	const DAMAGE_LOW					= 15;
	const DAMAGE_HIGH					= 25;
	const DAMAGE_SCALE_TOP				= 2;

	const DURATION_MJOLNIR_RETURN 		= (3000.0 / TICRATEF);

	int waitProjectile;

	bool connected;

	Default
	{
		Weapon.SelectionOrder 3500;
		Weapon.KickBack 150;
		Weapon.YAdjust 0;
		+BLOODSPLATTER
		Obituary "$OB_MPCWEAPWARHAMMER";
		Tag "$TAG_CWEAPWARHAMMER";
	}

	States
	{
	Select:
        TNT1 A 0 Offset(0, 32);
        CWSL ABCDEFGHI 3;
		CWID A 0 A_Raise(100);
		Loop;
	Deselect:
		CWID A 0;
        CWSL IHGFEDCBA 3;
		TNT1 A 0 A_Lower(100);
		Loop;
	Ready:
		CWID A 1 A_WeaponReady;
		Loop;
	Fire:
		CWID A 0 A_DecideAttack;
		Loop;
	SwingTop: // Top Down
        CWCH ABCDEF 2;
        CWCH G 2 A_SwingStart("top", -30);
        CWCH H 2 Attack_Normal("top", 0);
        CWCH I 2 Attack_Normal("top", 30);
        CWCH JKL 2;
		Goto Ready;
	SwingLR: // Left to Right
		CWLR ABCD 2;
        CWLR E 2 A_SwingStart("ltr", -30);
        CWLR F 2 Attack_Normal("ltr", 0);
        CWLR G 2 Attack_Normal("ltr", 30);
        CWLR HIJK 2;
		Goto Ready;
	SwingRL: // Right to Left
		CWRL ABC 2;
        //DEF   // skipped
        CWRL G 2 A_SwingStart("rtl", -30);
        CWRL H 2 Attack_Normal("rtl", 0);
        CWRL I 2 Attack_Normal("rtl", 30);
        CWRL JK 2;
		Goto ReturnToReady;
    ReturnToReady:
        CWRA ABCD 3;
		CWID A 0;
        Goto Ready;
    Throw:
        CWTH A 2 A_StartSound("hexen2/weapons/vorpswng", CHAN_AUTO);
		CWTH BCDEF 2;
		CWTH G 2 Attack_Powered();
		CWTH HIJ 2;
        Goto Throw_Gone;
	Throw_Gone:
		TNT0 A 1 CheckPoweredState();	// warhammer_gone()
		Loop;
	Throw_Returned:
		TNT0 A 0 A_PlayReturnSound();		// Play return sfx
		Goto Select;
    Hack:
        CWHA ABCDEFGHIJ 2;
        Goto Ready;
	}

	action void A_DecideAttack() {
		CWeapWarhammer weapon = CWeapWarhammer(player.ReadyWeapon);
        bool hasTome = Player.mo.FindInventory("PowerWeaponLevel2", true);
		if (hasTome) {
			weapon.waitProjectile = 0;
			Player.SetPsprite(PSP_WEAPON, Player.ReadyWeapon.FindState("Throw"));
		} else {
			int rnd = random(0,2);
			if (rnd == 0) {
				Player.SetPsprite(PSP_WEAPON, Player.ReadyWeapon.FindState("SwingTop"));
			} else if (rnd == 1) {
				Player.SetPsprite(PSP_WEAPON, Player.ReadyWeapon.FindState("SwingLR"));
			} else if (rnd == 2) {
				Player.SetPsprite(PSP_WEAPON, Player.ReadyWeapon.FindState("SwingRL"));
			}
			weaponspecial = ++weaponspecial % 3;
			SetConnectedState(false);
		}
	}

    action void A_SwingStart(String hitDirection, Double offset) {
        A_StartSound("hexen2/weapons/vorpswng");
        Attack_Normal(hitDirection, offset);
    }

	action void Attack_Normal(String hitDirection, Double offset) {
		if (player == null || GetConnectedState()) {
			return;
		}


		double damage = frandom[WarhammerAtk](DAMAGE_LOW, DAMAGE_HIGH);
		damage += GetPowerUpHolyStrengthMultiplier() * damage;

        double x = 1;
        double z = 1;
        if (hitDirection == "top") {
            z = -offset;
			damage *= 2;
        } else if (hitDirection == "ltr") {
            x = -offset;
        } else if (hitDirection == "rtl") {
            x = offset;
        }

		
		PlayerSlot pSlot = HXDDPlayerStore.GetPlayerSlot(Player.mo.PlayerNumber());
		int strengthValue = 10;
		if (pSlot) {
			PlayerSheetStat statStrength = pSlot.GetStat("strength");
			if (statStrength) {
				strengthValue = statStrength.value;
			}
		}

		//Array<Actor> hit;
		FTranslatedLineTarget t;
		for (int i = 0; i < 16; i++) {
			for (int j = 1; j >= -1; j -= 2) {
				double ang = angle + j*i*(45. / 16);
				double slope = AimLineAttack(ang, MELEE_RANGE, t, 0., ALF_CHECK3D);

				if (t.linetarget) { //&& hit.Find(t.linetarget) != hit.Size()) {

					LineAttack(ang + x, MELEE_RANGE, slope + z, damage, 'Melee', "SickleSparks_Hit", true, t);
					if (t.linetarget != null) {
						AdjustPlayerAngle(t);

						Actor target = Actor(t.linetarget);
						double targetMass = target.mass;

						int inertia = 1;
						if (targetMass > 10) {
							inertia = targetMass / 10.0;
						}
						if (inertia < 100 && !target.bBoss) {
							double force = strengthValue / 40.0 + 0.5;

							HXDD_GM_Matrix matRotation = HXDD_GM_Matrix.fromEulerAngles(target.angle, target.pitch, target.roll);

							Vector3 facing = (0, 0, -1);
							if (hitDirection == "ltr") {
								facing = (-1, 0, 0);
							} else if (hitDirection == "rtl") {
								facing = (1, 0, 0);
							}
							Vector3 thrustDir = matRotation.multiplyVector3(facing).asVector3();

							double power = ((1.0/inertia) * force) * (damage * 2.0);	// modified to work with doom values
							target.Thrust(power, atan2(thrustDir.y, thrustDir.x));
						}

						//hit.push(t.linetarget);
						SetConnectedState(true);
						return;
					}
				}
			}
		}

        if (offset == 0) {
            // didn't find any creatures, so try to strike any walls
            double slope = AimLineAttack (angle, DEFMELEERANGE, null, 0., ALF_CHECK3D);
            LineAttack(angle, DEFMELEERANGE, slope, damage, 'Melee', "SickleSparks");
        }
	}

	action void Attack_Powered() {
		let p = CWeapWarhammer_Mjolnir(SpawnFirstPerson("CWeapWarhammer_Mjolnir", 45, 12, -7, true, 0, 0));
		p.owner = self.player;
	}

	action void CheckPoweredState() {
		CWeapWarhammer weapon = CWeapWarhammer(player.ReadyWeapon);
        bool hasTome = Player.mo.FindInventory("PowerWeaponLevel2", true);
		if ((!hasTome || weapon.waitProjectile >= DURATION_MJOLNIR_RETURN)) {
			Player.SetPsprite(PSP_WEAPON, Player.ReadyWeapon.FindState("Throw_Returned"));
		} else {
			weapon.waitProjectile++;
		}
	}

	action void SetConnectedState(bool nextState) {
		CWeapWarhammer weapon = CWeapWarhammer(player.ReadyWeapon);
		weapon.connected = nextState;
	}

	action bool GetConnectedState() {
		CWeapWarhammer weapon = CWeapWarhammer(player.ReadyWeapon);
		return weapon.connected;
	}


	action bool TryAttackAngle(double angle) {
		return false;
	}

	action void A_PlayReturnSound() {
		// alt sounds support
		int soundAlt = LemonUtil.CVAR_GetInt("hxdd_crusader_warhammer_sound_return_alt", 1, Player);
		String sfx = soundAlt == 0 ? "hexen2/weapons/weappkup" : "hexen2/doors/penswing";
		A_StartSound(sfx, CHAN_AUTO, CHANF_LISTENERZ|CHANF_LOCAL);
	}
}

// https://github.com/search?q=repo%3Avideogamepreservation%2Fhexen2%20mjolnir&type=code
class CWeapWarhammer_Mjolnir : Hexen2Projectile {
	const DURATION = 3;						// seconds

	const BODY_OFFSET_Y = 14;				// matches player arm location
	const VIEWHEIGHT_ADJUST = 0.75;			// prevents the hammer from returning to player's eyes

	const SPEED_BASE = (800.0/32.0);
	const SPEED_WATER = SPEED_BASE * 0.5;

	const DISTANCE_RETURN = 377;
	const DISTANCE_PICKUP = 28;

	const MISSILE_DMG = 200;
	const MISSILE_DMG_RETURN = 32;

	const ROTATION_PER_TIC = (1080.0 * TICRATEFRAC);
	const ROTATION_WATER_PER_TIC = ROTATION_PER_TIC * 0.5;

	const USE_ACTOR_ROTATE = 1;

	PlayerInfo owner;
	Actor lastTrace;

	int aflag;

	double lifetime;	// duration

	vector3 aRotate;

	Default {
		+INTERPOLATEANGLES;
		+HITTRACER;
		+USEBOUNCESTATE;
		+BOUNCEONCEILINGS;
		+BOUNCEONACTORS;
		+ALLOWBOUNCEONACTORS;
		+DONTBOUNCEONSKY;
		+NOBOUNCESOUND;
        +SPAWNSOUNDSOURCE;

        +NOGRAVITY;

		Speed SPEED_BASE;
		Radius 4;
		Height 8;
		//Projectile;

		DamageFunction 0;
		Bouncetype "Grenade";

		SeeSound "hexen2/paladin/axblade";
		DeathSound "";
		Obituary "$OB_MPSWEAPACIDRUNE";
	}

	States {
		Spawn:
			0000 ABCDEF 2 Bright;
			Loop;
		Rotate:
			0000 A 1 Bright;
			Loop;
		Bounce:
			TNT0 A 0 A_OnBounce();
			Goto Spawn;
	}

	override void BeginPlay() {
		Super.BeginPlay();

		self.aflag = 0;
		self.lifetime = DURATION;

		self.A_StartSound("hexen2/paladin/axblade", CHAN_6, CHANF_LOOPING);

		if (USE_ACTOR_ROTATE) {
			State stRotate = self.FindState("Rotate");
			if (stRotate) {
				self.SetState(stRotate);
			}
		}
	}

	override void Tick() {
		Super.Tick();
		if (!self.owner) {
			self.Destroy();
			return;
		}

		self.speed = self.WaterLevel > 2 ? SPEED_WATER : SPEED_BASE;
		//self.aRotate = (self.aRotate + (self.WaterLevel > 2 ? ROTATION_WATER_PER_TIC : ROTATION_PER_TIC)) % 360;
		if (USE_ACTOR_ROTATE == 1) {
			double rate = (self.WaterLevel > 2 ? ROTATION_WATER_PER_TIC : ROTATION_PER_TIC);
			self.aRotate = LemonUtil.ModVector3(self.aRotate + (0, rate, 0), 360);
		}

		vector3 destiny = LemonUtil.GetVector3PosOffset(self.owner.mo.pos, self.owner.mo.angle, self.owner.mo.pitch, self.owner.mo.roll, (0,BODY_OFFSET_Y,self.owner.viewheight * VIEWHEIGHT_ADJUST), 0,0);

		double distance = (self.pos - destiny).Length();
		if (distance > DISTANCE_RETURN) {
			// stops weird behavior near the player
			self.bINTERPOLATEANGLES = false;
			self.SetReturnFlags();
		}

		if (distance < DISTANCE_PICKUP) {
			// return
			if (self.owner.ReadyWeapon is "CWeapWarhammer") {
				CWeapWarhammer weap = CWeapWarhammer(self.owner.ReadyWeapon);
				weap.waitProjectile = 100;	// works the same

				self.lifetime = 0;
			}
		}

		if (self.aflag == -1) {
			Vector3 dir = (destiny - self.pos).Unit();
			Vector3 vel = dir * self.speed;
			self.A_ChangeVelocity(vel.x, vel.y, vel.z, CVF_REPLACE);

			//self.angle = dir.Angle();
			//self.pitch = -asin(dir.z);
		}

		Vector3 dir = self.aflag == -1 ? (destiny - self.pos).Unit() : (self.pos - destiny).Unit();
		Vector3 vel = dir * self.speed;

		double a = dir.Angle();
		double p = -asin(dir.z);

		if (self.aflag == -1) {
			FLineTracedata trace;
			self.LineTrace(self.angle, self.radius * 0.5, self.pitch, TRF_SOLIDACTORS, self.height * 0.5, data: trace);
			Vector3 newpos = trace.HitLocation;
			if (trace.HitType == TRACE_HitActor) {
				if (!(trace.HitActor is self.owner.mo.GetClass()) && trace.HitActor != self.lastTrace) {
					self.tracer = trace.HitActor;
					self.lastTrace = self.tracer;
					Spawn("CWeapWarhammer_Mjolnir_Lightning", self.tracer.pos + (0,0,self.tracer.height * 0.5));
					self.tracer.DamageMobj(self, self, MISSILE_DMG_RETURN, 'Normal');
				}
			}
		}

		[self.angle, self.pitch, self.roll] = LemonUtil.GetFacingWithRotation((a,p,0), self.aRotate);

		if (self.lifetime <= 0) {
			self.Destroy();
		} else {
			self.lifetime -= TICRATEFRAC;
		}
	}

	void A_OnBounce() {
		if (!self.owner) {
			return;
		}
		if (!self.tracer) {
			A_StartSound("hexen2/weapons/hitwall", CHAN_7, CHANF_OVERLAP);
		} else {
			Spawn("CWeapWarhammer_Mjolnir_Lightning", self.tracer.pos + (0,0,self.tracer.height * 0.5));
			if (self.tracer != self.lastTrace && !(self.tracer is "PlayerPawn") && (self.tracer.bIsMonster || self.tracer.bShootable)) {
				if (self.aflag == -1) {
					self.tracer.DamageMobj(self, self, MISSILE_DMG_RETURN, 'Normal');
				} else {
					self.tracer.DamageMobj(self, self, MISSILE_DMG, 'Normal');
				}
			}
			self.lastTrace = self.tracer;
		}
		self.SetReturnFlags();

		if (USE_ACTOR_ROTATE) {
			State stRotate = self.FindState("Rotate");
			if (stRotate) {
				self.SetState(stRotate);
			}
		}
	}

	void SetReturnFlags() {
		self.aflag = -1;

		self.bNOCLIP = true;
		self.bBOUNCEONCEILINGS = false;
		self.bBOUNCEONFLOORS = false;
		self.bTHRUACTORS = true;
		self.bPUSHABLE = false;
	}
}


// https://github.com/videogamepreservation/hexen2/blob/eac5fd50832ce2509226761b3b1a387c468e7a50/H2W/Client/cl_tent.c#L1902
// https://github.com/videogamepreservation/hexen2/blob/eac5fd50832ce2509226761b3b1a387c468e7a50/H2W/HCode/lightning.hc#L231
class CWeapWarhammer_Mjolnir_Lightning : Actor {
	Default {
		+NOINTERACTION;
		+NOGRAVITY;
	}

	Array<BeamFX> list;

	double lifetime;

	override void BeginPlay() {
		Super.BeginPlay();

		// Play sound on start
		A_StartSound(frandom(0.0, 1.0) < 0.7 ? "hexen2/crusader/lghtn1" : "hexen2/crusader/lghtn2", CHAN_AUTO, CHANF_OVERLAP, attenuation: ATTN_NORM);
		A_StartSound("hexen2/misc/lighthit", CHAN_7, CHANF_OVERLAP, attenuation: ATTN_NORM);
	
		self.lifetime = 0.5;
		
		// Spawn 5 lightning nodes
		for (int i = 0; i < 5; i++) {
			// Spawn a lightning node at self.pos

			BeamFX fx = BeamFX(Spawn("BeamFX", self.pos, true));
			fx.SetFX("BeamFX_Lightning", (0,0,1080 * 10), 500);

			
			// Define skyTarget with some random horizontal offset and a fixed Z component
			Vector3 skyTarget = self.pos + (frandom(-300.0, 300.0), frandom(-300.0, 300.0), 500.0);
			[fx.angle, fx.pitch, fx.roll] = LemonUtil.GetFacingAngle(skyTarget, self.pos);

			// Add the node to the list
			self.list.Push(fx);
		}
	}

	override void Tick() {
		self.lifetime -= TICRATEFRAC;

		if (self.lifetime <= 0.0) {
			// clean
			for (int i = 0; i < self.list.Size(); i++) {
				BeamFX node = self.list[i];
				node.Destroy();
			}
			A_StopSound(CHAN_7);
			self.Destroy();
		}
	}
}