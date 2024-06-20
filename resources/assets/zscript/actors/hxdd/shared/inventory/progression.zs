//----------------------------------------------------------------------------
//
// Highly Modified Hexen II: Progression & Armor System
// Ref: https://github.com/sezero/uhexen2/blob/5da9351b3a219629ffd1b287d8fa7fa206e7d136/gamecode/hc/portals/stats.hc
//
//----------------------------------------------------------------------------

enum EPlaystyleArmorType {
	PSAT_DEFAULT = 0,
	PSAT_ARMOR_SIMPLE = 1,
	PSAT_ARMOR_HXAC = 2,
	//PSAT_ARMOR_HX2AC = 3,
	PSAT_ARMOR_HXAC_RANDOM = 3,
	PSAT_ARMOR_HX2AC_RANDOM = 4,
	PSAT_ARMOR_USER = 5
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

class PlayerSheetStatBase {
	int min;				// Starting Min
	int max;				// Starting Max
}
class PlayerSheetStatGain {
	int min;				// Compute Min
	int max;				// Compute Max
	int cap;				// Compute Max Level
}

class PlayerSheetStatParams {
	int maximum;			// Maximum Stat Value
	PlayerSheetStatBase base;
	PlayerSheetStatGain gain;
}

class PlayerSheetStat {
	String name;
	double value;
	bool isActual;			// Do not use percentages when scaling (default: false)
	double bonusScale;		// Backpack scale (default: based off of AmmoItem value)
	PlayerSheetStatParams params;

	PlayerSheetStat Init(String name) {
		self.params = new ("PlayerSheetStatParams");
		self.params.base = new ("PlayerSheetStatBase");
		self.params.gain = new ("PlayerSheetStatGain");

		self.name = name;
		self.value = 0;
		self.isActual = false;
		self.bonusScale = 1.0;

		return self;
	}

	double stat_compute(double min, double max) {
		double value = (max-min+1) * frandom(0.0, 1.0) + min;
		if (value > max) {
			return max;
		}
		value = ceil(value);
		return value;
	}

	PlayerSheetStat Roll(bool levelCap = false) {
		if (self.value == 0) {
			self.value = self.stat_compute(self.params.base.min, self.params.base.max);
		} else {
			self.ProcessLevelIncrease(levelCap);
		}

		return self;
	}

	PlayerSheetStat ProcessLevelIncrease(bool levelCap) {
		if (self.params) {
			int nextValue = self.value;
			if (levelCap && self.params.gain.cap) {
				nextValue += self.params.gain.cap;
			} else if (self.params.gain.min && self.params.gain.max) {
				nextValue += self.stat_compute(self.params.gain.min, self.params.gain.max);
			}
			if (self.params.maximum) {
				nextValue = min(nextValue, self.params.maximum);
			}
			self.value = nextValue;
		}

		return self;
	}

	PlayerSheetStat SetFromObject(HXDD_JsonObject o) {
		if (!self.params) {
			return self;
		}

		int valStartMin;
		int valStartMax;
		let oStatBase		= HXDD_JsonObject(o.get("base"));
		if (oStatBase) {
			valStartMin		= FileJSON.GetInt(oStatBase, "min");
			valStartMax		= FileJSON.GetInt(oStatBase, "max");
		}

		int valGainMin;
		int valGainMax;
		int valGainCap;
		let oStatGain		= HXDD_JsonObject(o.Get("gain"));
		if (oStatGain) {
			valGainMin		= FileJSON.GetInt(o, "min");
			valGainMax		= FileJSON.GetInt(o, "max");
			valGainCap		= FileJSON.GetInt(o, "cap");
		}

		let valMaximum		= FileJSON.GetInt(o, "maximum");
		let valIsActual		= FileJSON.GetBool(o, "actual");
		let valBonusScale	= FileJSON.GetDouble(o, "bonus");

		self.params.base.min = valStartMin;
		self.params.base.max = valStartMax;
		if (valGainMin != -1 && valGainMax != -1) {
			self.params.gain.min = valGainMin;
			self.params.gain.max = valGainMax;
		}
		if (valGainCap != -1) {
			self.params.gain.cap = valGainCap;
		}
		if (valMaximum != -1) {
			self.params.maximum = valMaximum;
		}
		self.bonusScale = valBonusScale;
		self.isActual = valIsActual;

		return self;
	}

	PlayerSheetStat SetFromArray(HXDD_JsonArray raw) {
		if (!self.params) {
			return self;
		}

		Array<int> result;
		result.Resize(raw.arr.Size());
		for (let i = 0; i < raw.arr.Size(); i++) {
			result[i] = HXDD_JsonInt(raw.arr[i]).i;
		}

		int size = result.Size();
		if (size < 2) {
			// error?
			return self;
		}

		self.params.base.min = result[0];
		self.params.base.max = result[1];
		if (size > 3) {
			self.params.gain.min = result[2];
			self.params.gain.max = result[3];
		}
		if (size > 4) {
			self.params.gain.cap = result[4];
		}
		if (size > 5) {
			self.params.maximum = result[5];
		}

		return self;
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
	//Array<int> resourceTable;
	Array<int> hexenArmorTable;
	bool hasHexenArmorTable;

	String xp_bonus_stat;

	Map<String, PlayerSheetStat> resources;
	Map<String, PlayerSheetStat> stats;

	String soundLevelUp;

	String soundClass;

	int GetEnumFromArmorType(String type) {
		Array<string> keys = {"ac", "armor", "armorclass", "hexen", "hx", "hx2"};
		if (keys.Find(type) != keys.Size()) {
			return PSAT_ARMOR_HXAC;
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
		//self.resourceTable.Copy(defaultRPTable);
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
			String valSoundClass		= FileJSON.GetString(jsonObject, "soundclass");
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

			HXDD_JsonObject objResources;
			if (!valResourceTable) {
				objResources 			= HXDD_JsonObject(jsonObject.get("resource"));
				if (!objResources) {
					objResources		= HXDD_JsonObject(jsonObject.get("rp"));			// alt
				}
				if (!objResources) {
					objResources		= HXDD_JsonObject(jsonObject.get("mp"));			// alt
				}
				if (!objResources) {
					objResources		= HXDD_JsonObject(jsonObject.get("mana"));		// alt
				}
				if (!objResources) {
					objResources		= HXDD_JsonObject(jsonObject.get("ammo"));		// alt
				}
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

			HXDD_JsonObject valHXDDArmor = HXDD_JsonObject(jsonObject.get("ac"));
			if (valHXDDArmor) {
				// TODO: Improved Armor Slot System
			}

			// Dynamic User Defined Stats
			HXDD_JsonObject objStats = HXDD_JsonObject(jsonObject.get("stats"));
			if (!objStats) {
			    objStats = HXDD_JsonObject(jsonObject.get("attributes"));
			}
			if (!objStats) {
			    objStats = HXDD_JsonObject(jsonObject.get("attr"));
			}
			if (objStats) {
				Array<String> keys;
				objStats.GetKeysInto(keys);

				for (let i = 0; i < keys.Size(); i++) {
					String key = keys[i];
					HXDD_JsonArray stat = FileJSON.GetArray(objStats, key);
					if (stat) {
						String name = key.MakeLower();
						PlayerSheetStat rt = new ("PlayerSheetStat");
						rt.Init(name).SetFromArray(stat).Roll();
						self.stats.Insert(name, rt);
					} else {
						console.printf("PlayerSheetJSON: Failed to read stat %s at %d.", key, i);
					}
				}
			}

			if (objResources) {
				Array<String> keys;
				objResources.GetKeysInto(keys);

				if (keys.Find("base") || keys.Find("gain")) {
					// single object
					PlayerSheetStat rt = new ("PlayerSheetStat").Init("_default").SetFromObject(objResources).Roll();
					self.resources.Insert("_default", rt);
				} else {
					for (let i = 0; i < keys.Size(); i++) {
						String key = keys[i];
						String name = key.MakeLower();

						PlayerSheetStat rt = new ("PlayerSheetStat");
						HXDD_JsonArray aRes = FileJSON.GetArray(objResources, key);
						if (aRes) {
							rt.Init(name).SetFromArray(aRes).Roll();
							self.resources.Insert(name, rt);
							continue;
						}

						HXDD_JsonObject oRes = HXDD_JsonObject(jsonObject.get(key));
						if (oRes) {
							rt.Init(name).SetFromObject(oRes).Roll();
							self.resources.Insert(name, rt);
							continue;
						}
						console.printf("PlayerSheetJSON: Failed to read resource %s at %d.", key, i);
					}
				}
			}



			String valXPStat = FileJSON.GetString(jsonObject, "xp_bonus_stat");
			if (self.stats.CheckKey(valXPStat)) {
				self.xp_bonus_stat = valXPStat;
			}

			let valUsesEventHandler 		= FileJSON.GetBool(jsonObject, "event_handler");


			String valSoundLevelUp			= FileJSON.GetString(jsonObject, "levelup_sfx");

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

			self.soundLevelUp				= valSoundLevelUp;
			self.soundClass					= valSoundClass;

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
				PlayerSheetStat rt = new ("PlayerSheetStat");
				rt.Init("_default").SetFromArray(valResourceTable).Roll();
				self.resources.insert("_default", rt);
			} else if (objResources) {

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
	//Array<int> resourceTable;
	Array<int> hexenArmorTable;

	Array<double> skillmodifier;

	// Character Stats
	int currlevel;
	int maxlevel;
	double experience;			// uint may not be large enough given some megawads and mods
	double experienceModifier;

	int maxHealth;
	//int maxResource;
	int strength;
	int intelligence;
	int wisdom;
	int dexterity;

	//Array<PlayerSheetStat> stats;
	//Array<String> stats_lookup;
	String xp_bonus_stat;

	ProgressionEventHandler handler;

	Map<String, PlayerSheetStat> resources;		// per resource
	Map<String, PlayerSheetStat> stats;

	String soundLevelUp;
	String soundClass;

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
		//self.MaxResource = 0;
		//self.Strength = 10;
		//self.Intelligence = 10;
		//self.Wisdom = 10;
		//self.Dexterity = 10;
	}

	override void PostBeginPlay() {
		Super.PostBeginPlay();

		LoadPlayerSheet();
		PostSheetSetup();
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
			cvarArmorType = PSAT_ARMOR_HXAC;
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

		self.soundLevelUp			= PlayerSheet.soundLevelUp;

		self.HalveXPBeforeLevel4	= PlayerSheet.HalveXPBeforeLevel4;

		self.maxlevel				= PlayerSheet.maxLevel;
		self.experienceModifier		= PlayerSheet.experienceModifier;

		self.xp_bonus_stat			= PlayerSheet.xp_bonus_stat;

		self.soundClass				= PLayerSheet.soundClass;

		self.skillmodifier.Copy(PlayerSheet.skillmodifier);

		self.experienceTable.Copy(PlayerSheet.experienceTable);

		self.hitpointTable.Copy(PlayerSheet.hitpointTable);
		//self.resourceTable.Copy(PlayerSheet.resourceTable);

		self.resources.Move(PlayerSheet.resources);
		self.stats.Move(PlayerSheet.stats);

		if (cvarProgression == PSP_LEVELS_USER) {

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

			/*
			self.resourceTable.Resize(5);
			self.resourceTable[0] = LemonUtil.CVAR_GetInt("hxdd_progression_user_mana_base_max", 100);
			self.resourceTable[1] = LemonUtil.CVAR_GetInt("hxdd_progression_user_mana_base_min", 100);
			self.resourceTable[2] = LemonUtil.CVAR_GetInt("hxdd_progression_user_mana_inc_min", 5);
			self.resourceTable[3] = LemonUtil.CVAR_GetInt("hxdd_progression_user_mana_inc_max", 10);
			self.resourceTable[4] = LemonUtil.CVAR_GetInt("hxdd_progression_user_mana_inc_cap", 5);
			*/

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

			/*
			self.resourceTable.Resize(5);
			self.resourceTable[0] = 70.0f;
			self.resourceTable[1] = 80.0f + (frandom[exprnd](0.0f, 1.0f) * 25.0f);
			self.resourceTable[2] = frandom[exprnd](0.5f, 1.0f) * 5.0f;
			self.resourceTable[3] = frandom[exprnd](0.75f, 1.0f) * 15.0f;
			self.resourceTable[4] = self.resourceTable[2] * (0.4 + frandom[exprnd](0.0, 0.2));
			*/

			//self.stats.Copy(PlayerSheet.stats);
			//self.stats_lookup.Copy(PlayerSheet.stats_lookup);

			self.stats.Move(PlayerSheet.stats);

			/*
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
			*/

			self.maxlevel = 10 + (random[RNGLEVEL](0,4) * 5);
		}

		// After assignment, set final type
		self.ProgressionType = cvarProgression == PSP_NONE ? PSP_NONE : PSP_LEVELS;
	}

	void PostSheetSetup() {
		let player = owner.player.mo;
		if (self.soundClass) {
			player.SoundClass = self.soundClass;
		}
	}

	PlayerSheetStat GetResource(String key) {
		return self.resources.GetIfExists(key);
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
		} else if (optionArmorMode == PSAT_ARMOR_HXAC) {
			ArmorModeSelection_HXAC(player);
		//} else if (optionArmorMode == PSAT_ARMOR_HX2AC) {
		//	ArmorModeSelection_HX2AC(player);
		} else if (optionArmorMode == PSAT_ARMOR_HXAC_RANDOM) {
			ArmorModeSelection_HXAC_Random(player);
		} else if (optionArmorMode == PSAT_ARMOR_USER) {
			ArmorModeSelection_User(player);
		}
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
			self.ArmorType = PSAT_ARMOR_SIMPLE;
		}
	}
	void ArmorModeSelection_HXAC(PlayerPawn player) {
		// ensure the class has hexen armor values, if not fill with defaults
		let itemHexenArmor = FindOrGivePlayerHexenArmor(player);
		if (itemHexenArmor) {
			int totalArmor = itemHexenArmor.Slots[4];
			for (int i = 0; i < 4; i++) {
				totalArmor += itemHexenArmor.SlotsIncrement[i];
			}
			if (totalArmor == 0) {
				// no armor, use random instead
				ArmorModeSelection_HXAC_Random(player);
			}
			self.ArmorType = PSAT_ARMOR_HXAC;
		}
	}
	void ArmorModeSelection_HXAC_Random(PlayerPawn player) {
		// ensure the class has hexen armor values, if not fill with defaults
		let itemHexenArmor = FindOrGivePlayerHexenArmor(player);
		if (itemHexenArmor) {
			itemHexenArmor.Slots[4] = random(0,3) * 5;
			for (int i = 0; i < 4; i++) {
				int amount = random(1,4) * 5;
				itemHexenArmor.SlotsIncrement[i] = amount;
			}
			self.ArmorType = PSAT_ARMOR_HXAC;
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
		self.ArmorType = PSAT_ARMOR_HXAC;
	}

	PlayerSheetStat FindResourceValue(String className) {
		PlayerSheetStat res = self.GetResource(className.MakeLower());
		int value = 0;
		if (res) {
			return res;
		}
		res = self.GetResource("_default");
		if (res) {
			return res;
		}
		return res;
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
		//self.maxResource = stats_compute(resourceTable[0], resourceTable[1]);

		// Calc initial ammo
		// Add ammo dummies to player
		uint end = AllActorClasses.Size();
		for (uint i = 0; i < end; ++i) {
			let ammotype = (class<Ammo>)(AllActorClasses[i]);
			if (ammotype && GetDefaultByType(ammotype).GetParentAmmo() == ammotype) {
				Ammo ammoItem = Ammo(Owner.player.mo.FindInventory(ammotype));
				bool isUnowned = false;
				if (ammoItem == null) {
					// The player did not have the ammoitem. Add it.
					ammoItem = Ammo(Spawn(ammotype));
					isUnowned = true;
				}
				ammoItem.AttachToOwner(Owner.player.mo);
				AmmoItem_RefreshAmount(ammoItem);
				if (isUnowned) {
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
		//console.printf("Resource: %0.2f", maxResource);
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
			double resourceInc = 0;
			if (lastLevel < self.MaxLevel) {
				if (self.UseMaxHealthScaler && self.SpawnHealth != 100) {
					healthInc = self.SpawnHealth * (stats_compute(self.hitpointTable[2],self.hitpointTable[3]) / 100.0);
				} else {
					healthInc = stats_compute(self.hitpointTable[2],self.hitpointTable[3]);
				}
				//resourceInc = stats_compute(self.resourceTable[2],self.resourceTable[3]);
			} else {
				if (self.UseMaxHealthScaler && self.SpawnHealth != 100) {
					healthInc = (double)(self.SpawnHealth) * (self.hitpointTable[4] / 100.0);
				} else {
					healthInc = self.hitpointTable[4];
				}
				//resourceInc = self.resourceTable[4];
			}
			self.MaxHealth += healthInc;
			//self.MaxResource += resourceInc;

			int limitMaxHealth = self.SpawnHealth * 1.5;
			if (self.hitpointTable.Size() == 6) {
				limitMaxHealth = self.hitpointTable[5];
			}
			//int limitMaxResource = 300;
			//if (self.resourceTable.Size() == 6) {
			//	limitMaxResource = self.resourceTable[5];
			//}
			if (self.Health > limitMaxHealth) {
				self.Health = limitMaxHealth;
			}
			if (self.MaxHealth > limitMaxHealth) {
				self.MaxHealth = limitMaxHealth;
			}
			//if (self.MaxResource > limitMaxResource) {
			//	self.MaxResource = limitMaxResource;
			//}

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
					AmmoItem_RefreshAmount(ammoItem);
				}
			}

			console.printf("");
			console.printf("You are now level %d!", self.currlevel);
			console.printf("-----Stats-----");
			console.printf("Health: %0.2f", self.MaxHealth);
			//console.printf("Resource: %0.2f", self.MaxResource);
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
		PlayerPawn player = PlayerPawn(owner.player.mo);
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
		console.printf("Gained %d Experience! (%d/%d)", amount, self.experience, self.experienceTable[clamp(0, self.currlevel - 1, MAX_LEVELS)]);

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