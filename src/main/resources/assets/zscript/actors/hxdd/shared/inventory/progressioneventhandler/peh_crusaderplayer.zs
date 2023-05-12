class PEH_CrusaderPlayer: ProgressionEventHandler {
	override void OnKill(PlayerPawn player, Actor target, double amount) {
		// Crusader Skill
		// Ref: https://github.com/videogamepreservation/hexen2/blob/master/H2W/HCode/stats.hc#L503

        Progression prog = Progression(owner.FindInventory("Progression"));
		
		if (prog == NULL) {
			return;
		}

		if (prog.level > 2) {
			double pct40 = 0;
			double pct80 = 0;
			int currLevel = prog.level;
			int nextLevel = currLevel + 1;
			if (prog.level == 1) {
				pct40 = prog.experienceTable[currLevel] * 0.4;
				pct80 = prog.experienceTable[currLevel] * 0.8;
			} else if (prog.level <= prog.MaxLevel) {	
				double diff = prog.experienceTable[nextLevel] - prog.experienceTable[currLevel]; 
				pct40 = prog.experienceTable[currLevel] + (diff * 0.4);
				pct80 = prog.experienceTable[currLevel] + (diff * 0.8);
			} else {
				double totalNext = prog.experienceTable[currLevel];
				totalnext += (currLevel - prog.MaxLevel) * prog.experienceTable[currLevel];

				pct40 = totalnext + (prog.experienceTable[currLevel] * 0.4);
				pct80 = totalnext + (prog.experienceTable[currLevel] * 0.8);
			}

			if ((((prog.experience - amount) < pct40) && (prog.experience > pct40)) || (((prog.experience - amount) < pct80) && (prog.experience > pct80))) {
				console.printf("Bonus Health!");
				owner.player.mo.GiveBody(prog.MaxHealth, prog.MaxHealth);
			}
		}

		if (prog.level > 5) {
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