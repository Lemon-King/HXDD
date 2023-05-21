//----------------------------------------------------------------------------
//
// Highly Modified Hexen II: Progression & Armor System
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

class PlayerSheetEventHandler: EventHandler {
    override void PlayerSpawned(PlayerEvent e) {
        PlayerPawn pp = PlayerPawn(players[e.PlayerNumber].mo);
        if (pp) {
            Progression prog = Progression(pp.FindInventory("Progression"));
            if (prog == null) {
                pp.GiveInventory("Progression", 1);
                prog = Progression(pp.FindInventory("Progression"));
            }
            GameModeCompat gmcompat = GameModeCompat(pp.FindInventory("GameModeCompat"));
            if (gmcompat == null) {
                pp.GiveInventory("GameModeCompat", 1);
            }
        }
    }

    override void WorldThingDied(WorldEvent e) {
        if (e.thing && e.thing.bIsMonster && e.thing.bCountKill && e.thing.target && e.thing.target.player) {
            if (e.thing.target.player.mo is "PlayerPawn") {
                PlayerPawn pt = PlayerPawn(e.thing.target.player.mo);
                if (pt.FindInventory("Progression")) {
                    Progression prog = Progression(pt.FindInventory("Progression"));
                    double exp = 0;
                    if (prog != NULL) {
                        exp = prog.AwardExperience(e.thing);
                    }
                    
                    if (prog.handler) {
                        prog.handler.OnKill(pt, e.thing, exp);
                    }
                }
            }
        }
    }
}

class PlayerSheetStat {
	String name;
	Array<int> table;
	double value;

	double stat_compute(double min, double max) {
		double value = (max-min+1) * frandom[sheetstat](0.0, 1.0) + min;
		if (value > max) {
			return max;
		}
		value = ceil(value);
		return value;
	}

	void Roll() {
		self.value = self.stat_compute(self.table[0], self.table[1]);
	}

	void ProcessLevelIncrease(bool levelCap) {
		// stat uses a leveling table
		if (self.table.Size() >= 5) {
			int max = self.table[1];
			if (self.table[5]) {
				max = self.table[5];
			}
			if (levelCap) {
				self.value += clamp(self.table[0], self.table[4], max);
			} else {
				self.value += clamp(self.table[0], self.stat_compute(self.table[2], self.table[3]), max);
			}
		}
	}
}

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

	Array<PlayerSheetStat> stats;
	Array<String> stats_lookup;
	String xp_bonus_stat;

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

        int lumpIndex = Wads.CheckNumForFullName(String.format("playersheets/%s.playersheet", file));
        console.printf("PlayerSheetJSON: Load %d", lumpIndex);
        if (lumpIndex != -1) {
            String lumpData = Wads.ReadLump(lumpIndex);
            let json = HXDD_JSON.parse(lumpData, false);
            if (json is "HXDD_JsonElement") {
                HXDD_JsonObject jsonObject = HXDD_JsonObject(json);
				if (jsonObject) {
                	console.printf("PlayerSheetJSON: Loaded %s!", file);

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
					
					// Dynamic User Defined Stats
					HXDD_JsonObject objStats = HXDD_JsonObject(jsonObject.get("stats"));
					if (objStats) {
						Array<String> keys;
						objStats.GetKeysInto(keys);

						self.stats.Resize(keys.Size());
						self.stats_lookup.Resize(keys.Size());
						for (let i = 0; i < keys.Size(); i++) {
							String key = keys[i];
							HXDD_JsonArray stat = GetArray(objStats, key);
							if (stat) {
								if (stat.arr.size() >= 2) {
									PlayerSheetStat nStat = new ("PlayerSheetStat");
									nStat.name = key.MakeLower();
									nStat.table.Resize(stat.arr.Size());
									for (let i = 0; i < stat.arr.Size(); i++) {
										nStat.table[i] = HXDD_JsonInt(stat.arr[i]).i;
									}
									//nStat.value = 0;
									nStat.Roll();

									self.stats[i] = nStat;
									self.stats_lookup[i] = nStat.name;
								} else {
									console.printf("PlayerSheetJSON: Stat %s array must be 2 or higher. [start_low, start_high] or [start_low, start_high, level_low, level_high, level_max, stat_cap]", key);
								}
							} else {
								console.printf("PlayerSheetJSON: Failed to read stat %s at %d.", key, i);
							}
						}
					}
					String valXPStat = GetString(jsonObject, "xp_bonus_stat");
					if (self.stats_lookup.Find(valXPStat) != self.stats.Size()) {
						self.xp_bonus_stat = valXPStat;
					}

					let valUsesEventHandler = GetBool(jsonObject, "event_handler");

					// TODO: Setup Item Class Table Here for MultiClassItem Refactor

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
						self.hitpointTable.Resize(clamp(5, valHPTable.arr.Size(), 6));
						for (let i = 0; i < valHPTable.arr.Size(); i++) {
							if (valHPTable.arr[i]) {
								self.hitpointTable[i] 		= HXDD_JsonInt(valHPTable.arr[i]).i;
							}
						}
						self.manaTable.Resize(clamp(5, valManaTable.arr.Size(), 6));
						for (let i = 0; i < valManaTable.arr.Size(); i++) {
							if (valManaTable.arr[i]) {
								self.manaTable[i] 			= HXDD_JsonInt(valManaTable.arr[i]).i;
							}
						}
					}
				}
            } else {
                console.printf("PlayerSheetJSON: Failed to load data from file %s!", file);
            }
        }
    }

	String GetPlayerClassName(PlayerPawn pp) {
		String playerClassName = pp.GetClassName();
		if (playerClassName.IndexOf("HXDD") != -1) {
			playerClassName = pp.GetParentClass().GetClassName();
		}
		return playerClassName.MakeLower();
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

	Array<PlayerSheetStat> stats;
	Array<String> stats_lookup;
	String xp_bonus_stat;

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
		//self.Strength = 10;
		//self.Intelligence = 10;
		//self.Wisdom = 10;
		//self.Dexterity = 10;
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
			
			self.stats.Copy(PlayerSheet.stats);
			self.stats_lookup.Copy(PlayerSheet.stats_lookup);
			self.xp_bonus_stat		= PlayerSheet.xp_bonus_stat;

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

			/*
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
			*/

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

			self.stats.Copy(PlayerSheet.stats);
			self.stats_lookup.Copy(PlayerSheet.stats_lookup);
			for (let i = 0; i < self.stats.Size(); i++) {
				self.stats[i].table.Resize(5);
				for (let j = 0; j < 2; j++) {
					double mult = ((j+1) * 10.0f);
					self.stats[i].table[j] = frandom[exprnd](0.5f, 1.0f) * mult;
					self.stats[i].table[j + 2] = random[exprnd](2, 5);
				}
				self.stats[i].table[4] = self.stats[i].table[1] * 4.0;
				self.stats[i].Roll();
			}
			self.maxlevel = 20;
		}
	}

	PlayerSheetStat GetStat(String key) {
		int index = self.stats_lookup.Find(key);
		if (index != self.stats_lookup.Size()) {
			return self.Stats[index];
		} else {
			console.printf("Progression.GetStat: Could not find stat %s!", key);
			return null;
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
						ammoItem.Amount = 0;
					}
					//ammoItem.Amount = 0;
					if (cvarAllowBackpackUse) {
						ammoItem.BackpackMaxAmount = ammoItem.MaxAmount * (ammoItem.Default.BackpackMaxAmount / ammoItem.Default.MaxAmount);
					} else {
						ammoItem.BackpackMaxAmount = ammoItem.MaxAmount;
					}
				}
				ammoItem.AttachToOwner(Owner.player.mo);
			}
		}

		level = 1;
		experience = 0;

		console.printf("");
		console.printf("----- Stats -----");
		console.printf("Health: %0.2f", MaxHealth);
		console.printf("Mana: %0.2f", maxMana);
		for (let i = 0; i < self.stats.Size(); i++) {
			if (self.stats[i]) {
				String name = self.stats[i].name;
				String nameCap = String.format("%s%s", name.Left(1).MakeUpper(), name.Mid(1, name.Length() - 1));
				console.printf("%s: %0.2f", nameCap, self.stats[i].value);
			} else {
				console.printf("Progression.InitLevel_PostBeginPlay: Failed to read stat %d.", i);
			}
		}
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

			int limitMaxHealth = self.SpawnHealth * 1.5;
			if (self.hitpointTable.Size() == 6) {
				limitMaxHealth = self.hitpointTable[5];
			}
			int limitMaxMana = 300;
			if (self.manaTable.Size() == 6) {
				limitMaxMana = self.manaTable[5];
			}
			if (self.Health > limitMaxHealth) {
				self.Health = limitMaxHealth;
			}
			if (self.MaxHealth > limitMaxHealth) {
				self.MaxHealth = limitMaxHealth;
			}
			if (self.MaxMana > limitMaxMana) {
				self.MaxMana = limitMaxMana;
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

			for (let i = 0; i < self.stats.Size(); i++) {
				self.stats[i].ProcessLevelIncrease(level == self.maxlevel);
			}

			console.printf("");
			console.printf("-----Stats-----");
			console.printf("Health: %0.2f", MaxHealth);
			console.printf("Mana: %0.2f", MaxMana);
			for (let i = 0; i < self.stats.Size(); i++) {
				String name = self.stats[i].name;
				String nameCap = String.format("%s%s", name.Left(1).MakeUpper(), name.Mid(1, name.Length() - 1));
				console.printf("%s: %0.2f", nameCap, self.stats[i].value);
			}
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

		if (self.xp_bonus_stat != "") {
			PlayerSheetStat stat = GetStat(self.xp_bonus_stat);
			if (stat) {
				int xp_bonus_stat_modifier = stat.value - 11;
				amount += amount * xp_bonus_stat_modifier / 20;
			}
		}

		self.experience += amount;

		//OnExperienceBonus(amount);

		if (self.level == self.maxlevel) {
			// Max Level
			return 0.0f;
		}
		int MAX_LEVELS = experienceTable.Size() - 1;
		console.printf("Gained %d Experience! Total Experience: %d (%d)", amount, self.experience, self.experienceTable[clamp(0, self.level - 1, MAX_LEVELS)]);

		double afterLevel = FindLevel();

		if (level != afterLevel) {
			AdvanceLevel(afterLevel);
		}

		return amount;
	}

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

		levelpct = 0;

		return pLevel;
	}

	double AwardExperience(Actor target) {
		double exp = 0;
		if (self.experienceTable.Size() == 0 || !target) {
			// Experience Table is not setup or no target
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
		GiveExperience(exp);
		return exp;
	}

	double GetExperienceFromLookupTable(Actor target) {
		// Placeholder
		return 0;
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
}