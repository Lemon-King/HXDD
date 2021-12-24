// Necromancer

class NecromancerPlayer : HXDDPlayerPawn
{
	Default
	{
		Health 100;
		ReactionTime 0;
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
		Player.SpawnClass "Necromancer";
		Player.DisplayName "Necromancer";
		Player.SoundClass "hexen2male";
		Player.ScoreIcon "MAGEFACE";
		Player.InvulnerabilityMode "Reflective";
		Player.HealRadiusType "Mana";
		Player.HexenArmor 0, 5, 15, 10, 25;
		Player.StartItem "Mana1";
		Player.StartItem "Mana2";
		Player.StartItem "NWeapSickle";
		Player.ForwardMove 0.88, 0.92;
		Player.SideMove 0.875, 0.925;
		Player.Portrait "P_MWALK1";
		Player.WeaponSlot 1, "NWeapSickle";
		Player.WeaponSlot 2, "NWeapMagicMissile";
		Player.WeaponSlot 3, "NWeapBoneShards";
		Player.WeaponSlot 4, "MWeapBloodscourge";
		Player.FlechetteType "ArtiPoisonBag2";

		HXDDPlayerPawn.ExperienceModifier 1.22;

		HXDDPlayerPawn.DefaultArmorMode "hexen";
		HXDDPlayerPawn.DefaultProgression "levels";

		// Fallback if no matching animations
		HXDDPlayerPawn.WeaponFallbackAnimations 4;
		HXDDPlayerPawn.Weapon1AnimationSet "NWeapSickle", 1;
		HXDDPlayerPawn.Weapon2AnimationSet "NWeapMagicMissile", 2;
		HXDDPlayerPawn.Weapon3AnimationSet "NWeapBoneShards", 3;
		HXDDPlayerPawn.Weapon4AnimationSet "MWeapBloodscourge", 4;
		HXDDPlayerPawn.HasJumpAnimation false;
		
		Player.ColorRange 0, 0;
		Player.Colorset		0, "$TXT_COLOR_BLUE",		146, 163,    161;
		Player.ColorsetFile 1, "$TXT_COLOR_RED",		"TRANTBL7",  0xB3;
		Player.ColorsetFile 2, "$TXT_COLOR_GOLD",		"TRANTBL8",  0x8C;
		Player.ColorsetFile 3, "$TXT_COLOR_DULLGREEN",	"TRANTBL9",  0x41;
		Player.ColorsetFile 4, "$TXT_COLOR_GREEN",		"TRANTBLA",  0xC9;
		Player.ColorsetFile 5, "$TXT_COLOR_GRAY",		"TRANTBLB",  0x30;
		Player.ColorsetFile 6, "$TXT_COLOR_BROWN",		"TRANTBLC",  0x72;
		Player.ColorsetFile 7, "$TXT_COLOR_PURPLE",		"TRANTBLD",  0xEE;
	}

	States
	{
	RefPose:
		PREF A 1;
		Loop;
	Spawn:
		PSHA ABCDEFGHIJKL 2;
		Loop;
	See:
		PRHA ABCDEFGHIJKL 2;
		Loop;
	Fly:
		PFHA ABCDEFGHIJKLMNO 2;
		Loop;
	Missile:
		PAHA ABCDEFGHI 2;
		Goto Spawn;
	Melee:
		PAHA ABCDEFGHI 2;
		Goto Spawn;
	Pain:
		TNT1 A 0 A_Pain;
		PPHA ABCDEFGH 2;
		Goto Spawn;
	CrouchSpawn:
		PCHA A 2;
		Loop;
	Crouch:
		PCHA ABCDEFGHIJKLMNOPQRS 2;
		Loop;
	Spawn1:
		PSSI ABCDEFGHIJKL 2;
		Loop;
	Spawn2:
		PSHA ABCDEFGHIJKL 2;
		Loop;
	Spawn3:
		PSHA ABCDEFGHIJKL 2;
		Loop;
	Spawn4:
		PSST ABCDEFGHIJKL 2;
		Loop;
	See1:
		PRSI ABCDEFGHIJKL 2;
		Loop;
	See2:
		PRHA ABCDEFGHIJKL 2;
		Loop;
	See3:
		PRHA ABCDEFGHIJKL 2;
		Loop;
	See4:
		PRST ABCDEFGHIJKL 2;
		Loop;
	Fly1:
		PFSI ABCDEFGHIJKLMNO 2;
		Loop;
	Fly2:
		PFHA ABCDEFGHIJKLMNO 2;
		Loop;
	Fly3:
		PFHA ABCDEFGHIJKLMNO 2;
		Loop;
	Fly4:
		PFST ABCDEFGHIJKLMNO 2;
		Loop;
	Weapon1:
		PASI ABCDEFGH 2;
		Goto Spawn1;
	Weapon2:
		PAHA ABCDEFGH 2;
		Goto Spawn2;
	Weapon3:
		PAHA ABCDEFGH 2;
		Goto Spawn3;
	Weapon4:
		PAST ABCDEFGH 2;
		Goto Spawn4;
	Pain1:
		TNT1 A 0 A_Pain;
		PPSI ABCDEFGH 2;
		Goto Spawn1;
	Pain2:
		TNT1 A 0 A_Pain;
		PPHA ABCDEFGH 2;
		Goto Spawn2;
	Pain3:
		TNT1 A 0 A_Pain;
		PPHA ABCDEFGH 2;
		Goto Spawn3;
	Pain4:
		TNT1 A 0 A_Pain;
		PPST ABCDEFGH 2;
		Goto Spawn4;
	Death:
		MAGE H 6;
		MAGE I 6 A_PlayerScream;
		MAGE JK 6;
		MAGE L 6 A_NoBlocking;
		MAGE M 6;
		MAGE N -1;
		Stop;
	XDeath:
		MAGE O 5 A_PlayerScream;
		MAGE P 5;
		MAGE R 5 A_NoBlocking;
		MAGE STUVW 5;
		MAGE X -1;
		Stop;
	Ice:
		MAGE Y 5 A_FreezeDeath;
		MAGE Y 1 A_FreezeDeathChunks;
		Wait;
	Burn:
		FDTH E 5 BRIGHT A_StartSound("*burndeath");
		FDTH F 4 BRIGHT;
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
		// Hexen 2: Necromancer Stat Tables
		experienceTable[0] =	823;
		experienceTable[1] =	1952;
		experienceTable[2] =	4575;
		experienceTable[3] =	8845;
		experienceTable[4] =	18300;
		experienceTable[5] =	34770;
		experienceTable[6] =	63440;
		experienceTable[7] =	104920;
		experienceTable[8] =	134200;
		experienceTable[9] =	183000;
		experienceTable[10] =	183000;

		hitpointTable[0] = 65;
		hitpointTable[1] = 75;
		hitpointTable[2] = 5;
		hitpointTable[3] = 10;
		hitpointTable[4] = 3;

		manaTable[0] = 96;
		manaTable[1] = 106;
		manaTable[2] = 10;
		manaTable[3] = 12;
		manaTable[4] = 4;

		strengthTable[0] = 6;
		strengthTable[1] = 10;

		intelligenceTable[0] = 15;
		intelligenceTable[1] = 18;

		wisdomTable[0] = 10;
		wisdomTable[1] = 13;

		dexterityTable[0] = 8;
		dexterityTable[1] = 12;
	}
}
