class PlayerSheet_PaladinPlayer: PlayerSheet {

	Default {
		PlayerSheet.ExperienceModifier 1.4;
		PlayerSheet.DefaultArmorMode PSAM_ARMOR_AC;
		PlayerSheet.DefaultProgression PSP_LEVELS;
		PlayerSheet.Alignment "Good";
	}

    override void DefineAdvancementStatTables() {
		// Hexen 2: Paladin Stat Tables
		experienceTable[0] =	945;
		experienceTable[1] =	2240;
		experienceTable[2] =	5250;
		experienceTable[3] =	10150;
		experienceTable[4] =	21000;
		experienceTable[5] =	39900;
		experienceTable[6] =	72800;
		experienceTable[7] =	120400;
		experienceTable[8] =	154000;
		experienceTable[9] =	210000;
		experienceTable[10] =	210000;

		hitpointTable[0] = 70;
		hitpointTable[1] = 85;
		hitpointTable[2] = 8;
		hitpointTable[3] = 13;
		hitpointTable[4] = 4;

		manaTable[0] = 84;
		manaTable[1] = 94;
		manaTable[2] = 6;
		manaTable[3] = 9;
		manaTable[4] = 1;

		strengthTable[0] = 15;
		strengthTable[1] = 18;

		intelligenceTable[0] = 6;
		intelligenceTable[1] = 10;

		wisdomTable[0] = 6;
		wisdomTable[1] = 10;

		dexterityTable[0] = 10;
		dexterityTable[1] = 13;
	}
}