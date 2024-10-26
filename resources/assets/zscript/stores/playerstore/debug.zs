mixin class PlayerStoreDebug {
	void DEBUG_LevelUp(int amount = 1) {
		console.printf("DEBUG CHEAT: LEVEL UP!");
		int pLevel = clamp(0, self.currlevel + amount, self.maxLevel);
		if (pLevel != self.currlevel && pLevel < self.maxLevel) {
			self.experience = self.experienceTable[min(pLevel, self.experienceTable.Size() - 1)];
			AdvanceLevel(pLevel);
		}
	}
}

// Supporting Actors
class Cheat_LevelUp : Actor {
	int amount;

	Default {
		+NOINTERACTION;

		Height 0;
		Radius 0;
	}
	
	States {
		Spawn:
			TNT0 A 1;
			Stop;
	}

	override void PostBeginPlay() {
		Super.PostBeginPlay();

		FindPlayerAndLevelUp();
	}

	void FindPlayerAndLevelUp() {
		if (!amount) {
			amount = 1;
		}

		console.printf("Searching for Players");
		int pid = -1;
		double dist = -1;
        for (int i = 0; i < Players.Size(); i++) {
            if (!PlayerInGame[i]) {
                continue;
			}

			PlayerPawn pp = PlayerPawn(players[i].mo);

			if (pp) {
				double ndist = pp.pos.Length() - self.pos.Length();
				if (dist == -1 || ndist < dist) {
					console.printf("Found %d", i);
					pid = i;
					dist = ndist;
				}
			}
		}

		if (pid != -1) {
			PlayerSlot pStore = HXDDPlayerStore.GetPlayerSlot(pid);
			if (pStore) {
				//pStore.DEBUG_LevelUp(amount);
			}
		}
	}
}


class Cheat_LevelUpMax : Cheat_LevelUp {
	override void BeginPlay() {
		amount = 255;
	}
}