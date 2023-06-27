
// Prototype world pickup to support more than one item type in a multiplayer environment
// Best when used with items that have Inventory.ForbiddenTo and Inventory.RestrictedTo set.
enum EMultiPickupState {
	MPS_NOTREADY = 0,
	MPS_PENDING = 1,
	MPS_READY = 2,
	MPS_FINISHED = 3
};

class MultiPickup: Inventory {
    Array<Inventory> ammo;
	Array<String> pickups;
    Array<Actor> pickupActors;

	bool single_mode;
    EMultiPickupState readyState;

    int selection;
	bool useOnce;
	bool hasCollected;
	bool hasSecret;

	String SpawnSelect;
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

    property SpawnSelect: SpawnSelect;
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

	override void BeginPlay() {

        PlayerInfo p = players[0];
        if (p.cls != null) {
            Super.BeginPlay();

			self.single_mode = LemonUtil.CVAR_GetInt("hxdd_multipickup_singlemode", false);
			Bind();

            self.readyState = MPS_READY;
        } else {
            self.readyState = MPS_PENDING;
        }
	}

    override void PostBeginPlay() {
		if (self.readyState == MPS_NOTREADY) {
			return;
		}

        PlayerInfo p = players[0];
        if (self.single_mode && p.cls != null) {
            Super.PostBeginPlay();
			SingleSpawnSelector();
			
        } else {
            Super.PostBeginPlay();

			CreatePickupActor(self.Fallback);
			CreatePickupActor(self.DoomMarine);
			CreatePickupActor(self.Corvus);
			CreatePickupActor(self.Fighter);
			CreatePickupActor(self.Cleric);
			CreatePickupActor(self.Mage);
			CreatePickupActor(self.Paladin);
			CreatePickupActor(self.Crusader);
			CreatePickupActor(self.Assassin);
			CreatePickupActor(self.Succubus);
		}

		for (int i = 0; i < pickups.size(); i++) {
			Actor newPickupActor = Spawn(pickups[i], self.pos);
			newPickupActor.bNoInteraction = true;
			newPickupActor.bCountItem = false;
			pickupActors.push(newPickupActor);;
		}
    }

    override void Tick() {
        Super.Tick();
        if (self.readyState == MPS_PENDING) {
            BeginPlay();
            PostBeginPlay();
			self.readyState = MPS_READY;
        }
        for (int i = 0; i < pickupActors.size(); i++) {
			pickupActors[i].SetOrigin(self.pos, true);
        }
    }

	virtual void Bind() {
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
		console.printf("MultiPickup: Class %s", strActorClass);
		if (strActorClass ~== "Unknown" || strActorClass ~== "none" || strActorClass ~== "") {
			return;
		}
		for (int i = 0; i < pickupActors.Size(); i++) {
			if (pickupActors[i] is strActorClass) {
				console.printf("MultiPickup: %s already exists in list, skipping", strActorClass);
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

    override void Touch(Actor toucher) {
		let player = toucher.player;

		// If a voodoo doll touches something, pretend the real player touched it instead.
		if (player != NULL) {
			toucher = player.mo;
		}

		bool localview = toucher.CheckLocalView();

		Inventory nItem;
		int index;
		if (self.single_mode) {
			nItem =  Inventory(pickupActors[0]);
		} else {
			[index, nItem] = GetPickupActorByRestrictedClass(toucher);
		}
		if (!nItem) {
			return;
		}

		if (!toucher.CanTouchItem(nItem))
			return;

		bool res;
		[res, toucher] = nItem.CallTryPickup(toucher);
		if (!res) return;

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
		
		// Item is used, can be removed safely
		console.printf("MultiPickup: Item Class = %s", nItem.GetClassName());
		pickupActors.Delete(index);

		// If entire pickup is used once, remove others
		if (self.useOnce) {
			for (int i = 0; i < pickupActors.size(); i++) {
				pickupActors[i].Destroy();
			}
		}
	}

    void SingleSpawnSelector() {
		PlayerInfo p = players[0];
		String playerClass = p.mo.GetPrintableDisplayName(p.cls);

		String spawn = "Unknown";
		if (playerClass ~== "marine") {
			spawn = self.DoomMarine;
		} else if (playerClass ~== "corvus") {
			spawn = self.Corvus;
		} else if (playerClass ~== "fighter") {
			spawn = self.Fighter;
		} else if (playerClass ~== "cleric") {
			spawn = self.Cleric;
		} else if (playerClass ~== "mage") {
			spawn = self.Mage;
		} else if (playerClass ~== "paladin") {
			spawn = self.Paladin;
		} else if (playerClass ~== "crusader") {
			spawn = self.Crusader;
		} else if (playerClass ~== "assassin") {
			spawn = self.Assassin;
		} else if (playerClass ~== "necromancer") {
			spawn = self.Necromancer;
		} else if (playerClass ~== "demoness") {
			spawn = self.Succubus;
		}
		if (spawn == "Unknown") {
			// Spawn Fallback Item, should make things less weird with mods like Walpurgis
			spawn = self.Fallback;
		}
		CreatePickupActor(spawn);
	}
}