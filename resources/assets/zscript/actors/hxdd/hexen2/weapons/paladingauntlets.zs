// Paladin Weapon: Gauntlets
// REF: https://github.com/videogamepreservation/hexen2/blob/master/H2MP/hcode/gauntlet.hc~

class PWeapGauntlet : PaladinWeapon
{

	Default
	{
		Weapon.SelectionOrder 3500;
		Weapon.KickBack 150;
		Weapon.YAdjust 0;
		+BLOODSPLATTER
		Obituary "$OB_MPPWEAPGAUNTLETS";
		Tag "$TAG_PWEAPGAUNTLETS";
	}

	States
	{
	Select:
        PGTA AB 3 Offset(0, 32);
        PGTA C 3 A_StartSound("hexen2/fx/wallbrk");
        PGTA DEFGHIJKLMN 3;
		PGAR A 0 A_Raise(100);
		Loop;
	Deselect:
		PGAR A 0;
		PGAB ABCDEF 2;
		TNT1 A 0 A_Lower(100);
		Loop;
	Ready:
		PGAR A 1 A_WeaponReady;
		Loop;
	Fire:
		PGAR A 0 A_DecideAttack;
		Loop;
	PunchA:
		PGAA A 2;
        PGAA B 2 A_StartSound("hexen2/weapons/gaunt1");
        PGAA C 2;
        PGAA D 2 A_Attack;
        PGAA EFGHIJKLM 2;
		Goto Ready;
	PunchB:
		PGAB ABC 2;
        //PGAB DE 2; // unused
        PGAB F 2 A_StartSound("hexen2/weapons/gaunt1");
        PGAB GH 2;
        PGAB I 2 A_Attack;
        PGAB JKLMNOP 2;
		Goto Ready;
	PunchC:
		PGAC AB 2;
        PGAC C 2 A_StartSound("hexen2/weapons/gaunt1");
        PGAC DE 2;
        PGAC F 2 A_Attack;
        PGAC GHIJKL 2;
		Goto Ready;
	PunchD:
		PGAD C 2;
        PGAD D 2 A_StartSound("hexen2/weapons/gaunt1");
        PGAD EF 2;
        PGAD G 2 A_Attack;
        PGAD HIJKLM 2;
		Goto Ready;
	}

	action void A_DecideAttack() {
		if (weaponspecial == 0) {
			Player.SetPsprite(PSP_WEAPON, Player.ReadyWeapon.FindState("PunchA"));
		} else if (weaponspecial == 1) {
			Player.SetPsprite(PSP_WEAPON, Player.ReadyWeapon.FindState("PunchB"));
		} else if (weaponspecial == 2) {
			Player.SetPsprite(PSP_WEAPON, Player.ReadyWeapon.FindState("PunchC"));
		} else if (weaponspecial == 3) {
			Player.SetPsprite(PSP_WEAPON, Player.ReadyWeapon.FindState("PunchD"));
		}
        weaponspecial = ++weaponspecial % 4;
	}

	action void A_Attack()
	{
        double GAUNT_BASE_DAMAGE		= 16;
        double GAUNT_ADD_DAMAGE			= 12;
        double GAUNT_PWR_BASE_DAMAGE	= 30;
        double GAUNT_PWR_ADD_DAMAGE		= 20;

		FTranslatedLineTarget t;

		if (player == null)
		{
			return;
		}

		double damage_amount = GAUNT_BASE_DAMAGE;
		double damage_amount_add = GAUNT_ADD_DAMAGE;
		Weapon weapon = Player.ReadyWeapon;
        bool hasTome = Player.mo.FindInventory("PowerWeaponLevel2", true);
        if (hasTome) {
			damage_amount = GAUNT_PWR_BASE_DAMAGE;
			damage_amount_add = GAUNT_PWR_ADD_DAMAGE;
        }

		int damage = random[GauntletAtk](damage_amount, damage_amount + damage_amount_add);
		damage += GetPowerUpHolyStrengthMultiplier() * damage;
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
						return;
					}
				}
			}
		}
		
		// didn't find any creatures, so try to strike any walls
		String sparksEffect = "SickleSparks";
		if (hasTome) {
			sparksEffect = "SickleSparks_PowerHit";
		}
		double slope = AimLineAttack (angle, DEFMELEERANGE, null, 0., ALF_CHECK3D);
		LineAttack (angle, DEFMELEERANGE, slope, damage, 'Melee', sparksEffect);
	}
}