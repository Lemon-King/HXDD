class PlayerSheet_AssassinPlayer: PlayerSheet {

	Default {
		PlayerSheet.DefaultArmorMode PSAM_ARMOR_AC;
		PlayerSheet.DefaultProgression PSP_LEVELS;
		PlayerSheet.Alignment "Evil";
	}

    override void DefineAdvancementStatTables() {
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
}