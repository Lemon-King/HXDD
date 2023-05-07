class PlayerSheet_SuccubusPlayer: PlayerSheet {

	Default {
		PlayerSheet.DefaultArmorMode PSAM_ARMOR_AC;
		PlayerSheet.DefaultProgression PSP_LEVELS;
		PlayerSheet.Alignment "Evil";
	}

    override void DefineAdvancementStatTables() {
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