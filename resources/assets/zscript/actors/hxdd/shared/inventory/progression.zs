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

class PlayerSheetResource {
	Array<int> resourceTable;
	bool useScale;
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
	Array<int> resourceTable;
	Array<int> hexenArmorTable;
	bool hasHexenArmorTable;
	
	String xp_bonus_stat;

	Map<String, PlayerSheetResource> resources;		// per resource
	Map<String, PlayerSheetStat> stats;

	int GetEnumFromArmorType(String type) {
		Array<string> keys = {"ac", "armor", "armorclass", "hexen", "hx", "hx2"};
		if (keys.Find(type) != keys.Size()) {
			return PSAT_ARMOR_AC;
		} else {
			return PSAT_ARMOR_SIMPLE;
		}
	}
	int GetEnumFromProgressionType(String type) {
		Array<string> keys = {"levels", "level", "leveling", "hexen2", "hx2"};
		if (keys.Find(type) != keys.Size()) {
			return PSP_LEVELS;
		} else {
			return PSP_NONE;
		}
	}

    void Load(String file) {
		// Create defaults
		self.alignment = "neutral";
		self.ArmorType = PSAT_DEFAULT;
		self.ProgressionType = PSP_DEFAULT;

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
		Array<int> defaultRPTable = {95,105,5,10,5};
		self.hitpointTable.Copy(defaultHPTable);
		self.resourceTable.Copy(defaultRPTable);
		self.hasHexenArmorTable = false;

        FileJSON fJSON = new ("FileJSON");
        let success = fJSON.Open(String.format("playersheets/%s.playersheet", file));
        //console.printf("PlayerSheetJSON: Load %d", fJSON.index);
        if (!success) {
            //console.printf("PlayerSheetJSON: Failed to load data from file %s!", file);
			return;
		}
		HXDD_JsonObject jsonObject = HXDD_JsonObject(fJSON.json);
		if (jsonObject) {
			console.printf("PlayerSheetJSON: Loaded %s!", file);

			String valClassName			= FileJSON.GetString(jsonObject, "name");
			String valPlayerClass		= FileJSON.GetString(jsonObject, "class");
			String valArmorType			= FileJSON.GetString(jsonObject, "armor_type");
			String valProgressionType	= FileJSON.GetString(jsonObject, "progression_type");
			int valMaxLevel				= FileJSON.GetInt(jsonObject, "max_level");
			String valAlignment			= FileJSON.GetString(jsonObject, "alignment");
			bool valUseMaxHealthScaler	= FileJSON.GetBool(jsonObject, "use_max_health_scaler");
			let valSkillModifier		= FileJSON.GetArray(jsonObject, "skill_modifier");
			double valXPModifier		= FileJSON.GetDouble(jsonObject, "xp_modifier");
			bool valHalveXPBeforeLevel4 = FileJSON.GetBool(jsonObject, "halve_xp_before_level_4");
			let valExperienceTable		= FileJSON.GetArray(jsonObject, "experience");
			let valHPTable				= FileJSON.GetArray(jsonObject, "health");
			if (!valHPTable) {
				valHPTable				= FileJSON.GetArray(jsonObject, "hp");			// alt
			}
			let valResourceTable		= FileJSON.GetArray(jsonObject, "resource");
			if (!valResourceTable) {
				valResourceTable		= FileJSON.GetArray(jsonObject, "rp");			// alt
			}
			if (!valResourceTable) {
				valResourceTable		= FileJSON.GetArray(jsonObject, "mp");			// alt
			}
			if (!valResourceTable) {
				valResourceTable		= FileJSON.GetArray(jsonObject, "mana");		// alt
			}
			if (!valResourceTable) {
				valResourceTable		= FileJSON.GetArray(jsonObject, "ammo");		// alt
			}

			let valHexenArmorTable		= FileJSON.GetArray(jsonObject, "ac");
			if (!valHexenArmorTable) {
				valHexenArmorTable		= FileJSON.GetArray(jsonObject, "armor");		// alt
			}
			if (!valHexenArmorTable) {
				valHexenArmorTable		= FileJSON.GetArray(jsonObject, "armorclass");	// alt
			}
			if (!valHexenArmorTable) {
				valHexenArmorTable		= FileJSON.GetArray(jsonObject, "hexenarmor");	// alt
			}
			if (!valHexenArmorTable) {
				valHexenArmorTable		= FileJSON.GetArray(jsonObject, "hxarmor");		// alt
			}

			// Dynamic User Defined Stats
			HXDD_JsonObject objStats = HXDD_JsonObject(jsonObject.get("stats"));
			if (objStats) {
				Array<String> keys;
				objStats.GetKeysInto(keys);

				//self.stats.Resize(keys.Size());
				//self.stats_lookup.Resize(keys.Size());
				for (let i = 0; i < keys.Size(); i++) {
					String key = keys[i];
					HXDD_JsonArray stat = FileJSON.GetArray(objStats, key);
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

							self.stats.Insert(nStat.name, nStat);
							//self.stats[i] = nStat;
							//self.stats_lookup[i] = nStat.name;
						} else {
							console.printf("PlayerSheetJSON: Stat %s array must be 2 or higher. [start_low, start_high] or [start_low, start_high, level_low, level_high, level_max, stat_cap]", key);
						}
					} else {
						console.printf("PlayerSheetJSON: Failed to read stat %s at %d.", key, i);
					}
				}
			}
			String valXPStat = FileJSON.GetString(jsonObject, "xp_bonus_stat");
			if (self.stats.CheckKey(valXPStat)) {
				self.xp_bonus_stat = valXPStat;
			}

			let valUsesEventHandler = FileJSON.GetBool(jsonObject, "event_handler");

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
						self.skillmodifier[i]	= HXDD_JsonDouble(valSkillModifier.arr[i]).d;
					}
				}
			}
			self.experienceTable.Resize(valExperienceTable.arr.Size());
			for (let i = 0; i < valExperienceTable.arr.Size(); i++) {
				self.experienceTable[i]			= HXDD_JsonInt(valExperienceTable.arr[i]).i;
			}

			if (valHPTable) {
				self.hitpointTable.Resize(clamp(5, valHPTable.arr.Size(), 6));
				for (let i = 0; i < valHPTable.arr.Size(); i++) {
					if (valHPTable.arr[i]) {
						self.hitpointTable[i]	= HXDD_JsonInt(valHPTable.arr[i]).i;
					}
				}
			}
			if (valResourceTable) {
				self.resourceTable.Resize(clamp(5, valResourceTable.arr.Size(), 6));
				for (let i = 0; i < valResourceTable.arr.Size(); i++) {
					if (valResourceTable.arr[i]) {
						self.resourceTable[i]	= HXDD_JsonInt(valResourceTable.arr[i]).i;
					}
				}
			}
			if (valHexenArmorTable && valHexenArmorTable.Size() >= 5) {
				self.hexenArmorTable.Resize(5);
				for (let i = 0; i < 5; i++) {
					self.hexenArmorTable[i] 	= HXDD_JsonInt(valHexenArmorTable.arr[i]).i;
				}
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
	Array<int> resourceTable;
	Array<int> hexenArmorTable;

	Array<double> skillmodifier;

	// Character Stats
	int currlevel;
	int maxlevel;
	double experience;			// uint may not be large enough given some megawads and mods
	double experienceModifier;

	int maxHealth;
	int maxResource;
	int strength;
	int intelligence;
	int wisdom;
	int dexterity;

	//Array<PlayerSheetStat> stats;
	//Array<String> stats_lookup;
	String xp_bonus_stat;

	ProgressionEventHandler handler;

	Map<String, PlayerSheetResource> resources;		// per resource
	Map<String, PlayerSheetStat> stats;

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
		self.currlevel = 0;
		self.Experience = 0;

		self.MaxHealth = 100;
		self.MaxResource = 0;
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

	override void Tick() {
		self.SecretWatcher();
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

		if (PlayerSheet.hexenArmorTable.Size() == 5) {
			self.hexenArmorTable.Copy(PlayerSheet.hexenArmorTable);
		}

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
			self.resourceTable.Copy(PlayerSheet.resourceTable);

			self.stats.Move(PlayerSheet.stats);
			//self.stats_lookup.Copy(PlayerSheet.stats_lookup);
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

			self.resourceTable.Resize(5);
			self.resourceTable[0] = LemonUtil.CVAR_GetInt("hxdd_progression_user_mana_base_max", 100);
			self.resourceTable[1] = LemonUtil.CVAR_GetInt("hxdd_progression_user_mana_base_min", 100);
			self.resourceTable[2] = LemonUtil.CVAR_GetInt("hxdd_progression_user_mana_inc_min", 5);
			self.resourceTable[3] = LemonUtil.CVAR_GetInt("hxdd_progression_user_mana_inc_max", 10);
			self.resourceTable[4] = LemonUtil.CVAR_GetInt("hxdd_progression_user_mana_inc_cap", 5);

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

			self.resourceTable.Resize(5);
			self.resourceTable[0] = 70.0f;
			self.resourceTable[1] = 80.0f + (frandom[exprnd](0.0f, 1.0f) * 25.0f);
			self.resourceTable[2] = frandom[exprnd](0.5f, 1.0f) * 5.0f;
			self.resourceTable[3] = frandom[exprnd](0.75f, 1.0f) * 15.0f;
			self.resourceTable[4] = self.resourceTable[2] * (0.4 + frandom[exprnd](0.0, 0.2));

			//self.stats.Copy(PlayerSheet.stats);
			//self.stats_lookup.Copy(PlayerSheet.stats_lookup);

			self.stats.Move(PlayerSheet.stats);

			foreach (k, v : self.stats) {
				v.table.Resize(5);
				for (let j = 0; j < 2; j++) {
					double mult = ((j+1) * 10.0f);
					v.table[j] = frandom[exprnd](0.5f, 1.0f) * mult;
					v.table[j + 2] = random[exprnd](2, 5);
				}
				v.table[4] = v.table[1] * 4.0;
				v.Roll();
			}
			
			self.maxlevel = 20;
		}

		// After assignment, set final type
		self.ProgressionType = cvarProgression == PSP_NONE ? PSP_NONE : PSP_LEVELS;
	}

	PlayerSheetStat GetStat(String key) {
		return self.stats.GetIfExists(key);
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

		// After assignment, set final type
		self.ArmorType = optionArmorMode == PSAT_ARMOR_SIMPLE ? PSAT_ARMOR_SIMPLE : PSAT_ARMOR_AC;
		ArmorSelected = true;
	}

	HexenArmor FindOrGivePlayerHexenArmor(PlayerPawn player) {
		Array<int> defaultHexenArmorTable = {10, 15, 15, 15, 15};
		let hasHexenArmor = true;
		let itemHexenArmor = HexenArmor(player.FindInventory("HexenArmor"));
		if (itemHexenArmor == null) {
			owner.player.mo.GiveInventory("HexenArmor", 1);
			itemHexenArmor = HexenArmor(player.FindInventory("HexenArmor"));
			hasHexenArmor = false;
		}
		if (!hasHexenArmor || hexenArmorTable.Size() == 5) {
			if (hexenArmorTable.Size() == 5) {
				itemHexenArmor.Slots[4] = hexenArmorTable[0];
			} else {
				itemHexenArmor.Slots[4] = defaultHexenArmorTable[0];
			}
			for (int i = 0; i < 4; i++) {
				itemHexenArmor.SlotsIncrement[i] = hexenArmorTable.Size() == 5 ? hexenArmorTable[i+1] : defaultHexenArmorTable[i+1];
			}
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
		if (self.currlevel != 0) {
			return;
		}

		bool cvarAllowBackpackUse = LemonUtil.CVAR_GetBool("hxdd_allow_backpack_use", false);

		let player = owner.player.mo;
		self.SpawnHealth = player.Health;

		if (self.UseMaxHealthScaler && self.SpawnHealth != 100) {
        	self.MaxHealth = self.SpawnHealth * (stats_compute(hitpointTable[0], hitpointTable[1]) / 100.0);
		} else {
			self.MaxHealth = stats_compute(hitpointTable[0], hitpointTable[1]);
		}
		player.MaxHealth = self.MaxHealth;
        player.A_SetHealth(self.MaxHealth, AAPTR_DEFAULT);

		// Alt Ammo Handler
		maxResource = stats_compute(resourceTable[0], resourceTable[1]);

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
						ammoItem.MaxAmount = (double)(ammoItem.Default.MaxAmount) * (maxResource / 100.0);
					} else {
						ammoItem.MaxAmount = maxResource;
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

		currlevel = 1;
		experience = 0;
		self.leveldiffxp = self.experienceTable[0];

		console.printf("");
		console.printf("----- Stats -----");
		console.printf("Health: %0.2f", MaxHealth);
		console.printf("Resource: %0.2f", maxResource);
		foreach (k, v : self.stats) {
			String nameCap = String.format("%s%s", k.Left(1).MakeUpper(), k.Mid(1, k.Length() - 1));
			console.printf("%s: %0.2f", nameCap, v.value);
		}
		/*
		for (let i = 0; i < self.stats.Size(); i++) {
			if (self.stats[i]) {
				String name = self.stats[i].name;
				String nameCap = String.format("%s%s", name.Left(1).MakeUpper(), name.Mid(1, name.Length() - 1));
				console.printf("%s: %0.2f", nameCap, self.stats[i].value);
			} else {
				console.printf("Progression.InitLevel_PostBeginPlay: Failed to read stat %d.", i);
			}
		}
		*/
	}

	void AdvanceLevel(int advanceLevel) {
		// https://github.com/sezero/uhexen2/blob/5da9351b3a219629ffd1b287d8fa7fa206e7d136/gamecode/hc/portals/stats.hc#L233
		String playerClassName = GetPlayerClassName();

		bool cvarAllowBackpackUse = LemonUtil.CVAR_GetBool("hxdd_allow_backpack_use", false);
		PlayerPawn player = PlayerPawn(owner.player.mo);

		String cvarLevelUpAudio = LemonUtil.CVAR_GetString(String.format("hxdd_playersheet_%s_level_audio", playerClassName), "misc/chat");
		S_StartSound(cvarLevelUpAudio, CHAN_AUTO);

		while (self.currlevel < advanceLevel && self.currlevel < self.maxlevel) {
			int lastLevel = self.currlevel++;

			double healthInc = 0;
			double resourceInc = 0;
			if (lastLevel < self.MaxLevel) {
				if (self.UseMaxHealthScaler && self.SpawnHealth != 100) {
					healthInc = self.SpawnHealth * (stats_compute(self.hitpointTable[2],self.hitpointTable[3]) / 100.0);
				} else {
					healthInc = stats_compute(self.hitpointTable[2],self.hitpointTable[3]);
				}
				resourceInc = stats_compute(self.resourceTable[2],self.resourceTable[3]);
			} else {
				if (self.UseMaxHealthScaler && self.SpawnHealth != 100) {
					healthInc = (double)(self.SpawnHealth) * (self.hitpointTable[4] / 100.0);
				} else {
					healthInc = self.hitpointTable[4];
				}
				resourceInc = self.resourceTable[4];
			}
			self.MaxHealth += healthInc;
			self.MaxResource += resourceInc;

			int limitMaxHealth = self.SpawnHealth * 1.5;
			if (self.hitpointTable.Size() == 6) {
				limitMaxHealth = self.hitpointTable[5];
			}
			int limitMaxResource = 300;
			if (self.resourceTable.Size() == 6) {
				limitMaxResource = self.resourceTable[5];
			}
			if (self.Health > limitMaxHealth) {
				self.Health = limitMaxHealth;
			}
			if (self.MaxHealth > limitMaxHealth) {
				self.MaxHealth = limitMaxHealth;
			}
			if (self.MaxResource > limitMaxResource) {
				self.MaxResource = limitMaxResource;
			}

			// Hacky solution to increase player health when leveling
			// TODO: Add an options toggle
			player.MaxHealth = self.MaxHealth;
			int levelHealth = Clamp(self.Health + healthInc, self.Health, self.MaxHealth);
			HealThing(levelHealth, self.MaxHealth);

			Inventory next;
			for (Inventory item = player.Inv; item != NULL; item = next) {
				next = item.Inv;

				let invItem = player.FindInventory(item.GetClass());
				if (invItem != NULL && invItem is "Ammo") {
					Ammo ammoItem = Ammo(invItem);
					if (ammoItem) {
						if (!(ammoItem is "mana1" || ammoItem is "mana2")) {
							ammoItem.MaxAmount = (double)(ammoItem.Default.MaxAmount) * (MaxResource / 100.0);
						} else {
							ammoItem.MaxAmount = MaxResource;
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

			foreach (k, v : self.stats) {
				v.ProcessLevelIncrease(self.currlevel == self.maxlevel);
			}
			//for (let i = 0; i < self.stats.Size(); i++) {
			//	self.stats[i].ProcessLevelIncrease(self.currlevel == self.maxlevel);
			//}

			console.printf("");
			console.printf("-----Stats-----");
			console.printf("Health: %0.2f", MaxHealth);
			console.printf("Resource: %0.2f", MaxResource);
			foreach (k, v : self.stats) {
				String nameCap = String.format("%s%s", k.Left(1).MakeUpper(), k.Mid(1, k.Length() - 1));
				console.printf("%s: %0.2f", nameCap, v.value);
			}
			/*
			for (let i = 0; i < self.stats.Size(); i++) {
				String name = self.stats[i].name;
				String nameCap = String.format("%s%s", name.Left(1).MakeUpper(), name.Mid(1, name.Length() - 1));
				console.printf("%s: %0.2f", nameCap, self.stats[i].value);
			}
			*/
			console.printf("");
			console.printf("You are now level %d!", self.currlevel);
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
				amount += amount * xp_bonus_stat_modifier / 20;
			}
		}

		if (self.currlevel == self.maxlevel) {
			// Max Level
			return 0.0f;
		}

		self.experience += amount;

		int MAX_LEVELS = experienceTable.Size() - 1;
		console.printf("Gained %d Experience! Total Experience: %d (%d)", amount, self.experience, self.experienceTable[clamp(0, self.currlevel - 1, MAX_LEVELS)]);

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
}