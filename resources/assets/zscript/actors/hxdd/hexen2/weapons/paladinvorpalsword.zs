// Paladin Weapon: Vorpal Sword
// REF: https://github.com/videogamepreservation/hexen2/blob/master/H2MP/hcode/vorpal.hc

class PWeapVorpalSword : PaladinWeapon
{
	Default
	{
		Weapon.SelectionOrder 1600;
		Weapon.KickBack 150;
		Weapon.YAdjust 0;
		Weapon.AmmoType1 "Mana1";
		Weapon.AmmoUse 0;
		Weapon.AmmoGive 25;
		Inventory.PickupMessage "$HXDD.HEXEN2.WEAPONS.PALADIN.VORPAL_SWORD.PICKUP";
		+BLOODSPLATTER
		+FLOATBOB
        +WEAPON.AMMO_OPTIONAL

		Obituary "$HXDD.HEXEN2.WEAPONS.PALADIN.VORPAL_SWORD.OBITUARY";
		Tag "$HXDD.HEXEN2.WEAPONS.PALADIN.VORPAL_SWORD.TAG";

		FloatBobStrength 0.25;
	}

	States {
		Spawn:
			PKUP A -1;
			Stop;
		Select:
			TNT1 A 0 Offset(0, 32);
			PSWA EDCBA 2;
			PSWA ABCDEFG 2;
			PSWA H 2 A_StartSound("hexen2/weapons/vorpswng");
			PSWA IJKL 2;
			PSWA M 2 A_StartSound("hexen2/weapons/vorpswng");
			PSWA NOPQRSTUV 2;
			PSWR A 0 A_Raise(100);
			Loop;
		Deselect:
			PSWR A 2 Offset(0, 32);		// has a unique blending issue, setting to 2 ticks corrects deselect motion
			PSWC ABCDE 2;
			TNT1 A 0 A_Lower(100);
			Loop;
		Ready:
			PSWR A 2 A_WeaponReady;
			Loop;
		Fire:
			PSWB A 2;
			PSWB B 2 A_SwingSFX;
			PSWB C 2 A_Swing;
			PSWB DEFGHIJKLM 2;
			Goto Ready;
	}

    override void Tick() {
        Super.Tick();
        
		if (player == null) {
			self.lightlevel = LemonActor.HX2RenderPickupGlow(self);
		}
    }


	action void A_SwingSFX() {
		if (player == null) {
			return;
		}

        Ammo ammoMana1 = Ammo((Player.mo.FindInventory("Mana1", true)));
        int amount = ammoMana1.amount;

		Weapon weapon = player.ReadyWeapon;
        bool hasTome = Player.mo.FindInventory("PowerWeaponLevel2", true);

		if (hasTome && amount > 0) {
			A_StartSound("hexen2/weapons/vorppwr");
		} else {
			A_StartSound("hexen2/weapons/vorpswng");
		}
	}

	action void A_Swing() {
		if (player == null) {
			return;
		}

        Ammo ammoMana1 = Ammo((Player.mo.FindInventory("Mana1", true)));
        int amount = ammoMana1.amount;

		Weapon weapon = player.ReadyWeapon;
        bool hasTome = Player.mo.FindInventory("PowerWeaponLevel2", true);
        if (hasTome) {
            weapon.AmmoUse1 = min(4, amount);	// vorpal projectile can use all remaining ammo and deal less damage
        } else {
            weapon.AmmoUse1 = 2;
        }

        bool success = A_Melee(hasTome, amount);
        if (success || hasTome) {
            if (weapon != null) {
                if (!weapon.DepleteAmmo(weapon.bAltFire)) {
                    return;
                }
            }
        }
        if (hasTome && amount > 0) {
		    PWeapVorpalSword_MissileWave projWave = PWeapVorpalSword_MissileWave(SpawnPlayerMissile("PWeapVorpalSword_MissileWave", angle, 0, 0, 7));
			if (projWave) {
				projWave.angle = Player.mo.angle;
				projWave.pitch = Player.mo.pitch;
				projWave.roll = Player.mo.roll;
				projWave.waveType = weaponspecial;
				weaponspecial++;
				if (weaponspecial > 1) {
					weaponspecial = 0;
				}
				if (amount < 4) {
					projWave.damageMulti = 0.5;
				}
			}
        }
	}

    action bool A_Melee(bool hasTome, int ammoAmount) {
		FTranslatedLineTarget t;

		if (player == null) {
			return false;
		}

		String fx = "Hexen2HitSFX";
		if (ammoAmount > 2) {
			// spawn swipe
			PWeapVorpalSword_Swipe swipe = PWeapVorpalSword_Swipe(Spawn("PWeapVorpalSword_Swipe"));
			if (swipe) {
				swipe.SetOwner(player);

				fx = "SmallWhiteFlashSFX";
			}
		}

        double damage = 0;
        if (ammoAmount >= 4 && hasTome) {
            // Powered Melee Damage
			damage = 40 + frandom[vorpalmelee](0.0, 30.0);
			damage += damage * .25;
        } else if (ammoAmount > 2) {
            // Normal Melee Damage with Mana
			damage = 30 + frandom[vorpalmelee](0.0, 20.0);
        } else {
            // Normal Melee Damage
			damage = 20 + frandom[vorpalmelee](0.0, 10.0);
        }
		damage += GetPowerUpHolyStrengthMultiplier() * damage;

		for (int i = 0; i < 16; i++)
		{
			for (int j = 1; j >= -1; j -= 2)
			{
				double ang = angle + j*i*(45. / 16);
				double slope = AimLineAttack(ang, MELEE_RANGE, t, 0., ALF_CHECK3D);
				if (t.linetarget)
				{
					LineAttack(ang, MELEE_RANGE, slope, damage, 'Melee', fx, LAF_ISMELEEATTACK, t);
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
		LineAttack(angle, DEFMELEERANGE, slope, damage, 'Melee', "WhiteSmokeSFX", offsetz: 2);
        return false;
    }
}

class PWeapVorpalSword_Swipe : Actor {
	PlayerInfo owner;

	Default
	{
		RenderStyle "Translucent";
		Alpha 1.0;

		Scale 0.5;

		+NOGRAVITY
		+NOBLOCKMAP
		+ZDOOMTRANS
	}

	States
	{
	Spawn:
		TNT1 A 2;		// Single frame delay
		SWIP ABCDEFG 2;
		Stop;
	}

    override void BeginPlay() {
        Super.BeginPlay();
    }

	override void PostBeginPlay() {
		Super.PostBeginPlay();

		self.UpdateOrigin();
	}

	override void Tick() {
		Super.Tick();

		self.UpdateOrigin();
	}

	void SetOwner(PlayerInfo p) {
		self.owner = p;
		self.target = self.owner.mo;
		self.angle = self.target.angle;
		self.pitch = self.target.pitch;
		self.roll = self.target.roll;

		self.UpdateOrigin();

		for (int i = 0; i < Players.Size(); i++) {
			if (i != p.mo.PlayerNumber()) {
				self.DisableLocalRendering(i, true);
			}
		}
	}

	void UpdateOrigin() {
		self.angle = self.target.angle;
		self.pitch = self.target.pitch;
		self.roll = self.target.roll;

		double a = self.angle;
        double p = Clamp(self.pitch, -90, 90);
        double r = self.roll;
        let mat = HXDD_GM_Matrix.fromEulerAngles(a, p, r);
        mat = mat.multiplyVector3((0, 0, -10));
        vector3 offsetPos = mat.asVector3(false);

		Vector3 pos = (self.target.pos.x, self.target.pos.y, self.owner.viewz) + offsetPos;
		SetOrigin(pos, true);
	}
}

// Powered Projectile

class PWeapVorpalSword_MissileWaveFX : Actor {
	Actor parent;
	
	Default {
		+NOBLOCKMAP
		+NOGRAVITY
		+NOINTERACTION
		+NOCLIP
		+ZDOOMTRANS

		RenderStyle "Add";
		Alpha 0.9;
        Scale 0.5;

		Height 0;
		Radius 0;
	}
	States
	{
	Spawn:
		SHKS ABCDEFGHIJKLMNO 1 Bright;
		Goto Looping;
	Looping:
		SHKL ABCDEFGHIJKLMNO 1 Bright;
		Loop;
	}

    override void BeginPlay() {
        Super.BeginPlay();
	}

	override void Tick() {
		Super.Tick();
		Scaler();
		if (parent == NULL) {
			Destroy();
		}
	}

	action void Scaler() {
		if (Scale.x < 2.4) {
			double s = Scale.x += 0.15;
			if (s > 2.4) {
				s = 2.4;
			}
			Scale.x = s;
			Scale.y = s;
		}
	}
}

// TODO REPLACE WITH CHANGEMODEL
class PWeapVorpalSword_MissileWaveA : PWeapVorpalSword_MissileWaveFX {
	override void Tick() {
		Super.Tick();
	}
}
class PWeapVorpalSword_MissileWaveB : PWeapVorpalSword_MissileWaveFX {
	override void Tick() {
		Super.Tick();
	}
}
class PWeapVorpalSword_MissileWave : Hexen2Projectile {

	double tickDuration;
	property tickDuration: tickDuration;

	Actor attachedActor[2];

	double damageMulti;

	int waveType;

	Default {
		DamageFunction 0;
		+HITTRACER
		+ZDOOMTRANS
		+SPAWNSOUNDSOURCE

		RenderStyle "Add";

		Speed 31.25;
		//Radius 5;
		Radius 15;
		Height 10;
		DamageType "Electric";		// flavor
		Projectile;
		DeathSound "hexen2/weapons/explode";
		Obituary "$HXDD.HEXEN2.WEAPONS.PALADIN.VORPAL_SWORD.SHOCKWAVE.OBITUARY";
        Scale 1.0;

        PWeapVorpalSword_MissileWave.tickDuration 3.0f;
	}

	States
	{
	Spawn:
		TNT1 A 1;
		Loop;
	Death:
		TNT1 A 1 A_GetDamage;
		Stop;
	}

    override void PostBeginPlay() {
        Super.PostBeginPlay();

		attachedActor[0] = Spawn("PWeapVorpalSword_MissileWaveA", pos);
		attachedActor[1] = Spawn("PWeapVorpalSword_MissileWaveB", pos);
		PWeapVorpalSword_MissileWaveFX(attachedActor[0]).parent = self;
		PWeapVorpalSword_MissileWaveFX(attachedActor[1]).parent = self;
		bool cvarFlickingProjectile = LemonUtil.CVAR_GetBool("hxdd_disable_vorpal_flashing_projectile", false);
		if (cvarFlickingProjectile) {
			attachedActor[0].Alpha = 0.5;
			attachedActor[1].Alpha = 0.5;
		}
    }

	override void Tick() {
		Super.Tick();

		if (InStateSequence(CurState, self.Findstate("Death"))) {
			return;
		}
		if (tickDuration <= 0) {
			if (attachedActor[0]) {
				attachedActor[0].Destroy();
				attachedActor[1].Destroy();
			}
			Destroy();
		}

		tickDuration -= TICRATEF / 1000.0f;

		Vector3 facing = LemonUtil.GetEularFromVelocity(self.vel);
		self.angle = facing.x;
		self.pitch = facing.y;
		self.roll = facing.z;
		
		//if (!self.tracer) {
			//TraceSide(-90.0);
			//TraceSide(90.0);
		//}

		if (attachedActor[0]) {
			bool cvarFlickingProjectile = LemonUtil.CVAR_GetBool("hxdd_disable_vorpal_flashing_projectile", false);
			if (!cvarFlickingProjectile) {
				waveType = (waveType + 1) % 2;
				attachedActor[0].Alpha = waveType;
				attachedActor[1].Alpha = (waveType + 1) % 2;
			}
			for (int i = 0; i < 2; i++) {
				attachedActor[i].angle = self.angle;
				attachedActor[i].pitch = self.pitch;
				attachedActor[i].roll = self.roll;
				attachedActor[i].SetOrigin(self.pos, true);
			}
		}
	}

	override int DoSpecialDamage(Actor victim, int damage, Name damagetype)
	{
		if (special2 > 0)
		{
			damage <<= special2;
		}
		return damage;
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
			shock.damageMulti = self.damageMulti;
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
         	int newDamage = tracer.DamageMobj(self, target, damage, 'Electric');
			tracer.TraceBleed(newDamage > 0 ? newDamage : damage, self);
		}
	}

	void TraceSide(double angleOffset) {
		// Fakes a wide projectile without a large radius
        FTranslatedLineTarget t;
		AimLineAttack(angle + angleOffset, 64.0, t, 32, ALF_CHECK3D);
		//LineAttack(self.angle + angleOffset, 64, self.pitch, 0, 'Electric', "BulletPuff", LAF_TARGETISSOURCE, t);
		if (t.linetarget) {
			self.tracer = t.linetarget;
			//A_StartSound(DeathSound, CHAN_WEAPON);
			//self.SetState(self.Findstate("Death"));
			A_Die();
			/*
			if (damageMulti == 0) {
				damageMulti = 1.0;
			}
         	int damage = random[VorpalWave](30, 60) * damageMulti;
         	t.linetarget.DamageMobj(self, target, damage, 'Electric');
			 */

		}
	}
}

class PWeapVorpalSword_Shock : Actor {
	double tickDuration;
	property tickDuration: tickDuration;

	double damageMulti;
	int waveType;

	int idx;

	Default {
		+NOBLOCKMAP
		+NOGRAVITY
		+NOCLIP
		+ZDOOMTRANS
		+PUFFONACTORS

		RenderStyle "Add";
		Alpha 0.9;
        Scale 1.0;

		Height 0;
		Radius 0;
		
		PWeapVorpalSword_Shock.tickDuration 0.5 * 35;
	}

	States {
		Spawn:
			SHOK AB 1 Bright;
			Loop;
	}

    override void BeginPlay() {
        Super.BeginPlay();
    }

	override void PostBeginPlay() {
		Super.PostBeginPlay();
	}

	override void Tick() {
		Super.Tick();

		if (tickDuration <= 0) {
			Destroy();
		}

		// fade out
		double tickFade = self.Default.tickDuration * 0.33333;
		if (tickDuration <= tickFade) {
			Alpha = self.Default.Alpha * (tickDuration / tickFade);
		}

		Scale.x = self.Default.Scale.x * frandom[shokrng](0.8, 1.4);
		Scale.y = self.Default.Scale.y * frandom[shokrng](0.8, 1.4);

		self.tickDuration--;
		self.idx = (idx + 1) % 2;
		if (self.idx == 1 && self.target && self.target.health > 0) {
			if (self.damageMulti == 0) {
				self.damageMulti = 1.0;
			}
			double damage = 5.0 * self.damageMulti;
         	int newDamage = self.DamageMobj(self, self.target, damage, 'Electric');
			self.target.TraceBleed(newDamage > 0 ? newDamage : damage, self);
		}
	}
}

class PWeapVorpalSword_Shock2 : Actor {
	int idxTexture;
	double lifeTime;

	double damageMulti;

	Actor parent;

	States {
		Spawn:
			PSK2 A 1 Bright;
			Loop;
	}

	override void BeginPlay() {
		self.lifeTime = 0.5 * TICRATEF;
	}

	override void Tick() {
		Super.Tick();

		self.lifeTime--;

		SwapTexture();

		self.Scale.x;
		self.Scale.y;	
	}

	void SetParent(Actor nextParent) {
		self.parent = nextParent;
	}

	void SwapTexture() {
		self.idxTexture = (idxTexture + 1) % 2;
		self.A_ChangeModel(self.GetClassName(),
			modelindex: 0, modelpath: "models/", model: "vorpshk2.md3",
			skinindex: 0, skinpath: "models/", String.format("vorpshk2_skin%d", self.idxTexture),
			generatorindex: 0
        );
	}
}