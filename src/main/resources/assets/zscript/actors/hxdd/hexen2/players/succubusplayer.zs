// Assassin

class SuccubusPlayer : HXDDHexenIIPlayerPawn
{
	Default
	{
		Health 100;
		PainChance 255;
		Radius 16;
		Height 56;
		Speed 1;
		+NOSKIN
		+NODAMAGETHRUST
		+PLAYERPAWN.NOTHRUSTWHENINVUL
		RadiusDamageFactor 0.25;
		Player.JumpZ 9;
		Player.Viewheight 48;
		Player.SpawnClass "Demoness";
		Player.DisplayName "Demoness";
		Player.SoundClass "hexen2female";
		Player.ScoreIcon "FITEFACE";
		Player.HealRadiusType "Armor";
		//Player.HexenArmor 0, 25, 15, 5, 10;	// Default by Raven
		Player.HexenArmor 0, 5, 15, 10, 25;		// Copy of Necro Armor values (Maybe as a toggle?)
		Player.StartItem "Mana1";
		Player.StartItem "Mana2";
		Player.StartItem "SWeapBloodRain";
		Player.ForwardMove 1.08, 1.2;
		Player.SideMove 1.125, 1.475;
		Player.Portrait "P_FWALK1";
		Player.WeaponSlot 1, "SWeapBloodRain";
		Player.WeaponSlot 2, "SWeapAcidRune";
		Player.WeaponSlot 3, "SWeapFireStorm";
		Player.WeaponSlot 4, "FWeapQuietus";

		HXDDPlayerPawn.DefaultArmorMode PSAM_ARMOR_AC;
		HXDDPlayerPawn.DefaultProgression PSP_LEVELS;
		HXDDPlayerPawn.Alignment "Evil";

		// Fallback if no matching animations
		HXDDHexenIIPlayerPawn.WeaponFallbackAnimations 4;
		HXDDHexenIIPlayerPawn.Weapon1AnimationSet "SWeapBloodRain", 1;
		HXDDHexenIIPlayerPawn.Weapon2AnimationSet "SWeapAcidRune", 2;
		HXDDHexenIIPlayerPawn.Weapon3AnimationSet "SWeapFireStorm", 3;
		HXDDHexenIIPlayerPawn.Weapon4AnimationSet "FWeapQuietus", 4;
		
		
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
		PLAY H 6;
		PLAY I 6 A_PlayerScream;
		PLAY JK 6;
		PLAY L 6 A_NoBlocking;
		PLAY M 6;
		PLAY N -1;
		Stop;		
	XDeath:
		PLAY O 5 A_PlayerScream;
		PLAY P 5 A_SkullPop("BloodyFighterSkull");
		PLAY R 5 A_NoBlocking;
		PLAY STUV 5;
		PLAY W -1;
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

	override void SetAdvancementStatTables() {
		// Hexen 2: Succubus Stat Tables
		experienceTable[0] =	871;
		experienceTable[1] =	2060;
		experienceTable[2] =	4822;
		experienceTable[3] =	9319;
		experienceTable[4] =	19278;
		experienceTable[5] =	36626;
		experienceTable[6] =	66804;
		experienceTable[7] =	110494;
		experienceTable[8] =	141334;
		experienceTable[9] =	192700;
		experienceTable[10] =	192700;

		hitpointTable[0] = 65;
		hitpointTable[1] = 75;
		hitpointTable[2] = 5;
		hitpointTable[3] = 10;
		hitpointTable[4] = 3;

		manaTable[0] = 90;
		manaTable[1] = 100;
		manaTable[2] = 8;
		manaTable[3] = 11;
		manaTable[4] = 3;

		strengthTable[0] = 11;
		strengthTable[1] = 14;

		intelligenceTable[0] = 9;
		intelligenceTable[1] = 13;

		wisdomTable[0] = 11;
		wisdomTable[1] = 14;

		dexterityTable[0] = 9;
		dexterityTable[1] = 13;
	}
}
