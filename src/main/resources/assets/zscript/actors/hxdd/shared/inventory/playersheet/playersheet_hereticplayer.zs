class PlayerSheet_HereticPlayer: PlayerSheet {
	Default {
		PlayerSheet.DefaultArmorMode PSAM_ARMOR_SIMPLE;
		PlayerSheet.DefaultProgression PSP_NONE;
		PlayerSheet.Alignment "Good";
	}

    override void DefineAdvancementStatTables() {
		// From AssassinPlayer with Modifications
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

		strengthTable[0] = 6;
		strengthTable[1] = 10;

		intelligenceTable[0] = 10;
		intelligenceTable[1] = 13;

		wisdomTable[0] = 12;
		wisdomTable[1] = 15;

		dexterityTable[0] = 15;
		dexterityTable[1] = 18;
	}
}