class PlayerSheet: Inventory {
	// Progression
	int DefaultArmorMode;
	int DefaultProgression;
	property DefaultArmorMode: DefaultArmorMode;
	property DefaultProgression: DefaultProgression;

	// Alignment (Used for some pickups)
	String Alignment;
	property Alignment: Alignment;

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

		PlayerSheet.ExperienceModifier 1.0;

		PlayerSheet.Level 0;
		PlayerSheet.Experience 0;
		
        PlayerSheet.MaxHealth 100;
		PlayerSheet.MaxMana 0;      // TODO: scale off of default if ammo type does not match
		PlayerSheet.Strength 0;
		PlayerSheet.Intelligence 0;
		PlayerSheet.Wisdom 0;
		PlayerSheet.Dexterity 0;
    }

	override void BeginPlay() {
		Super.BeginPlay();
		DefineAdvancementStatTables();
	}

    virtual void DefineAdvancementStatTables() {}
	virtual void OnExperienceBonus(double experience) {}
	virtual void OnKill(PlayerPawn player, Actor target, double experience) {}
}