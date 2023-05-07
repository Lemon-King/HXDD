class PlayerSheet_CrusaderPlayer: PlayerSheet {

	Default {
		PlayerSheet.ExperienceModifier 1.35;
		PlayerSheet.DefaultArmorMode PSAM_ARMOR_AC;
		PlayerSheet.DefaultProgression PSP_LEVELS;
		PlayerSheet.Alignment "Good";
	}

    override void DefineAdvancementStatTables() {
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

	override void OnKill(PlayerPawn player, Actor target, double amount) {
		// Crusader Skill
		// Ref: https://github.com/videogamepreservation/hexen2/blob/master/H2W/HCode/stats.hc#L503

        Progression prog = Progression(owner.FindInventory("Progression"));
		
		if (prog == NULL) {
			return;
		}

		if (level > 2) {
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
				owner.player.mo.GiveBody(MaxHealth, MaxHealth);
			}
		}

		if (level > 5) {
			double chance = 0.05 + (prog.level - 3) * 0.03;
			if (chance > 0.2) {
				chance = 0.2;
			}
			if (frandom[poweruporb](0.0, 1.0) > chance) {
				return;
			}
			Actor itemHolyStrength = Spawn("H2HolyStrength");
			itemHolyStrength.SetOrigin(target.pos, false);
			itemHolyStrength.angle = target.angle;
		}
	}
}