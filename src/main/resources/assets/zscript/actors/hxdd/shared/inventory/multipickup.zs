
// Prototype world pickup to support more than one item type in a multiplayer environment
// Best when used with items that have Inventory.ForbiddenTo and Inventory.RestrictedTo set.
class MultiPickup: Inventory {
    Array<Inventory> ammo;
	Array<String> pickups;
    Array<Actor> pickupActors;

    int selection;
	bool useOnce;
	bool hasCollected;
	bool hasSecret;

    String Fallback;
    String DoomMarine;
    String Corvus;
    String Fighter;
    String Cleric;
    String Mage;
    String Paladin;
    String Crusader;
    String Assassin;
    String Necromancer;
    String Succubus;

    property Doom: Doom;
    property Heretic: Heretic;
    property Hexen: Hexen;
    property Fallback: Fallback;
    property DoomMarine: DoomMarine;
    property Corvus: Corvus;
    property Fighter: Fighter;
    property Cleric: Cleric;
    property Mage: Mage;
    property Paladin: Paladin;
    property Crusader: Crusader;
    property Assassin: Assassin;
    property Necromancer: Necromancer;
    property Succubus: Succubus;
    property useOnce: UseOnce;

    Default {
        Inventory.PickupMessage "";
		Inventory.MaxAmount 1;
		Height 0;
    }

    States {
        Spawn:
            TNT1 A -1;
            Loop;
    }

	virtual void Bind() {
        self.Doom = "Unknown";
        self.Heretic = "Unknown";
        self.Hexen = "Unknown";

        self.Fallback = "Unknown";
        self.DoomMarine = "Unknown";
        self.Corvus = "Unknown";
        self.Fighter = "Unknown";
        self.Cleric = "Unknown";
        self.Mage = "Unknown";
        self.Paladin = "Unknown";
        self.Crusader = "Unknown";
        self.Assassin = "Unknown";
        self.Necromancer = "Unknown";
        self.Succubus = "Unknown";
	}

	void CreatePickupActor(String strActorClass) {
		if (strActorClass ~== "Unknown" || strActorClass ~== "none" || strActorClass ~== "") {
			return;
		}
		for (int i = 0; i < pickupActors.Size(); i++) {
			if (pickupActors[i] is strActorClass) {
				//console.printf("MultiPickup: %s already exists in list, skipping", strActorClass);
				return;
			}
		}
		Actor pickupActor = Spawn(strActorClass, self.pos);
		if (!pickupActor) {
			console.printf("MultiPickup: Failed to spawn %s!", strActorClass);
			return;
		}
		if (pickupActor.bCountItem && !self.bCountItem) {
			self.bCountItem = true;
		}
		if (pickupActor.bCountSecret && !self.bCountSecret) {
			self.bCountSecret = true;
		}
		pickupActor.bNoInteraction = true;
		pickupActor.bNoGravity = false;
		pickupActor.bCountItem = false;
		pickupActor.bNotOnAutomap = true;
		pickupActors.push(pickupActor);
	}

	int, Inventory GetPickupActorByRestrictedClass(Actor toucher) {
		for (int i = 0; i < pickupActors.Size(); i++) {
			Inventory pickup = Inventory(pickupActors[i]);
			for (int j = 0; j < pickup.RestrictedToPlayerClass.Size(); j++) {
				if (toucher is pickup.RestrictedToPlayerClass[j]) {
					return i, pickup;
				}
			}
		}
		return -1, null;
	}

    override void PostBeginPlay() {
        Super.PostBeginPlay();

		Bind();
		//CreatePickupActor(self.Fallback);
		CreatePickupActor(self.DoomMarine);
		CreatePickupActor(self.Corvus);
		CreatePickupActor(self.Fighter);
		CreatePickupActor(self.Cleric);
		CreatePickupActor(self.Mage);
		CreatePickupActor(self.Paladin);
		CreatePickupActor(self.Crusader);
		CreatePickupActor(self.Assassin);
		CreatePickupActor(self.Succubus);

        for (int i = 0; i < pickups.size(); i++) {
			Actor newPickupActor = Spawn(pickups[i], self.pos);
            newPickupActor.bNoInteraction = true;
            newPickupActor.bCountItem = false;
        	pickupActors.push(newPickupActor);;
        }
    }

    override void Tick() {
        Super.Tick();

        for (int i = 0; i < pickupActors.size(); i++) {
			pickupActors[i].SetOrigin(self.pos, true);
        }
    }
    
    override void Touch (Actor toucher) {
		let player = toucher.player;

		// If a voodoo doll touches something, pretend the real player touched it instead.
		if (player != NULL) {
			toucher = player.mo;
		}

		bool localview = toucher.CheckLocalView();

		Inventory nItem;
		int index;
		[index, nItem] = GetPickupActorByRestrictedClass(toucher);
		if (!nItem) {
			return;
		}

		if (!toucher.CanTouchItem(nItem))
			return;

		bool res;
		[res, toucher] = nItem.CallTryPickup(toucher);
		if (!res) return;
		// Item is used, can be removed safely
		console.printf("MultiPickup: Item Class = %s", nItem.GetClassName());
		pickupActors.Delete(index);

		// If entire pickup is used once, remove others
		if (self.useOnce) {
			for (int i = 0; i < pickupActors.size(); i++) {
				pickupActors[i].Destroy();
			}
		}

		// This is the only situation when a pickup flash should ever play.
		if (nItem.PickupFlash != NULL && !nItem.ShouldStay()) {
			Spawn(PickupFlash, Pos, ALLOW_REPLACE);
		}

		if (!nItem.bQuiet) {
			nItem.PrintPickupMessage(localview, nItem.PickupMessage());

			// Special check so voodoo dolls picking up items cause the
			// real player to make noise.
			if (player != NULL) {
				nItem.PlayPickupSound (player.mo);
				if (!nItem.bNoScreenFlash && player.playerstate != PST_DEAD) {
					player.bonuscount = BONUSADD;
				}
			} else {
				nItem.PlayPickupSound (toucher);
			}
		}							

		// [RH] Execute an attached special (if any)
		nItem.DoPickupSpecial (toucher);

		// only count once if can be collected
		if (self.bCountItem && !self.hasCollected) {
			if (player != NULL) {
				player.itemcount++;
			}
			level.found_items++;
			self.hasCollected = true;
		}

		if (nItem.bCountSecret && !self.hasSecret) {
			Actor ac = player != NULL? Actor(player.mo) : toucher;
			ac.GiveSecret(true, true);
			self.hasSecret = true;
		}

		//Added by MC: Check if item taken was the roam destination of any bot
		for (int i = 0; i < MAXPLAYERS; i++) {
			if (players[i].Bot != NULL && nItem == players[i].Bot.dest)
				players[i].Bot.dest = NULL;
		}
	}
}