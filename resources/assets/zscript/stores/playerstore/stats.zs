class PlayerSheetStatBase {
	int min;				// Starting Min
	int max;				// Starting Max
}
class PlayerSheetStatGain {
	int min;				// Compute Min
	int max;				// Compute Max
	int cap;				// Compute Max Level
}

class PlayerSheetStatParams {
	int maximum;			// Maximum Stat Value
	PlayerSheetStatBase base;
	PlayerSheetStatGain gain;			
}

class PlayerSheetItemSlot {
	String item;
	int quantity;
}

class PlayerSheetStat {
	String name;
	double value;
	bool isActual;			// Do not use percentages when scaling (default: false)
	double bonusScale;		// Backpack scale (default: based off of AmmoItem value)
	PlayerSheetStatParams params;

	PlayerSheetStat Init(String name) {
		self.params = new("PlayerSheetStatParams");
		self.params.base = new("PlayerSheetStatBase");
		self.params.gain = new("PlayerSheetStatGain");

		self.name = name;
		self.value = 0;
		self.isActual = false;
		self.bonusScale = 1.0;

		return self;
	}

	double stat_compute(double min, double max) {
		double value = (max-min+1) * frandom(0.0, 1.0) + min;
		if (value > max) {
			return max;
		}
		value = ceil(value);
		return value;
	}

	PlayerSheetStat Roll(bool levelCap = false) {
		if (self.value == 0) {
			self.value = self.stat_compute(self.params.base.min, self.params.base.max);
		} else {
			self.ProcessLevelIncrease(levelCap);
		}

		return self;
	}

	PlayerSheetStat ProcessLevelIncrease(bool levelCap) {
		if (self.params) {
			int nextValue = self.value;
			if (levelCap && self.params.gain.cap) {
				nextValue += self.params.gain.cap;
			} else if (self.params.gain.min && self.params.gain.max) {
				nextValue += self.stat_compute(self.params.gain.min, self.params.gain.max);
			}
			if (self.params.maximum) {
				nextValue = min(nextValue, self.params.maximum);
			}
			self.value = nextValue;
		}

		return self;
	}

	PlayerSheetStat SetFromObject(HXDD_JsonObject o) {
		if (!self.params) {
			return self;
		}

		int valStartMin;
		int valStartMax;
		let oStatBase		= HXDD_JsonObject(o.get("base"));
		if (oStatBase) {
			valStartMin		= FileJSON.GetInt(oStatBase, "min");
			valStartMax		= FileJSON.GetInt(oStatBase, "max");
		}

		int valGainMin;
		int valGainMax;
		int valGainCap;
		let oStatGain		= HXDD_JsonObject(o.Get("gain"));
		if (oStatGain) {
			valGainMin		= FileJSON.GetInt(o, "min");
			valGainMax		= FileJSON.GetInt(o, "max");
			valGainCap		= FileJSON.GetInt(o, "cap");
		}

		let valMaximum		= FileJSON.GetInt(o, "maximum");
		let valIsActual		= FileJSON.GetBool(o, "actual");
		let valBonusScale	= FileJSON.GetDouble(o, "bonus");
		
		self.params.base.min = valStartMin;
		self.params.base.max = valStartMax;
		if (valGainMin != -1 && valGainMax != -1) {
			self.params.gain.min = valGainMin;
			self.params.gain.max = valGainMax;
		}
		if (valGainCap != -1) {
			self.params.gain.cap = valGainCap;
		}
		if (valMaximum != -1) {
			self.params.maximum = valMaximum;
		}
		self.bonusScale = valBonusScale;
		self.isActual = valIsActual;

		return self;
	}

	PlayerSheetStat SetFromArray(HXDD_JsonArray raw) {
		if (!self.params) {
			return self;
		}

		Array<int> result;
		result.Resize(raw.arr.Size());
		for (let i = 0; i < raw.arr.Size(); i++) {
			result[i] = HXDD_JsonInt(raw.arr[i]).i;
		}

		int size = result.Size();
		if (size < 2) {
			// error?
			return self;
		}
		
		self.params.base.min = result[0];
		self.params.base.max = result[1];
		if (size > 3) {
			self.params.gain.min = result[2];
			self.params.gain.max = result[3];
		}
		if (size > 4) {
			self.params.gain.cap = result[4];
		}
		if (size > 5) {
			self.params.maximum = result[5];
		}

		return self;
	}
}