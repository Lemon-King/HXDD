class HXDDHereticPlayer : HereticPlayer {
	Default {
		Player.SpawnClass "Corvus";
		Player.JumpZ 9;							// Match Hexen Jump
		Player.HealRadiusType "Health";
		//Player.Hexenarmor 10, 10, 25, 5, 15;	// total 65, between mage and cleric
		Player.Portrait "P_HWALK1";
		Player.WeaponSlot 1, "Staff", "Gauntlets";
		Player.WeaponSlot 2, "GoldWand";
		Player.WeaponSlot 3, "Crossbow";
		Player.WeaponSlot 4, "Blaster";
		Player.WeaponSlot 5, "SkullRod";
		Player.WeaponSlot 6, "PhoenixRod";
		Player.WeaponSlot 7, "Mace";
		Player.FlechetteType "ArtiPoisonBag2";
	}

	States {
		Spawn:
			CORV A -1;
			Stop;
		See:
			CORV ABCD 4;
			Loop;
		Melee:
		Missile:
			CORV F 6 BRIGHT;
			CORV E 12;
			Goto Spawn;
		Pain:
			CORV G 4;
			CORV G 4 A_Pain;
			Goto Spawn;
		Death:
			CORV H 6 A_PlayerSkinCheck("AltSkinDeath");
			CORV I 6 A_PlayerScream;
			CORV JK 6;
			CORV L 6 A_NoBlocking;
			CORV MNO 6;
			CORV P -1;
			Stop;
		XDeath:
			CORV Q 0 A_PlayerSkinCheck("AltSkinXDeath");
			CORV Q 5 A_PlayerScream;
			CORV R 0 A_NoBlocking;
			CORV R 5 A_SkullPop;
			CORV STUVWX 5;
			CORV Y -1;
			Stop;
		Burn:
			FDTH A 5 BRIGHT A_StartSound("*burndeath");
			FDTH B 4 BRIGHT;
			FDTH C 5 BRIGHT;
			FDTH D 4 BRIGHT A_PlayerScream;
			FDTH E 5 BRIGHT;
			FDTH F 4 BRIGHT;
			FDTH G 5 BRIGHT A_StartSound("*burndeath");
			FDTH H 4 BRIGHT;
			FDTH I 5 BRIGHT;
			FDTH J 4 BRIGHT;
			FDTH K 5 BRIGHT;
			FDTH L 4 BRIGHT;
			FDTH M 5 BRIGHT;
			FDTH N 4 BRIGHT;
			FDTH O 5 BRIGHT A_NoBlocking;
			FDTH P 4 BRIGHT;
			FDTH Q 5 BRIGHT;
			FDTH R 4 BRIGHT;
			ACLO E 35 A_CheckPlayerDone;
			Wait;
		AltSkinDeath:
			CORV H 10;
			CORV I 10 A_PlayerScream;
			CORV J 10 A_NoBlocking;
			CORV KLM 10;
			CORV N -1;
			Stop;
		AltSkinXDeath:
			CORV O 5;
			CORV P 5 A_XScream;
			CORV Q 5 A_NoBlocking;
			CORV RSTUV 5;
			CORV W -1;
			Stop;
	}
}

