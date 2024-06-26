// Single and Multiplayer pickup node

// Needs RestrictedToPlayerClass-like as a HiddenToPlayerNumber where it is not rendered or interactable to that class

class HXDDPickupNodeSlot {
    String className;
    bool bPickedUp;
    Inventory pickup;
}

class HXDDPickupNode : Inventory {
    Class<Actor> parent;
    String parentClass;
    bool isMapSpawn;                // Items which spawn at maptime 0
    bool isDropped;                 // Any pickup handles all, dropped items
    bool isPending;                // Exists in original state, waiting for swap call

    Default {
    }
	States {
        Spawn:
            TNT1 A -1;
            Stop;
	}

    // per player pickups
    Map<int, HXDDPickupNodeSlot> slots;

    override void BeginPlay() {
        self.BecomePickup();
    }

    override void Tick() {
        Super.Tick();

        foreach ( slot : self.slots ) {
            if (slot && slot.pickup && self.pos != slot.pickup.pos) {
                slot.pickup.SetOrigin(self.pos, true);
            }
        }
    }

    override void Touch(Actor toucher) {
        if (toucher is "PlayerPawn") {
            PlayerPawn pp = PlayerPawn(toucher);
            int playerNumber = self.isPending ? -1 : pp.PlayerNumber();

            HXDDPickupNodeSlot slot;
            bool hasSlot = false;
            [slot, hasSlot] = self.slots.CheckValue(playerNumber);
            if (hasSlot && slot.pickup) {
                if (self.ProxyTouch(slot.pickup, toucher)) {
                    self.slots.Remove(playerNumber);

                    if (self.isDropped && !sv_localitems) {
                        foreach( slot : self.slots ) {
                            slot.pickup.Destroy();
                        }
                    }
                }
            }
            if ((!self.isMapSpawn && self.slots.CountUsed() == 0) || (self.parent is "Key" && !sv_coopsharekeys)) {
                self.GoAwayAndDie();
            }
        }
    }

    // Modified from: https://github.com/ZDoom/gzdoom/blob/ddbf90389b34c926aee11dea92f8cf0787198f74/wadsrc/static/zscript/actors/inventory/inventory.zs#L822
    // Lets the touch event act as a proxy for PickupNode slotted inventory actors and return its state if the pickup was good
    bool ProxyTouch(Inventory source, Actor toucher) {
		bool localPickUp;
		let player = toucher.player;
		if (player) {
			// If a voodoo doll touches something, pretend the real player touched it instead.
			toucher = player.mo;
			// Client already picked this up, so ignore them.
			if (source.HasPickedUpLocally(toucher)) {
				return false;
            }

			localPickUp = source.CanPickUpLocally(toucher) && !source.ShouldStay() && !source.ShouldRespawn();
		}

		bool localview = toucher.CheckLocalView();

		if (!toucher.CanTouchItem(source)) {
			return false;
        }

		Inventory give = source;
		if (localPickUp) {
			give = source.CreateLocalCopy(toucher);
			if (!give) {
				return false;
            }

			localPickUp = give != source;
		}

		bool res;
		[res, toucher] = give.CallTryPickup(toucher);
		if (!res) {
			if (give != source) {
				give.Destroy();
            }

			return false;
		}

		// This is the only situation when a pickup flash should ever play.
		if (source.PickupFlash != NULL && !source.ShouldStay()) {
			source.Spawn(source.PickupFlash, source.Pos, ALLOW_REPLACE);
		}

		if (!source.bQuiet) {
			source.PrintPickupMessage(localview, give.PickupMessage ());

			// Special check so voodoo dolls picking up items cause the
			// real player to make noise.
			if (player != NULL) {
				give.PlayPickupSound (player.mo);
				if (!source.bNoScreenFlash && player.playerstate != PST_DEAD) {
					player.bonuscount = BONUSADD;
				}
			} else {
				give.PlayPickupSound (toucher);
			}
		}

		// [RH] Execute an attached special (if any)
		source.DoPickupSpecial (toucher);

		if (source.bCountItem) {
			if (player != NULL) {
				player.itemcount++;
			}
			level.found_items++;
		}

        // TODO: make local
		if (self.bCountSecret) {
			Actor ac = player != NULL? Actor(player.mo) : toucher;
			ac.GiveSecret(true, true);
		}

		if (localPickUp) {
			PickUpLocally(toucher);
        }

		//Added by MC: Check if item taken was the roam destination of any bot
		for (int i = 0; i < MAXPLAYERS; i++) {
			if (players[i].Bot != NULL && source == players[i].Bot.dest) {
				players[i].Bot.dest = NULL;
            }
		}

        return true;
	}

    HXDDPickupNode Setup(Inventory original) {
        self.parent = original.GetClass();
        self.parentClass = original.GetClassName();

        // becomes proxy
        self.bCountSecret = original.bCountSecret;

        if (self.slots.CountUsed() == 0) {
            original.angle = self.angle;
            original.vel = self.vel;
            original.target = self;
            original.A_ChangeLinkFlags(1, FLAG_NO_CHANGE);

            HXDDPickupNodeSlot slot = new("HXDDPickupNodeSlot");
            slot.className = self.parentClass;
            slot.pickup = original;
            slot.bPickedUp = false;
            self.slots.Insert(-1, slot);
        }

        self.isPending = true;

        return self;
    }

    HXDDPickupNode SwapOriginal() {
        HXDDPickupNodeSlot slot;
        bool hasSlot = false;
        [slot, hasSlot] = self.slots.CheckValue(-1);
        if (self.isPending && hasSlot) {
            if (hasSlot) {
                slot.pickup.Destroy();
                self.slots.Remove(-1);
            }
            self.isPending = false;
        }


        return self;
    }

    // Called when a player enters or a new spawn occurs
    void AssignPickup(int index, String itemClass, String pickupSound = "") {
        if (!itemClass || itemClass == "none" || itemClass == "") {
            return;
        }
        Inventory newPickup = Inventory(Spawn(itemClass, self.pos));
        if (newPickup) {
            newPickup.angle = self.angle;
            newPickup.vel = self.vel;
            newPickup.target = self;
            newPickup.A_ChangeLinkFlags(1, FLAG_NO_CHANGE);
            if (pickupSound != "") {
                newPickup.PickupSound = pickupSound;
            }
            for (int i = 0; i < players.Size(); i++) {
                if (i != index) {
                    newPickup.DisableLocalRendering(i, true);
                }
            }

            HXDDPickupNodeSlot slot = new("HXDDPickupNodeSlot");
            slot.className = itemClass;
            slot.pickup = newPickup;
            slot.bPickedUp = false;
            self.slots.Insert(index, slot);
        }
    }

    // Should only be called when a player leaves
    void RemovePickup(int index) {
        bool hasSlot = self.slots.CheckKey(index);
        if (hasSlot) {
            HXDDPickupNodeSlot slot = self.slots.Get(index);
            if (slot) {
                slot.pickup.Destroy();
                self.slots.Remove(index);
            }
        }
    }

    Class<Actor> GetParentClass() {
        return self.parent;
    }

    String GetParentClassName() {
        return self.parentClass;
    }

    void SetPermanant() {
        self.isMapSpawn = true;
    }

    void SetDropped() {
        self.isDropped = true;
    }
}