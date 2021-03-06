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

	String DefaultArmorMode;
	String DefaultProgression;

	// Gameplay Modes
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
		if (owner.player.mo is "HXDDPlayerPawn") {
			HXDDPlayerPawn hxddplayer = HXDDPlayerPawn(owner.player.mo);
			if (optionProgression == PSP_DEFAULT) {
				optionProgression = hxddplayer.DefaultProgression;
			}
		} else if (optionProgression == PSP_DEFAULT) {
			optionProgression = PSP_NONE;
		}
		return optionProgression == PSP_LEVELS || optionProgression == PSP_LEVELS_RANDOM || optionProgression == PSP_LEVELS_USER;
	}

	override void BeginPlay() {
		Super.BeginPlay();

		// Don't do anything here, the Progression Inventory item is not fully initialized until PostBeginPlay.
	}

	override void PostBeginPlay() {
		Super.PostBeginPlay();
		if (!ProgressionSelected) {
			if (ProgressionAllowed() ) {
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
		CompatabilityScale();
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
		if (owner.player.mo is "HXDDPlayerPawn") {
			HXDDPlayerPawn hxddplayer = HXDDPlayerPawn(owner.player.mo);
			if (optionArmorMode == PSAM_DEFAULT) {
				optionArmorMode = hxddplayer.DefaultArmorMode;
			}
		} else if (optionArmorMode == PSAM_DEFAULT) {
			optionArmorMode = PSAM_ARMOR_SIMPLE;
		}
		if (optionArmorMode == PSAM_ARMOR_SIMPLE) {
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
		} else if (optionArmorMode == PSAM_ARMOR_AC) {
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
						itemHexenArmor.SlotsIncrement[i] = 20;
					}
				}
			}
		} else if (optionArmorMode == PSAM_ARMOR_RANDOM) {
			// random armor values are applied
			let itemHexenArmor = HexenArmor(player.FindInventory("HexenArmor"));
			if (itemHexenArmor) {
				for (int i = 0; i < 5; i++) {
					itemHexenArmor.Slots[i] = 0;
				}
				itemHexenArmor.Slots[4] = random(5, 20);
				for (int i = 0; i < 4; i++) {
					itemHexenArmor.SlotsIncrement[i] = random(5, 30);
				}
			}
		} else if (optionArmorMode == PSAM_ARMOR_USER) {
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
		ArmorSelected = true;
	}

	void CompatabilityScale() {
		// Disabled until I can get it working
		/*
		if (CompatabilityScaleSelected) {
			return;
		}
		let player = PlayerPawn(owner.player.mo);
		if (player == NULL) {
			return;
		}
		int optionCompatScale = CVar.FindCVar("hxdd_player_scale").GetInt();

		if (player.Height == 56 && optionCompatScale == 2) {
			// Hexen Style
			player.Height = 64;
			player.Viewheight = 48;
			double s = 64.0 / 56.0;
			player.Scale.X = s;
			player.Scale.Y = s;
		} else if (player.Height == 64 && optionCompatScale == 1) {
			// Doom & Heretic Style
			player.Height = 56;
			player.Viewheight = 41;
			double s = 56.0 / 64.0;
			player.Scale.X = s;
			player.Scale.Y = s;
		}

		console.printf("Player Compat Scale %d", player.Height);
		console.printf("Player Height: %d", player.Viewheight);
		console.printf("Player Viewheight: %d", player.Scale.X);
		console.printf("Player Scale: %0.2f, 0.2f", player.Scale.Y);
		CompatabilityScaleSelected = true;
		*/
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
		} else if (owner.player.mo is "HXDDPlayerPawn") {
			// capture stats from hxddplayerpawn.
			HXDDPlayerPawn hxddplayer = HXDDPlayerPawn(owner.player.mo);

			experienceModifier =		hxddplayer.experienceModifier;
			for (let i = 0; i < 11; i++) {
				experienceTable[i] =	hxddplayer.experienceTable[i];
			}
			for (let i = 0; i < 5; i++) {
				hitpointTable[i] =		hxddplayer.hitpointTable[i];
				manaTable[i] =			hxddplayer.manaTable[i];
			}
			for (let i = 0; i < 2; i++) {
				strengthTable[i] =		hxddplayer.strengthTable[i];
				intelligenceTable[i] =	hxddplayer.intelligenceTable[i];
				wisdomTable[i] =		hxddplayer.wisdomTable[i];
				dexterityTable[i] =		hxddplayer.dexterityTable[i];
			}
		} else {
			// Placeholder Values
			experienceTable[0] = 800;
			for (let i = 1; i < 11; i++) {
				experienceTable[i] = experienceTable[i-1] * 2.0f;
			}

			hitpointTable[0] = 100;
			hitpointTable[1] = 100;
			hitpointTable[2] = 0;
			hitpointTable[3] = 5;
			hitpointTable[4] = 5;

			manaTable[0] = 100;
			manaTable[1] = 100;
			manaTable[2] = 5;
			manaTable[3] = 10;
			manaTable[4] = 5;

			strengthTable[0] = 10;
			strengthTable[1] = 10;

			intelligenceTable[0] = 10;
			intelligenceTable[1] = 10;

			wisdomTable[0] = 10;
			wisdomTable[1] = 10;

			dexterityTable[0] = 10;
			dexterityTable[1] = 10;
		}
	}

	void InitLevel_PostBeginPlay() {
		if (level != 0) {
			return;
		}
		
		bool cvarAllowBackpackUse = LemonUtil.CVAR_GetBool("hxdd_allow_backpack_use", false);

		let player = owner.player.mo;

		if (player is "HXDDPlayerPawn") {
			player = HXDDPlayerPawn(owner.player.mo);
		} else {
			player = PlayerPawn(owner.player.mo);
		}
		
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
				if (!(ammoType is "mana1") || !(ammoType is "mana2")) {
					double scaler = ammoItem.Default.MaxAmount / 200.0f;
					double scalerBackpack = scaler;
					if (ammoItem.Default.BackpackMaxAmount > ammoItem.Default.MaxAmount && ammoItem.Default.MaxAmount > 0) {
						scalerBackpack *= ammoItem.Default.BackpackMaxAmount / ammoItem.Default.MaxAmount;
					}
					ammoItem.MaxAmount = maxMana * scaler;
					if (cvarAllowBackpackUse) {
							ammoItem.BackpackMaxAmount = ammoItem.Default.BackpackMaxAmount * scalerBackpack;
						} else {
							ammoItem.BackpackMaxAmount = ammoItem.Default.BackpackMaxAmount * scaler;
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

		bool cvarAllowBackpackUse = CVar.FindCVar("hxdd_allow_backpack_use").GetBool();
		PlayerPawn player = PlayerPawn(owner.player.mo);

		S_StartSound("hexen2/misc/comm", CHAN_VOICE);

		while (level < advanceLevel && level < 20) {
			int lastLevel = level++;

			double healthInc = 0;
			double manaInc = 0;
			if (lastLevel < 11) {
				healthInc = stats_compute(hitpointTable[2],hitpointTable[3]);
				manaInc = stats_compute(manaTable[2],manaTable[3]);
			} else {
				healthInc = hitpointTable[4];
				manaInc = manaTable[4];
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
						double scaler = ammoItem.Default.MaxAmount / 200.0f;
						double scalerBackpack = scaler;
						if (ammoItem.Default.BackpackMaxAmount > ammoItem.Default.MaxAmount && ammoItem.Default.MaxAmount > 0) {
							scalerBackpack *= ammoItem.Default.BackpackMaxAmount / ammoItem.Default.MaxAmount;
						}
						ammoItem.MaxAmount = MaxMana * scaler;
						if (cvarAllowBackpackUse) {
							ammoItem.BackpackMaxAmount = ammoItem.Default.BackpackMaxAmount * scalerBackpack;
						} else {
							ammoItem.BackpackMaxAmount = ammoItem.Default.BackpackMaxAmount * scaler;
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
			double calcExp = target.Default.health * frandom[ExpRange](0.6, 0.7);
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
	virtual void OnExperienceBonus(double amount) {}
	virtual void OnKill(Actor target) {}
}