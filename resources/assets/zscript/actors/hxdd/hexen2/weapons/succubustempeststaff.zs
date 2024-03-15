// Demoness Weapon: Tempest Staff
// https://github.com/videogamepreservation/hexen2/blob/master/H2MP/hcode/lightwp.hc

class SWeapTempestStaffPiece: WeaponPiece {
	Default {
		Inventory.PickupSound "misc/w_pkup";
		Inventory.PickupMessage "$TXT_TEMPTESTSTAFF_PIECE";
		Inventory.RestrictedTo "HX2SuccubusPlayer";
		WeaponPiece.Weapon "SWeapTempestStaff";
		+FLOATBOB
	}
}

class SWeapTempestStaffPiece1: SWeapTempestStaffPiece {
	Default {
		WeaponPiece.Number 1;
	}
	States {
        Spawn:
            PKUP A -1 Bright;
            Stop;
	}
}

class SWeapTempestStaffPiece2: SWeapTempestStaffPiece {
	Default {
		WeaponPiece.Number 2;
	}
	States {
        Spawn:
            PKUP A -1 Bright;
            Stop;
	}
}

class SWeapTempestStaff: SuccubusWeapon {
    bool lastPoweredState;

	Default {
		+BLOODSPLATTER;
		+FLOATBOB;

		+WEAPON.PRIMARY_USES_BOTH;

        Health 2;

		Weapon.SelectionOrder 1000;
		Weapon.AmmoType1 "Mana1";
		Weapon.AmmoType2 "Mana2";
		Weapon.AmmoUse1 1;
		Weapon.AmmoUse2 1;
		Weapon.AmmoGive 150;
		Weapon.KickBack 150;
		//Weapon.YAdjust 10;
		Obituary "$OB_MPSWEAPTEMPESTSTAFF";
		Tag "$TAG_SWEAPTEMPESTSTAFF";
	}

	States {
		Spawn:
			PKUP A -1;
			Stop;
		Select:
			500A ABCDEFGHIJKL 2 Offset(0, 32);
			TNT1 A 0 A_Raise(100);
			Loop;
		Deselect:
			500A LKJIHGFEDCBA 2;
			TNT1 A 0 A_Lower(100);
			Loop;
		Ready:
			200A A 2 A_WeaponReadyRngJelly;
			Loop;
		Ready_Jelly:
			100A ABCDEFGHIJKLMNOP 2 A_WeaponReady;
			Goto Ready;
		Ready_Power:
			300A A 2 A_WeaponReadyRngJelly;
			Goto Ready;
		Fire:
			000A ABCDEFGHIJKLMNOP 2;
			200A ABCDEFGHIJKLMNOP 2;
			//000A ABCDEFG 2;
			//000A H 2 A_TryFire;
			//000A IJKLMNOP 2;
			Goto Ready;	// Fallback
		Fire_Normal:
		Fire_Powered:
		PH:
			400A ABCDEFG 2;
			Goto Ready;
    }

	bool IsInReadySequence(bool inPower = false) {
		if (!Player) {
			return false;
		}
		SWeapTempestStaff weapon = SWeapTempestStaff(Player.ReadyWeapon);

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
	
	action void A_WeaponReadyRngJelly() {
		SWeapTempestStaff weapon = SWeapTempestStaff(Player.ReadyWeapon);
        bool isPowered = weapon.IsTomeOfPowerActive();
		
		if (isPowered) {
			if (!weapon.InStateSequence(CurState, Player.ReadyWeapon.FindState("Ready_Power")) && frandom[idle](0.0, 1.0) <= 0.07) {
				SWeapTempestStaff weapon = SWeapTempestStaff(Player.ReadyWeapon);
				Player.SetPsprite(PSP_WEAPON, Player.ReadyWeapon.FindState("Ready_Power"));
				PSprite pspr = player.GetPSprite(PSP_WEAPON);
				if (pspr) {
					pspr.frame = random(0,15);
					pspr.firstTic = true;
					pspr.InterpolateTic = false;
					pspr.bInterpolate = false;
				}
				A_StartSound("hexen2/succubus/buzz", CHAN_WEAPON, 0.5);
			}
		} else {
			if (random[idle](0, 1000) < 1) {
				Player.SetPsprite(PSP_WEAPON, Player.ReadyWeapon.FindState("Ready_Jelly"));
			}
		}
		A_WeaponReady();
	}

	action void A_Select() {
		SWeapTempestStaff weapon = SWeapTempestStaff(Player.ReadyWeapon);
        bool isPowered = weapon.IsTomeOfPowerActive();

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

		SWeapTempestStaff weapon = SWeapTempestStaff(Player.ReadyWeapon);
		State nextState = weapon.FindState("Deselect_Normal");
		if (haveTome) {
			nextState = weapon.FindState("Deselect_Power");
		}
		Player.SetPsprite(PSP_WEAPON, nextState);
	}

	action void A_Ready(bool allowJellyState = false) {
		if (Player == null) {
			return;
		}

        bool isPowered = Player.mo.FindInventory("PowerWeaponLevel2", true);

		SWeapTempestStaff weapon = SWeapTempestStaff(Player.ReadyWeapon);
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

	action void A_SelectFire() {
        bool haveTome = Player.mo.FindInventory("PowerWeaponLevel2", true);

		SWeapTempestStaff weapon = SWeapTempestStaff(Player.ReadyWeapon);
		State nextState = weapon.FindState("Fire_Normal");
		if (haveTome) {
			nextState = weapon.FindState("Fire_Power");
		}
		Player.SetPsprite(PSP_WEAPON, nextState);
	}

	action void A_TryFire() {
		if (player == null) {
			return;
		}
		SWeapTempestStaff weapon = SWeapTempestStaff(Player.ReadyWeapon);
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

		//Actor proj = SpawnFirstPerson("SWeapFireStorm_FlameStream", 45, -14, -7, true, 0, 0);
		if (isPowered) {
			// Do camera kickback if possible
			refire = 1.0;
			recoil = (-6, 0);
			sfx = "hexen2/succubus/flamstrt";

			//SWeapFireStorm_FlameStream(proj).isPowered = true;
		}
		weapon.AddRecoil(recoil);
		A_StartSound(sfx, CHAN_WEAPON, 0.5);
		//SetCooldown(weapon, refire, 2);
	}

	action void A_ResetCooldown() {
		if (player == null) {
			return;
		}
		ResetCooldown(Player.ReadyWeapon);
	}
}