
// In Hexen II this item can give a damage multiplier: damage += super_damage * damage
// Its mostly unused with each use case setting super_damage to 1 and just doubles player damage in latest releases
// For completeness we'll set the multiplier at spawn time and handle it elsewhere.
class PowerHolyStrength: Powerup {
    int super_damage;
	Default {
		Powerup.Duration -30;   // time from pickup added to duration
		Powerup.Strength 1;
	}

    override void PostBeginPlay() {
        Super.PostBeginPlay();
    }
}