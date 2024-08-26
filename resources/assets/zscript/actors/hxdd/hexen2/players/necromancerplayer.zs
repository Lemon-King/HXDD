// Necromancer
// Ref: https://github.com/sezero/uhexen2/blob/5da9351b3a219629ffd1b287d8fa7fa206e7d136/gamecode/hc/portals/stats.hc
// Hexen Armor: https://github.com/sezero/uhexen2/blob/5da9351b3a219629ffd1b287d8fa7fa206e7d136/gamecode/hc/h2/damage.hc#L16

class HX2NecromancerPlayer : HXDDHexenIIPlayerPawn
{
	Default
	{
		+NOSKIN
		+NODAMAGETHRUST
		+PLAYERPAWN.NOTHRUSTWHENINVUL
		PainSound "Hexen2PlayerMalePain";
		RadiusDamageFactor 0.25;
		Player.SpawnClass "Necromancer";
		Player.DisplayName "Necromancer";
		Player.SoundClass "hexen2male";
		Player.ScoreIcon "MAGEFACE";
		Player.InvulnerabilityMode "Reflective";
		Player.HealRadiusType "Mana";
		Player.JumpZ 9;
		Player.Viewheight 41;
		Player.HexenArmor 5, 5, 15, 10, 25;
		//Player.StartItem "Mana1";
		//Player.StartItem "Mana2";
		Player.StartItem "NWeapSickle";
		Player.Portrait "P_MWALK1";
		Player.WeaponSlot 1, "NWeapSickle";
		Player.WeaponSlot 2, "NWeapMagicMissile";
		Player.WeaponSlot 3, "NWeapBoneShards";
		Player.WeaponSlot 4, "MWeapBloodscourge";
		Player.FlechetteType "ArtiPoisonBag2";

		// Fallback if no matching animations
		HXDDHexenIIPlayerPawn.WeaponFallbackAnimations 4;
		HXDDHexenIIPlayerPawn.Weapon1AnimationSet 1, "NWeapSickle";
		HXDDHexenIIPlayerPawn.Weapon2AnimationSet 2, "NWeapMagicMissile";
		HXDDHexenIIPlayerPawn.Weapon3AnimationSet 3, "NWeapBoneShards";
		HXDDHexenIIPlayerPawn.Weapon4AnimationSet 4, "MWeapBloodscourge";
		HXDDHexenIIPlayerPawn.HasJumpAnimation false;

		
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
}
