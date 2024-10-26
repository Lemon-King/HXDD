
enum EPlaystyleArmorType {
	PSAT_DEFAULT = 0,
	PSAT_ARMOR_BASIC = 1,
	PSAT_ARMOR_HXAC = 2,
	PSAT_ARMOR_HX2AC = 3,
	PSAT_ARMOR_HXAC_RANDOM = 4,
	PSAT_ARMOR_HX2AC_RANDOM = 5,
	PSAT_ARMOR_USER = 6
};

enum EPlaystyleProgressionType {
	PSP_DEFAULT = 0,
	PSP_NONE = 1,
	PSP_LEVELS = 2,
	PSP_LEVELS_RANDOM = 3,
	PSP_LEVELS_USER = 4,
};

class HXDDPlayerStore : LemonTreeBranch {
	mixin HXDDPlayerStoreEvents;
	mixin PlayerSlotNode;
    
    Array<PlayerSlot> slots;

    override void OnCreate() {
    }

	static play PlayerSlot GetPlayerSlot(int num) {
		HXDDPlayerStore pStore = HXDDPlayerStore(LemonTree.GetStore("HXDDPlayerStore"));
		if (pStore) {
			return pStore.slots[num];
		}
		return null;
	}

	static clearscope PlayerSlot DATA_GetPlayerSlot(int num) {
		HXDDPlayerStore pStore = HXDDPlayerStore(LemonTree.DATA_GetStore("HXDDPlayerStore"));
		if (pStore) {
			return pStore.slots[num];
		}
		return null;
	}

	static ui PlayerSlot UI_GetPlayerSlot(int num) {
		HXDDPlayerStore pStore = HXDDPlayerStore(LemonTree.UI_GetStore("HXDDPlayerStore"));
		if (pStore) {
			return pStore.slots[num];
		}
		return null;
	}
}


