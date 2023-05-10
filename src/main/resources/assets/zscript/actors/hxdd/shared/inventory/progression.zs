//----------------------------------------------------------------------------
//
// Hexen II: Progression & Armor System
// Ref: https://github.com/sezero/uhexen2/blob/5da9351b3a219629ffd1b287d8fa7fa206e7d136/gamecode/hc/portals/stats.hc
//
//----------------------------------------------------------------------------

enum EPlaystyleArmorMode {
	PSAM_DEFAULT = 0,
	PSAM_ARMOR_SIMPLE = 1,
	PSAM_ARMOR_AC = 2,
	PSAM_ARMOR_RANDOM = 3,
	PSAM_ARMOR_USER = 4
};

enum EPlaystyleProgression {
	PSP_DEFAULT = 0,
	PSP_NONE = 1,
	PSP_LEVELS = 2,
	PSP_LEVELS_RANDOM = 3,
	PSP_LEVELS_USER = 4,
};

class Progression: Inventory {
	bool ArmorSelected;
	bool ProgressionSelected;
	bool CompatabilityScaleSelected;

	// Gameplay Modes
	int DefaultArmorMode;
	int DefaultProgression;
	property DefaultArmorMode: DefaultArmorMode;
	property DefaultProgression: DefaultProgression;

	// Class Tables
	double experienceTable[11];	// TODO: Convert to Dynamic Array
	double hitpointTable[5];
	double manaTable[5];
	double strengthTable[2];
	double intelligenceTable[2];
	double wisdomTable[2];
	double dexterityTable[2];

	// Character Stats
	int level;
	int experience;
	double experienceModifier;

	int maxHealth;
	int maxMana;
	int strength;
	int intelligence;
	int wisdom;
	int dexterity;

	// Class Tables
	property experienceTable: experienceTable;
	property hitpointTable: hitpointTable;
	property manaTable: manaTable;
	property strengthTable: strengthTable;
	property intelligenceTable: intelligenceTable;
	property wisdomTable: wisdomTable;
	property dexterityTable: dexterityTable;

	// Character Stats
	property Level: level;
	property Experience: experience;
	property ExperienceModifier: experienceModifier;

	property MaxHealth: maxHealth;
	property MaxMana: maxMana;
	property Strength: strength;
	property Intelligence: intelligence;
	property Wisdom: wisdom;
	property Dexterity: dexterity;

	PlayerSheet sheet;

    Default {
		+INVENTORY.KEEPDEPLETED
        +INVENTORY.HUBPOWER
        +INVENTORY.UNDROPPABLE
        +INVENTORY.UNTOSSABLE
        +INVENTORY.UNCLEARABLE
        -INVENTORY.INVBAR

        Inventory.MaxAmount 1;
        Inventory.InterHubAmount 1;

		Progression.ExperienceModifier 1.0;

		Progression.Level 0;
		Progression.Experience 0;
		
        Progression.MaxHealth 100;
		Progression.MaxMana 0;      // TODO: scale off of default if ammo type does not match
		Progression.Strength 0;
		Progression.Intelligence 0;
		Progression.Wisdom 0;
		Progression.Dexterity 0;
    }

	// Stat Compute
	double stats_compute(double min, double max) {
		double value = (max-min+1) * frandom[Stats](0.0, 1.0) + min;
		if (value > max) {
			return max;
		}
		value = ceil(value);
		return value;
	}

	bool ProgressionAllowed() {
		int optionProgression = LemonUtil.CVAR_GetInt("hxdd_progression", PSP_DEFAULT);
		if (self.sheet) {
			if (optionProgression == PSP_DEFAULT) {
				optionProgression = self.sheet.DefaultProgression;
			}
		} else if (optionProgression == PSP_DEFAULT) {
			optionProgression = PSP_NONE;
		}
		return optionProgression == PSP_LEVELS || optionProgression == PSP_LEVELS_RANDOM || optionProgression == PSP_LEVELS_USER;
	}

	override void BeginPlay() {
		Super.BeginPlay();
	}

	override void PostBeginPlay() {
		Super.PostBeginPlay();

		CreatePlayerSheetItem();
		if (!ProgressionSelected) {
			if (ProgressionAllowed()) {
        		SetAdvancementStatTables();
				InitLevel_PostBeginPlay();
			} else {
				// Set stats to 10 to prevent any penalties
				Strength = 10;
				Intelligence = 10;
				Wisdom = 10;
				Dexterity = 10;
			}
			ProgressionSelected = true;
		}
		ArmorModeSelection();
	}

	void CreatePlayerSheetItem() {
		String playerClassName = owner.player.mo.GetClassName();
		playerClassName = playerClassName.MakeLower();

		uint end = AllActorClasses.Size();
		for (uint i = 0; i < end; ++i) {
			let item = (class<PlayerSheet>)(AllActorClasses[i]);
			if (item) {
				String strSearch = "PlayerSheet_";
				String itemName = item.GetClassName();
				if (playerClassName.IndexOf(itemName.MakeLower().Mid(strSearch.Length() - 1)) != -1) {	
					let invsheet = owner.player.mo.FindInventory(item);
					if (invsheet == null) {
						owner.player.mo.GiveInventory(item, 1);
						self.sheet = PlayerSheet(owner.player.mo.FindInventory(item));
						self.sheet.DefineAdvancementStatTables();
						return;
					}
				}
			}
		}

		PlayerSheet invsheet = PlayerSheet(owner.player.mo.FindInventory("PlayerSheet"));
		if (invsheet == null) {
			owner.player.mo.GiveInventory("PlayerSheet", 1);
			self.sheet = PlayerSheet(owner.player.mo.FindInventory("PlayerSheet"));
			return;
		}
	}

	PlayerSheet GetPlayerSheet() {
		return self.sheet;
	}

	void ArmorModeSelection() {
		if (ArmorSelected) {
			return;
		}
		let player = PlayerPawn(owner.player.mo);
		if (player == NULL) {
			return;
		}
		int optionArmorMode = LemonUtil.CVAR_GetInt("hxdd_armor_mode", PSAM_DEFAULT);
		if (self.sheet) {
			if (optionArmorMode == PSAM_DEFAULT) {
				optionArmorMode = self.sheet.DefaultArmorMode;
			}
		} else if (optionArmorMode == PSAM_DEFAULT) {
			let itemHexenArmor = HexenArmor(player.FindInventory("HexenArmor"));
			if (itemHexenArmor) {
				optionArmorMode = PSAM_ARMOR_AC;
			}
		}
		if (optionArmorMode == PSAM_ARMOR_SIMPLE) {
			ArmorModeSelection_Simple(player);
		} else if (optionArmorMode == PSAM_ARMOR_AC) {
			ArmorModeSelection_AC(player);
		} else if (optionArmorMode == PSAM_ARMOR_RANDOM) {
			ArmorModeSelection_Random(player);
		} else if (optionArmorMode == PSAM_ARMOR_USER) {
			ArmorModeSelection_User(player);
		}
		ArmorSelected = true;
	}

	void ArmorModeSelection_Simple(PlayerPawn player) {
		// Remove Hexen AC armor Values to force simple armor mechanics
		let itemHexenArmor = HexenArmor(player.FindInventory("HexenArmor"));
		if (itemHexenArmor) {
			// unset all
			for (int i = 0; i < 5; i++) {
				itemHexenArmor.Slots[i] = 0;
			}
			for (int i = 0; i < 4; i++) {
				itemHexenArmor.SlotsIncrement[i] = 0;
			}
		}
	}
	void ArmorModeSelection_AC(PlayerPawn player) {
		// ensure the class has hexen armor values, if not fill with defaults
		let itemHexenArmor = HexenArmor(player.FindInventory("HexenArmor"));
		if (itemHexenArmor) {
			int totalArmor = itemHexenArmor.Slots[4];
			for (int i = 0; i < 4; i++) {
				totalArmor += itemHexenArmor.SlotsIncrement[i];
			}
			if (totalArmor == 0) {
				// no armor, use random instead
				ArmorModeSelection_Random(player);
			}
		}
	}
	void ArmorModeSelection_Random(PlayerPawn player) {
		// ensure the class has hexen armor values, if not fill with defaults
		let itemHexenArmor = HexenArmor(player.FindInventory("HexenArmor"));
		if (itemHexenArmor) {
			int totalArmor = itemHexenArmor.Slots[4];
			for (int i = 0; i < 4; i++) {
				totalArmor += itemHexenArmor.SlotsIncrement[i];
			}
			if (totalArmor == 0) {
				// no armor, fill with basic armor values
				itemHexenArmor.Slots[4] = 10;
				for (int i = 0; i < 4; i++) {
					itemHexenArmor.SlotsIncrement[i] = i * 5;
				}
			}
		}
	}
	void ArmorModeSelection_User(PlayerPawn player) {
		let itemHexenArmor = HexenArmor(player.FindInventory("HexenArmor"));
		if (itemHexenArmor) {
			// unset all
			for (int i = 0; i < 5; i++) {
				itemHexenArmor.Slots[i] = 0;
			}
			itemHexenArmor.Slots[4] = LemonUtil.CVAR_GetInt("hxdd_armor_user_4", 10);
			for (int i = 0; i < 4; i++) {
				String cvarHexenArmorSlot = String.format("hxdd_armor_user_%d", i);
				itemHexenArmor.SlotsIncrement[i] = LemonUtil.CVAR_GetInt(cvarHexenArmorSlot, 20);
			}
		}
	}

	// This is dumb, but: https://discord.com/channels/268086704961748992/268877450652549131/385134419893288960
	virtual void SetAdvancementStatTables() {
		int cvarCustomProgressionType = LemonUtil.CVAR_GetInt("hxdd_progression", PSP_DEFAULT);
		if (cvarCustomProgressionType == PSP_LEVELS_USER) {
			// User Defined Stats
			int lastExpDefault = 800;
			experienceTable[0] = LemonUtil.CVAR_GetInt("hxdd_progression_user_level_0", lastExpDefault);
			for (let i = 1; i < 11; i++) {
				lastExpDefault *= 2;
				String cvarExpTableLevelNum = String.format("hxdd_progression_user_level_%d", i);
				experienceTable[i] = LemonUtil.CVAR_GetInt(cvarExpTableLevelNum, lastExpDefault);
			}

			hitpointTable[0] = LemonUtil.CVAR_GetInt("hxdd_progression_user_health_base_max", 100);
			hitpointTable[1] = LemonUtil.CVAR_GetInt("hxdd_progression_user_health_base_min", 100);
			hitpointTable[2] = LemonUtil.CVAR_GetInt("hxdd_progression_user_health_inc_min", 0);
			hitpointTable[3] = LemonUtil.CVAR_GetInt("hxdd_progression_user_health_inc_max", 5);
			hitpointTable[4] = LemonUtil.CVAR_GetInt("hxdd_progression_user_health_inc_cap", 5);

			manaTable[0] = LemonUtil.CVAR_GetInt("hxdd_progression_user_mana_base_max", 100);
			manaTable[1] = LemonUtil.CVAR_GetInt("hxdd_progression_user_mana_base_min", 100);
			manaTable[2] = LemonUtil.CVAR_GetInt("hxdd_progression_user_mana_inc_min", 5);
			manaTable[3] = LemonUtil.CVAR_GetInt("hxdd_progression_user_mana_inc_max", 10);
			manaTable[4] = LemonUtil.CVAR_GetInt("hxdd_progression_user_mana_inc_cap", 5);

			strengthTable[0] = LemonUtil.CVAR_GetInt("hxdd_progression_user_strength_min", 10);
			strengthTable[1] = LemonUtil.CVAR_GetInt("hxdd_progression_user_strength_max", 10);

			intelligenceTable[0] = LemonUtil.CVAR_GetInt("hxdd_progression_user_intelligence_min", 10);
			intelligenceTable[1] = LemonUtil.CVAR_GetInt("hxdd_progression_user_intelligence_max", 10);

			wisdomTable[0] = LemonUtil.CVAR_GetInt("hxdd_progression_user_wisdom_min", 10);
			wisdomTable[1] = LemonUtil.CVAR_GetInt("hxdd_progression_user_wisdom_max", 10);

			dexterityTable[0] = LemonUtil.CVAR_GetInt("hxdd_progression_user_dexterity_min", 10);
			dexterityTable[1] = LemonUtil.CVAR_GetInt("hxdd_progression_user_dexterity_max", 10);

		} else if (cvarCustomProgressionType == PSP_LEVELS_RANDOM) {
			// Go wild
			// TODO: Add ranges?
			experienceModifier = 1.0f + frandom[exprnd](0.0f, 0.5f);

			experienceTable[0] = (0.2f + frandom[exprnd](0.8f, 1.0f)) * 800;
			for (let i = 1; i < 11; i++) {
				experienceTable[i] = 	experienceTable[i-1] * (1.8 + (frandom[exprnd](0.0, 1.0) * 4.0f));
			}

			hitpointTable[0] = 65.0f;
			hitpointTable[1] = hitpointTable[0] + (frandom[exprnd](0.15f, 0.25f) * 100.0f);;
			hitpointTable[2] = frandom[exprnd](0.5f, 1.0f) * 5.0f;
			hitpointTable[3] = frandom[exprnd](0.75f, 1.0f) * 10.0f;
			hitpointTable[4] = hitpointTable[2];

			manaTable[0] = 40.0f;
			manaTable[1] = 50.0f + (frandom[exprnd](0.0f, 1.0f) * 25.0f);
			manaTable[2] = frandom[exprnd](0.5f, 1.0f) * 5.0f;
			manaTable[3] = frandom[exprnd](0.75f, 1.0f) * 15.0f;
			manaTable[4] = manaTable[2];

			for (let i = 0; i < 2; i++) {
				double mult = ((i+1) * 10.0f);
				strengthTable[i] =		frandom[exprnd](0.5f, 1.0f) * mult;
				intelligenceTable[i] =	frandom[exprnd](0.5f, 1.0f) * mult;
				wisdomTable[i] =		frandom[exprnd](0.5f, 1.0f) * mult;
				dexterityTable[i] =		frandom[exprnd](0.5f, 1.0f) * mult;
			}
		} else {
			// find advancement item
			if (self.sheet) {
				experienceModifier =		self.sheet.experienceModifier;
				for (let i = 0; i < 11; i++) {
					experienceTable[i] =	self.sheet.experienceTable[i];
				}
				for (let i = 0; i < 5; i++) {
					hitpointTable[i] =		self.sheet.hitpointTable[i];
					manaTable[i] =			self.sheet.manaTable[i];
				}
				for (let i = 0; i < 2; i++) {
					strengthTable[i] =		self.sheet.strengthTable[i];
					intelligenceTable[i] =	self.sheet.intelligenceTable[i];
					wisdomTable[i] =		self.sheet.wisdomTable[i];
					dexterityTable[i] =		self.sheet.dexterityTable[i];
				}
			} else {
				experienceTable[0] = 800;
				for (let i = 1; i < 11; i++) {
					experienceTable[i] = experienceTable[i-1] * 2.0f;
				}

				hitpointTable[0] = 50;
				hitpointTable[1] = 60;
				hitpointTable[2] = 0;
				hitpointTable[3] = 5;
				hitpointTable[4] = 5;

				manaTable[0] = 40;
				manaTable[1] = 50;
				manaTable[2] = 5;
				manaTable[3] = 10;
				manaTable[4] = 5;

				strengthTable[0] = 8;
				strengthTable[1] = 12;

				intelligenceTable[0] = 8;
				intelligenceTable[1] = 12;

				wisdomTable[0] = 8;
				wisdomTable[1] = 12;

				dexterityTable[0] = 8;
				dexterityTable[1] = 12;
			}
		}
	}

	void InitLevel_PostBeginPlay() {
		if (level != 0) {
			return;
		}
		
		bool cvarAllowBackpackUse = LemonUtil.CVAR_GetBool("hxdd_allow_backpack_use", true);

		let player = PlayerPawn(owner.player.mo);
		
        MaxHealth = stats_compute(hitpointTable[0], hitpointTable[1]);
		player.MaxHealth = MaxHealth;
        player.A_SetHealth(MaxHealth, AAPTR_DEFAULT);

		// Alt Ammo Handler
		maxMana = stats_compute(manaTable[0], manaTable[1]);

		// Calc initial ammo
		// Add ammo dummies to player
		uint end = AllActorClasses.Size();
		for (uint i = 0; i < end; ++i) {
			let ammotype = (class<Ammo>)(AllActorClasses[i]);
			if (ammotype && GetDefaultByType(ammotype).GetParentAmmo() == ammotype) {
				Ammo ammoItem = Ammo(Owner.player.mo.FindInventory(ammotype));
				if (ammoItem == null) {
					// The player did not have the ammoitem. Add it.
					ammoItem = Ammo(Spawn(ammotype));
				}
				//console.printf("ammoItem: %s", ammoItem.GetClassName());
				if (!(ammoType is "mana1") || !(ammoType is "mana2")) {
					double scaler = ammoItem.Default.MaxAmount / 200.0;
					ammoItem.MaxAmount = maxMana * scaler;
					if (ammoItem.Amount > ammoItem.MaxAmount) {
						ammoitem.Amount = ammoItem.MaxAmount;
					}
					if (cvarAllowBackpackUse) {
						ammoItem.BackpackMaxAmount = ammoItem.MaxAmount * (ammoItem.Default.BackpackMaxAmount / ammoItem.Default.MaxAmount);
					} else {
						ammoItem.BackpackMaxAmount = ammoItem.MaxAmount;
					}
					ammoItem.AttachToOwner(Owner.player.mo);
				} else {
					ammoItem.Destroy();
				}
			}
		}

		strength = stats_compute(strengthTable[0], strengthTable[1]);
		intelligence = stats_compute(intelligenceTable[0], intelligenceTable[1]);
		wisdom = stats_compute(wisdomTable[0], wisdomTable[1]);
		dexterity = stats_compute(dexterityTable[0], dexterityTable[1]);

		level = 1;
		experience = 0;

		console.printf("----- Stats -----");
		console.printf("Health: %0.2f", MaxHealth);
		console.printf("Mana: %0.2f", maxMana);
		console.printf("Strength: %0.2f", strength);
		console.printf("Intelligence: %0.2f", intelligence);
		console.printf("Wisdom: %0.2f", wisdom);
		console.printf("Dexterity: %0.2f", dexterity);
	}

	void AdvanceLevel(int advanceLevel) {
		// https://github.com/sezero/uhexen2/blob/5da9351b3a219629ffd1b287d8fa7fa206e7d136/gamecode/hc/portals/stats.hc#L233

		bool cvarAllowBackpackUse = LemonUtil.CVAR_GetBool("hxdd_allow_backpack_use", true);
		PlayerPawn player = PlayerPawn(owner.player.mo);

		S_StartSound("hexen2/misc/comm", CHAN_VOICE);

		while (level < advanceLevel && level < 20) {
			int lastLevel = level++;

			double healthInc = 0;
			double manaInc = 0;
			if (lastLevel < 11) {
				healthInc = stats_compute(self.sheet.hitpointTable[2],self.sheet.hitpointTable[3]);
				manaInc = stats_compute(self.sheet.manaTable[2],self.sheet.manaTable[3]);
			} else {
				healthInc = self.sheet.hitpointTable[4];
				manaInc = self.sheet.manaTable[4];
			}
			MaxHealth += HealthInc;
			MaxMana += ManaInc;

			// TODO: Allow max values to be set by cvars
			if (Health > 150) {
				Health = 150;
			}
			if (MaxHealth > 150) {
				MaxHealth = 150;
			}
			if (MaxMana > 300) {
				MaxMana = 300;
			}

			// Hacky solution to increase player health when leveling
			// TODO: Add an options toggle
			player.MaxHealth = MaxHealth;
			int levelHealth = Clamp(Health + HealthInc, Health, MaxHealth);
			HealThing(levelHealth, MaxHealth);

			Inventory next;
			for (Inventory item = player.Inv; item != NULL; item = next) {
				next = item.Inv;

				let invItem = player.FindInventory(item.GetClass());
				if (invItem != NULL && invItem is "Ammo") {
					Ammo ammoItem = Ammo(invItem);
					if (ammoItem) {
						double scaler = ammoItem.Default.MaxAmount / 200.0;
						ammoItem.MaxAmount = MaxMana * scaler;
						if (ammoItem.Amount > ammoItem.MaxAmount) {
							ammoitem.Amount = ammoItem.MaxAmount;
						}
						if (cvarAllowBackpackUse) {
							ammoItem.BackpackMaxAmount = ammoItem.MaxAmount * (ammoItem.Default.BackpackMaxAmount / ammoItem.Default.MaxAmount);
						} else {
							ammoItem.BackpackMaxAmount = ammoItem.MaxAmount;
						}
					}
				}
			}

			console.printf("You are now level %d!", level);
			console.printf("-----Stats-----");
			console.printf("Health: %0.2f", MaxHealth);
			console.printf("Mana: %0.2f", MaxMana);
			console.printf("Strength: %0.2f", strength);
			console.printf("Intelligence: %0.2f", intelligence);
			console.printf("Wisdom: %0.2f", wisdom);
			console.printf("Dexterity: %0.2f", dexterity);
		}
	}

	double GiveExperience(double amount) {
		if (level < 4) {
			amount *= 0.5;
		}

		amount *= experienceModifier;
		int wisdom_modifier = wisdom - 11;
		amount += amount * wisdom_modifier / 20;

		experience += amount;
		console.printf("Gained %d Experience!", amount);

		OnExperienceBonus(amount);

		if (level == 20) {
			// Max Level
			return 0.0f;
		}

		double afterLevel = FindLevel();

		console.printf("Total Experience: %d", experience);

		if (level != afterLevel) {
			AdvanceLevel(afterLevel);
		}

		return amount;
	}

	double FindLevel() {
		int MAX_LEVELS = 10;

		double Amount;

		int pLevel = 0;
		int Position = 0;
		while(Position < MAX_LEVELS && pLevel == 0) {
			if (experience < experienceTable[Position]) {
				pLevel = Position + 1;
			}

			Position += 1;
		}

		if (pLevel == 0) {
			Amount = experience - experienceTable[MAX_LEVELS - 1];
			pLevel = ceil(Amount / experienceTable[MAX_LEVELS]) + 10;
		}

		return pLevel;
	}

	// Exists to allow progression from Doom Engine mobs
	double GiveExperienceByTargetHealth(Actor target) {
		// Setup cvars?
		double expDifficulty[5] = {1.0, 1.0, 1.0, 1.0, 1.0};
		double experience = 0;
		if (experienceTable[0] == 0 || !target) {
			// Experience Table is not setup or no target
			return experience;
		}
		if (target.health <= 0) {
			double calcExp = target.Default.health;
			if (LemonUtil.GetOptionGameMode() == GAME_Hexen) {
				// Hexen receives an xp penalty due to larger health pools vs Heretic and Hexen II
				calcExp *= 0.5;
			}
			calcExp *= frandom[ExpRange](0.6, 0.7);
			if (target.bBoss) {
				calcExp *= 1.75;
			}
			calcExp = (calcExp * 0.9) + frandom[ExpBonus](calcExp * 0.05, calcExp * 0.15);
			int skSpawnFilter = G_SkillPropertyInt(SKILLP_SpawnFilter) - 1;
			if (skSpawnFilter > 4) {
				skSpawnFilter = 4;
			}
			calcExp *= expDifficulty[skSpawnFilter];
			return GiveExperience(calcExp);
		}
		return experience;
	}

	// Event Stubs
	virtual void OnExperienceBonus(double experience) {}
	virtual void OnKill(PlayerPawn player, Actor target, double experience) {}
}