
// Not a real ammo type, but gives the player said ammo type
// Should be coop friendly
Class MultiClassAmmo: Ammo {
    Array<Inventory> ammo;
    Array<Actor> mockActors;
    bool lastIsVisible;
    
    String message;

    Default {
        Inventory.PickupMessage "";
		Inventory.MaxAmount 1;
    }

    States {
        Spawn:
            TNT1 A -1;
            Loop;
        //Pickup:
        //    TNT1 A -1;
        //    Stop;
    }

    override void PostBeginPlay() {
        Super.PostBeginPlay();

        
        ammo.push(Inventory(Spawn("Mana1")));
        ammo.push(Inventory(Spawn("CrossbowAmmo")));

        mockActors.push(Spawn("CrossbowAmmo_VTPC"));
        mockActors.push(Spawn("Mana1_VTPC"));

        for (int i = 0; i < mockActors.size(); i++) {
            MockActor(mockActors[i]).Attach(self);
        }
    }

    Inventory GetInventoryActor() {
        int item = 0;
        if (Owner is "CrusaderPlayer") {
            item = 0;
            self.message = "$TXT_MANA_1";
        } else if (Owner is "HereticPlayer") {
            item = 1;
            self.message = "$TXT_AMMOCROSSBOW1";
        }
        return ammo[item];
    }

	override String PickupMessage() {
        return self.message;
	}

	//===========================================================================
	//
	// AAmmo :: HandlePickup
	//
	//===========================================================================

	override bool HandlePickup (Inventory item) {
		let sourceAmmo = Ammo(self.GetInventoryActor());
		let ammoItem = Ammo(Owner.player.mo.FindInventory(sourceAmmo.GetClass()));
        if (ammoItem == null) {
            console.printf("Ammo null");
        }
		if (ammoItem != null) {
            console.printf("Ammo? %s %d %d", ammoItem.GetClassName(), ammoItem.Amount, ammoItem.MaxAmount);
			if (ammoItem.Amount < ammoItem.MaxAmount || sv_unlimited_pickup) {
				int receiving = ammoItem.Amount;

				if (!ammoItem.bIgnoreSkill)
				{ // extra ammo in baby mode and nightmare mode
					receiving = int(receiving * G_SkillPropertyFloat(SKILLP_AmmoFactor));
				}
				int oldamount = ammoItem.Amount;

				if (ammoItem.Amount > 0 && ammoItem.Amount + receiving < 0)
				{
					ammoItem.Amount = 0x7fffffff;
				}
				else
				{
					ammoItem.Amount += receiving;
				}
				if (ammoItem.Amount > ammoItem.MaxAmount && !sv_unlimited_pickup)
				{
					ammoItem.Amount = ammoItem.MaxAmount;
				}
				self.bPickupGood = true;

				// If the player previously had this ammo but ran out, possibly switch
				// to a weapon that uses it, but only if the player doesn't already
				// have a weapon pending.

				if (oldamount == 0 && Owner != null && Owner.player != null)
				{
					PlayerPawn(Owner).CheckWeaponSwitch(ammoItem.GetClass());
				}
			}
			return true;
		}
		return false;
	}

	//===========================================================================
	//
	// AAmmo :: CreateCopy
	//
	//===========================================================================

	override Inventory CreateCopy (Actor other) {
            console.printf("CC");
		let sourceAmmo = Ammo(self.GetInventoryActor());
		let type = sourceAmmo;
        if (Owner != null) {
            type = Ammo(Owner.player.mo.FindInventory(sourceAmmo.GetClass()));
        }

		Inventory copy;
		int amount = sourceAmmo.Amount;

		// extra ammo in baby mode and nightmare mode
		if (!bIgnoreSkill)
		{
			amount = int(amount * G_SkillPropertyFloat(SKILLP_AmmoFactor));
		}

		if (type != null) {
			if (!GoAway ())
			{
				Destroy ();
			}

			copy = Inventory(type);
			copy.Amount = amount;
			copy.BecomeItem ();
		}
		else
		{
			copy = Super.CreateCopy (type);
			copy.Amount = amount;
		}
		if (copy.Amount > copy.MaxAmount)
		{ // Don't pick up more ammo than you're supposed to be able to carry.
			copy.Amount = copy.MaxAmount;
		}
		return copy;
	}
	
	override void ModifyDropAmount(int dropamount) {
            console.printf("ModifyDropAmount");
		let item = self.GetInventoryActor();

		bool ignoreskill = true;
		double dropammofactor = G_SkillPropertyFloat(SKILLP_DropAmmoFactor);
		// Default drop amount is half of regular amount * regular ammo multiplication
		if (dropammofactor == -1) 
		{
			dropammofactor = 0.5;
			ignoreskill = false;
		}

		if (dropamount > 0)
		{
			if (ignoreskill)
			{
				item.Amount = int(dropamount * dropammofactor);
				bIgnoreSkill = true;
			}
			else
			{
				item.Amount = dropamount;
			}
		}
		else
		{
			// Half ammo when dropped by bad guys.
			int amount = self.DropAmount;
			if (amount <= 0)
			{
				amount = MAX(1, int(item.Amount * dropammofactor));
			}
			item.Amount = amount;
			bIgnoreSkill = ignoreskill;
		}
	}

    /*
	override Class<Ammo> GetParentAmmo () {
		class<Object> type = GetClass();

		while (type.GetParentClass() != "Ammo" && type.GetParentClass() != NULL)
		{
			type = type.GetParentClass();
		}
		return (class<Ammo>)(type);
	}

	override bool HandlePickup(Inventory item) {
        int item = 0;
        if (Owner is "CrusaderPlayer") {
            item = 0;
            self.message = "$TXT_MANA_1";
        } else if (Owner is "HereticPlayer") {
            item = 1;
            self.message = "$TXT_AMMOCROSSBOW1";
        }
        return Super.HandlePickup(ammo[item]);
    }

    override bool TryPickup(in out Actor toucher) {
		if (Super.TryPickup(toucher)) {
            String item = "CrossbowAmmo";
            self.message = "$TXT_AMMOCROSSBOW1";
            if (toucher is "CrusaderPlayer") {
                item = "Mana1";
                self.message = "$TXT_MANA_1";
            } else if (toucher is "HereticPlayer") {
                item = "CrossbowAmmo";
                self.message = "$TXT_AMMOCROSSBOW1";
            }
            toucher.GiveInventoryType(item);
            
            return true;
        }
        return false;
	}
    */

    override void Tick() {
        Super.Tick();
        bool vis = self.IsVisible();
        if (self.lastIsVisible != vis) {
            self.lastIsVisible = vis;

            for (int i = 0; i < mockActors.size(); i++) {
                State nextState = mockActors[i].FindState("Held");
                if (self.lastIsVisible) {
                    nextState = mockActors[i].FindState("Spawn");
                }
                mockActors[i].SetState(nextState);
            }
        }
        
    }

    bool IsVisible() {
        State statesVisibility[4] = {
            FindState("Held"),
            FindState("HideSpecial"),
            FindState("HideDoomish"),
            FindState("HoldAndDestroy")
        };

        for (int i = 0; i < 4; i++) {
            if (InStateSequence(CurState, statesVisibility[i])) {
                return false;
            }
        }
        return true;
    }
}


Class CrossbowAmmo_VTPC: MockActor {
	Default {
        VisibleToPlayerClass "HereticPlayer";
	}
	States {
        Spawn:
            AMC1 A -1;
            Stop;
	}
}

Class Mana1_VTPC: MockActor {
	Default {
        +FLOATBOB;

        VisibleToPlayerClass "CrusaderPlayer";
	}
	States {
        Spawn:
            MAN1 ABCDEFGHI 4 Bright;
            Loop;
	}
}

class MockActor: Actor {
	Default {
		//+NOBLOCKMAP;
		+NOINTERACTION;
		//+NOCLIP;
	}

    void Attach(Actor owner) {
        self.target = owner;
        self.SetOrigin(self.target.pos, false);
    }

    override void Tick() {
        Super.Tick();

        if (!self.target) {
            self.Destroy();
            return;
        }

        self.SetOrigin(self.target.pos, true);
    }
}