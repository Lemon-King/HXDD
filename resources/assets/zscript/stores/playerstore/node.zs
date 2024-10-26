mixin class PlayerSlotNode {
	void NodeUpdate(HXDDPickupNode node, PlayerPawn pp) {
		if (!pp) {
			return;
		}
		bool isMapSpawn = level.MapTime == 0;
		int num = pp.PlayerNumber();
		PlayerSlot pSlot = HXDDPlayerStore.GetPlayerSlot(num);
		if (pSlot) {
			bool onlyDropUnownedWeapons = pSlot.OnlyDropUnownedWeapons;

			if (pSlot.XClass) {							
				let swapped = pSlot.XClass.TryXClass(num, node.parentClass);

				if (node.parent is "Weapon" && onlyDropUnownedWeapons && !isMapSpawn) {
					class<Weapon> clsWeapon;
					let weap = Weapon(pp.FindInventory(swapped));
					if (weap) {
						clsWeapon = weap.GetClass();
					}
					if (clsWeapon) {
						if (pp.CountInv(swapped) > 0) {
							let ammo1 = GetDefaultByType(clsWeapon).AmmoType1;
							let ammo2 = GetDefaultByType(clsWeapon).AmmoType2;
							String clsAmmo1;
							if (ammo1) {
								clsAmmo1 = GetDefaultByType(ammo1).GetClassName();
								clsAmmo1 = pSlot.XClass.TryXClass(num, clsAmmo1);
							}
							String clsAmmo2;
							if (ammo2) {
								clsAmmo2 = GetDefaultByType(ammo2).GetClassName();
								clsAmmo2 = pSlot.XClass.TryXClass(num, clsAmmo2);
							}

							if (ammo1 && ammo2) {
								int select = random[rngWeapDrop](0,1);
								if (select == 0) {
									swapped = clsAmmo1;
								} else if (select == 1) {
									swapped = clsAmmo2;
								}
							} else if (ammo1) {
								swapped = clsAmmo1;
							} else if (ammo2) {
								swapped = clsAmmo2;
							}
						}
					}
				}

				Class<Inventory> clsSwapped = swapped;
				String sfxPickup = "";
				String sfxUse = "";
				if (swapped != "none" && swapped != "") {
					sfxPickup = GetDefaultByType(clsSwapped).PickupSound;
					sfxPickup = pSlot.FindSoundReplacement(sfxPickup);
					sfxUse = GetDefaultByType(clsSwapped).UseSound;
					sfxUse = pSlot.FindSoundReplacement(sfxUse);
				}
				node.SwapOriginal().AssignPickup(num, swapped);
				node.SetPickupSound(num, sfxPickup).SetUseSound(num, sfxUse);

				if (!isMapSpawn) {
					node.SetDropped();
				}
			} else {
				node.AssignPickup(num, node.parentClass);

				if (!isMapSpawn) {
					node.SetDropped();
				}
			}
		}
	}
}