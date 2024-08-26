// Succubus

class HX2SuccubusPlayer : HXDDHexenIIPlayerPawn
{
	Default
	{
		+NOSKIN
		+NODAMAGETHRUST
		+PLAYERPAWN.NOTHRUSTWHENINVUL
		PainSound "Hexen2PlayerFemalePain";
		RadiusDamageFactor 0.25;
		Player.SpawnClass "Succubus";
		Player.DisplayName "Demoness";
		Player.SoundClass "hexen2female";
		Player.ScoreIcon "FITEFACE";
		Player.HealRadiusType "Health";
		Player.JumpZ 9;
		Player.Viewheight 48;
		Player.HexenArmor 0, 5, 15, 10, 25;
		//Player.StartItem "Mana1";
		//Player.StartItem "Mana2";
		Player.StartItem "SWeapBloodRain";
		Player.Portrait "P_FWALK1";
		Player.WeaponSlot 1, "SWeapBloodRain";
		Player.WeaponSlot 2, "SWeapAcidRune";
		Player.WeaponSlot 3, "SWeapFireStorm";
		Player.WeaponSlot 4, "SWeapTempestStaff";

		// Fallback if no matching animations
		HXDDHexenIIPlayerPawn.WeaponFallbackAnimations 4;
		HXDDHexenIIPlayerPawn.Weapon1AnimationSet 1, "SWeapBloodRain";
		HXDDHexenIIPlayerPawn.Weapon2AnimationSet 2, "SWeapAcidRune";
		HXDDHexenIIPlayerPawn.Weapon3AnimationSet 3, "SWeapFireStorm";
		HXDDHexenIIPlayerPawn.Weapon4AnimationSet 4, "SWeapTempestStaff";
		
		
		Player.ColorRange 0, 0;
		Player.Colorset		0, "$TXT_COLOR_GOLD",		246, 254,    253;
		Player.ColorsetFile 1, "$TXT_COLOR_RED",		"TRANTBL0",  0xAC;
		Player.ColorsetFile 2, "$TXT_COLOR_BLUE",		"TRANTBL1",  0x9D;
		Player.ColorsetFile 3, "$TXT_COLOR_DULLGREEN",	"TRANTBL2",  0x3E;
		Player.ColorsetFile 4, "$TXT_COLOR_GREEN",		"TRANTBL3",  0xC8;
		Player.ColorsetFile 5, "$TXT_COLOR_GRAY",		"TRANTBL4",  0x2D;
		Player.ColorsetFile 6, "$TXT_COLOR_BROWN",		"TRANTBL5",  0x6F;
		Player.ColorsetFile 7, "$TXT_COLOR_PURPLE",		"TRANTBL6",  0xEE;
	}
	
	States
	{
	Spawn:
		PSHA ABCDEFGHIJKL 2;
		Loop;
	See:
		PRHA ABCDEFGHIJKL 2;
		Loop;
	Fly:
		PFSA ABCDEFGHIJKLMNO 2;
		Loop;
	Missile:
		PAHA ABCDEFGH 2;
		Goto Spawn;
	Melee:
		PAHA ABCDEFGH 2;
		Goto Spawn;
	Pain:
		TNT1 A 0 A_Pain;
		PPHA ABCDEFG 2;
		Goto Spawn;
	CrouchSpawn:
		PMCA A 2;
		Loop;
	Crouch:
		PMCA ABCDEFGHIJKLMNOPQRST 2;
		Loop;
	Jump:
		PAJA ABCDEFGHIJKLMNO 2;
		Goto Spawn;
	Spawn1:
		PSHA ABCDEFGHIJKL 2;
		Loop;
	Spawn2:
		PSRA ABCDEFGHIJKL 2;
		Loop;
	Spawn3:
		PSRA ABCDEFGHIJKL 2;
		Loop;
	Spawn4:
		PSSA ABCDEFGHIJKL 2;
		Loop;
	See1:
		PRHA ABCDEFGHIJKL 2;
		Loop;
	See2:
		PRRA ABCDEFGHIJKL 2;
		Loop;
	See3:
		PRRA ABCDEFGHIJKL 2;
		Loop;
	See4:
		PRSA ABCDEFGHIJKL 2;
		Loop;
	Fly1:
		PFHA ABCDEFGHIJKLMNO 2;
		Loop;
	Fly2:
		PFRA ABCDEFGHIJKLMNO 2;
		Loop;
	Fly3:
		PFRA ABCDEFGHIJKLMNO 2;
		Loop;
	Fly4:
		PFSA ABCDEFGHIJKLMNO 2;
		Loop;
	Weapon1:
		PAHA ABCDEFGH 2;
		Goto Spawn1;
	Weapon2:
		PARA ABCDEFGH 2;
		Goto Spawn2;
	Weapon3:
		PARA ABCDEFGH 2;
		Goto Spawn3;
	Weapon4:
		PASA ABCDEFGH 2;
		Goto Spawn4;
	Pain1:
		TNT1 A 0 A_Pain;
		PPHA ABCDEFG 2;
		Goto Spawn1;
	Pain2:
		TNT1 A 0 A_Pain;
		PPRA ABCDEFG 2;
		Goto Spawn2;
	Pain3:
		TNT1 A 0 A_Pain;
		PPRA ABCDEFG 2;
		Goto Spawn3;
	Pain4:
		TNT1 A 0 A_Pain;
		PPSA ABCDEFG 2;
		Goto Spawn4;
	Death:
		PDEA A 2 A_PlayerScream;
		PDEA BCDEFGHIJKLMNOPQRS 2;
		PDEA T -1;
		//PLAY H 6;
		//PLAY I 6 A_PlayerScream;
		//PLAY JK 6;
		//PLAY L 6 A_NoBlocking;
		//PLAY M 6;
		//PLAY N -1;
		Stop;		
	XDeath:
		PDDA A 2 A_SkullPop("HX2SuccubusPlayerHead");
		PDDA BCDEFGHIJKLMNOPQRSTUVWXYZ 2;
		PDDB A 2;
		PDDB B -1;
		//PLAY O 5 A_PlayerScream;
		//PLAY P 5 A_SkullPop("BloodyFighterSkull");
		//PLAY R 5 A_NoBlocking;
		//PLAY STUV 5;
		//PLAY W -1;
		Stop;
	Ice:
		PLAY X 5 A_FreezeDeath;
		PLAY X 1 A_FreezeDeathChunks;
		Wait;
	Burn:
		FDTH A 5 BRIGHT A_StartSound("*burndeath");
		FDTH B 4 BRIGHT;
		FDTH G 5 BRIGHT;
		FDTH H 4 BRIGHT A_PlayerScream;
		FDTH I 5 BRIGHT;
		FDTH J 4 BRIGHT;
		FDTH K 5 BRIGHT;
		FDTH L 4 BRIGHT;
		FDTH M 5 BRIGHT;
		FDTH N 4 BRIGHT;
		FDTH O 5 BRIGHT;
		FDTH P 4 BRIGHT;
		FDTH Q 5 BRIGHT;
		FDTH R 4 BRIGHT;
		FDTH S 5 BRIGHT A_NoBlocking;
		FDTH T 4 BRIGHT;
		FDTH U 5 BRIGHT;
		FDTH V 4 BRIGHT;
		ACLO E 35 A_CheckPlayerDone;
		Wait;
		ACLO E 8;
		Stop;
	}
}

class HX2SuccubusPlayerHead : HX2PlayerHead {}