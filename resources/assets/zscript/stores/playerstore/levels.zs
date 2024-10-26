mixin class PlayerSlotLevel {
	void InitLevel_PostBeginPlay() {
		if (self.currlevel != 0) {
			return;
		}

		bool cvarAllowBackpackUse = LemonUtil.CVAR_GetBool("hxdd_allow_backpack_use", false);

		let player = self.GetPlayer().mo;
		self.SpawnHealth = player.Health;

		if (self.UseMaxHealthScaler && self.SpawnHealth != 100) {
        	self.MaxHealth = self.SpawnHealth * (stats_compute(hitpointTable[0], hitpointTable[1]) / 100.0);
		} else {
			self.MaxHealth = stats_compute(hitpointTable[0], hitpointTable[1]);
		}
		player.MaxHealth = self.MaxHealth;
        player.A_SetHealth(self.MaxHealth, AAPTR_DEFAULT);

		// Calc initial ammo
		// Add ammo dummies to player
		uint end = AllActorClasses.Size();
		for (uint i = 0; i < end; ++i) {
			let ammotype = (class<Ammo>)(AllActorClasses[i]);
			if (ammotype && GetDefaultByType(ammotype).GetParentAmmo() == ammotype) {
				Ammo ammoItem = Ammo(self.GetPlayer().mo.FindInventory(ammotype));
				bool isUnowned = false;
				if (ammoItem == null) {
					// The player did not have the ammoitem. Add it.
					ammoItem = Ammo(self.GetPlayer().mo.Spawn(ammotype));	// use player as a surrogate actor to spawn ammo
					ammoItem.UseSound = "TAG_HXDD_IGNORE_SPAWN";	// HACK
					isUnowned = true;
				}
				ammoItem.AttachToOwner(self.GetPlayer().mo);
				AmmoItem_RefreshAmount(ammoItem);
				if (ammoItem.UseSound == "TAG_HXDD_IGNORE_SPAWN") {
					// Clear any unowned ammo
					ammoItem.Amount = 0;
				}
			}
		}

		Inventory next;
		for (Inventory item = player.Inv; item != NULL; item = next) {
			next = item.Inv;

			let invItem = player.FindInventory(item.GetClass());
			if (invItem != NULL && invItem is "Ammo") {
				Ammo ammoItem = Ammo(invItem);
				AmmoItem_RefreshAmount(ammoItem);
			}
		}

		self.currlevel = 1;
		self.experience = 0;
		self.leveldiffxp = self.experienceTable[0];

		console.printf("");
		console.printf("Level: %d", self.currlevel);
		console.printf("----- Stats -----");
		console.printf("Health: %0.2f", self.MaxHealth);
		foreach (k, v : self.stats) {
			String nameCap = String.format("%s%s", k.Left(1).MakeUpper(), k.Mid(1, k.Length() - 1));
			console.printf("%s: %0.2f", nameCap, v.value);
		}
        bool cvar_isdev_environment = LemonUtil.CVAR_GetBool("hxdd_isdev_environment", false);
		if (cvar_isdev_environment) {
			foreach (k, v : self.resources) {
				String nameCap = String.format("%s%s", k.Left(1).MakeUpper(), k.Mid(1, k.Length() - 1));
				console.printf("Ammo - %s: %0.2f", nameCap, v.value);
			}
		}
		console.printf("");
	}

	void AmmoItem_RefreshAmount(Ammo item) {
		if (!item) {
			return;
		}
		PlayerSheetStat res = self.FindResourceValue(item.GetClassName());
		if (res.isActual) {
			item.MaxAmount = self.HasBackpack() ? (double)(res.value) * res.bonusScale : res.value ;
			item.BackpackMaxAmount = (double)(res.value) * res.bonusScale;
			item.Amount = clamp(item.Amount, 0.0, self.HasBackpack() ? item.BackpackMaxAmount: res.value);
		} else {
			double scaler = ((double)(res.value) / 100.0);
			double backpackAmount = res.bonusScale ? item.Default.MaxAmount * res.bonusScale :item.Default.BackpackMaxAmount;
			item.MaxAmount = (self.HasBackpack() ? backpackAmount : item.Default.MaxAmount) * scaler;
			item.BackpackMaxAmount = backpackAmount * scaler;
			item.Amount = clamp(item.Amount, 0.0, self.HasBackpack() ? item.BackpackMaxAmount: item.MaxAmount);
		}
	}

	bool HasBackpack() {
		PlayerPawn player = PlayerPawn(self.GetPlayer().mo);
		Inventory next;
		for (Inventory item = player.Inv; item != NULL; item = next) {
			next = item.Inv;

			let invItem = player.FindInventory(item.GetClass());
			if (invItem != NULL && invItem is "BackpackItem") {
				BackpackItem backpackItem = BackpackItem(invItem);
				if (backpackItem && backpackItem.Amount > 0) {
					return true;
				}
			}
		}
		return false;
	}
	
	void AdvanceLevel(int advanceLevel) {
		// https://github.com/sezero/uhexen2/blob/5da9351b3a219629ffd1b287d8fa7fa206e7d136/gamecode/hc/portals/stats.hc#L233
		String playerClassName = GetPlayerClassName();

		bool cvarAllowBackpackUse = LemonUtil.CVAR_GetBool("hxdd_allow_backpack_use", false);
		PlayerPawn player = PlayerPawn(self.GetPlayer().mo);

		String cvarLevelUpAudio = soundLevelUp != "" ? soundLevelUp : LemonUtil.CVAR_GetString(String.format("hxdd_level_audio", playerClassName), "misc/chat");
		S_StartSound(cvarLevelUpAudio, CHAN_AUTO);

		while (self.currlevel < advanceLevel && self.currlevel < self.maxlevel) {
			int lastLevel = self.currlevel++;

			foreach (k, v : self.stats) {
				v.ProcessLevelIncrease(self.currlevel == self.maxlevel);
			}
			foreach (k, v : self.resources) {
				v.ProcessLevelIncrease(self.currlevel == self.maxlevel);
			}

			double healthInc = 0;
			if (lastLevel < self.MaxLevel) {
				if (self.UseMaxHealthScaler && self.SpawnHealth != 100) {
					healthInc = self.SpawnHealth * (stats_compute(self.hitpointTable[2],self.hitpointTable[3]) / 100.0);
				} else {
					healthInc = stats_compute(self.hitpointTable[2],self.hitpointTable[3]);
				}
			} else {
				if (self.UseMaxHealthScaler && self.SpawnHealth != 100) {
					healthInc = (double)(self.SpawnHealth) * (self.hitpointTable[4] / 100.0);
				} else {
					healthInc = self.hitpointTable[4];
				}
			}
			self.MaxHealth += healthInc;

			int limitMaxHealth = self.SpawnHealth * 1.5;
			if (self.hitpointTable.Size() == 6) {
				limitMaxHealth = self.hitpointTable[5];
			}
			if (player.Health > limitMaxHealth) {
				player.Health = limitMaxHealth;
			}
			if (self.MaxHealth > limitMaxHealth) {
				self.MaxHealth = limitMaxHealth;
			}

			// Hacky solution to increase player health when leveling
			// TODO: Add an options toggle
			player.MaxHealth = self.MaxHealth;
			int levelHealth = Clamp(player.Health + healthInc, player.Health, self.MaxHealth);
			HealThing(levelHealth, self.MaxHealth);

			Inventory next;
			for (Inventory item = player.Inv; item != NULL; item = next) {
				next = item.Inv;

				let invItem = player.FindInventory(item.GetClass());
				if (invItem != NULL && invItem is "Ammo") {
					Ammo ammoItem = Ammo(invItem);
					AmmoItem_RefreshAmount(ammoItem);
				}
			}

			console.printf("");
			console.printf("You are now level %d!", self.currlevel);
			console.printf("-----Stats-----");
			console.printf("Health: %0.2f", self.MaxHealth);
			foreach (k, v : self.stats) {
				String nameCap = String.format("%s%s", k.Left(1).MakeUpper(), k.Mid(1, k.Length() - 1));
				console.printf("%s: %0.2f", nameCap, v.value);
			}
			bool cvar_isdev_environment = LemonUtil.CVAR_GetBool("hxdd_isdev_environment", false);
			if (cvar_isdev_environment) {
				foreach (k, v : self.resources) {
					String nameCap = String.format("%s%s", k.Left(1).MakeUpper(), k.Mid(1, k.Length() - 1));
					console.printf("Ammo - %s: %d", nameCap, v.value);
				}
			}
			console.printf("");
		}
	}

	double GiveExperience(double amount) {
		if (self.HalveXPBeforeLevel4 && self.currlevel < 4) {
			amount *= 0.5;
		}

		amount *= experienceModifier;

		if (self.xp_bonus_stat != "") {
			PlayerSheetStat stat = GetStat(self.xp_bonus_stat);
			if (stat) {
				int xp_bonus_stat_modifier = stat.value - 11;
				amount += amount * xp_bonus_stat_modifier / self.maxlevel;
			}
		}

		if (self.currlevel == self.maxlevel) {
			// Max Level
			return 0.0f;
		}

		self.experience += amount;

		int MAX_LEVELS = experienceTable.Size() - 1;
		//console.printf("Gained %d Experience! (%d/%d)", amount, self.experience, self.experienceTable[clamp(0, self.currlevel - 1, MAX_LEVELS)]);

		double afterLevel = FindLevel();

		if (self.currlevel != afterLevel) {
			AdvanceLevel(afterLevel);
		}

		return amount;
	}

	double leveldiffxp;
	double levelpct;
	double FindLevel() {
		int MAX_LEVELS = experienceTable.Size() - 1;

		double Amount;

		int pLevel = 0;
		int Position = 0;
		while (Position < MAX_LEVELS && pLevel == 0) {
			if (self.experience < self.experienceTable[Position]) {
				pLevel = Position + 1;
			}

			Position += 1;
		}

		if (pLevel == 0) {
			Amount = self.experience - self.experienceTable[MAX_LEVELS - 1];
			pLevel = ceil(Amount / self.experienceTable[MAX_LEVELS]) + (MAX_LEVELS - 1);
		}

		int wrappedMaxXP = 1 + floor(self.experience / self.experienceTable[MAX_LEVELS]);
		double lastXP = self.experienceTable[clamp(0, pLevel - 2, MAX_LEVELS)];
		double targetXP = self.experienceTable[clamp(0, pLevel - 1, MAX_LEVELS)];
		if (pLevel < 2) {
			lastXP = 0;
		}
		int lastLevelXP = lastXP * wrappedMaxXP;
		self.leveldiffxp = targetXP - lastLevelXP;
		levelpct = ((self.experience - lastLevelXP) / self.leveldiffxp) * 100;
		if (pLevel == self.MaxLevel) {
			levelpct = 100;
		}

		return pLevel;
	}

	double AwardExperience(Actor target, bool isShared = false) {
		double exp = 0;
		if (self.ProgressionType != PSP_LEVELS || self.experienceTable.Size() == 0 || !target) {
			// Progression is not set to leveling, or Experience Table is not setup, or no target
			return exp;
		}
		if (target.health <= 0) {
			String name = target.GetClassName();
			bool useTable = false;
			// lookup target name, if in table use xp table to give xp
			// it not in table use legacy system
			if (useTable) {
				exp = GetExperienceFromLookupTable(target);
			} else {
				exp = GetExperienceByTargetHealth(target);
			}
		}
		if (isShared) {
			double CVAR_HXDD_PROGRESSION_XP_SHARED = LemonUtil.CVAR_GetFloat("hxdd_progression_xp_shared", 0.25);
			exp = exp * CVAR_HXDD_PROGRESSION_XP_SHARED;
		}
		GiveExperience(exp);
		return exp;
	}

	double GetExperienceFromLookupTable(Actor target) {
		// Placeholder
		// if in table
		// else
		return GetExperienceByTargetHealth(target);
	}

	// Allows progression from Doom Engine mobs with no lookup table entry
	double GetExperienceByTargetHealth(Actor target) {
		double exp = 0;
		double calcExp = target.Default.health;
		if (LemonUtil.GetOptionGameMode() == GAME_Hexen) {
			// Hexen receives an xp penalty due to larger health pools vs Heretic and Hexen II
			calcExp *= 0.5;
		}
		calcExp *= frandom[ExpRange](0.8, 0.9);
		if (target.bBoss) {
			calcExp *= LemonUtil.CVAR_GetFloat("hxdd_progression_xp_health_bossbonus", 1.75);
		}
		calcExp = (calcExp * 0.9) + frandom[ExpBonus](calcExp * 0.05, calcExp * 0.15);
		int skSpawnFilter = G_SkillPropertyInt(SKILLP_SpawnFilter) - 1;
		skSpawnFilter = clamp(skSpawnFilter, 0, 4);
		if (self.skillmodifier[skSpawnFilter]) {
			calcExp *= self.skillmodifier[skSpawnFilter];
		}
		return calcExp;
	}

	// Secret Watcher (Bonus XP)
	bool sectorSecretsReady;
	String levelName;
	int foundSecrets;
	void SecretWatcher() {
		if (self.currlevel == 0) {
			return;
		}

		if (self.levelName != level.MapName) {
			self.levelName = level.MapName;
			self.foundSecrets = level.Found_Secrets;
		}
		
		if (self.foundSecrets != level.Found_Secrets) {
			self.foundSecrets = level.Found_Secrets;

			int MAX_LEVELS = experienceTable.Size() - 1;
			double xp = self.leveldiffxp * 0.05;	// TODO: add percentage bonus of level to playersheet

			int skSpawnFilter = G_SkillPropertyInt(SKILLP_SpawnFilter) - 1;
			skSpawnFilter = clamp(skSpawnFilter, 0, 4);
			if (self.skillmodifier[skSpawnFilter]) {
				xp *= self.skillmodifier[skSpawnFilter];
			}

			self.GiveExperience(xp);
		}
	}

	String FindSoundReplacement(String key) {
		if (self.soundSet.CheckKey(key)) {
			return self.soundSet.Get(key);
		}
		return key;
	}

	void RescanAllActors() {
		bool isMapSpawn = level.MapTime == 0;
		int num = self.GetPlayer().mo.PlayerNumber();
		ThinkerIterator it = ThinkerIterator.Create("Actor");
		Actor actor;
		int count = 0;
		while (actor = Actor(it.Next())) {
			HXDDPickupNode node = HXDDPickupNode(actor);
			if (node) {
				if (self.XClass) {
					self.NodeUpdate(node, self.GetPlayer().mo);
				}
			}
		}
	}
}