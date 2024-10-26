mixin class PlayerSlotJSON {
	bool isLoaded;

    void LoadJSON(String file) {
		if (self.isLoaded) {
			console.printf("Already Loaded!");
			return;
		}
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

        FileJSON fJSON = new("FileJSON");
        let success = fJSON.Open(String.format("playersheets/%s.playersheet", file));
        //console.printf("PlayerSheetJSON: Load %d", fJSON.index);
        if (!success) {
            //console.printf("PlayerSheetJSON: Failed to load data from file %s!", file);
			return;
		}
		HXDD_JsonObject jsonObject = HXDD_JsonObject(fJSON.json);
		if (jsonObject) {
        	bool cvar_isdev_environment = LemonUtil.CVAR_GetBool("hxdd_isdev_environment", false);
			if (cvar_isdev_environment) {
				console.printf("PlayerSheetJSON: Loaded %s!", file);
			}

			self.XClass = new("XClassTranslation");
			self.XClass.CreateXClassTranslation(jsonObject);

			String valClassName			= FileJSON.GetString(jsonObject, "name");
			String valPlayerClass		= FileJSON.GetString(jsonObject, "class");
			String valGameType			= FileJSON.GetString(jsonObject, "game_type");
			String valPickupType		= FileJSON.GetString(jsonObject, "pickup_type");
			String valArmorType			= FileJSON.GetString(jsonObject, "armor_type");
			String valProgressionType	= FileJSON.GetString(jsonObject, "progression_type");
			int valMaxLevel				= FileJSON.GetInt(jsonObject, "max_level");
			String valAlignment			= FileJSON.GetString(jsonObject, "alignment");
			String valSoundClass		= FileJSON.GetString(jsonObject, "soundclass");
			String valStatusBarClass	= FileJSON.GetString(jsonObject, "statusbar");
			String valTeleportFog		= FileJSON.GetString(jsonObject, "teleportfog");

			bool valUseMaxHealthScaler	= FileJSON.GetBool(jsonObject, "use_max_health_scaler");
			let valSkillModifier		= FileJSON.GetArray(jsonObject, "skill_modifier");
			double valXPModifier		= FileJSON.GetDouble(jsonObject, "xp_modifier");
			bool valHalveXPBeforeLevel4 = FileJSON.GetBool(jsonObject, "halve_xp_before_level_4");
			bool valOnlyDropUnownedWeapons	= FileJSON.GetBool(jsonObject, "only_drop_unowned_weapons");
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
						PlayerSheetStat rt = new("PlayerSheetStat");
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
					PlayerSheetStat rt = new("PlayerSheetStat").Init("_default").SetFromObject(objResources).Roll();
					self.resources.Insert("_default", rt);
				} else {
					for (let i = 0; i < keys.Size(); i++) {
						String key = keys[i];
						String name = key.MakeLower();

						PlayerSheetStat rt = new("PlayerSheetStat");
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

			HXDD_JsonObject objSoundSet	= HXDD_JsonObject(jsonObject.get("sound_set"));
			if (objSoundSet) {
				Array<String> keys;
				objSoundSet.GetKeysInto(keys);

				for (let i = 0; i < keys.Size(); i++) {
					String key = keys[i];
					let value = FileJSON.GetString(objSoundSet, key);
					self.soundSet.insert(key, value);
				}
			}

			HXDD_JsonArray valInventory	= HXDD_JsonArray(jsonObject.get("inventory"));
			if (valInventory && valInventory.arr.Size() > 0) {
				for (int i = 0; i < valInventory.arr.Size(); i++) {
					HXDD_JsonObject o = HXDD_JsonObject(valInventory.arr[i]);
					if (o) {
						String item		= FileJSON.GetString(o, "item");
						int quantity	= FileJSON.GetInt(o, "quantity");

						if (!item) {
							// skip
							continue;
						}

						PlayerSheetItemSlot slot = new("PlayerSheetItemSlot");
						slot.item = item;
						slot.quantity = max(1, quantity);
						self.initInventory.push(slot);
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
			self.GameType					= valGameType.MakeLower();
			self.ArmorType 					= GetEnumFromArmorType(valArmorType.MakeLower());
			self.PickupType					= valPickupType.MakeLower();
			self.ProgressionType 			= GetEnumFromProgressionType(valProgressionType.MakeLower());

			self.UseMaxHealthScaler 		= valUseMaxHealthScaler;
			self.HalveXPBeforeLevel4 		= valHalveXPBeforeLevel4;
			self.maxlevel 					= valMaxLevel;
			self.experienceModifier			= valXPModifier;

			self.UsesEventHandler			= valUsesEventHandler;

			self.soundLevelUp				= valSoundLevelUp;
			self.soundClass					= valSoundClass;
			self.defaultStatusBar			= valStatusBarClass;

			self.OnlyDropUnownedWeapons		= valOnlyDropUnownedWeapons;

			self.teleportfog				= valTeleportFog;

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
				PlayerSheetStat rt = new("PlayerSheetStat");
				rt.Init("_default").SetFromArray(valResourceTable).Roll();
				self.resources.insert("_default", rt);
			}
			if (valHexenArmorTable && valHexenArmorTable.Size() >= 5) {
				self.hexenArmorTable.Resize(5);
				for (let i = 0; i < 5; i++) {
					self.hexenArmorTable[i] 	= HXDD_JsonInt(valHexenArmorTable.arr[i]).i;
				}
			}
		}

		self.isLoaded = true;
    }

	//String GetPlayerClassName(PlayerPawn pp) {
	//	String playerClassName = pp.GetClassName();
	//	if (playerClassName.IndexOf("HXDD") != -1) {
	//		playerClassName = pp.GetParentClass().GetClassName();
	//	}
	//	return playerClassName.MakeLower();
	//}
}