// Assassin

class AssassinPlayer : HXDDHexenIIPlayerPawn
{
	double stealthLevel;

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
		Player.SpawnClass "Assassin";
		Player.DisplayName "Assassin";
		Player.SoundClass "hexen2female";
		Player.ScoreIcon "FITEFACE";
		Player.HealRadiusType "Armor";
		Player.HexenArmor 0, 25, 15, 5, 10;
		Player.StartItem "Mana1";
		Player.StartItem "Mana2";
		Player.StartItem "AWeapPunchDagger";
		Player.ForwardMove 1.08, 1.2;
		Player.SideMove 1.125, 1.475;
		Player.Portrait "P_FWALK1";
		Player.WeaponSlot 1, "AWeapPunchDagger";
		Player.WeaponSlot 2, "AWeapCrossbow";
		Player.WeaponSlot 3, "AWeapGrenades";
		Player.WeaponSlot 4, "FWeapQuietus";

		HXDDPlayerPawn.DefaultArmorMode PSAM_ARMOR_AC;
		HXDDPlayerPawn.DefaultProgression PSP_LEVELS;
		HXDDPlayerPawn.Alignment "Evil";

		// Fallback if no matching animations
		HXDDHexenIIPlayerPawn.WeaponFallbackAnimations 4;
		HXDDHexenIIPlayerPawn.Weapon1AnimationSet "AWeapPunchDagger", 1;
		HXDDHexenIIPlayerPawn.Weapon2AnimationSet "AWeapCrossbow", 2;
		HXDDHexenIIPlayerPawn.Weapon3AnimationSet "AWeapGrenades", 3;
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
		PSSA ABCDEFGHIJKLM 2;
		Loop;
	See:
		PSSA ABCDEFGHIJKL 2;
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
		PPDA ABCDEFG 2;
		Goto Spawn;
	CrouchSpawn:
		PCAA A 2;
		Loop;
	Crouch:
		PMCA ABCDEFGHIJKLMNOPQRST 2;
		Loop;
	Jump:
		PAJA ABCDEFGHIJKL 2;
		Goto JumpEnd;
	JumpEnd:
		PSDA ABCDEFGHIJKLM 2;
		Loop;
	Spawn1:
		PSDA ABCDEFGHIJKLM 2;
		Loop;
	Spawn2:
		PSXA ABCDEFGHIJKLM 2;
		Loop;
	Spawn3:
		PSDA ABCDEFGHIJKLM 2;
		Loop;
	Spawn4:
		PSSA ABCDEFGHIJKLM 2;
		Loop;
	See1:
		PRDA ABCDEFGHIJKL 2;
		Loop;
	See2:
		PRXA ABCDEFGHIJKL 2;
		Loop;
	See3:
		PRDA ABCDEFGHIJKL 2;
		Loop;
	See4:
		PRSA ABCDEFGHIJKL 2;
		Loop;
	Fly1:
		PFDA ABCDEFGHIJKLMNO 2;
		Loop;
	Fly2:
		PFXA ABCDEFGHIJKLMNO 2;
		Loop;
	Fly3:
		PFDA ABCDEFGHIJKLMNO 2;
		Loop;
	Fly4:
		PFSA ABCDEFGHIJKLMNO 2;
		Loop;
	Weapon1:
		PADA ABCDEFGHIJK 2;
		Goto Spawn1;
	Weapon2:
		PAXA ABCD 2;
		Goto Spawn2;
	Weapon3:
		PADA ABCDEFGHIJK 2;
		Goto Spawn3;
	Weapon4:
		PASA ABCD 2;
		Goto Spawn4;
	Pain1:
		TNT1 A 0 A_Pain;
		PPDA ABCDEFG 2;
		Goto Spawn1;
	Pain2:
		TNT1 A 0 A_Pain;
		PPXA ABCDEFG 2;
		Goto Spawn2;
	Pain3:
		TNT1 A 0 A_Pain;
		PPDA ABCDEFG 2;
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
		// Hexen 2: Assassin Stat Tables
		experienceTable[0] =	675;
		experienceTable[1] =	1600;
		experienceTable[2] =	3750;
		experienceTable[3] =	7250;
		experienceTable[4] =	15000;
		experienceTable[5] =	28500;
		experienceTable[6] =	52000;
		experienceTable[7] =	86000;
		experienceTable[8] =	110000;
		experienceTable[9] =	150000;
		experienceTable[10] =	150000;

		hitpointTable[0] = 65;
		hitpointTable[1] = 75;
		hitpointTable[2] = 5;
		hitpointTable[3] = 10;
		hitpointTable[4] = 3;

		manaTable[0] = 92;
		manaTable[1] = 102;
		manaTable[2] = 9;
		manaTable[3] = 11;
		manaTable[4] = 3;

		strengthTable[0] = 10;
		strengthTable[1] = 13;

		intelligenceTable[0] = 6;
		intelligenceTable[1] = 10;

		wisdomTable[0] = 12;
		wisdomTable[1] = 15;

		dexterityTable[0] = 15;
		dexterityTable[1] = 18;
	}

	override void Tick() {
		Super.Tick();

		// NYI: Just testing tech

		if (level >= 0) {
			//GetActorLightLevel
			// Check Player Light level, update stealth state
			if (InStateSequence(CurState, Player.mo.FindState("Death")) || InStateSequence(CurState, Player.mo.FindState("XDeath"))) {

			} else {
				int lightLevel = self.cursector.GetLightLevel();
				double stealthChange = 0;
				double lightHigh = 144;
				if (lightLevel >= lightHigh) {
					stealthChange = -lightLevel * 0.00075f;
				} else {
					stealthChange = (255.0f - lightLevel) * 0.00025f;
				}

				stealthLevel = Clamp(stealthLevel + stealthChange, 0.0f, 1.0f);

				if (stealthLevel == 1.0) {
					A_SetRenderStyle(1, STYLE_Shadow);
				} else {
					self.Alpha = 1.0f;
					A_SetRenderStyle(1, STYLE_Normal);
				}
			}
		}
	}
}
