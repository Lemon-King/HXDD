// https://github.com/videogamepreservation/hexen2/blob/master/H2MP/hcode/purifier.hc

class PWeapPurifierPiece: WeaponPiece {
	Default {
		Inventory.PickupSound "misc/w_pkup";
		Inventory.PickupMessage "$TXT_PURIFIER_PIECE";
		Inventory.RestrictedTo "HX2PaladinPlayer";
		WeaponPiece.Weapon "PWeapPurifier";
		+FLOATBOB
	}
}

class PWeapPurifierPiece1: PWeapPurifierPiece {
	Default {
		WeaponPiece.Number 1;
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
		Weapon.AmmoGive 20;
		Weapon.KickBack 150;
		//Weapon.YAdjust 40;
		Inventory.PickupMessage "$TXT_WEAPON_PURIFIER";
		Inventory.PickupSound "WeaponBuild";
		Tag "$TAG_PWEAPPURIFIER";
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
		vector2 recoil = (frandom(-3.0, 0.0), 0.0);
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
				proj.Scale.y = -1;		// hack: it works by flipping the model
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
		
		//SeeSound "hexen2/succubus/acidfire";
		DeathSound "hexen2/weapons/expsmall";
		Obituary "$OB_MPPWEAPPURIFIER";

		PWeapPurifier_Missile.tickDuration (2.5 * 35.0);
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
}


class PWeapPurifier_DragonBall: Actor {
	double tickDuration;
	property tickDuration: tickDuration;

	vector3 avelocity;	

	double delayHoming;

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
		
		DeathSound "hexen2/weapons/exphuge";
		Obituary "$OB_MPPWEAPPURIFIER";

		PWeapPurifier_DragonBall.tickDuration (2.5 * 35.0);
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
			self.delayHoming = (0.15 * 35.0);
			return;
		}
		self.delayHoming--;
	}

	override void PostBeginPlay() {
		Super.PostBeginPlay();

		self.delayHoming = ((1/3) * 35.0);

		Vector3 avelocity = (-6.25, 6.25, -6.25);
		angle += avelocity.x;
		pitch += avelocity.y;
		roll += avelocity.z;
	
		ParticleGenerator pg = ParticleGenerator(Spawn("ParticleGenerator"));
		pg.Attach(self);
		pg.velocity[0] = (0, 0, 15);
		pg.velocity[1] = (0, 0, 15);
		pg.amount = 1;
		pg.lifetime = 1.2;
		pg.rate = 35 * 0.15;
		pg.startalpha = 1.0;
		pg.sizestep = 0.00;
		pg.size = 5;
		pg.actorParticleTypes.push("PWeapPurifier_PuffRing");
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
}

class PWeapPurifier_PuffRing: SpriteFXParticle {
	double tickDuration;
	property tickDuration: tickDuration;

	Default {
		RenderStyle "Translucent";
		Alpha 0.9;

		PWeapPurifier_PuffRing.tickDuration (2.5 * 35.0);
	}

	States {
		Spawn:
			RING A 1;
			Loop;
	}
}