class PlayerSheet_ClericPlayer: PlayerSheet {
	Default {
		PlayerSheet.DefaultArmorMode PSAM_ARMOR_AC;
		PlayerSheet.DefaultProgression PSP_NONE;
		PlayerSheet.Alignment "Good";
	}

    override void DefineAdvancementStatTables() {
		// From CrusaderPlayer
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
}