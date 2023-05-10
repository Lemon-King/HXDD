// Crusader Weapon: Warhammer

class CWeapWarhammer : CrusaderWeapon
{
	Default
	{
		Weapon.SelectionOrder 3500;
		Weapon.KickBack 150;
		Weapon.YAdjust 0;
		+BLOODSPLATTER
		Obituary "$OB_MPCWEAPWARHAMMER";
		Tag "$TAG_CWEAPWARHAMMER";
	}

	States
	{
	Select:
        TNT1 A 0 Offset(0, 32);
        CWSL ABCDEFGHI 3;
		CWID A 0 A_Raise(100);
		Loop;
	Deselect:
		CWID A 0;
        CWSL IHGFEDCBA 3;
		TNT1 A 0 A_Lower(100);
		Loop;
	Ready:
		CWID A 1 A_WeaponReady;
		Loop;
	Fire:
		CWID A 0 A_DecideAttack;
		Loop;
	SwingTop: // Top Down
        CWCH ABCDEF 2;
        CWCH G 2 A_SwingStart("top", -30);
        CWCH H 2 A_Attack("top", 0);
        CWCH I 2 A_Attack("top", 30);
        CWCH JKL 2;
		Goto ReturnToReady;
	SwingLR: // Left to Right
		CWLR ABCD 2;
        CWLR E 2 A_SwingStart("ltr", -30);
        CWLR F 2 A_Attack("ltr", 0);
        CWLR G 2 A_Attack("ltr", 30);
        CWLR HIJK 2;
		Goto Ready;
	SwingRL: // Right to Left
		CWRL ABC 2;
        //DEF   // skipped
        CWRL G 2 A_SwingStart("rtl", -30);
        CWRL H 2 A_Attack("rtl", 0);
        CWRL I 2 A_Attack("rtl", 30);
        CWRL JK 2;
		Goto ReturnToReady;
    ReturnToReady:
        CWRA ABCD 3;
		CWID A 0;
        Goto Ready;
    Throw:
        CWTH ABCDEFGHIJ 2;
        Goto Ready;
    Hack:
        CWHA ABCDEFGHIJ 2;
        Goto Ready;
	}

	action void A_DecideAttack() {
        // TODO: if tome is active, throw weapon
        int rnd = random(0,2);
		if (rnd == 0) {
			Player.SetPsprite(PSP_WEAPON, Player.ReadyWeapon.FindState("SwingTop"));
		} else if (rnd == 1) {
			Player.SetPsprite(PSP_WEAPON, Player.ReadyWeapon.FindState("SwingLR"));
		} else if (rnd == 2) {
			Player.SetPsprite(PSP_WEAPON, Player.ReadyWeapon.FindState("SwingRL"));
        }
        weaponspecial = ++weaponspecial % 3;
	}

    action void A_SwingStart(String hitDirection, Double offset) {
        A_StartSound("hexen2/weapons/vorpswng");
        A_Attack(hitDirection, offset);
    }

	action void A_Attack(String hitDirection, Double offset)
	{
		FTranslatedLineTarget t;

		if (player == null) {
			return;
		}

        double x = 1;
        double z = 1;
        if (hitDirection == "top") {
            z = -offset;
        } else if (hitDirection == "ltr") {
            x = -offset;
        } else if (hitDirection == "rtl") {
            x = offset;
        }

        // Until targets can only be hit once (bug), damage needs to be dividied by 2.
        // But the effect is way cooler this way.
		double damage = frandom[WarhammerAtk](15, 25) * 0.5;
		damage += GetPowerUpHolyStrengthMultiplier() * damage;

        Progression prog = Progression(Player.mo.FindInventory("Progression"));
		double strength = 10;
		if (prog.sheet) {
			strength = prog.strength;
		}

		//Array<Actor> hit;

		for (int i = 0; i < 16; i++) {
			for (int j = 1; j >= -1; j -= 2) {
				double ang = angle + j*i*(45. / 16);
				double slope = AimLineAttack(ang, MELEE_RANGE, t, 0., ALF_CHECK3D);

				if (t.linetarget) { //&& hit.Find(t.linetarget) != hit.Size()) {
					
                    double force = strength / 40.0f + 0.5f;

					Actor target = Actor(t.linetarget);
                    double targetMass = target.mass;

					LineAttack(ang + x, MELEE_RANGE, slope + z, damage, 'Melee', "SickleSparks_Hit", true, t);
					if (t.linetarget != null) {
						AdjustPlayerAngle(t);
						//hit.push(t.linetarget);
						return;
					}
				}
			}
		}
		
        if (offset == 0) {
            // didn't find any creatures, so try to strike any walls
            double slope = AimLineAttack (angle, DEFMELEERANGE, null, 0., ALF_CHECK3D);
            LineAttack(angle, DEFMELEERANGE, slope, damage, 'Melee', "SickleSparks");
        }
	}
}