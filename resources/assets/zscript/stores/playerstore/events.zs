mixin class HXDDPlayerStoreEvents {
	override void PlayerEntered (PlayerEvent e) {
		int num = e.PlayerNumber;
		if (self.slots.Size() == 0 || !self.slots[num]) {
			PlayerSlot slot = PlayerSlot(new("PlayerSlot"));
			slot.Init(num);
			self.slots.Insert(num, slot);
		}

		PlayerPawn pp = players[num].mo;
		if (pp) {
			ThinkerIterator it = ThinkerIterator.Create("HXDDPickupNode");
			HXDDPickupNode node;
			while (node = HXDDPickupNode(it.Next())) {
				if (node) {
					NodeUpdate(node, pp);
				}
			}
		}

		PlayerSlot pSlot = HXDDPlayerStore.GetPlayerSlot(num);
		if (pSlot) {
			PlayerPawn pp = PlayerPawn(players[num].mo);
			GameModeCompat gmcompat = GameModeCompat(pp.FindInventory("GameModeCompat"));
			if (!gmcompat) {
				pp.GiveInventory("GameModeCompat", 1);
				gmcompat = GameModeCompat(pp.FindInventory("GameModeCompat"));
				gmcompat.Init();
			}
		}
	}

	override void PlayerDisconnected(PlayerEvent e) {
		// remove slots in nodes
		int num = e.PlayerNumber;
		ThinkerIterator it = ThinkerIterator.Create("HXDDPickupNode");
		HXDDPickupNode node;
		while (node = HXDDPickupNode(it.Next())) {
			if (node) {
				node.RemovePickup(num);
			}
		}
	}

	// KNOWN ISSUE: Items can be picked up as the original at spawn (1 tic)
	// Currently limited due to WorldThingSpawned being triggered via PostBeginPlay
	// Would need a World Event for BeginPlay to prevent cases where an item can be picked up right as it spawns
	override void WorldThingSpawned(WorldEvent e) {
		// Pickup Nodes
		Actor original = e.thing;
		if (original is "Inventory" && !(original is "Key") && !(original is "HXDDPickupNode") && !(Inventory(original).owner) && !(Inventory(original).target is "HXDDPickupNode")) {
			// Fixes combined mana dropping things at 0,0,0 before PickupNode catches it
			if (Inventory(original).bDropped && original.pos == (0,0,0) && original.vel == (0,0,0)) {
				return;
			}

			// Ignore spawned ammo at map start, used with HX2 Leveling
			if (level.MapTime == 0 && Inventory(original).UseSound == "TAG_HXDD_IGNORE_SPAWN") {
				return;
			}

			HXDDPickupNode node = HXDDPickupNode(original.Spawn("HXDDPickupNode", original.pos));
			node.Setup(Inventory(original));

			if (node) {
				for (int i = 0; i < players.Size(); i++) {
					PlayerPawn pp = players[i].mo;
					NodeUpdate(node, pp);
				}
			}
		}
	}

	override void WorldThingDied(WorldEvent e) {
		if (e.thing && e.thing.bIsMonster && e.thing.bCountKill && e.thing.target && e.thing.target.player) {
			if (e.thing.target.player.mo is "PlayerPawn") {
				PlayerPawn pt = PlayerPawn(e.thing.target.player.mo);
				int targetNum = pt.PlayerNumber();
				PlayerSlot pSlot = HXDDPlayerStore.GetPlayerSlot(targetNum);
				if (pSlot) {
					double exp = pSlot.AwardExperience(e.thing, false);

					for (int i = 0; i < players.Size(); i++) {
						PlayerPawn pp = players[i].mo;
						if (pp) {
							if (targetNum != pp.PlayerNumber()) {
								PlayerSlot poSlot = HXDDPlayerStore.GetPlayerSlot(i);
								if (poSlot) {
									poSlot.AwardExperience(e.thing, true);
								}
							}
						}
					}
					
					HXDDSkillBase skill = HXDDSkillBase(pt.FindInventory("HXDDSkillBase", true));
					if (skill) {
						skill.OnKill(pt, e.thing, exp);
					}
				}
			}
		}
	}
}