class PlayerSlot play {
    int num;
    String baseClass;
    bool hasPlayerSheet;

	// Player Pickup Transforms
	XClassTranslation XClass;

	// Player Unique Data
	mixin PlayerSlotVariables;

	mixin PlayerSlotMain;
	mixin PlayerSlotShared;

	mixin PlayerSlotJSON;	// Reads and imports all JSON data for the class
	mixin PlayerSlotNode;
	mixin PlayerSlotLevel;
	mixin PlayerSlotArmor;

	PlayerInfo GetPlayer() {
		return players[self.num];
	}
}

mixin class PlayerSlotVariables {
	bool ArmorSelected;
	bool ProgressionSelected;
	bool CompatabilityScaleSelected;

	String PlayerClass;
	String Alignment;
	String GameType;
	String PickupType;
	int ArmorType;
	int ProgressionType;

	String ActiveArmorType;
	bool UseMaxHealthScaler;
	bool HalveXPBeforeLevel4;
	bool UsesEventHandler;
	bool OnlyDropUnownedWeapons;

	Array<double> skillmodifier;

	Array<int> experienceTable;
	Array<int> hitpointTable;
	//Array<int> resourceTable;
	Array<int> hexenArmorTable;
	bool hasHexenArmorTable;

	Array<PlayerSheetItemSlot> initInventory;

	String xp_bonus_stat;

	Map<String, PlayerSheetStat> resources;
	Map<String, PlayerSheetStat> stats;

	String soundLevelUp;

	String soundClass;
	Map<String, String> soundSet;

	String defaultStatusBar;

	// actor params
	String teleportfog;

	// Character Stats
	int currlevel;
	int maxlevel;
	double experience;			// uint may not be large enough given some megawads and mods
	double experienceModifier;
	int SpawnHealth;
	int MaxHealth;
}

mixin class PlayerSlotMain {
	void Init(int num) {
		self.num = num;
		if (!self.GetPlayer()) {
			console.printf("Player %d not found!", self.num);
			return;
		}

		self.ExperienceModifier = 1.0;
		self.currlevel = 0;
		self.Experience = 0;

		self.MaxHealth = self.GetPlayer().Health;

		LoadPlayerData();
		PostSheetSetup();
		if (!ProgressionSelected) {
			if (ProgressionAllowed()) {
				InitLevel_PostBeginPlay();
			}
			ProgressionSelected = true;
		}
		ArmorModeSelection();
		RescanAllActors();
	}

	bool ProgressionAllowed() {
		int optionProgression = LemonUtil.CVAR_GetInt("hxdd_progression", PSP_DEFAULT);
		if (optionProgression == PSP_DEFAULT) {
			optionProgression = self.ProgressionType;
		}
		return optionProgression == PSP_LEVELS || optionProgression == PSP_LEVELS_RANDOM || optionProgression == PSP_LEVELS_USER;
	}

	void LoadPlayerData() {
		String playerClassName = GetPlayerClassName();

		int cvarProgression = LemonUtil.CVAR_GetInt("hxdd_progression", PSP_DEFAULT);

		int cvarArmorType = PSAT_ARMOR_BASIC;
		let itemHexenArmor = HexenArmor(self.GetPlayer().mo.FindInventory("HexenArmor"));
		if (itemHexenArmor) {
			cvarArmorType = PSAT_ARMOR_HXAC;
		}

		self.LoadJSON(playerClassName);

		//self.XClass = PlayerSheet.XClass;

		if (self.ArmorType == PSAT_DEFAULT) {
			self.ArmorType = cvarArmorType == PSAT_DEFAULT ? PSAT_ARMOR_BASIC : cvarArmorType;
		}
		if (self.ProgressionType == PSAT_DEFAULT) {
			self.ProgressionType = cvarProgression == PSP_DEFAULT ? cvarProgression : cvarProgression;
		}
		self.Alignment = self.Alignment.MakeLower();

		//self.UseMaxHealthScaler = PlayerSheet.UseMaxHealthScaler;

		//if (PlayerSheet.hexenArmorTable.Size() == 5) {
		//	self.hexenArmorTable.Copy(PlayerSheet.hexenArmorTable);
		//}
		if (self.ProgressionType == PSP_DEFAULT) {
			self.ProgressionType = PSP_NONE;
			console.printf("Incorrect Class Progression Mode, PSP_DEFAULT or 0 should not be used! Using PSP_NONE as Default.");
		}

		if (cvarProgression == PSP_DEFAULT) {
			cvarProgression = self.ProgressionType;
		}

		for (int i = 0; i < self.initInventory.Size(); i++) {
			PlayerSheetItemSlot itemSlot = self.initInventory[i];
			self.GetPlayer().mo.GiveInventory(itemSlot.item, itemSlot.quantity);
		}

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

			//self.stats.Move(PlayerSheet.stats);

			self.maxlevel = 10 + (random[RNGLEVEL](0,4) * 5);
		}

		// After assignment, set final type
		self.ProgressionType = cvarProgression == PSP_NONE ? PSP_NONE : PSP_LEVELS;
	}

	void PostSheetSetup() {
		let player = self.GetPlayer().mo;
		if (self.soundClass) {
			player.SoundClass = self.soundClass;
		}
		if (self.teleportfog) {
			player.TeleFogSourceType = self.teleportfog;
			player.TeleFogDestType = self.teleportfog;
		}
	}

	PlayerSheetStat GetResource(String key) {
		return self.resources.GetIfExists(key);
	}

	PlayerSheetStat GetStat(String key) {
		return self.stats.GetIfExists(key);
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


}

