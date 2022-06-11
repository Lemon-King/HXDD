// Assassin Weapon: Punch Dagger

class AWeapPunchDagger : AssassinWeapon
{
	Default
	{
		Weapon.SelectionOrder 3500;
		Weapon.KickBack 150;
		Weapon.YAdjust 0;
		Inventory.Icon "APDRA0";
		+BLOODSPLATTER
		Obituary "$OB_MPAWEAPPUNCHDAGGER";
		Tag "$TAG_AWEAPPUNCHDAGGER";
	}

	States
	{
	Select:
		TNT1 A 0 A_StartSound("hexen2/weapons/unsheath");
		APDS HGFEDCBA 2 Offset(0, 32);
		APDR A 0 A_Raise(100);
		Loop;
	Deselect:
		APDR A 0;
		APDS ABCDEFGH 2;
		TNT1 A 0 A_Lower(100);
		Loop;
	Ready:
		APDR A 1 A_WeaponReady;
		Loop;
	Fire:
		APDR A 0 A_DecideAttack;
		Loop;
	AttackA:
		APDA AB 2;
		APDA C 2  A_StartSound("hexen2/weapons/gaunt1");
		APDA D 2;
		APDA E 2 A_Attack;
		APDA F 2 A_ReFire;
		Goto Ready;
	AttackB:
		APDB A 2;
		APDB B 2 A_StartSound("hexen2/weapons/gaunt1");
		APDB CDE 2;
		APDB F 2 A_Attack;
		APDB GHIJKL 2;
		Goto Ready;
	AttackC:
		APDC ABCD 2;
		APDC E 2 A_StartSound("hexen2/weapons/gaunt1");
		APDC F 2 A_Attack;
		APDC GHIJKL 2;
		Goto Ready;
	AttackD:
		APDD AB 2;
		APDD C 2 A_StartSound("hexen2/weapons/gaunt1");
		APDD D 2;
		APDD E 2 A_Attack;
		APDD FGHIJKLM 2;
		Goto Ready;
	}

	action void A_DecideAttack() {
		if (weaponspecial == 1) {
			Player.SetPsprite(PSP_WEAPON, Player.ReadyWeapon.FindState("AttackA"));
		} else if (weaponspecial == 2) {
			Player.SetPsprite(PSP_WEAPON, Player.ReadyWeapon.FindState("AttackB"));
		} else if (weaponspecial == 3) {
			Player.SetPsprite(PSP_WEAPON, Player.ReadyWeapon.FindState("AttackC"));
		} else {
			Player.SetPsprite(PSP_WEAPON, Player.ReadyWeapon.FindState("AttackD"));
		}
		weaponspecial = (weaponspecial + 1) % 5;
	}

	action void A_Attack()
	{
		FTranslatedLineTarget t;

		if (player == null)
		{
			return;
		}

		double DAMAGE_BASE = 12;
		double DAMAGE_ADD = 12;

		int damage = frandom[ADaggerAtk](DAMAGE_BASE, DAMAGE_BASE + DAMAGE_ADD);
		for (int i = 0; i < 16; i++)
		{
			for (int j = 1; j >= -1; j -= 2)
			{
				double ang = angle + j*i*(45. / 16);
				double slope = AimLineAttack(ang, MELEE_RANGE, t, 0., ALF_CHECK3D);
				if (t.linetarget)
				{
					// check t.linetarget facing for backstab bonus
					int PlayerLevel = HXDDPlayerPawn(self).level;
					if (PlayerLevel > 5)
					{
						if (PlayerLevel > 10) {
							PlayerLevel = 10;
						}

						if (random(1,10) <= (PlayerLevel - 4)) {
							//CreateRedFlash(trace_endpos);
							//centerprint(self,"Critical Hit Backstab!\n");
							//AwardExperience(self,trace_ent,10);
							DAMAGE_BASE *= frandom(2.5,4);
							damage = frandom[ADaggerAtk](DAMAGE_BASE, DAMAGE_BASE + DAMAGE_ADD);
						}
					}

					LineAttack(ang, MELEE_RANGE, slope, damage, 'Melee', "DaggerSparks_Hit", true, t);
					if (t.linetarget != null) {
						AdjustPlayerAngle(t);
						return;
					}
				}
			}
		}
		
		// didn't find any creatures, so try to strike any walls
		double slope = AimLineAttack (angle, DEFMELEERANGE, null, 0., ALF_CHECK3D);
		LineAttack (angle, DEFMELEERANGE, slope, damage, 'Melee', "DaggerSparks");
	}
}

class CritialHit_RedFlash: DaggerSparks {
	// Placeholder
	Default
	{
		Alpha 0.0;
	}
}

class DaggerSparks : Actor
{
	Default
	{
		+NOBLOCKMAP +NOGRAVITY
		+PUFFONACTORS
		RenderStyle "Add";
		Alpha 1.0;
		SeeSound "hexen2/weapons/slash";
		AttackSound "hexen2/weapons/hitwall";
		//ActiveSound "hexen2/weapons/gaunt1";
		VSpeed 0;
	}
	States
	{
	Spawn:
		SPA1 ABCDEFGHI 3 Bright;
		Stop;
	}
}

class DaggerSparks_Hit : DaggerSparks
{
	Default
	{
		Alpha 0.0;
	}
}