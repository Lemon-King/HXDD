
// Both Magic Missiles and Bone Shards share a single model
// Homing needs to be fixed, but otherwise functional

class NWeapMagicMissile: NWeapSpellbook {
	Default {
		Weapon.SelectionOrder 1600;
		
		Weapon.AmmoType1 "Mana1";
		Weapon.AmmoUse 2;
		Weapon.AmmoGive 25;
		Obituary "$OB_MPNWEAPMAGICMISSILE";
		Tag "$TAG_NWEAPMAGICMISSILE";
	}
}

class NWeapBoneShards: NWeapSpellbook {
	Default {
		Weapon.AmmoType1 "Mana2";
		Weapon.AmmoUse 1;
		Weapon.AmmoGive 25;
		Obituary "$OB_MPNWEAPBONESHARDS";
		Tag "$TAG_NWEAPBONESHARDS";
	}
}

class NWeapSpellbook : NecromancerWeapon
{
	bool animationSwitch;

	Default
	{
		Weapon.SelectionOrder 3500;
		Weapon.KickBack 150;
		Weapon.YAdjust 0;
		Weapon.AmmoType1 "Mana1";
		Weapon.AmmoUse 3;
		Weapon.AmmoGive 100;
		+BLOODSPLATTER
		+FLOATBOB

		FloatBobStrength 0.25;
	}

	States
	{
	Spawn:
		PKUP A -1;
		Stop;
	Select:
		TNT1 A 0 A_DecideSelect;
		Loop;
	Deselect:
		TNT1 A 0 A_DecideDeselect;
		Loop;
	Select_MagicMissiles:
        TNT1 A 0 Offset(0, 32);
		NBMS ABCDEFGHIJKLMNOPQRST 2;
		NBMI A 0 A_Raise(100);
		Loop;
	Select_BoneShards:
        TNT1 A 0 Offset(0, 32);
		NBBS GFEDCBA 2;
		NBBI A 0 A_Raise(100);
		Loop;
	Deselect_MagicMissiles:
		NBMI A 0;
		NBMS TSRPONMLKJIHGFEDCBA 2;
		TNT1 A 0 A_Lower(100);
		Loop;
	Deselect_BoneShards:
		NBBI A 0;
		NBBS ABCDEFG 2;
		TNT1 A 0 A_Lower(100);
		Loop;
	FastSelect:
		// Fast Select for SwitchTo*
        TNT1 A 0 Offset(0, 32);
		TNT1 A 0 A_Raise(100);
		Loop;
	SwitchToMagicMissiles:
		NBBM ABCDEFGHIJKLM 2;
		NBMI A 0 A_Lower(100);
		Loop;
	SwitchToBoneShards:
		NBMB ABCDEFGHIJKLMN 2;
		NBBI A 0 A_Lower(100);
		Loop;
	Ready:
		TNT1 A 0 A_DecideReady;
		Loop;
	Ready_MagicMissiles:
		NBMI A 2 A_WeaponReadyRngIdles;
		Loop;
	Ready_BoneShards:
		NBBI A 2 A_WeaponReadyRngIdles;
		Loop;
	Idle_MagicMissiles:
		NBMI ABCDEFGHIJKLMNOPQRSTUV 2 A_WeaponReady;
		Goto Ready_MagicMissiles;
	Idle_BoneShards:
		NBBI ABCDEFGHIJKLMNOPQRSTUV 2 A_WeaponReady;
		Goto Ready_BoneShards;
	Fire:
		NBMF A 0 A_DecideAttackType;
		Goto Ready;
	Fire_MagicMissiles:
		NBMF ABCD 1;
		Goto Fire_MagicMissiles_ReFire;
	Fire_MagicMissiles_ReFire:
		NBMF E 1 A_FireMagicMissile;
		NBMF E 8;
		NBMF E 1 A_ReFire("Fire_MagicMissiles_ReFire");
		NBMF FGH 2;
		Goto Ready_MagicMissiles;
	Fire_MagicMissilesPower:
		NBMF ABCD 1;
		Goto Fire_MagicMissilesPower_ReFire;
	Fire_MagicMissilesPower_ReFire:
		NBMF E 1 A_FireMagicMissile;
		NBMF E 20;
		NBMF E 1 A_ReFire("Fire_MagicMissilesPower_ReFire");
		NBMF FGH 2;
		Goto Ready_MagicMissiles;
	Fire_BoneShards:
		NBBF AB 1;
		Goto Fire_BoneShards_ReFire;
	Fire_BoneShards_ReFire:
		NBBF C 1 A_FireBoneShard;
		NBBF C 2;
		NBBF C 1 A_ReFire("Fire_BoneShards_ReFire");
		NBBF DEFGHIJKL 1;
		Goto Ready_BoneShards;
	Fire_BoneShardsPower:
		NBBF AB 1;
		NBBF C 1 A_FireBoneShard;
		NBBF DEFGHIJKL 1;
		NBBF L 35;	// ~1.3 seconds (all frames after A_FireBoneShard)
		NBBF L 1;
		NBBI A 0;	// for blending
		Goto Ready_BoneShards;
	}

	action void A_DecideSelect() {
		State nextState = Player.ReadyWeapon.FindState("Select_MagicMissiles");
		if (Player.ReadyWeapon is "NWeapMagicMissile") {
			NWeapSpellbook weapSpellBook = NWeapSpellbook(Player.ReadyWeapon);
			if (weapSpellBook.animationSwitch) {
				weapSpellBook.animationSwitch = false;
				nextState = Player.ReadyWeapon.FindState("FastSelect");
			} else {
				nextState = Player.ReadyWeapon.FindState("Select_MagicMissiles");
			}
		} else if (Player.ReadyWeapon is "NWeapBoneShards") {
			NWeapSpellbook weapSpellBook = NWeapSpellbook(Player.ReadyWeapon);
			if (weapSpellBook.animationSwitch) {
				weapSpellBook.animationSwitch = false;
				nextState = Player.ReadyWeapon.FindState("FastSelect");
			} else {
				nextState = Player.ReadyWeapon.FindState("Select_BoneShards");
			}
		}
		Player.SetPsprite(PSP_WEAPON, nextState);
	}

	action void A_DecideDeselect() {
		State nextState = Player.ReadyWeapon.FindState("Deselect_MagicMissiles");
		if (Player.ReadyWeapon is "NWeapMagicMissile") {
			if (Player.PendingWeapon is "NWeapBoneShards") {
				NWeapSpellbook weapSpellBook = NWeapSpellbook(Player.PendingWeapon);
				weapSpellBook.animationSwitch = true;
				nextState = Player.ReadyWeapon.FindState("SwitchToBoneShards");
			} else {
				nextState = Player.ReadyWeapon.FindState("Deselect_MagicMissiles");
			}
		} else if (Player.ReadyWeapon is "NWeapBoneShards") {
			if (Player.PendingWeapon is "NWeapMagicMissile") {
				NWeapSpellbook weapSpellBook = NWeapSpellbook(Player.PendingWeapon);
				weapSpellBook.animationSwitch = true;
				nextState = Player.ReadyWeapon.FindState("SwitchToMagicMissiles");
			} else {
				nextState = Player.ReadyWeapon.FindState("Deselect_BoneShards");
			}
		}
		Player.SetPsprite(PSP_WEAPON, nextState);
	}

	action void A_DecideReady() {
		State nextState = Player.ReadyWeapon.FindState("Ready_MagicMissiles");
		if (Player.ReadyWeapon is "NWeapMagicMissile") {
			nextState = Player.ReadyWeapon.FindState("Ready_MagicMissiles");
		} else if (Player.ReadyWeapon is "NWeapBoneShards") {
			nextState = Player.ReadyWeapon.FindState("Ready_BoneShards");
		}
		Player.SetPsprite(PSP_WEAPON, nextState);
	}

	action void A_DecideAttackType() {
        bool hasTome = Player.mo.FindInventory("PowerWeaponLevel2", true);
		State nextState = Player.ReadyWeapon.FindState("Fire_MagicMissiles");
		if (Player.ReadyWeapon is "NWeapMagicMissile") {
			if (hasTome) {
				nextState = Player.ReadyWeapon.FindState("Fire_MagicMissilesPower");
			} else {
				nextState = Player.ReadyWeapon.FindState("Fire_MagicMissiles");
			}
		} else if (Player.ReadyWeapon is "NWeapBoneShards") {
			if (hasTome) {
				nextState = Player.ReadyWeapon.FindState("Fire_BoneShardsPower");
			} else {
				nextState = Player.ReadyWeapon.FindState("Fire_BoneShards");
			}
		}
		Player.SetPsprite(PSP_WEAPON, nextState);
	}

	action void A_WeaponReadyRngIdles() {
		if (frandom[spllbkidle](0.0, 1.0) < 0.1 && frandom[spllbkidle](0.0, 1.0) < 0.3 && frandom[spllbkidle](0.0, 1.0) < 0.5) {
			if (Player.ReadyWeapon is "NWeapMagicMissile") {
				Player.SetPsprite(PSP_WEAPON, Player.ReadyWeapon.FindState("Idle_MagicMissiles"));
			} else if (Player.ReadyWeapon is "NWeapBoneShards") {
				Player.SetPsprite(PSP_WEAPON, Player.ReadyWeapon.FindState("Idle_BoneShards"));
			}
		} else {
			A_WeaponReady();
		}
	}

	action void A_FireMagicMissile() {
		if (player == null) {
			return;
		}
		Weapon weapon = Player.ReadyWeapon;
        bool hasTome = Player.mo.FindInventory("PowerWeaponLevel2", true);
        if (hasTome) {
            weapon.AmmoUse1 = 10;
        } else {
            weapon.AmmoUse1 = 2;
        }

		if (weapon != null) {
			if (!weapon.DepleteAmmo(weapon.bAltFire)) {
				return;
            }
		}

		Actor flash = SpawnFirstPerson("NWeapSpellbook_Flash", 30, 10, -3, false, 0, 0);
		flash.angle = angle;
		flash.pitch = pitch;
		flash.roll = roll;

		// All 3 projectiles use veer
		// Make this work: https://github.com/videogamepreservation/hexen2/blob/eac5fd50832ce2509226761b3b1a387c468e7a50/H2MP/hcode/projbhvr.hc#L51
		String cvarHX2 = LemonUtil.CVAR_GetString("hxdd_installed_hexen2_world", "", Player);
		if (hasTome) {
			NWeapSpellbook_MagicMissile mmisA = NWeapSpellbook_MagicMissile(SpawnFirstPerson("NWeapSpellbook_MagicMissilePower", 30, 10, -3, false, 0, 0));
			NWeapSpellbook_MagicMissile mmisB = NWeapSpellbook_MagicMissile(SpawnFirstPerson("NWeapSpellbook_MagicMissilePower", 30, 10, -3, false, 0, 0));
			NWeapSpellbook_MagicMissile mmisC = NWeapSpellbook_MagicMissile(SpawnFirstPerson("NWeapSpellbook_MagicMissilePower", 30, 10, -3, false, 0, 0));
			if (cvarHX2.IndexOf("world") != -1) {
				mmisA.useNewModel = true;
				mmisB.useNewModel = true;
				mmisC.useNewModel = true;
			}
		} else {
			NWeapSpellbook_MagicMissile mmis = NWeapSpellbook_MagicMissile(SpawnFirstPerson("NWeapSpellbook_MagicMissile", 40, 10, -3, false, 0, 0));
			if (cvarHX2.IndexOf("world") != -1) {
				mmis.useNewModel = true;
			}
		}
	}

	action void A_FireBoneShard() {
		if (player == null) {
			return;
		}
		Weapon weapon = Player.ReadyWeapon;
        bool hasTome = Player.mo.FindInventory("PowerWeaponLevel2", true);
        if (hasTome) {
            weapon.AmmoUse1 = 10;
        } else {
			// can't use 0.5 as ammo cost, so alternation of 1 and 0 is best case
			if (weapon.AmmoUse1 == 1) {
				weapon.AmmoUse1 = 1;
			} else {
				weapon.AmmoUse1 = 1;
			}
        }

		if (weapon != null) {
			if (!weapon.DepleteAmmo(weapon.bAltFire)) {
				return;
            }
		}


		if (hasTome) {
			SpawnFirstPerson("NWeapSpellbook_BoneShotPower", 40, 10, -6, false, 0, 0);
			A_StartSound("hexen2/necro/bonefpow", CHAN_WEAPON);
		} else {
			// Approx to Hexen II Bone Shards InstantShot
			// Ref: https://github.com/videogamepreservation/hexen2/blob/master/H2W/HCode/boner.hc#L396
			for (int i = 0 ; i < 4 ; i++) {
				LineAttack(angle + (frandom[bstrace](-10.0,10.0)), 2048, pitch + (frandom[bstrace](-10.0,10.0)), 4, 'Hitscan', "StaffPuff");
			}
			SpawnFirstPerson("NWeapSpellbook_BoneShot", 40, 13.0 + frandom[bsproj](-16.0, 16.0), -3.0 + frandom[bsproj](-16.0, 16.0), false, 0, 0);
			A_StartSound("hexen2/necro/bonefnrm", CHAN_WEAPON);
		}
	}
}

class NWeapSpellbook_Flash : Actor {
	double tickDuration;
	property tickDuration: tickDuration;

	double avelocityz;

	Default {
		+NOBLOCKMAP
		+NOGRAVITY
		+ZDOOMTRANS

		RenderStyle "Add";
		Alpha 0.3f;
		Scale 6.0f;

        NWeapSpellbook_Flash.tickDuration 0.75;
	}
	States
	{
	Spawn:
		HDFX A 1 Bright;
		Loop;
	}

    override void PostBeginPlay() {
        Super.PostBeginPlay();

		avelocityz = frandom(360,720) / 32.0;
		roll = frandom(0.0, 360.0);
    }

	// Broken, needs to match up
	override void Tick() {
		Super.Tick();

		Scale.x += 0.05;
		Scale.y += 0.05;

		roll += -avelocityz;

		if (tickDuration <= 0.0f) {
			Destroy();
		}
		if (tickDuration <= 0.75 * 0.5) {
			Alpha = self.Default.Alpha * (tickDuration / (0.75 * 0.5));
		}

		tickDuration -= TICRATEF / 100.0f;
	}
}

// Combines into a single object
// FX Incorrect
class NWeapSpellbook_MissileStar : Actor {
	Actor parent;
	Default {
		+NOBLOCKMAP
		+NOGRAVITY
		+NOINTERACTION
		+NOCLIP
		+ZDOOMTRANS

		RenderStyle "Add";
		Alpha 0.4f;
        Scale 1.0f;

		Height 0;
		Radius 0;
	}
	States
	{
	Spawn:
		BODY A 1 Bright;
		Loop;
	}
	override void Tick() {
		Super.Tick();

		if (parent == NULL) {
			Destroy();
		}
	}
}
class NWeapSpellbook_MissileStarA : NWeapSpellbook_MissileStar {
	override void Tick() {
		Super.Tick();

		Vector3 avelocity = (-6.25, -6.25, 6.25);
		angle += avelocity.x;
		pitch += avelocity.y;
		roll += avelocity.z;
	}
}

class NWeapSpellbook_MissileStarB : NWeapSpellbook_MissileStar {
	override void Tick() {
		Super.Tick();

		Vector3 avelocity = (6.25, -6.25, -6.25);
		angle += avelocity.x;
		pitch += avelocity.y;
		roll += avelocity.z;
	}
}

class NWeapSpellbook_MissileFlare : NWeapSpellbook_MissileStar {
	Default {
		RenderStyle "Add";
		Alpha 0.9f;
        Scale 1.0f;
	}
	override void Tick() {
		Super.Tick();

		Vector3 avelocity = (-6.25, 6.25, -6.25);
		angle += avelocity.x;
		pitch += avelocity.y;
		roll += avelocity.z;
	}
}

class NWeapSpellbook_MagicMissilePower : NWeapSpellbook_MagicMissile {
	Default {
		Hexen2Projectile.homeRate 0.2;
		Hexen2Projectile.turnTime 0.5;
		Hexen2Projectile.veerAmount 100;

        NWeapSpellbook_MagicMissile.tickDuration 5.0f;
	}
    override void BeginPlay() {
        Super.BeginPlay();
        Speed = 0;
    }
	override void Tick() {
		Super.Tick();
	}
}

class NWeapSpellbook_MagicMissile : Hexen2Projectile {
	bool useNewModel;
	double tickDuration;
	property tickDuration: tickDuration;

	Actor attachedActors[3];

	Default {
		DamageFunction 0;
		+HITTRACER
		+ZDOOMTRANS
		+SPAWNSOUNDSOURCE

		RenderStyle "Add";

		Speed 37.5;	//(1200 / 32) = ~1200 Quake Engine Velocity
		Radius 8;
		Height 8;
		DamageType "Normal";
		Projectile;
        SeeSound "hexen2/necro/mmfire";
		DeathSound "hexen2/weapons/explode";
		Obituary "$OB_MPMWEAPFROST";
        Scale 0.5f;

        NWeapSpellbook_MagicMissile.tickDuration 3.0f;
	}

	States {
		Spawn:
			BODY A 1 Bright;
			Loop;
		SpawnHXWorld:
			MMIS ABCDEFGHIJ 2 Bright;
			Loop;
		Death:
			MMEX A 2 Bright A_GetDamage;
			MMEX BCDEFGHIJKLMNO 2 Bright;
			Stop;
	}

    override void BeginPlay() {
        Super.BeginPlay();
        Speed = 1000.0f / 32.0f;
    }
	
	override void PostBeginPlay() {
        Super.PostBeginPlay();

		if (self.useNewModel) {
			// set state to SpawnHXWorld
			State stateSpawnHXWorld = self.FindState("SpawnHXWorld");
			if (stateSpawnHXWorld) {
				Alpha = 0.8f;
				self.SetState(stateSpawnHXWorld);
			}
		} else {
			// Fallback to old emulated effect
			attachedActors[0] = Spawn("NWeapSpellbook_MissileFlare", pos);
			attachedActors[1] = Spawn("NWeapSpellbook_MissileStarA", pos);
			attachedActors[2] = Spawn("NWeapSpellbook_MissileStarB", pos);

			NWeapSpellbook_MissileFlare(attachedActors[0]).parent = self;
			NWeapSpellbook_MissileStar(attachedActors[1]).parent = self;
			NWeapSpellbook_MissileStar(attachedActors[2]).parent = self;
		}

        pg = ParticleGenerator(Spawn("ParticleGenerator"));
        pg.Attach(self);
        pg.color[0] = (52, 44, 80);
        pg.color[1] = (172, 172, 212);
        pg.origin[0] = (-24, -24, self.height + -12);
        pg.origin[1] = (24, 24, self.height - 12);
        pg.velocity[0] = (0, 0, -24);
        pg.velocity[1] = (0, 0, 0);
        pg.startalpha = 1.0;
        pg.sizestep = 0.05;
		pg.flag_fullBright = true;
    }

	override void Tick() {
		Super.Tick();

		if (InStateSequence(CurState, self.Findstate("Death"))) {
			return;
		}
		if (tickDuration <= 0) {
			for (let i = 0; i < attachedActors.Size(); i++) {
				if (attachedActors[i]) {
					attachedActors[i].Destroy();
				}
			}
			Destroy();
		}

		tickDuration -= TICRATEF / 1000.0f;

		Vector3 avelocity = (0, 0, frandom(300.0f,600.0f) / 32.0f);
		if (!self.useNewModel) {
			self.angle += avelocity.x;
			self.pitch += avelocity.y;
		}
		self.roll += avelocity.z;

		for (let i = 0; i < attachedActors.Size(); i++) {
			if (attachedActors[i]) {
				Actor attached = attachedActors[i];
				if (attached) {
					attached.SetOrigin(self.pos, true);
				}
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
		for (let i = 0; i < attachedActors.Size(); i++) {
			if (attachedActors[i]) {
				attachedActors[i].Destroy();
			}
		}
		pg.Remove();

		angle = 0;
		pitch = 0;
		roll = 0;
		Scale.x = 1.0f;
		Scale.y = 1.0f;
		Alpha = 0.8f;
        A_SetRenderStyle(1, STYLE_Add);
		if (tracer) {
         	int damage = random[MagicMissile](20, 25);
         	tracer.DamageMobj(self, target, damage, 'Normal');
		}
	}
}

class NWeapSpellbook_BoneShot : Hexen2Projectile {
	Default {
		DamageFunction 0;
		+HITTRACER
		+ZDOOMTRANS
		+SPAWNSOUNDSOURCE

		Speed 31.25;
		Radius 8;
		Height 8;
        Scale 1.0f;
		DamageType "Normal";
		Projectile;
        //SeeSound "hexen2/necro/bonefnrm";
		DeathSound "hexen2/necro/bonenwal";
		Obituary "$OB_MPMWEAPFROST";
	}

	States
	{
	Spawn:
		BONE A 1;
		Loop;
	Death:
		WHT1 A 2 A_GetDamage;
		WHT1 BCDE 2;
		Stop;
	}

    override void BeginPlay() {
        Super.BeginPlay();
		Speed += frandom[bonespeed](0.0, 1.0) * (500.0 / 32.0);
    }

	override void Tick() {
		Super.Tick();

		if (InStateSequence(CurState, self.Findstate("Death"))) {
			return;
		}
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
		Scale.x = 1.0f;
		Scale.y = 1.0f;
		Alpha = 0.8f;
        A_SetRenderStyle(1, STYLE_Add);
		if (tracer) {
         	int damage = 7;
         	tracer.DamageMobj(self, target, damage, 'Normal');
		}
	}
}

class NWeapSpellbook_BoneShotPower : Hexen2Projectile {
	Vector3 avelocity;

	Default {
		DamageFunction 0;
		+HITTRACER
		+ZDOOMTRANS
		+SPAWNSOUNDSOURCE

		Speed 31.25;
		Radius 8;
		Height 8;
        Scale 1.0f;
		DamageType "Normal";
		Projectile;
        //SeeSound "hexen2/necro/bonefnrm";
		DeathSound "hexen2/necro/bonephit";
		Obituary "$OB_MPMWEAPFROST";
	}

	States
	{
	Spawn:
		BONE A 1;
		Loop;
	Death:
		WHT1 A 2 A_GetDamage;
		WHT1 BCDE 2;
		Stop;
	}

    override void BeginPlay() {
        Super.BeginPlay();

		double range = 777.0 / 32.0;
		avelocity.x = frandom(-range, range);
		avelocity.y = frandom(-range, range);
		avelocity.z = frandom(-range, range);
    }

	override void Tick() {
		Super.Tick();

		if (InStateSequence(CurState, self.Findstate("Death"))) {
			return;
		}

		angle += avelocity.x;
		pitch += avelocity.y;
		roll += avelocity.z;
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
        int damage = 100;

		angle = 0;
		pitch = 0;
		roll = 0;
		Scale.x = 1.0f;
		Scale.y = 1.0f;
		Alpha = 0.8f;
        A_SetRenderStyle(1, STYLE_Add);
		if (tracer) {
         	tracer.DamageMobj(self, target, damage * 2, 'Normal');
		}
		A_Explode(damage, damage + 40);

		for (let i = 0; i < 20; i++) {
			Actor proj = Spawn("NWeapSpellbook_BoneShotPowerShrapnel", pos);

			double a = frandom[shrapnel](0.0, 360.0);
			double p = frandom[shrapnel](0.0, 360.0);
			double r = frandom[shrapnel](0.0, 360.0);

			let mat = HXDD_GM_Matrix.fromEulerAngles(a, p, r);   
       		mat = mat.multiplyVector3((1.0,1.0,1.0));     
        	vector3 projVel = mat.asVector3(false) * (GetDefaultByType("NWeapSpellbook_BoneShotPowerShrapnel").Speed + frandom[bonespeed](0.0, 1.0) * (500.0 / 32.0));

            proj.angle = a;
            proj.pitch = p;
            proj.roll = r;
            proj.vel = projVel;
            proj.target = self.target;
		}
	}
}

class NWeapSpellbook_BoneShotPowerShrapnel : Hexen2Projectile {
	Vector3 avelocity;

	Default {
		DamageFunction 0;
		+HITTRACER
		+ZDOOMTRANS
		+SPAWNSOUNDSOURCE

		Speed 31.25;
		Radius 8;
		Height 8;
        Scale 1.0f;
		DamageType "Normal";
		Projectile;
        //SeeSound "hexen2/necro/bonefnrm";
		DeathSound "hexen2/necro/bonenwal";
		Obituary "$OB_MPMWEAPFROST";
	}

	States
	{
	Spawn:
		BONE A 1;
		Loop;
	Death:
		WHT1 A 2 A_GetDamage;
		WHT1 BCDE 2;
		Stop;
	}

    override void BeginPlay() {
        Super.BeginPlay();
		//Speed += frandom[bonespeed](0.0, 1.0) * (500.0 / 32.0);
		
		double range = 777.0 / 32.0;
		avelocity.x = frandom(-range, range);
		avelocity.y = frandom(-range, range);
		avelocity.z = frandom(-range, range);
    }

	override void Tick() {
		Super.Tick();

		if (InStateSequence(CurState, self.Findstate("Death"))) {
			return;
		}

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
		Scale.x = 1.0f;
		Scale.y = 1.0f;
		Alpha = 0.8f;
        A_SetRenderStyle(1, STYLE_Add);
		if (tracer) {
         	int damage = 15;
         	tracer.DamageMobj(self, target, damage, 'Normal');
		}
	}
}