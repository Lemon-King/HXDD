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

	// Alignment (Used for some pickups)
	String Alignment;
	property Alignment: Alignment;

	// Gameplay Modes
	int DefaultArmorMode;
	int DefaultProgression;
	property DefaultArmorMode: DefaultArmorMode;
	property DefaultProgression: DefaultProgression;

	bool UseMaxHealthScaler;
	property UseMaxHealthScaler: UseMaxHealthScaler;
	int SpawnHealth;

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
	int maxlevel;
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
	property MaxLevel: maxlevel;
	property Experience: experience;
	property ExperienceModifier: experienceModifier;

	property MaxHealth: maxHealth;
	property MaxMana: maxMana;
	property Strength: strength;
	property Intelligence: intelligence;
	property Wisdom: wisdom;
	property Dexterity: dexterity;

	ProgressionEventHandler handler;

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
		if (optionProgression == PSP_DEFAULT) {
			optionProgression = self.DefaultProgression;
		}
		return optionProgression == PSP_LEVELS || optionProgression == PSP_LEVELS_RANDOM || optionProgression == PSP_LEVELS_USER;
	}

	override void BeginPlay() {
		Super.BeginPlay();
	}

	override void PostBeginPlay() {
		Super.PostBeginPlay();

		LoadPlayerSheet();
		if (!ProgressionSelected) {
			if (ProgressionAllowed()) {
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

	void LoadPlayerSheet() {
		int cvarProgression = LemonUtil.CVAR_GetInt("hxdd_progression", PSP_DEFAULT);

		String playerClassName = owner.player.mo.GetClassName();
		if (playerClassName.IndexOf("HXDD") != -1) {
			playerClassName = owner.player.mo.GetParentClass().GetClassName();
		}
		playerClassName = playerClassName.MakeLower();

		int cvarDefaultArmorMode = PSAM_ARMOR_SIMPLE;
		let itemHexenArmor = HexenArmor(owner.player.mo.FindInventory("HexenArmor"));
		if (itemHexenArmor) {
			cvarDefaultArmorMode = PSAM_ARMOR_AC;
		}

		self.DefaultArmorMode = LemonUtil.CVAR_GetInt(String.format("hxdd_playersheet_%s_armor", playerClassName), cvarDefaultArmorMode);
		self.DefaultProgression = LemonUtil.CVAR_GetInt(String.format("hxdd_playersheet_%s_progression", playerClassName), PSP_NONE);
		self.Alignment = LemonUtil.CVAR_GetString(String.format("hxdd_playersheet_%s_alignment", playerClassName), "Neutral");

		self.UseMaxHealthScaler = LemonUtil.CVAR_GetBool(String.format("hxdd_playersheet_%s_use_maxhealth_scaler", playerClassName), true);

		if (self.DefaultArmorMode == PSAM_DEFAULT) {
			self.DefaultArmorMode = PSAM_ARMOR_SIMPLE;
			console.printf("Incorrect Class Armor Mode, PSAM_DEFAULT or 0 should not be used! Using PSAM_SIMPLE as Default.");
		}
		if (self.DefaultProgression == PSP_DEFAULT) {
			self.DefaultProgression = PSP_NONE;
			console.printf("Incorrect Class Progression Mode, PSP_DEFAULT or 0 should not be used! Using PSP_NONE as Default.");
		}

		if (cvarProgression == PSP_DEFAULT) {
			cvarProgression = self.DefaultProgression;
		}

		if (cvarProgression != PSP_NONE) {
			bool hasEvents = LemonUtil.CVAR_GetBool(String.format("hxdd_playersheet_%s_eventhandler", playerClassName), false);
			if (hasEvents) {
				String eventClass = String.format("peh_%s", playerClassName);
				Class<Actor> handler = eventClass;
				if (handler) {
					ProgressionEventHandler invEventHandler = ProgressionEventHandler(owner.player.mo.FindInventory(eventClass));
					if (invEventHandler == null) {
						owner.player.mo.GiveInventory(eventClass, 1);
						self.handler = ProgressionEventHandler(owner.player.mo.FindInventory(eventClass));
					}
				}
			}
		}

		if (cvarProgression == PSP_LEVELS) {
			double cvarPS_ExpModifer = LemonUtil.CVAR_GetFloat(String.format("hxdd_playersheet_%s_expmod", playerClassName), 1.0);

			int last = 800;
			String expDefaultGen = "800";
			for (let i = 1; i < 11; i++) {
				last = last * 2.0;
				expDefaultGen = String.format("%s,%d", expDefaultGen, last);
			}

			Array<String> tblExp;
			LemonUtil.CVAR_GetString(String.format("hxdd_playersheet_%s_experience", playerClassName), expDefaultGen).Split(tblExp, ",");

			Array<String> tblHP;
			LemonUtil.CVAR_GetString(String.format("hxdd_playersheet_%s_hitpoints", playerClassName), "60,70,2,6,5").Split(tblHP, ",");

			Array<String> tblMana;
			LemonUtil.CVAR_GetString(String.format("hxdd_playersheet_%s_mana", playerClassName), "95,105,5,10,5").Split(tblMana, ",");

			Array<String> tblStr;
			LemonUtil.CVAR_GetString(String.format("hxdd_playersheet_%s_strength", playerClassName), "6,16").Split(tblStr, ",");

			Array<String> tblInt;
			LemonUtil.CVAR_GetString(String.format("hxdd_playersheet_%s_intelligence", playerClassName), "6,16").Split(tblInt, ",");

			Array<String> tblWis;
			LemonUtil.CVAR_GetString(String.format("hxdd_playersheet_%s_wisdom", playerClassName), "6,16").Split(tblWis, ",");

			Array<String> tblDex;
			LemonUtil.CVAR_GetString(String.format("hxdd_playersheet_%s_dexterity", playerClassName), "6,16").Split(tblDex, ",");

			int cvarPS_MaxLevel = LemonUtil.CVAR_GetInt(String.format("hxdd_playersheet_%s_maxlevel", playerClassName), 20);

			// validation
			bool valid = true;
			if (tblExp.Size() != 11) {
				valid = false;
				console.printf("Incorrect size for Experience Table! Size is %d, should be 11.", tblExp.Size());
			}
			if (tblHP.Size() != 5) {
				valid = false;
				console.printf("Incorrect size for Hitpoints Table! Size is %d, should be 5.", tblHP.Size());
			}
			if (tblMana.Size() != 5) {
				valid = false;
				console.printf("Incorrect size for Mana Table! Size is %d, should be 5.", tblMana.Size());
			}
			if (tblStr.Size() != 2) {
				valid = false;
				console.printf("Incorrect size for Strength Table! Size is %d, should be 2.", tblStr.Size());
			}
			if (tblInt.Size() != 2) {
				valid = false;
				console.printf("Incorrect size for Intelligence Table ! Size is %d, should be 2.", tblInt.Size());
			}
			if (tblWis.Size() != 2) {
				valid = false;
				console.printf("Incorrect size for Wisdom Table! Size is %d, should be 2.", tblWis.Size());
			}
			if (tblDex.Size() != 2) {
				valid = false;
				console.printf("Incorrect size for Dexterity Table! Size is %d, should be 2.", tblDex.Size());
			}
			if (cvarPS_MaxLevel <= 0) {
				valid = false;
				console.printf("MaxLevel should be greater than 0!");
			}

			if (valid) {
				self.maxlevel 				= cvarPS_MaxLevel;
				self.experienceModifier	=		cvarPS_ExpModifer;
				for (let i = 0; i < 11; i++) {
					self.experienceTable[i] =	tblExp[i].ToInt();
				}
				for (let i = 0; i < 5; i++) {
					self.hitpointTable[i] =		tblHP[i].ToInt();
					self.manaTable[i] =			tblMana[i].ToInt();
				}
				for (let i = 0; i < 2; i++) {
					self.strengthTable[i] =		tblStr[i].ToInt();
					self.intelligenceTable[i] =	tblInt[i].ToInt();
					self.wisdomTable[i] =		tblWis[i].ToInt();
					self.dexterityTable[i] =		tblDex[i].ToInt();
				}
			}
		} else if (cvarProgression == PSP_LEVELS_USER) {
			// User Defined Stats
			int lastExpDefault = 800;
			self.experienceTable[0] = LemonUtil.CVAR_GetInt("hxdd_progression_user_level_0", lastExpDefault);
			for (let i = 1; i < 11; i++) {
				lastExpDefault *= 2;
				String cvarExpTableLevelNum = String.format("hxdd_progression_user_level_%d", i);
				self.experienceTable[i] = LemonUtil.CVAR_GetInt(cvarExpTableLevelNum, lastExpDefault);
			}

			self.hitpointTable[0] = LemonUtil.CVAR_GetInt("hxdd_progression_user_health_base_max", 100);
			self.hitpointTable[1] = LemonUtil.CVAR_GetInt("hxdd_progression_user_health_base_min", 100);
			self.hitpointTable[2] = LemonUtil.CVAR_GetInt("hxdd_progression_user_health_inc_min", 0);
			self.hitpointTable[3] = LemonUtil.CVAR_GetInt("hxdd_progression_user_health_inc_max", 5);
			self.hitpointTable[4] = LemonUtil.CVAR_GetInt("hxdd_progression_user_health_inc_cap", 5);

			self.manaTable[0] = LemonUtil.CVAR_GetInt("hxdd_progression_user_mana_base_max", 100);
			self.manaTable[1] = LemonUtil.CVAR_GetInt("hxdd_progression_user_mana_base_min", 100);
			self.manaTable[2] = LemonUtil.CVAR_GetInt("hxdd_progression_user_mana_inc_min", 5);
			self.manaTable[3] = LemonUtil.CVAR_GetInt("hxdd_progression_user_mana_inc_max", 10);
			self.manaTable[4] = LemonUtil.CVAR_GetInt("hxdd_progression_user_mana_inc_cap", 5);

			self.strengthTable[0] = LemonUtil.CVAR_GetInt("hxdd_progression_user_strength_min", 10);
			self.strengthTable[1] = LemonUtil.CVAR_GetInt("hxdd_progression_user_strength_max", 10);

			self.intelligenceTable[0] = LemonUtil.CVAR_GetInt("hxdd_progression_user_intelligence_min", 10);
			self.intelligenceTable[1] = LemonUtil.CVAR_GetInt("hxdd_progression_user_intelligence_max", 10);

			self.wisdomTable[0] = LemonUtil.CVAR_GetInt("hxdd_progression_user_wisdom_min", 10);
			self.wisdomTable[1] = LemonUtil.CVAR_GetInt("hxdd_progression_user_wisdom_max", 10);

			self.dexterityTable[0] = LemonUtil.CVAR_GetInt("hxdd_progression_user_dexterity_min", 10);
			self.dexterityTable[1] = LemonUtil.CVAR_GetInt("hxdd_progression_user_dexterity_max", 10);

			self.maxlevel = LemonUtil.CVAR_GetInt("hxdd_progression_user_level_max", 20);

		} else if (cvarProgression == PSP_LEVELS_RANDOM) {
			// TODO: Add ranges?
			self.experienceModifier = 1.0f + frandom[exprnd](0.0f, 0.5f);

			self.experienceTable[0] = (0.2f + frandom[exprnd](0.8f, 1.0f)) * 800;
			for (let i = 1; i < 11; i++) {
				self.experienceTable[i] = 	experienceTable[i-1] * (1.8 + (frandom[exprnd](0.0, 1.0) * 4.0f));
			}

			self.hitpointTable[0] = 65.0f;
			self.hitpointTable[1] = hitpointTable[0] + (frandom[exprnd](0.15f, 0.25f) * 100.0f);;
			self.hitpointTable[2] = frandom[exprnd](0.5f, 1.0f) * 5.0f;
			self.hitpointTable[3] = frandom[exprnd](0.75f, 1.0f) * 10.0f;
			self.hitpointTable[4] = hitpointTable[2];

			self.manaTable[0] = 40.0f;
			self.manaTable[1] = 50.0f + (frandom[exprnd](0.0f, 1.0f) * 25.0f);
			self.manaTable[2] = frandom[exprnd](0.5f, 1.0f) * 5.0f;
			self.manaTable[3] = frandom[exprnd](0.75f, 1.0f) * 15.0f;
			self.manaTable[4] = manaTable[2];

			for (let i = 0; i < 2; i++) {
				double mult = ((i+1) * 10.0f);
				self.strengthTable[i] =		frandom[exprnd](0.5f, 1.0f) * mult;
				self.intelligenceTable[i] =	frandom[exprnd](0.5f, 1.0f) * mult;
				self.wisdomTable[i] =		frandom[exprnd](0.5f, 1.0f) * mult;
				self.dexterityTable[i] =		frandom[exprnd](0.5f, 1.0f) * mult;
			}
			self.maxlevel = 20;
		}
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
		if (optionArmorMode == PSAM_DEFAULT) {
			optionArmorMode = self.DefaultArmorMode;
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

	HexenArmor FindOrGivePlayerHexenArmor(PlayerPawn player) {
		let itemHexenArmor = HexenArmor(player.FindInventory("HexenArmor"));
		if (itemHexenArmor == null) {
			owner.player.mo.GiveInventory("HexenArmor", 1);
			itemHexenArmor = HexenArmor(player.FindInventory("HexenArmor"));
		}
		return itemHexenArmor;
	}

	void ArmorModeSelection_Simple(PlayerPawn player) {
		// Remove Hexen AC armor Values to force simple armor mechanics
		let itemHexenArmor = FindOrGivePlayerHexenArmor(player);
		if (itemHexenArmor) {
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
		let itemHexenArmor = FindOrGivePlayerHexenArmor(player);
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
		let itemHexenArmor = FindOrGivePlayerHexenArmor(player);
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
		let itemHexenArmor = FindOrGivePlayerHexenArmor(player);
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

	void InitLevel_PostBeginPlay() {
		if (level != 0) {
			return;
		}
		
		bool cvarAllowBackpackUse = LemonUtil.CVAR_GetBool("hxdd_allow_backpack_use", false);

		let player = owner.player.mo;
		self.SpawnHealth = player.Health;
		console.printf("H %d", self.SpawnHealth);

		if (self.UseMaxHealthScaler && self.SpawnHealth != 100) {
        	MaxHealth = self.SpawnHealth * (stats_compute(hitpointTable[0], hitpointTable[1]) / 100.0);
		} else {
			MaxHealth = stats_compute(hitpointTable[0], hitpointTable[1]);
		}
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
				if (ammoItem) {
					if (!(ammoItem is "mana1" || ammoItem is "mana2")) {
						ammoItem.MaxAmount = (double)(ammoItem.Default.MaxAmount) * (MaxMana / 100.0);
					} else {
						ammoItem.MaxAmount = MaxMana;
					}
					ammoItem.Amount = clamp(ammoItem.Amount, 0.0, ammoItem.MaxAmount);
					if (cvarAllowBackpackUse) {
						ammoItem.BackpackMaxAmount = ammoItem.MaxAmount * (ammoItem.Default.BackpackMaxAmount / ammoItem.Default.MaxAmount);
					} else {
						ammoItem.BackpackMaxAmount = ammoItem.MaxAmount;
					}
				}
				ammoItem.AttachToOwner(Owner.player.mo);
			}
		}

		strength = stats_compute(strengthTable[0], strengthTable[1]);
		intelligence = stats_compute(intelligenceTable[0], intelligenceTable[1]);
		wisdom = stats_compute(wisdomTable[0], wisdomTable[1]);
		dexterity = stats_compute(dexterityTable[0], dexterityTable[1]);

		level = 1;
		experience = 0;

		console.printf("");
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

		bool cvarAllowBackpackUse = LemonUtil.CVAR_GetBool("hxdd_allow_backpack_use", false);
		PlayerPawn player = PlayerPawn(owner.player.mo);

		S_StartSound("hexen2/misc/comm", CHAN_VOICE);

		while (self.level < advanceLevel && self.level < self.maxlevel) {
			int lastLevel = self.level++;

			double healthInc = 0;
			double manaInc = 0;
			if (lastLevel < self.MaxLevel) {
				if (self.UseMaxHealthScaler && self.SpawnHealth != 100) {
					healthInc = self.SpawnHealth * (stats_compute(self.hitpointTable[2],self.hitpointTable[3]) / 100.0);
				} else {
					healthInc = stats_compute(self.hitpointTable[2],self.hitpointTable[3]);
				}
				manaInc = stats_compute(self.manaTable[2],self.manaTable[3]);
			} else {
				if (self.UseMaxHealthScaler && self.SpawnHealth != 100) {
					healthInc = (double)(self.SpawnHealth) * (self.hitpointTable[4] / 100.0);
				} else {
					healthInc = self.hitpointTable[4];
				}
				manaInc = self.manaTable[4];
			}
			MaxHealth += HealthInc;
			self.MaxMana += ManaInc;

			// TODO: Allow max values to be set by cvars
			int scaledMaxHealth = self.SpawnHealth * 1.5;
			// 150
			if (self.Health > scaledMaxHealth) {
				self.Health = scaledMaxHealth;
			}
			if (self.MaxHealth > scaledMaxHealth) {
				self.MaxHealth = scaledMaxHealth;
			}
			if (self.MaxMana > 300) {
				self.MaxMana = 300;
			}

			// Hacky solution to increase player health when leveling
			// TODO: Add an options toggle
			player.MaxHealth = self.MaxHealth;
			int levelHealth = Clamp(self.Health + HealthInc, self.Health, self.MaxHealth);
			HealThing(levelHealth, self.MaxHealth);

			Inventory next;
			for (Inventory item = player.Inv; item != NULL; item = next) {
				next = item.Inv;

				let invItem = player.FindInventory(item.GetClass());
				if (invItem != NULL && invItem is "Ammo") {
					Ammo ammoItem = Ammo(invItem);
					if (ammoItem) {
						if (!(ammoItem is "mana1" || ammoItem is "mana2")) {
							ammoItem.MaxAmount = (double)(ammoItem.Default.MaxAmount) * (MaxMana / 100.0);
						} else {
							ammoItem.MaxAmount = MaxMana;
						}
						ammoItem.Amount = clamp(ammoItem.Amount, 0.0, ammoItem.MaxAmount);
						if (cvarAllowBackpackUse) {
							ammoItem.BackpackMaxAmount = ammoItem.MaxAmount * (ammoItem.Default.BackpackMaxAmount / ammoItem.Default.MaxAmount);
						} else {
							ammoItem.BackpackMaxAmount = ammoItem.MaxAmount;
						}
					}
				}
			}

			console.printf("");
			console.printf("-----Stats-----");
			console.printf("Health: %0.2f", MaxHealth);
			console.printf("Mana: %0.2f", MaxMana);
			console.printf("Strength: %0.2f", strength);
			console.printf("Intelligence: %0.2f", intelligence);
			console.printf("Wisdom: %0.2f", wisdom);
			console.printf("Dexterity: %0.2f", dexterity);
			console.printf("");
			console.printf("You are now level %d!", level);
			console.printf("");
		}
	}

	double GiveExperience(double amount) {
		if (level < 4) {
			amount *= 0.5;
		}

		amount *= experienceModifier;
		int wisdom_modifier = wisdom - 11;
		amount += amount * wisdom_modifier / 20;

		self.experience += amount;
		console.printf("Gained %d Experience!", amount);

		OnExperienceBonus(amount);

		if (self.level == self.maxlevel) {
			// Max Level
			return 0.0f;
		}

		double afterLevel = FindLevel();

		console.printf("Total Experience: %d", self.experience);

		if (level != afterLevel) {
			AdvanceLevel(afterLevel);
		}

		return amount;
	}

	double FindLevel() {
		int MAX_LEVELS = experienceTable.Size() - 1;

		double Amount;

		int pLevel = 0;
		int Position = 0;
		while(Position < MAX_LEVELS && pLevel == 0) {
			if (self.experience < self.experienceTable[Position]) {
				pLevel = Position + 1;
			}

			Position += 1;
		}

		if (pLevel == 0) {
			Amount = self.experience - self.experienceTable[MAX_LEVELS - 1];
			pLevel = ceil(Amount / self.experienceTable[MAX_LEVELS]) + 10;
		}

		return pLevel;
	}

	// Allows progression from Doom Engine mobs
	double GiveExperienceByTargetHealth(Actor target) {
		// Setup cvars?
		double expDifficulty[5] = {1.0, 1.0, 1.0, 1.0, 1.0};
		double exp = 0;
		if (self.experienceTable[0] == 0 || !target) {
			// Experience Table is not setup or no target
			return exp;
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
		return exp;
	}

	// Event Stubs
	virtual void OnExperienceBonus(double experience) {}
	virtual void OnKill(PlayerPawn player, Actor target, double experience) {}
}