class HXDDHereticPlayer : HereticPlayer
{
	Default
	{
		// Better compatability in Hexen Maps
		// Keeping with staff based weapons, maybe
		Player.SpawnClass "Corvus";
		Player.HealRadiusType "Health";
		Player.Hexenarmor 10, 20, 5, 5, 25;	// total 65, between mage and cleric
		Player.Portrait "P_HWALK1";
		Player.WeaponSlot 1, "Staff", "Gauntlets";
		Player.WeaponSlot 2, "GoldWand";
		Player.WeaponSlot 3, "Crossbow", "CWeapStaff";
		Player.WeaponSlot 4, "Blaster";
		Player.WeaponSlot 5, "SkullRod", "MWeapLightning";	// for now
		Player.WeaponSlot 6, "PhoenixRod";
		Player.WeaponSlot 7, "Mace", "MWeapBloodscourge";
		Player.FlechetteType "ArtiPoisonBag2";
	}
}

