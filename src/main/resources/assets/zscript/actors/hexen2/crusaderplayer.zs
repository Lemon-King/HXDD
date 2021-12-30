// Assassin

class CrusaderPlayer : HXDDPlayerPawn
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
		Player.SpawnClass "Crusader";
		Player.DisplayName "Crusader";
		Player.SoundClass "hexen2male";
		Player.ScoreIcon "FITEFACE";
		Player.HealRadiusType "Armor";
		Player.HexenArmor 0, 10, 5, 25, 15;
		Player.StartItem "Mana1";
		Player.StartItem "Mana2";
		Player.StartItem "CWeapWarhammer";
		Player.ForwardMove 1.08, 1.2;
		Player.SideMove 1.125, 1.475;
		Player.Portrait "P_FWALK1";
		Player.WeaponSlot 1, "CWeapWarhammer";
		Player.WeaponSlot 2, "CWeapIceMace";
		Player.WeaponSlot 3, "CWeapMeteorStaff";
		Player.WeaponSlot 4, "FWeapQuietus";

		HXDDPlayerPawn.ExperienceModifier 1.35;

		HXDDPlayerPawn.DefaultArmorMode "hexen";
		HXDDPlayerPawn.DefaultProgression "levels";

		// Fallback if no matching animations
		HXDDPlayerPawn.WeaponFallbackAnimations 4;
		HXDDPlayerPawn.Weapon1AnimationSet "CWeapWarhammer", 1;
		HXDDPlayerPawn.Weapon2AnimationSet "CWeapIceMace", 2;
		HXDDPlayerPawn.Weapon3AnimationSet "CWeapMeteorStaff", 3;
		HXDDPlayerPawn.Weapon4AnimationSet "FWeapQuietus", 4;
		
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
		PPHA ABCDEFGH 2;
		Goto Spawn;
	CrouchSpawn:
		PMCA A 2;
		Loop;
	Crouch:
		PMCA ABCDEFGHIJKLMNOPQRST 2;
		Loop;
	Jump:
		PAJA ABCDEFGHIJKLM 2;
		Goto JumpEnd;
	JumpEnd:
		PSHA ABCDEFGHIJKLM 2;
		Loop;
	Spawn1:
		PSHA ABCDEFGHIJKLM 2;
		Loop;
	Spawn2:
		PSIS ABCDEFGHIJKLM 2;
		Loop;
	Spawn3:
		PSSA ABCDEFGHIJKLM 2;
		Loop;
	Spawn4:
		PSSA ABCDEFGHIJKLM 2;
		Loop;
	See1:
		PRHA ABCDEFGHIJKL 2;
		Loop;
	See2:
		PRIS ABCDEFGHIJKL 2;
		Loop;
	See3:
		PRSA ABCDEFGHIJKL 2;
		Loop;
	See4:
		PRSA ABCDEFGHIJKL 2;
		Loop;
	Fly1:
		PFHA ABCDEFGHIJKLMNO 2;
		Loop;
	Fly2:
		PFIS ABCDEFGHIJKLMNO 2;
		Loop;
	Fly3:
		PFSA ABCDEFGHIJKLMNO 2;
		Loop;
	Fly4:
		PFSA ABCDEFGHIJKLMNO 2;
		Loop;
	Weapon1:
		PAHA ABCDEFGHIJ 2;
		Goto Spawn1;
	Weapon2:
		PAIS ABCD 2;
		Goto Spawn2;
	Weapon3:
		PASA ABCDE 2;
		Goto Spawn3;
	Weapon4:
		PASA ABCDE 2;
		Goto Spawn4;
	Pain1:
		TNT1 A 0 A_Pain;
		PPHA ABCDEFGH 2;
		Goto Spawn1;
	Pain2:
		TNT1 A 0 A_Pain;
		PPIS ABCDEFGH 2;
		Goto Spawn2;
	Pain3:
		TNT1 A 0 A_Pain;
		PPSA ABCDEFGH 2;
		Goto Spawn3;
	Pain4:
		TNT1 A 0 A_Pain;
		PPSA ABCDEFGH 2;
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
		// Hexen 2: Crusader Stat Tables
		experienceTable[0] =	911;
		experienceTable[1] =	2160;
		experienceTable[2] =	5062;
		experienceTable[3] =	9787;
		experienceTable[4] =	20250;
		experienceTable[5] =	38475;
		experienceTable[6] =	70200;
		experienceTable[7] =	116100;
		experienceTable[8] =	148500;
		experienceTable[9] =	202500;
		experienceTable[10] =	202500;

		hitpointTable[0] = 65;
		hitpointTable[1] = 75;
		hitpointTable[2] = 5;
		hitpointTable[3] = 10;
		hitpointTable[4] = 3;

		manaTable[0] = 88;
		manaTable[1] = 98;
		manaTable[2] = 7;
		manaTable[3] = 10;
		manaTable[4] = 2;

		strengthTable[0] = 12;
		strengthTable[1] = 15;

		intelligenceTable[0] = 10;
		intelligenceTable[1] = 13;

		wisdomTable[0] = 15;
		wisdomTable[1] = 18;

		dexterityTable[0] = 6;
		dexterityTable[1] = 10;
	}

	override void OnKill(Actor target, double amount) {
		// Crusader Skill
		// Ref: https://github.com/videogamepreservation/hexen2/blob/master/H2W/HCode/stats.hc#L503

        Progression prog = Progression(self.FindInventory("Progression"));
		
		if (level < 3 || prog == NULL) {
			return;
		}

		double pct40 = 0;
		double pct80 = 0;
		int currLevel = level - 1;
		int nextLevel = currLevel + 1;
		if (level == 1) {
			pct40 = prog.experienceTable[currLevel] * 0.4;
			pct80 = prog.experienceTable[currLevel] * 0.8;
		} else if (level <= 20) {	
			double diff = prog.experienceTable[nextLevel] - prog.experienceTable[currLevel]; 
			pct40 = prog.experienceTable[currLevel] + (diff * 0.4);
			pct80 = prog.experienceTable[currLevel] + (diff * 0.8);
		} else {
			double totalNext = prog.experienceTable[currLevel];
			totalnext += (currLevel - 20) * prog.experienceTable[currLevel];

			pct40 = totalnext + (prog.experienceTable[currLevel] * 0.4);
			pct80 = totalnext + (prog.experienceTable[currLevel] * 0.8);
		}

		if ((((experience - amount) < pct40) && (experience > pct40)) || (((experience - amount) < pct80) && (experience > pct80))) {
			console.printf("Bonus Health!");
			HealThing(MaxHealth, MaxHealth);
		}
	}
}
