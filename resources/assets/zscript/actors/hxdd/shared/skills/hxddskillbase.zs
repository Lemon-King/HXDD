class HXDDSkillBase: Inventory {
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
	
    virtual void OnLevelGain(int level) {}
	virtual void OnExperienceBonus(double experience) {}
	virtual void OnKill(PlayerPawn player, Actor target, double experience) {}
}