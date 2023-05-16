//----------------------------------------------------------------------------
//
// Modified Hexen II: Progression & Armor System
// Ref: https://github.com/sezero/uhexen2/blob/5da9351b3a219629ffd1b287d8fa7fa206e7d136/gamecode/hc/portals/stats.hc
//
//----------------------------------------------------------------------------

enum EPlaystyleArmorType {
	PSAT_DEFAULT = 0,
	PSAT_ARMOR_SIMPLE = 1,
	PSAT_ARMOR_AC = 2,
	PSAT_ARMOR_RANDOM = 3,
	PSAT_ARMOR_USER = 4
};

enum EPlaystyleProgressionType {
	PSP_DEFAULT = 0,
	PSP_NONE = 1,
	PSP_LEVELS = 2,
	PSP_LEVELS_RANDOM = 3,
	PSP_LEVELS_USER = 4,
};

class PlayerSheetJSON {
	bool IsLoaded;

	String PlayerClass;
	String Alignment;
	int ArmorType;
	int ProgressionType;

	bool UseMaxHealthScaler;
	bool HalveXPBeforeLevel4;
	bool UsesEventHandler;

	double experienceModifier;

	Array<double> skillmodifier;

	int maxLevel;

	Array<int> experienceTable;
	Array<int> hitpointTable;
	Array<int> manaTable;
	Array<int> strengthTable;
	Array<int> intelligenceTable;
	Array<int> wisdomTable;
	Array<int> dexterityTable;

    String GetString(HXDD_JsonObject jo, String key) {
        HXDD_JsonElement type_elem = jo.get(key);
        if (!type_elem) {
            return "";
        }
		HXDD_JsonString type_str = HXDD_JsonString(type_elem);
		return type_str.s;
    }
    int GetInt(HXDD_JsonObject jo, String key) {
        HXDD_JsonElement type_elem = jo.get(key);
        if (!type_elem) {
            return -1;
        }
		HXDD_JsonInt type_int = HXDD_JsonInt(type_elem);
		return type_int.i;
    }
    double GetDouble(HXDD_JsonObject jo, String key) {
        HXDD_JsonElement type_elem = jo.get(key);
        if (!type_elem) {
            return -1;
        }
		HXDD_JsonDouble type_double = HXDD_JsonDouble(type_elem);
		return type_double.d;
    }
    HXDD_JsonArray GetArray(HXDD_JsonObject jo, String key) {
        HXDD_JsonElement type_elem = jo.get(key);
        if (!type_elem) {
            return null;
        }
		HXDD_JsonArray type_arr = HXDD_JsonArray(type_elem);
		return type_arr;
    }
    bool GetBool(HXDD_JsonObject jo, String key) {
        HXDD_JsonElement type_elem = jo.get(key);
        if (!type_elem) {
            return false;
        }
		HXDD_JsonBool type_bool = HXDD_JsonBool(type_elem);
		return type_bool.b;
    }

	int GetEnumFromArmorType(String type) {
		if (type == "ac" || type == "armor" || type == "armorclass" || type == "hexen") {
			return PSAT_ARMOR_AC;
		} else {
			return PSAT_ARMOR_SIMPLE;
		}
	}
	int GetEnumFromProgressionType(String type) {
		if (type == "levels" || type == "level" || type == "leveling" || type == "hexen2") {
			return PSP_LEVELS;
		} else {
			return PSP_NONE;
		}
	}

    void Load(String file) {
		// Create defaults
		self.alignment = "neutral";
		self.ArmorType = 0;
		self.ProgressionType = 0;

		self.UseMaxHealthScaler = true;

		self.HalveXPBeforeLevel4 = true;
		self.experienceModifier = 1.0;
		self.maxLevel = 20;

		self.UsesEventHandler = false;

		Array<int> defaultExpTable;
		int last = 800;
		defaultExpTable.push(last);
		for (let i = 1; i < 11; i++) {
			last = last * 2.0;
			defaultExpTable.push(last);
		}
		self.experienceTable.Copy(defaultExpTable);

		Array<double> defaultSkillMod = {1.5,1.25,1.1,1.0,0.9};
		self.skillmodifier.Copy(defaultSkillMod);

		Array<int> defaultHPTable = {60,70,2,6,5};
		Array<int> defaultMPTable = {95,105,5,10,5};
		self.hitpointTable.Copy(defaultHPTable);
		self.manaTable.Copy(defaultMPTable);

		Array<int> defaultStatTable = {6,12};
		self.strengthTable.Copy(defaultStatTable);
		self.intelligenceTable.Copy(defaultStatTable);
		self.wisdomTable.Copy(defaultStatTable);
		self.dexterityTable.Copy(defaultStatTable);

        int lumpIndex = Wads.CheckNumForFullName(String.format("playersheets/%s.playersheet", file));
        console.printf("Progression: Load %d", lumpIndex);
        if (lumpIndex != -1) {
            String lumpData = Wads.ReadLump(lumpIndex);
            let json = HXDD_JSON.parse(lumpData, false);
            if (json is "HXDD_JsonElement") {
                HXDD_JsonObject jsonObject = HXDD_JsonObject(json);
				if (jsonObject) {
                	console.printf("Progression: Loaded %s!", file);

					String valPlayerClass = GetString(jsonObject, "class");
					String valArmorType = GetString(jsonObject, "armor_type");
					String valProgressionType = GetString(jsonObject, "progression_type");
					int valMaxLevel = GetInt(jsonObject, "max_level");
					String valAlignment = GetString(jsonObject, "alignment");
					bool valUseMaxHealthScaler = GetBool(jsonObject, "use_max_health_scaler");
					let valSkillModifier = GetArray(jsonObject, "skill_modifier");
					double valXPModifier = GetDouble(jsonObject, "xp_modifier");
					bool valHalveXPBeforeLevel4 = GetBool(jsonObject, "halve_xp_before_level_4");

					let valExperienceTable = GetArray(jsonObject, "experience");
					let valHPTable = GetArray(jsonObject, "health");
					let valManaTable = GetArray(jsonObject, "mana");
					let valStrTable = GetArray(jsonObject, "strength");
					let valIntTable = GetArray(jsonObject, "intelligence");
					let valWisTable = GetArray(jsonObject, "wisdom");
					let valDexTable = GetArray(jsonObject, "dexterity");

					let valUsesEventHandler = GetBool(jsonObject, "event_handler");

					self.PlayerClass 				= valPlayerClass.MakeLower();
					self.Alignment 					= valAlignment.MakeLower();
					self.ArmorType 					= GetEnumFromArmorType(valArmorType.MakeLower());
					self.ProgressionType 			= GetEnumFromProgressionType(valProgressionType.MakeLower());

					self.UseMaxHealthScaler 		= valUseMaxHealthScaler;
					self.HalveXPBeforeLevel4 		= valHalveXPBeforeLevel4;
					self.maxlevel 					= valMaxLevel;
					self.experienceModifier			= valXPModifier;

					self.UsesEventHandler			= valUsesEventHandler;

					if (valSkillModifier) {
						if (defaultSkillMod.Size() < valSkillModifier.arr.Size()) {
							self.skillmodifier.Resize(valSkillModifier.arr.Size());
						}
						for (let i = 0; i < valSkillModifier.arr.Size(); i++) {
							if (valSkillModifier.arr[i]) {
								self.skillmodifier[i]		= HXDD_JsonDouble(valSkillModifier.arr[i]).d;
							}
						}
					}
					self.experienceTable.Resize(valExperienceTable.arr.Size());
					for (let i = 0; i < valExperienceTable.arr.Size(); i++) {
						self.experienceTable[i] 	= HXDD_JsonInt(valExperienceTable.arr[i]).i;
					}

					if (valHPTable && valManaTable) {
						for (let i = 0; i < 5; i++) {
							if (valHPTable.arr[i]) {
								self.hitpointTable[i] 		= HXDD_JsonInt(valHPTable.arr[i]).i;
							}
							if (valManaTable.arr[i]) {
								self.manaTable[i] 			= HXDD_JsonInt(valManaTable.arr[i]).i;
							}
						}
					}
					if (valStrTable && valIntTable && valWisTable && valDexTable) {
						for (let i = 0; i < 2; i++) {
							if (valStrTable.arr[i]) {
								self.strengthTable[i] 		= HXDD_JsonInt(valStrTable.arr[i]).i;
							}
							if (valIntTable.arr[i]) {
								self.intelligenceTable[i] 	= HXDD_JsonInt(valIntTable.arr[i]).i;
							}
							if (valWisTable.arr[i]) {
								self.wisdomTable[i] 		= HXDD_JsonInt(valWisTable.arr[i]).i;
							}
							if (valDexTable.arr[i]) {
								self.dexterityTable[i] 		= HXDD_JsonInt(valDexTable.arr[i]).i;
							}
						}
					}
				}
            } else {
                console.printf("Progression: Failed to load %s data from JSON!", file);
            }
        }
    }
}

class Progression: Inventory {
	bool ArmorSelected;
	bool ProgressionSelected;
	bool CompatabilityScaleSelected;

	// Alignment (Used for some pickups)
	String Alignment;

	// Gameplay Modes
	int ArmorType;
	int ProgressionType;

	bool UseMaxHealthScaler;
	int SpawnHealth;

	bool HalveXPBeforeLevel4;
	bool UsesEventHandler;

	// Class Tables
	Array<int> experienceTable;
	Array<int> hitpointTable;
	Array<int> manaTable;
	Array<int> strengthTable;
	Array<int> intelligenceTable;
	Array<int> wisdomTable;
	Array<int> dexterityTable;

	Array<double> skillmodifier;

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
			optionProgression = self.ProgressionType;
		}
		return optionProgression == PSP_LEVELS || optionProgression == PSP_LEVELS_RANDOM || optionProgression == PSP_LEVELS_USER;
	}

	override void BeginPlay() {
		Super.BeginPlay();

		self.ExperienceModifier = 1.0;
		self.Level = 0;
		self.Experience = 0;

		self.MaxHealth = 100;
		self.MaxMana = 0;
		self.Strength = 10;
		self.Intelligence = 10;
		self.Wisdom = 10;
		self.Dexterity = 10;
	}

	override void PostBeginPlay() {
		Super.PostBeginPlay();

		LoadPlayerSheet();
		if (!ProgressionSelected) {
			if (ProgressionAllowed()) {
				InitLevel_PostBeginPlay();
			}
			ProgressionSelected = true;
		}
		ArmorModeSelection();
	}

	String GetPlayerClassName() {
		String playerClassName = owner.player.mo.GetClassName();
		if (playerClassName.IndexOf("HXDD") != -1) {
			playerClassName = owner.player.mo.GetParentClass().GetClassName();
		}
		return playerClassName.MakeLower();
	}

	void LoadPlayerSheet() {
		int cvarProgression = LemonUtil.CVAR_GetInt("hxdd_progression", PSP_DEFAULT);

		String playerClassName = GetPlayerClassName();

		int cvarArmorType = PSAT_ARMOR_SIMPLE;
		let itemHexenArmor = HexenArmor(owner.player.mo.FindInventory("HexenArmor"));
		if (itemHexenArmor) {
			cvarArmorType = PSAT_ARMOR_AC;
		}

		let PlayerSheet = new("PlayerSheetJSON");
		PlayerSheet.Load(playerClassName);

		if (PlayerSheet.ArmorType == PSAT_DEFAULT) {
			self.ArmorType = cvarArmorType;
		} else {
			self.ArmorType = PlayerSheet.ArmorType;
		}
		if(PlayerSheet.ProgressionType == PSAT_DEFAULT) {
			self.ProgressionType = PSP_NONE;
		} else {
			self.ProgressionType = PlayerSheet.ProgressionType;
		}
		self.Alignment = PlayerSheet.Alignment.MakeLower();

		self.UseMaxHealthScaler = PlayerSheet.UseMaxHealthScaler;

		if (self.ArmorType == PSAT_DEFAULT) {
			self.ArmorType = PSAT_ARMOR_SIMPLE;
			console.printf("Incorrect Class Armor Mode, PSAT_DEFAULT or 0 should not be used! Using PSAT_SIMPLE as Default.");
		}
		if (self.ProgressionType == PSP_DEFAULT) {
			self.ProgressionType = PSP_NONE;
			console.printf("Incorrect Class Progression Mode, PSP_DEFAULT or 0 should not be used! Using PSP_NONE as Default.");
		}

		if (cvarProgression == PSP_DEFAULT) {
			cvarProgression = self.ProgressionType;
		}

		if (cvarProgression != PSP_NONE) {
			bool hasEvents = PlayerSheet.UsesEventHandler;
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
			self.HalveXPBeforeLevel4 = PlayerSheet.HalveXPBeforeLevel4;

			self.maxlevel 			= PlayerSheet.maxLevel;
			self.experienceModifier	= PlayerSheet.experienceModifier;

			self.skillmodifier.Copy(PlayerSheet.skillmodifier);

			self.experienceTable.Copy(PlayerSheet.experienceTable);

			self.hitpointTable.Copy(PlayerSheet.hitpointTable);
			self.manaTable.Copy(PlayerSheet.manaTable);

			self.strengthTable.Copy(PlayerSheet.strengthTable);
			self.intelligenceTable.Copy(PlayerSheet.intelligenceTable);
			self.wisdomTable.Copy(PlayerSheet.wisdomTable);
			self.dexterityTable.Copy(PlayerSheet.dexterityTable);

		} else if (cvarProgression == PSP_LEVELS_USER) {
			// User Defined Stats
			int lastExpDefault = 800;
			self.experienceTable.Resize(11);
			self.experienceTable[0] = LemonUtil.CVAR_GetInt("hxdd_progression_user_level_0", lastExpDefault);
			for (let i = 1; i < 11; i++) {
				lastExpDefault *= 2;
				String cvarExpTableLevelNum = String.format("hxdd_progression_user_level_%d", i);
				self.experienceTable[i] = LemonUtil.CVAR_GetInt(cvarExpTableLevelNum, lastExpDefault);
			}

			self.hitpointTable.Resize(5);
			self.hitpointTable[0] = LemonUtil.CVAR_GetInt("hxdd_progression_user_health_base_max", 100);
			self.hitpointTable[1] = LemonUtil.CVAR_GetInt("hxdd_progression_user_health_base_min", 100);
			self.hitpointTable[2] = LemonUtil.CVAR_GetInt("hxdd_progression_user_health_inc_min", 0);
			self.hitpointTable[3] = LemonUtil.CVAR_GetInt("hxdd_progression_user_health_inc_max", 5);
			self.hitpointTable[4] = LemonUtil.CVAR_GetInt("hxdd_progression_user_health_inc_cap", 5);

			self.manaTable.Resize(5);
			self.manaTable[0] = LemonUtil.CVAR_GetInt("hxdd_progression_user_mana_base_max", 100);
			self.manaTable[1] = LemonUtil.CVAR_GetInt("hxdd_progression_user_mana_base_min", 100);
			self.manaTable[2] = LemonUtil.CVAR_GetInt("hxdd_progression_user_mana_inc_min", 5);
			self.manaTable[3] = LemonUtil.CVAR_GetInt("hxdd_progression_user_mana_inc_max", 10);
			self.manaTable[4] = LemonUtil.CVAR_GetInt("hxdd_progression_user_mana_inc_cap", 5);

			self.strengthTable.Resize(2);
			self.strengthTable[0] = LemonUtil.CVAR_GetInt("hxdd_progression_user_strength_min", 10);
			self.strengthTable[1] = LemonUtil.CVAR_GetInt("hxdd_progression_user_strength_max", 10);

			self.intelligenceTable.Resize(2);
			self.intelligenceTable[0] = LemonUtil.CVAR_GetInt("hxdd_progression_user_intelligence_min", 10);
			self.intelligenceTable[1] = LemonUtil.CVAR_GetInt("hxdd_progression_user_intelligence_max", 10);

			self.wisdomTable.Resize(2);
			self.wisdomTable[0] = LemonUtil.CVAR_GetInt("hxdd_progression_user_wisdom_min", 10);
			self.wisdomTable[1] = LemonUtil.CVAR_GetInt("hxdd_progression_user_wisdom_max", 10);

			self.dexterityTable.Resize(2);
			self.dexterityTable[0] = LemonUtil.CVAR_GetInt("hxdd_progression_user_dexterity_min", 10);
			self.dexterityTable[1] = LemonUtil.CVAR_GetInt("hxdd_progression_user_dexterity_max", 10);

			self.maxlevel = LemonUtil.CVAR_GetInt("hxdd_progression_user_level_max", 20);

		} else if (cvarProgression == PSP_LEVELS_RANDOM) {
			// TODO: Add ranges?
			self.experienceModifier = 1.0f + frandom[exprnd](0.0f, 0.5f);

			self.experienceTable.Resize(11);
			self.experienceTable[0] = (0.2f + frandom[exprnd](0.8f, 1.0f)) * 800;
			for (let i = 1; i < 11; i++) {
				self.experienceTable[i] = 	self.experienceTable[i-1] * (1.8 + (frandom[exprnd](0.0, 1.0) * 4.0f));
			}

			self.hitpointTable.Resize(5);
			self.hitpointTable[0] = 65.0f;
			self.hitpointTable[1] = self.hitpointTable[0] + (frandom[exprnd](0.15f, 0.25f) * 100.0f);;
			self.hitpointTable[2] = frandom[exprnd](0.5f, 1.0f) * 5.0f;
			self.hitpointTable[3] = frandom[exprnd](0.75f, 1.0f) * 10.0f;
			self.hitpointTable[4] = self.hitpointTable[2] * (0.4 + frandom[exprnd](0.0, 0.2));

			self.manaTable.Resize(5);
			self.manaTable[0] = 70.0f;
			self.manaTable[1] = 80.0f + (frandom[exprnd](0.0f, 1.0f) * 25.0f);
			self.manaTable[2] = frandom[exprnd](0.5f, 1.0f) * 5.0f;
			self.manaTable[3] = frandom[exprnd](0.75f, 1.0f) * 15.0f;
			self.manaTable[4] = self.manaTable[2] * (0.4 + frandom[exprnd](0.0, 0.2));

			self.strengthTable.Resize(2);
			self.intelligenceTable.Resize(2);
			self.wisdomTable.Resize(2);
			self.dexterityTable.Resize(2);
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
		int optionArmorMode = LemonUtil.CVAR_GetInt("hxdd_armor_mode", PSAT_DEFAULT);
		if (optionArmorMode == PSAT_DEFAULT) {
			optionArmorMode = self.ArmorType;
		}
		if (optionArmorMode == PSAT_ARMOR_SIMPLE) {
			ArmorModeSelection_Simple(player);
		} else if (optionArmorMode == PSAT_ARMOR_AC) {
			ArmorModeSelection_AC(player);
		} else if (optionArmorMode == PSAT_ARMOR_RANDOM) {
			ArmorModeSelection_Random(player);
		} else if (optionArmorMode == PSAT_ARMOR_USER) {
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
		String playerClassName = GetPlayerClassName();

		bool cvarAllowBackpackUse = LemonUtil.CVAR_GetBool("hxdd_allow_backpack_use", false);
		PlayerPawn player = PlayerPawn(owner.player.mo);

		String cvarLevelUpAudio = LemonUtil.CVAR_GetString(String.format("hxdd_playersheet_%s_level_audio", playerClassName), "misc/chat");
		S_StartSound(cvarLevelUpAudio, CHAN_AUTO);

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
		if (self.HalveXPBeforeLevel4 && level < 4) {
			amount *= 0.5;
		}

		amount *= experienceModifier;
		int wisdom_modifier = wisdom - 11;
		amount += amount * wisdom_modifier / 20;

		self.experience += amount;

		//OnExperienceBonus(amount);

		if (self.level == self.maxlevel) {
			// Max Level
			return 0.0f;
		}
		console.printf("Gained %d Experience! Total Experience: %d", amount, self.experience);

		double afterLevel = FindLevel();

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
	bool xpModWarning;
	double GiveExperienceByTargetHealth(Actor target) {
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
			calcExp *= frandom[ExpRange](0.8, 0.9);
			if (target.bBoss) {
				calcExp *= 1.75;
			}
			calcExp = (calcExp * 0.9) + frandom[ExpBonus](calcExp * 0.05, calcExp * 0.15);
			int skSpawnFilter = G_SkillPropertyInt(SKILLP_SpawnFilter) - 1;
			skSpawnFilter = clamp(skSpawnFilter, 0, 4);
			if (self.skillmodifier[skSpawnFilter]) {
				calcExp *= self.skillmodifier[skSpawnFilter];
			}
			return GiveExperience(calcExp);
		}
		return exp;
	}
}