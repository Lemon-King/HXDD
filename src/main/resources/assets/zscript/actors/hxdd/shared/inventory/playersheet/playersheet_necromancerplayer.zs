class PlayerSheet_NecromancerPlayer: PlayerSheet {

	Default {
		PlayerSheet.ExperienceModifier 1.22;
		PlayerSheet.DefaultArmorMode PSAM_ARMOR_AC;
		PlayerSheet.DefaultProgression PSP_LEVELS;
		PlayerSheet.Alignment "Evil";
	}

    override void DefineAdvancementStatTables() {
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

	override void OnKill(PlayerPawn player, Actor target, double amount) {
        Progression prog = Progression(owner.FindInventory("Progression"));
		if (prog == NULL) {
			return;
		}

		if (level > 5) {
			double chance = 0.05 + (prog.level - 3) * 0.03;
			if (chance > 0.2) {
				chance = 0.2;
			}
			if (frandom[poweruporb](0.0, 1.0) > chance) {
				return;
			}
			Actor itemSoulSphere = Spawn("H2SoulSphere");
			itemSoulSphere.SetOrigin(target.pos, false);
			itemSoulSphere.angle = target.angle;
		}
	}
}