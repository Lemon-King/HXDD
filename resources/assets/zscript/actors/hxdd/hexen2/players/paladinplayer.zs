// Paladin

class HX2PaladinPlayer : HXDDHexenIIPlayerPawn {
	Default {
		Health 100;
		PainChance 255;
		Radius 16;
		Height 56;
		Speed 1;
		+NOSKIN
		+NODAMAGETHRUST
		+PLAYERPAWN.NOTHRUSTWHENINVUL
		PainSound "Hexen2PlayerMalePain";
		RadiusDamageFactor 0.25;
		Player.JumpZ 9;
		Player.Viewheight 41;
		Player.SpawnClass "Paladin";
		Player.DisplayName "Paladin";
		Player.SoundClass "hexen2male";
		Player.ScoreIcon "FITEFACE";
		Player.HealRadiusType "Armor";
		Player.HexenArmor 15, 25, 10, 20, 5;
		//Player.StartItem "Mana1";
		//Player.StartItem "Mana2";
		Player.StartItem "PWeapGauntlet";
		Player.Portrait "P_FWALK1";
		Player.WeaponSlot 1, "PWeapGauntlet";
		Player.WeaponSlot 2, "PWeapVorpalSword";
		Player.WeaponSlot 3, "PWeapAxe";
		Player.WeaponSlot 4, "PWeapPurifier";

		// Fallback if no matching animations
		HXDDHexenIIPlayerPawn.WeaponFallbackAnimations 4;
		HXDDHexenIIPlayerPawn.Weapon1AnimationSet "PWeapGauntlet", 1;
		HXDDHexenIIPlayerPawn.Weapon2AnimationSet "PWeapVorpalSword", 2;
		HXDDHexenIIPlayerPawn.Weapon3AnimationSet "PWeapAxe", 3;
		HXDDHexenIIPlayerPawn.Weapon4AnimationSet "PWeapPurifier", 4;

		
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
	
	States {
		Spawn:
			PSSA ABCDEFGHIJKLM 2;
			Loop;
		See:
			PRSA ABCDEFGHIJKL 2;
			Loop;
		Fly:
			PFSA ABCDEFGHIJKLMNO 2;
			Loop;
		Missile:
			PASA ABCD 2;
			Goto Spawn;
		Melee:
			PADA ABCDEFGHIJK 2;
			Goto Spawn;
		Pain:
			TNT1 A 0 A_Pain;
			PPGA ABCDEFG 2;
			Goto Spawn;
		CrouchSpawn:
			PMCA A 2;
			Loop;
		Crouch:
			PMCA ABCDEFGHIJKLMNOPQRST 2;
			Loop;
		Jump:
			PAJA ABCDEFGHIJKL 2;
			Goto Spawn;
		Spawn1:
			PSGA ABCDEFGHIJKLM 2;
			Loop;
		Spawn2:
			PSSA ABCDEFGHIJKLM 2;
			Loop;
		Spawn3:
			PSSA ABCDEFGHIJKLM 2;
			Loop;
		Spawn4:
			PSST ABCDEFGHIJKLM 2;
			Loop;
		See1:
			PRGA ABCDEFGHIJKL 2;
			Loop;
		See2:
			PRSA ABCDEFGHIJKL 2;
			Loop;
		See3:
			PRSA ABCDEFGHIJKL 2;
			Loop;
		See4:
			PRST ABCDEFGHIJKL 2;
			Loop;
		Fly1:
			PFGA ABCDEFGHIJKLMNO 2;
			Loop;
		Fly2:
			PFSA ABCDEFGHIJKLMNO 2;
			Loop;
		Fly3:
			PFSA ABCDEFGHIJKLMNO 2;
			Loop;
		Fly4:
			PFST ABCDEFGHIJKLMNO 2;
			Loop;
		Weapon1:
			PAGA ABCDEFGHIJK 2;
			Goto Spawn1;
		Weapon2:
			PASA ABCDEFGHIJKL 2;
			Goto Spawn2;
		Weapon3:
			PASA ABCDEFGHIJKL 2;
			Goto Spawn3;
		Weapon4:
			PAST ABCD 2;
			Goto Spawn4;
		Pain1:
			TNT1 A 0 A_Pain;
			PPGA ABCDEFG 2;
			Goto Spawn1;
		Pain2:
			TNT1 A 0 A_Pain;
			PPSA ABCDEFG 2;
			Goto Spawn2;
		Pain3:
			TNT1 A 0 A_Pain;
			PPSA ABCDEFG 2;
			Goto Spawn3;
		Pain4:
			TNT1 A 0 A_Pain;
			PPST ABCDEFG 2;
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
			PDDA A 2 A_SkullPop("HX2PaladinPlayerHead");
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

class HX2PaladinPlayerHead : HX2PlayerHead {}
