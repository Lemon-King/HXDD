// Demoness Weapon: Temptest Staff
// https://github.com/videogamepreservation/hexen2/blob/master/H2MP/hcode/lightwp.hc

class SWeapTempestStaff: SuccubusWeapon {
    bool lastPoweredState;

	Default {
		+BLOODSPLATTER;
		+FLOATBOB;

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
		/*
		Select:
			500A A 0 A_Select;
			Loop;
		Deselect:
			500A A 0 A_Deselect;
			Loop;
		Select_Normal:
			FSSN KJIHGFEDCBA 2 Offset(0, 32);
			TNT1 A 0 A_Raise(100);
			Goto Ready;
		Select_Power:
			FSSP ABCDEFGHIJK 2 Offset(0, 32);
			TNT1 A 0 A_Raise(100);
			Goto Ready_Power;
		Deselect_Normal:
			FSIA A 0;
			FSSN ABCDEFGHIJK 2;
			TNT1 A 0 A_Lower(100);
			Loop;
		Deselect_Power:
			FSIC A 0;
			FSSP KJIHGFEDCBA 2;
			TNT1 A 0 A_Lower(100);
			Loop;
		Ready:
			FSIA ABCDEFGHIJKLMNOPQRSTUVWX 2 A_FireStormReady;
			FSIA Y 2 A_FireStormReady(true);
			Loop;
			*/
    }
}