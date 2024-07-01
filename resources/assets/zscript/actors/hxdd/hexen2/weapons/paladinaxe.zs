// Paladin Weapon: Axe
// ref: https://github.com/videogamepreservation/hexen2/blob/master/H2MP/hcode/axe.hc

class PWeapAxe : PaladinWeapon {
	Default {
		Weapon.SelectionOrder 1000;
		Weapon.KickBack 150;
		Weapon.YAdjust 0;
		Weapon.AmmoType1 "Mana2";
		Weapon.AmmoUse 2;
		Weapon.AmmoGive 32;
		Inventory.PickupMessage "$HXDD.HEXEN2.WEAPONS.PALADIN.AXE.PICKUP";
		+BLOODSPLATTER
		+FLOATBOB

		Obituary "$OB_MPPWEAPAXE";
		Tag "$TAG_PWEAPAXE";

		FloatBobStrength 0.25;
	}

	States {
		Spawn:
			PKUP A -1;
			Stop;
		Select:
			TNT1 A 0 Offset(0, 32);
			PAXS ABC 2;
			PAXS D 2 A_StartSound("hexen2/weapons/vorpswng");
			PAXS EFGHIJKL 2;
			PAXR A 0 A_Raise(100);
			Loop;
		Deselect:
			PAXR A 2 Offset(0, 32);
			PAXS ABCDEFG 2;             // Hexen II has all frames queued, but only displays about half during weapon swap
			TNT1 A 0 A_Lower(100);
			Loop;
		Ready:
			PAXR A 2 A_WeaponReady;
			Loop;
		Fire:
			PAXA AEHIJK 2;				// Skipped Frames: https://github.com/videogamepreservation/hexen2/blob/master/H2MP/hcode/axe.hc#L231
			PAXA L 2 A_Swing;
			PAXA MNOPQR 2;
			Goto Ready;
	}

	override void Tick() {
		Super.Tick();
	}

	action void A_Swing() {
		if (player == null) {
			return;
		}

		Weapon weapon = player.ReadyWeapon;
        bool hasTome = Player.mo.FindInventory("PowerWeaponLevel2", true);
        if (hasTome) {
            weapon.AmmoUse1 = 8;
        } else {
            weapon.AmmoUse1 = 2;
        }

		if (weapon != null) {
			if (!weapon.DepleteAmmo(weapon.bAltFire)) {
				return;
			}
		}

        Ammo ammoMana1 = Ammo((Player.mo.FindInventory("Mana2", true)));
        int amount = ammoMana1.amount;

		A_StartSound("hexen2/weapons/vorpswng");
        A_Melee(hasTome, amount);

        if (hasTome) {
			double angOff = 5.0 * 3.2;
			A_StartSound("hexen2/paladin/axgenpr");
		    PWeapAxe_BladeProjectilePower(SpawnFirstPerson("PWeapAxe_BladeProjectilePower", 30, 7, -5, 0));
		    PWeapAxe_BladeProjectilePower(SpawnFirstPerson("PWeapAxe_BladeProjectilePower", 30, 7, -5, false, -angOff));
		    PWeapAxe_BladeProjectilePower(SpawnFirstPerson("PWeapAxe_BladeProjectilePower", 30, 7, -5, false, angOff));
        } else {
			A_StartSound("hexen2/paladin/axgen");
		    PWeapAxe_BladeProjectilePower(SpawnFirstPerson("PWeapAxe_BladeProjectile", 30, 7, -5, true));
		}
	}

    action bool A_Melee(bool hasTome, int ammoAmount) {
		FTranslatedLineTarget t;

		if (player == null) {
			return false;
		}

        double damage = 0;
        if (ammoAmount >= 8 && hasTome) {
            // Powered Melee Damage
			damage = frandom[axemelee](50.0, 75.0);
        } else {
            // Normal Melee Damage with Mana
			damage = frandom[axemelee](24.0, 30.0);
        }

		for (int i = 0; i < 16; i++)
		{
			for (int j = 1; j >= -1; j -= 2)
			{
				double ang = angle + j*i*(45. / 16);
				double slope = AimLineAttack(ang, MELEE_RANGE, t, 0., ALF_CHECK3D);
				if (t.linetarget)
				{
					LineAttack(ang, MELEE_RANGE, slope, damage, 'Melee', "SickleSparks_Hit", true, t);
					if (t.linetarget != null)
					{
						AdjustPlayerAngle(t);
						return true;
					}
				}
			}
		}
		
		// didn't find any creatures, try to strike any walls
		double slope = AimLineAttack (angle, DEFMELEERANGE, null, 0., ALF_CHECK3D);
		String sparksEffect = "SickleSparks";
		if (hasTome) {
			sparksEffect = "SickleSparks_PowerHit";
		}
		LineAttack(angle, DEFMELEERANGE, slope, damage, 'Melee', sparksEffect);
        return false;
    }
}

class PWeapAxe_BladeProjectileTail: Actor {
	// TODO
	// https://github.com/videogamepreservation/hexen2/blob/master/H2MP/hcode/axe.hc#L74

	Default {
		RenderStyle "Translucent";
		Alpha 0.4;

		Scale 1.0;

		+NOGRAVITY
		+NOBLOCKMAP
		+ZDOOMTRANS
	}

	States {
		Spawn:
			TAIL AB 2;
			Loop;
	}

	override void Tick() {
		Super.Tick();
		
		if (!self.target) {
			self.Destroy();
		}
	}
}

class PWeapAxe_BladeProjectileExplodeHit: Actor {
	Default {
		RenderStyle "Add";

		+NOGRAVITY
		+NOBLOCKMAP
		+ZDOOMTRANS
	}
	States {
		Spawn:
			SMEX A 2 Bright;
			SMEX BCDEFGHIJKL 2 Bright;
			Stop;
	}
}
class PWeapAxe_BladeProjectileExplodePowerHit: Actor {
	Default {
		RenderStyle "Add";
		Scale 0.5;

		+NOGRAVITY
		+NOBLOCKMAP
		+ZDOOMTRANS
	}
	States {
		Spawn:
			BLU3 A 2 Bright;
			BLU3 BCDEFGHI 2 Bright;
			Stop;
	}
}
class PWeapAxe_BladeProjectileFade: Actor {
	Default {
		RenderStyle "Add";
		Alpha 0.75;

		+NOGRAVITY
		+NOBLOCKMAP
		+ZDOOMTRANS
	}
	States {
		Spawn:
			SMBL ABC 2 Bright;
			Stop;
	}
}

class PWeapAxe_BladeProjectilePower : PWeapAxe_BladeProjectile {
	Default {
		RenderStyle "Add";
	}

	override void BeginPlay() {
		self.A_ChangeModel(self.GetClassName(),
			modelindex: 0, modelpath: "models/", model: "axblade.md3",
			skinindex: 0, skinpath: "models/", "axblade_skin1",
			generatorindex: 0
        );
	}
}
class PWeapAxe_BladeProjectile : Hexen2Projectile {

	double tickDuration;
	property tickDuration: tickDuration;

	Actor attachedTail;

	double damageMulti;

	int waveType;

	int bounces;
	property bounces: bounces;

	Default {
		DamageFunction 0;
		+HITTRACER
		+SPAWNSOUNDSOURCE
		+USEBOUNCESTATE
		+BOUNCEONCEILINGS
		+CANBOUNCEWATER
		+ALLOWBOUNCEONACTORS
		+BOUNCEONACTORS
		+DONTBOUNCEONSKY
		
		// https://zdoom.org/wiki/Actor_properties#BounceType
		Bouncetype "Hexen";
		BounceFactor 1.0;
		WallBounceFactor 1.0;

		Speed 28.125;
		Radius 10;
		Height 5;
		Projectile;
		ActiveSound "";
		BounceSound "hexen2/paladin/axric1";
		WallBounceSound "hexen2/paladin/axric1";
		//DeathSound "hexen2/weapons/explode";
		Obituary "$OB_MPMWEAPFROST";
        Scale 1.0;

        PWeapAxe_BladeProjectile.tickDuration 2.0f;
	}

	States {
		Spawn:
			AXEP ABCD 1;
			Loop;
		Bounce:
			AXEP A 0 A_OnBounce();
			Goto Spawn;
		Death:
			Stop;
	}

	override void PostBeginPlay() {
		Super.PostBeginPlay();
		PWeapAxe_BladeProjectileTail tail = PWeapAxe_BladeProjectileTail(Spawn("PWeapAxe_BladeProjectileTail"));
		if (tail) {
			tail.target = self;
			tail.angle = self.angle;
			tail.pitch = self.pitch;
			tail.roll = self.roll;
			tail.SetOrigin(self.pos, false);
			self.attachedTail = tail;
		}
	}

	override void Tick() {
		Super.Tick();
		
		Vector3 facing = LemonUtil.GetEularFromVelocity(self.vel);
		self.angle = facing.x;
		self.pitch = facing.y;
		self.roll = facing.z;

		if (self.attachedTail) {
			self.attachedTail.angle = facing.x;
			self.attachedTail.pitch = facing.y;
			self.attachedTail.roll = facing.z;
			self.attachedTail.SetOrigin(self.pos, true);
		}

		if (tickDuration <= 0) {
			A_DestroySelf();
		}

		tickDuration -= 35.0f / 1000.0f;
	}

	void A_OnBounce() {
		// use lightbringer code for adjustment!

		Actor fx;
		A_StartSound("hexen2/weapons/explode");
		if (self is "PWeapAxe_BladeProjectilePower") {
			fx = Actor(Spawn("BlueExplosion"));
		} else {
			fx = Actor(Spawn("SmallExplosion"));
		}
		if (fx) {
			fx.SetOrigin(self.pos, false);
		}

		self.bounces++;
		if (tracer && (tracer.bIsMonster || tracer.bShootable)) {
			self.bounces++;	// doubled on monster hit
			if (self is "PWeapAxe_BladeProjectilePower") {
				A_DamageRadius();
			}
			A_DamageHit();
		}
		if (self.bounces >= 4) {
			A_DestroySelf();
		}
	}

	void A_DamageHit() {
		int damage = random[AxeProjectile](30, 50);
		damage += GetPowerUpHolyStrengthMultiplier() * damage;
		int newDamage = tracer.DamageMobj(self, target, damage, "None");
		//if (tracer.bIsMonster) {
		//	tracer.TraceBleed(newDamage > 0 ? newDamage : damage, self);
		//}
		tracer = null;
	}

	void A_DamageRadius() {
		int damage = random[AxeProjectile](25, 45);
		damage += GetPowerUpHolyStrengthMultiplier() * damage;
		A_Explode(damage, 30.0, alert:true);
	}

	void A_DestroySelf() {
		Actor fxFade;
		if (self is "PWeapAxe_BladeProjectilePower") {
			fxFade = Actor(Spawn("SmallWhiteFlash"));
		} else {
			fxFade = Actor(Spawn("SmallBlueFlash"));
		}
		if (fxFade) {
			fxFade.SetOrigin(self.pos, false);
		}

		if (attachedTail) {
			attachedTail.Destroy();
		}
		self.Destroy();
	}
}