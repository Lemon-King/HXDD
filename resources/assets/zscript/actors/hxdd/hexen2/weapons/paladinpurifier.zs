// Paladin Weapon: Purifier
// https://github.com/videogamepreservation/hexen2/blob/master/H2MP/hcode/purifier.hc

class PWeapPurifierPiece: WeaponPiece {
	Default {
		Inventory.PickupSound "misc/w_pkup";
		Inventory.RestrictedTo "HX2PaladinPlayer";
		WeaponPiece.Weapon "PWeapPurifier";
		+FLOATBOB
	}

    override void Tick() {
        Super.Tick();
        
        self.lightlevel = LemonActor.HX2RenderPickupGlow(self);
    }

}

class PWeapPurifierPiece1: PWeapPurifierPiece {
	Default {
		WeaponPiece.Number 1;
		Inventory.PickupMessage "$HXDD.HEXEN2.WEAPONS.PALADIN.PURIFIER.PEICE.1.PICKUP";
	}
	States {
        Spawn:
            PKUP A -1 Bright;
            Stop;
	}
}

class PWeapPurifierPiece2: PWeapPurifierPiece {
	Default {
		WeaponPiece.Number 2;
		Inventory.PickupMessage "$HXDD.HEXEN2.WEAPONS.PALADIN.PURIFIER.PEICE.2.PICKUP";
	}
	States {
        Spawn:
            PKUP A -1 Bright;
            Stop;
	}
}

class PWeapPurifier: PaladinWeapon {

	Default {
		+BLOODSPLATTER;
		+FLOATBOB;

		+WEAPON.PRIMARY_USES_BOTH;

        Health 2;

		Weapon.SelectionOrder 2900;
		Weapon.AmmoType1 "Mana1";
		Weapon.AmmoType2 "Mana2";
		Weapon.AmmoUse1 1;
		Weapon.AmmoUse2 1;
		Weapon.AmmoGive1 20;
		Weapon.AmmoGive2 20;
		Weapon.KickBack 150;
		//Weapon.YAdjust 40;
		Inventory.PickupMessage "$HXDD.HEXEN2.WEAPONS.PALADIN.PURIFIER.PICKUP";
		Inventory.PickupSound "WeaponBuild";
		Tag "$HXDD.HEXEN2.WEAPONS.PALADIN.PURIFIER.TAG";
	}

	States {
		Select:
			PSEL ABCDEFGHIJKL 2 Offset(0, 32);
			PROT A 0 A_Raise(100);
			Goto Ready;
		Deselect:
			PROT A 0;
			PSEL LKJIHGFEDCBA 2;
			TNT1 A 0 A_Lower(100);
			Loop;
		Ready:
			PROT A 1 A_PuriferReady;
			Loop;
		Fire:
			PROT A 0 A_DecideAttack;
			Goto Ready;
		Fire_Rapid1Left:
			P1FL AB 2;
			P1FL C 2 A_TryFire("left");
			Goto Ready;
		Fire_Rapid1Right:
			P1FR AB 2;
			P1FR C 2 A_TryFire("right");
			Goto Ready;
		Fire_Rapid2Left:
			P2FL AB 2;
			P2FL C 2 A_TryFire("left");
			Goto Ready;
		Fire_Rapid2Right:
			P2FR AB 2;
			P2FR C 2 A_TryFire("right");
			Goto Ready;
		Fire_Rapid3Right:
			P3FR AB 2;
			P3FR C 2 A_TryFire("right");
			Goto Ready;
		Fire_Power:
			PBIG AB 2;
			PBIG C 2 A_TryFire("powered");
			PBIG DEFGHI 2 A_CooldownHandler;
			Goto Ready;
    }
	
	action void A_PuriferReady() {
		if (Player == null) {
			return;
		}
		PWeapPurifier weapon = PWeapPurifier(Player.ReadyWeapon);
		if (!weapon.Cooldown(Player.ReadyWeapon)) {
			A_WeaponReady();
		}
	}

	action void A_CooldownHandler() {
		PWeapPurifier weapon = PWeapPurifier(Player.ReadyWeapon);
		weapon.Cooldown(Player.ReadyWeapon);
	}

	action void A_DecideAttack() {
        bool isPowered = Player.mo.FindInventory("PowerWeaponLevel2", true);
		if (isPowered) {
			Player.SetPsprite(PSP_WEAPON, Player.ReadyWeapon.FindState("Fire_Power"));
		} else {
			if (weaponspecial == 0) {
				Player.SetPsprite(PSP_WEAPON, Player.ReadyWeapon.FindState("Fire_Rapid1Left"));
			} else if (weaponspecial == 1) {
				Player.SetPsprite(PSP_WEAPON, Player.ReadyWeapon.FindState("Fire_Rapid1Right"));
			} else if (weaponspecial == 2) {
				Player.SetPsprite(PSP_WEAPON, Player.ReadyWeapon.FindState("Fire_Rapid2Left"));
			} else if (weaponspecial == 3) {
				Player.SetPsprite(PSP_WEAPON, Player.ReadyWeapon.FindState("Fire_Rapid2Right"));
			}
			weaponspecial = ++weaponspecial % 4;
		}
	}

	action void A_TryFire(string position = "left") {
		if (player == null) {
			return;
		}
		PWeapPurifier weapon = PWeapPurifier(Player.ReadyWeapon);
		if (weapon.Cooldown(Player.ReadyWeapon)) {
			return;
		}
        bool isPowered = Player.mo.FindInventory("PowerWeaponLevel2", true);
		if (isPowered && weapon.AmmoUse1 != 8) {
			weapon.AmmoUse1 = 8;
			weapon.AmmoUse2 = 8;
		} else if (!isPowered && weapon.AmmoUse1 != 1) {
			weapon.AmmoUse1 = 1;
			weapon.AmmoUse2 = 1;
		}
		if (weapon && !weapon.DepleteAmmo(weapon.bAltFire)) {
			return;
		}

		double refire = 0.0;
		vector2 recoil = (frandom(-1.75, -0.25), 0.0);	// modified from hx2's -3 recoil strength to -1.75 to -0.75 for GZDoom
		String sfx = "hexen2/paladin/purfire";
		Actor proj;
		if (isPowered) {
			proj = SpawnFirstPerson("PWeapPurifier_DragonBall", 32, 0, -9, true, 0, 0);
			refire = 0.5;
			recoil = (-4, 0);
			sfx = "hexen2/paladin/purfireb";
		} else {
			proj = SpawnFirstPerson("PWeapPurifier_Missile", 32, position == "left" ? -15 : 15, -9, true, 0, 0);
			if (position == "right") {
				proj.Scale.y = -1;
			}
		}
		weapon.AddRecoil(recoil);
		A_StartSound(sfx, CHAN_WEAPON, 0.5);
		SetCooldown(weapon, refire, 2);
	}
}

class PWeapPurifier_Missile: Actor {
	double tickDuration;
	property tickDuration: tickDuration;

	double nextPuff;

	Default {
		+HITTRACER;
        +ZDOOMTRANS;

		RenderStyle "Add";

		DamageFunction 0;
		DamageType "Fire";

		Speed (1000.0/32.0);
		Radius 12;
		Height 12;
		Projectile;
		Scale 1;
		
		DeathSound "hexen2/weapons/expsmall";
		Obituary "$HXDD.HEXEN2.WEAPONS.PALADIN.PURIFIER.OBITUARY.1";

		PWeapPurifier_Missile.tickDuration (2.5 * TICRATEF);
	}

	States {
		Spawn:
			MISS A 1 Bright;
			Loop;
		Death:
			TNT1 A 0 A_GetDamage;
			Stop;
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

		self.tickDuration -= 1;
		if (self.tickDuration <= 0) {
			self.Destroy();
		}
	}

	void A_GetDamage() {
		int damage = random[pweap_purifer_missile](15,25);
		A_SetRenderStyle(0.7, STYLE_Translucent);
		if (tracer) {
			tracer.DamageMobj(self, target, damage, 'Fire');
		}
		Actor sprfx = Spawn("FireCircle");
		sprfx.SetOrigin(self.pos, false);
	}

	override string GetObituary(Actor victim, Actor inflictor, Name mod, bool playerattack) {
		static const string messages[] = {
			"$HXDD.HEXEN2.WEAPONS.PALADIN.PURIFIER.OBITUARY.1",
			"$HXDD.HEXEN2.WEAPONS.PALADIN.PURIFIER.OBITUARY.2"
		};

		return messages[Random(0, messages.Size() - 1)];
	}
}


class PWeapPurifier_DragonBall: Actor {
	double tickDuration;
	property tickDuration: tickDuration;

	vector3 avelocity;	

	double delayHoming;

	Default {
		+HITTRACER;
        +ZDOOMTRANS;
		+FORCERADIUSDMG;

		RenderStyle "Add";

		DamageFunction 0;
		DamageType "Fire";

		Speed (1000.0/32.0);
		Radius 12;
		Height 12;
		Projectile;
		Scale 1;
		
		DeathSound "hexen2/weapons/exphuge";
		Obituary "$HXDD.HEXEN2.WEAPONS.PALADIN.PURIFIER.OBITUARY.1";

		PWeapPurifier_DragonBall.tickDuration (2.5 * TICRATEF);
	}

	States {
		Spawn:
			DBLL A 1 Bright A_HandleHoming;
			Loop;
		Death:
			TNT1 A 0 A_GetDamage;
			Stop;
	}

	void A_HandleHoming() {
		if (self.delayHoming <= 0.0) {
			self.A_SeekerMissile(2, 10, SMF_LOOK | SMF_CURSPEED, 50);
			self.delayHoming = (0.15 * TICRATEF);
			return;
		}
		self.delayHoming--;
	}

	override void PostBeginPlay() {
		Super.PostBeginPlay();

		self.delayHoming = ((1/3) * TICRATEF);

		Vector3 avelocity = (-6.25, 6.25, -6.25);
		angle += avelocity.x;
		pitch += avelocity.y;
		roll += avelocity.z;
	
		ParticleGenerator pg = ParticleGenerator(Spawn("ParticleGenerator"));
		pg.Attach(self);
		pg.velocity[0] = (0, 0, 15);
		pg.velocity[1] = (0, 0, 15);
		pg.amount = 1;
		pg.lifetime = 1.7;
		pg.rate = 35 * 0.15;
		pg.startalpha = 1.0;
		pg.sizestep = 0.12;
		pg.size = 5;
		pg.actorParticleTypes.push("PWeapPurifier_PuffRing");
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

		self.tickDuration -= 1;
		if (self.tickDuration <= 0) {
			self.Destroy();
		}
	}

	void A_GetDamage() {
		int damage = random[pweap_purifer_dball_touch](120,200);
		A_SetRenderStyle(0.7, STYLE_Translucent);
		if (tracer) {
			tracer.DamageMobj(self, target, damage, 'Fire');
		}
		int ex_damage = random[pweap_purifer_dball_ex](120,160);
		self.A_Explode(ex_damage, ex_damage + 40, 0, true, damagetype: "Fire");

		Actor sprfx = Spawn("BigExplosion");
		sprfx.SetOrigin(self.pos, false);
	}

	override string GetObituary(Actor victim, Actor inflictor, Name mod, bool playerattack) {
		static const string messages[] = {
			"$HXDD.HEXEN2.WEAPONS.PALADIN.PURIFIER.OBITUARY.1",
			"$HXDD.HEXEN2.WEAPONS.PALADIN.PURIFIER.OBITUARY.2"
		};

		return messages[Random(0, messages.Size() - 1)];
	}
}

class PWeapPurifier_PuffRing: SpriteFXParticle {
	double duration;
	property duration: duration;

	int idxTexture;

	Default {
		RenderStyle "Translucent";
		Alpha 0.9;

		PWeapPurifier_PuffRing.duration 1.7;	// ramp up time is ~1/3rd of a second
	}

	States {
		Spawn:
			RING A 1;
			Loop;
	}

	override void Tick() {
		Super.Tick();

		self.duration -= 1.0 / TICRATEF;

		if (self.duration < 0.30) {
			self.ChangeTexture(4);
		} else if (self.duration < 0.60) {
			self.ChangeTexture(3);
		} else if (self.duration < 0.90) {
			self.ChangeTexture(2);
		} else if (self.duration < 1.20) {
			self.ChangeTexture(1);
		}
	}

	void ChangeTexture(int nextIdx) {
		if (self.idxTexture != nextIdx) {
			self.idxTexture = nextIdx;
			self.A_ChangeModel(self.GetClassName(),
				modelindex: 0, modelpath: "models/", model: "ring.md3",
				skinindex: 0, skinpath: "models/", String.format("ring_skin%d", self.idxTexture),
				generatorindex: 0
			);
		}
	}
}