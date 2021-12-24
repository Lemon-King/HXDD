// Paladin Weapon: Axe

class PWeapAxe : PaladinWeapon
{
	Default
	{
		Weapon.SelectionOrder 1500;
		Weapon.KickBack 150;
		Weapon.YAdjust 0;
		Weapon.AmmoType1 "Mana2";
		Weapon.AmmoUse 2;
		Weapon.AmmoGive 100;
		+BLOODSPLATTER
		+FLOATBOB
        +WEAPON.AMMO_OPTIONAL

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
		PAXA AEHIJK 2;		// https://github.com/videogamepreservation/hexen2/blob/master/H2MP/hcode/axe.hc#L231
		PAXA L 2 A_Swing;
		PAXA MNOPQR 2;
		Goto Ready;
	}

	override void Tick() {
		Super.Tick();
	}

	action void A_SwingSFX(bool hasTome, int ammoAmount) {
		if (player == null) {
			return;
		}

		if (hasTome && ammoAmount > 0) {
			A_StartSound("hexen2/paladin/axgenpr");
		} else {
			A_StartSound("hexen2/weapons/vorpswng");
		}
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

        Ammo ammoMana1 = Ammo((Player.mo.FindInventory("mana1", true)));
        int amount = ammoMana1.amount;

		A_SwingSFX(hasTome, amount);
        A_Melee(hasTome, amount);

        if (hasTome && amount > 0) {
		    PWeapVorpalSword_MissileWave(SpawnPlayerMissile("PWeapAxe_BladeProjectile", angle, 0, 0, 12));
        } else {
			A_StartSound("hexen2/paladin/axgen");
		    PWeapVorpalSword_MissileWave(SpawnPlayerMissile("PWeapAxe_BladeProjectile", angle, 0, 0, 12));
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
}

class PWeapAxe_BladeProjectile : Hexen2Projectile {

	double tickDuration;
	property tickDuration: tickDuration;

	Actor attachedActor[2];

	double damageMulti;

	int waveType;

	Default {
		DamageFunction 0;
		+HITTRACER
		+SPAWNSOUNDSOURCE
		+BOUNCEONCEILINGS
		+CANBOUNCEWATER
		+ALLOWBOUNCEONACTORS
		+DONTBOUNCEONSKY
		
		// https://zdoom.org/wiki/Actor_properties#BounceType
		Bouncetype "Hexen";
		BounceFactor 1.0;
		WallBounceFactor 1.0;

		Speed 28.125;
		//Radius 5;
		Radius 10;
		Height 10;
		Projectile;
        //SeeSound "hexen2/necro/mmfire";
		BounceSound "";
		DeathSound "hexen2/weapons/explode";
		Obituary "$OB_MPMWEAPFROST";
        Scale 1.0;

        PWeapAxe_BladeProjectile.tickDuration 3.0f;
	}

	States
	{
	Spawn:
		AXEP ABCD 1;
		Loop;
	Death:
		TNT1 A 1 A_GetDamage;
		Stop;
	}

	void A_GetDamage() {
		if (!attachedActor[0]) {
			// Hacky check to prevent double A_GetDamage triggers with side tracers
			return;
		}
		PWeapVorpalSword_Shock shock = PWeapVorpalSword_Shock(Spawn("PWeapVorpalSword_Shock"));
		if (shock) {
			shock.angle = self.angle;
			shock.pitch = self.pitch;
			shock.roll = self.roll;
			shock.target = self.target;
			shock.SetOrigin(self.pos, false);
		}

		if (attachedActor[0]) {
			attachedActor[0].Destroy();
			attachedActor[1].Destroy();
		}

		angle = 0;
		pitch = 0;
		roll = 0;
		Scale.x = 1.0f;
		Scale.y = 1.0f;
		Alpha = 0.8f;
        A_SetRenderStyle(1, STYLE_Add);
		if (tracer) {
			if (damageMulti == 0) {
				damageMulti = 1.0;
			}
         	int damage = random[VorpalWave](30, 60) * damageMulti;
         	tracer.DamageMobj(self, target, damage, "None");
		}
	}
}