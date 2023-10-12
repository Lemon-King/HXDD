// Necromancer Weapon: Sickle

class NWeapSickle : NecromancerWeapon
{
	Default
	{
		Weapon.SelectionOrder 3500;
		Weapon.KickBack 150;
		Weapon.YAdjust 0;
		+BLOODSPLATTER
		Obituary "$OB_MPNWEAPSICKLE";
		Tag "$TAG_NWEAPSICKLE";
	}

	States
	{
	Select:
		NWSS JIHGFEDCBA 2 Offset(0, 32);
		NWSR A 0 A_Raise(100);
		Loop;
	Deselect:
		NWSR A 0;	// Fixes blending between states
		NWSS ABCDEFGHIJ 2;
		TNT1 A 0 A_Lower(100);
		Loop;
	Ready:
		NWSR A 1 A_WeaponReady;
		Loop;
	Fire:
		NWSR A 0 A_DecideAttack;
		Loop;
	SwipeA:
		NWSA A 2;
		NWSA B 2 A_NSickleAttack;
		NWSA CDEFGHI 2;
		Goto Ready;
	SwipeB:
		NWSB AB 2;
		NWSB C 2 A_NSickleAttack;
		NWSB DEFGHIJ 2;
		Goto Ready;
	SwipeC:
		NWSC AB 2;
		NWSC C 2 A_NSickleAttack;
		NWSC DEFGHIJ 2;
		Goto Ready;
	}

	action void A_DecideAttack() {
		if (weaponspecial < 1) {
			weaponspecial++;
			Player.SetPsprite(PSP_WEAPON, Player.ReadyWeapon.FindState("SwipeA"));
		} else {
			weaponspecial--;
			Player.SetPsprite(PSP_WEAPON, Player.ReadyWeapon.FindState("SwipeB"));
		}
	}

	action void A_NSickleAttack()
	{
		FTranslatedLineTarget t;

		if (player == null) {
			return;
		}

        bool hasTome = Player.mo.FindInventory("PowerWeaponLevel2", true);
		for (int i = 0; i < 16; i++) {
			for (int j = 1; j >= -1; j -= 2) {
				double ang = angle + j*i*(45. / 16);
				double slope = AimLineAttack(ang, MELEE_RANGE, t, 0., ALF_CHECK3D);
				if (t.linetarget) {
					if (hasTome) {
						int damage = frandom[SickleAtk](WEAPON1_PWR_BASE_DAMAGE, WEAPON1_PWR_BASE_DAMAGE + WEAPON1_PWR_ADD_DAMAGE);
						LineAttack(ang, DEFMELEERANGE, slope, damage, 'Melee', "SickleSparks_PowerHit", true, t);
					} else {
						int damage = frandom[SickleAtk](WEAPON1_BASE_DAMAGE, WEAPON1_BASE_DAMAGE + WEAPON1_ADD_DAMAGE);
						LineAttack(ang, DEFMELEERANGE, slope, damage, 'Melee', "SickleSparks_Hit", true, t);
					}

					if (t.linetarget != null) {
						// Ability 2 (Level 6): Health Drain on Hit;
						HXDDPlayerPawn hxddplayer = HXDDPlayerPawn(player.mo);
						Progression prog = Progression(hxddplayer.FindInventory("Progression"));
						if (t.linetarget.CountsAsKill() && prog.currlevel >= 6) {
							double drainChance = (prog.currlevel - 5) * 0.04f;
							if (drainChance > 0.20f) {
								drainChance = 0.20f;
							}

							if (frandom[sickledrain](0.0f, 1.0f) < drainChance) {
								double healAmount = min((prog.currlevel - 5) * 2, 10);
								double playerHealth = hxddplayer.Health;
								double playerMaxHealth = hxddplayer.MaxHealth;

								if (healAmount != 0) {
									hxddplayer.A_SetHealth(clamp(playerHealth + healAmount, 0.0f, playerMaxHealth), AAPTR_DEFAULT);

									A_StartSound("hexen2/weapons/drain", CHAN_WEAPON);
								}
							}
						}

						AdjustPlayerAngle(t);
						return;
					}
				}
			}
		}
		
		// didn't find any creatures, so try to strike any walls
		double slope = AimLineAttack (angle, DEFMELEERANGE, null, 0., ALF_CHECK3D);
		String sparksEffect = "SickleSparks";
		if (hasTome) {
			sparksEffect = "SickleSparks_PowerHit";
		}
		LineAttack(angle, DEFMELEERANGE, slope, damage, 'Melee', sparksEffect);
	}
}

class SickleSparks : Actor
{
	Default
	{
		+NOBLOCKMAP +NOGRAVITY
		+PUFFONACTORS
        +FORCEXYBILLBOARD;
		RenderStyle "Add";
		Alpha 0.8;
		SeeSound "hexen2/weapons/slash";
		AttackSound "hexen2/weapons/hitwall";
		ActiveSound "hexen2/weapons/gaunt1";
		VSpeed 0;
	}
	States
	{
	Spawn:
		SPAR ABCDEFGHI 3 Bright;
		Stop;
	}
}

class SickleSparks_Hit : SickleSparks
{
	Default
	{
		Alpha 0.0;
	}
	States
	{
	Spawn:
		TNT1 A -1;
		Stop;
	}
}

class SickleSparks_PowerHit : SickleSparks
{
	Default
	{
		Alpha 0.8;
	}
	States
	{
	Spawn:
		GRYS ABCDE 3 Bright;
		Stop;
	}
}