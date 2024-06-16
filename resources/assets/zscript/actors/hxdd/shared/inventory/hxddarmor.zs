
// REF: 
// HX2 Armor Calc: https://github.com/videogamepreservation/hexen2/blob/master/H2MP/hcode/damage.hc#L661


class HXDDArmorSlot {
    String name;
	String type;
    int current;
    int saveAmount;
    double savePercent;
	bool isAdditive;
    bool isStatic;

    void Init(HXDDArmor item) {
		self.name = item.GetClassName();
		self.type = item.type;
        self.saveAmount = item.SaveAmount;
		self.savePercent = item.SavePercent;
		self.isAdditive = item.IsAdditive;
		if (self.isAdditive) {
			self.Add();
		} else {
        	self.Reset();
		}
    }

	void InitFromProgression() {
		// TODO
	}

	void Add() {
		self.current += self.saveAmount;
	}

    void Reset() {
        self.current = self.saveAmount;
    }

    void Zero() {
        self.current = 0;
    }

    void ReduceBy(int value) {
        self.current = max(0, self.current - value);
    }

    int GetTotal() {
        return self.saveAmount;
    }

    int GetCurrent() {
        return self.current;
    }

    bool isDamaged() {
		if (self.isAdditive) {
			return false;
		}
        return self.current < self.saveAmount;
    }

	bool canProtect() {
		return self.current > 0;
	}

    void SetIsStatic() {
        self.isStatic = true;
    }

    String GetName() {
        return self.name;
    }

	bool isType(String type) {
		return self.type == type;
	}
}

class HXDDArmor : Armor {
	String type;
	double SavePercent;
	int SaveAmount;
	bool IsAdditive;

	property type: Type;
	property SaveAmount: SaveAmount;
	property SavePercent: SavePercent;
	property IsAdditive: IsAdditive;

    Map<String, HXDDArmorSlot> Slots;
	
	Default
	{
		+Inventory.KEEPDEPLETED
		+Inventory.UNTOSSABLE
	}
	
	//===========================================================================
	//
	// AHexenArmor :: CreateCopy
	//
	//===========================================================================

	override Inventory CreateCopy(Actor other) {
		// Like BasicArmor, HexenArmor is used in the inventory but not the map.
		// health is the slot this armor occupies.
		// Amount is the quantity to give (0 = normal max).
		let copy = HXDDArmor(Spawn("HXDDArmor"));
		console.printf("CreateCopy %s", copy.GetClassName());
		copy.AddArmorToSlot(self);
		GoAwayAndDie();
		return copy;
	}

	//===========================================================================
	//
	// AHexenArmor :: CreateTossable
	//
	// Since this isn't really a single item, you can't drop it. Ever.
	//
	//===========================================================================

	override Inventory CreateTossable (int amount) {
		return NULL;
	}

	//===========================================================================
	//
	// AHexenArmor :: HandlePickup
	//
	//===========================================================================

	override bool HandlePickup (Inventory item) {
		if (item is "HexenArmor") {
			console.printf("HandlePickup T %s", item.GetClassName());
		}
		if (item is "HXDDArmor") {
			HXDDArmor armor = HXDDArmor(item);
			console.printf("HandlePickup %s", armor.GetClassName());
			if (self.AddArmorToSlot(armor)) {
			    console.printf("HandlePickup T %s", armor.GetClassName());
				item.bPickupGood = true;
			}
			return true;
		}
		return false;
	}

	//===========================================================================
	//
	// AHexenArmor :: AddArmorToSlot
	//
	//===========================================================================

	bool AddArmorToSlot(HXDDArmor item) {
		String name = item.GetClassName();
        bool exists = self.Slots.CheckKey(name);
        if (!exists) {
            let slot = new("HXDDArmorSlot");
            slot.Init(item);
            self.AddArmorType(slot);
			console.printf("New, Init, %s", self.GetClassName());
            return true;
        }
		let slot = self.Slots.Get(name);
		if (slot.isAdditive) {
			slot.Add();
			return true;
		} else if (slot.isDamaged()) {
            slot.Reset();
			console.printf("Damaged, reset");
            return true;
        } else {
		}
		return false;
	}

	//===========================================================================
	//
	// AHexenArmor :: AbsorbDamage
	//
	//===========================================================================

	override void AbsorbDamage (int damage, Name damageType, out int newdamage, Actor inflictor, Actor source, int flags) {
		if (!DamageTypeDefinition.IgnoreArmor(damageType)) {
			int saved = 0;

			// Doom / Heretic / Strife Armor Calc
			int totalBasic = self.GetBasic();
			if (totalBasic) {
				// NYI
			}

			// Hexen Armor Calc
			int totalHX = self.GetHX();
			int savedPercent = min(self.GetHX(true), 100);
			if (savedPercent) {
                foreach (type, slot : self.Slots) {
                    if (!slot.isType("hexen") || slot.isStatic || !slot.canProtect()) {
                        continue;
                    }
                    if (damage < 10000) {
                        slot.ReduceBy(damage * slot.GetTotal() / 300.0);
                    } else {
                        slot.Zero();
                    }
                }
				saved =+ int(damage * savedPercent / 100.0);
				if (saved > savedPercent*2) {	
					saved = int(savedPercent*2);
				}
			    console.printf("Damage: %d New: %d Saved: %d", damage, damage - saved, saved);
			}

			// Hexen II Armor Calc
			int countHX2Peices = self.GetHX2Peices();
			if (countHX2Peices > 0 && damage > 0) {
				console.printf("incoming %d", damage);
				double totalHX2Armor = GetHX2();
				console.printf("totalHX2Armor %d, countHX2Peices %d", totalHX2Armor, countHX2Peices);
				Progression itemProgression = Progression(Owner.FindInventory("Progression"));
				if (itemProgression) {
					totalHX2Armor += itemProgression.currlevel * .001;
				}
				double armor_damage = (totalHX2Armor * .01) * damage;
				console.printf("armor_damage %d", armor_damage);
				if (armor_damage > self.GetHX2(true)) {
					console.printf("zero'd?");
                	foreach (type, slot : self.Slots) {
						if (slot.isType("hexen") && slot.canProtect()) {
							slot.Zero();
						}
					}
				} else {
					int armorSave = armor_damage / countHX2Peices;

					console.printf("armor_damage %d, armorSave %d", armor_damage, armorSave);
					foreach (type, slot : self.Slots) {
						if (slot.isType("hexen2") && slot.canProtect()) {
							slot.ReduceBy(armorSave);
							saved += armorSave;
							console.printf("type %s, damage %d, saved %d", type, armorSave, saved);
						}
					}
				}
			}

			if (saved) {
				newdamage -= saved;
				damage = newdamage;
				console.printf("outgoing %d", newdamage);
			}
		}
	}

	//===========================================================================
	//
	// AHexenArmor :: DepleteOrDestroy
	//
	//===========================================================================

	override void DepleteOrDestroy() {
		self.Slots.Clear();
    }

    void AddArmorType(HXDDArmorSlot slot) {
        self.Slots.Insert(slot.name, slot);
		console.printf("AddArmorType %s", slot.name);
    }

    int GetTotal() {
        int total = 0;
        foreach (slot : self.Slots) {
            total += slot.GetTotal();
        }
        return total;
    }

	int GetBasic(bool getRemaining = false) {
        int total = 0;
        foreach (slot : self.Slots) {
			if (slot.isType("basic")) {
            	total += getRemaining ? slot.GetCurrent() : slot.GetTotal();
			}
        }
        return total;
	}
	
	int GetHX(bool getRemaining = false) {
        int total = 0;
        foreach (slot : self.Slots) {
			if (slot.isType("hexen")) {
            	total += getRemaining ? slot.GetCurrent() : slot.GetTotal();
			}
        }
        return total;
	}

	int GetHX2(bool getRemaining = false) {
        int total = 0;
        foreach (slot : self.Slots) {
			if (slot.isType("hexen2")) {
            	total += getRemaining ? slot.GetCurrent() : slot.GetTotal();
			}
        }
        return total;
	}

	int GetHX2Peices() {
        int count = 0;
        foreach (slot : self.Slots) {
			if (slot.isType("hexen2")) {
				if (slot.current > 0) {
            		count++;
				}
			}
        }
        return count;
	}
}
