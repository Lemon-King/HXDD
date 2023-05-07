
// This isn't a good solution,
// TODO: Add a PR with an improvement:
// https://github.com/coelckers/gzdoom/issues/1644

// BUG: Pickups using Lights from gldefs do not hide lights with VisibleToPlayerClass.

// Bag & Arti Boost
class HXDDBagOfHolding: BagOfHolding replaces BagOfHolding {
    Default {
        VisibleToPlayerClass "HereticPlayer";
        Inventory.RestrictedTo "HereticPlayer";
    }
}

class HXDDArtiBoostMana: ArtiBoostMana replaces ArtiBoostMana {
    Default {
        VisibleToPlayerClass "FighterPlayer", "ClericPlayer", "MagePlayer", "PaladinPlayer", "CrusaderPlayer", "NecromancerPlayer", "AssassinPlayer", "SuccubusPlayer";
        Inventory.RestrictedTo "FighterPlayer", "ClericPlayer", "MagePlayer", "PaladinPlayer", "CrusaderPlayer", "NecromancerPlayer", "AssassinPlayer", "SuccubusPlayer";
    }
}

// Heretic Ammo
class HXDDGoldWandAmmo: GoldWandAmmo replaces GoldWandAmmo {
    Default {
        VisibleToPlayerClass "HereticPlayer";
        Inventory.RestrictedTo "HereticPlayer";
    }
}
class HXDDGoldWandHefty: GoldWandHefty replaces GoldWandHefty {
    Default {
        VisibleToPlayerClass "HereticPlayer";
        Inventory.RestrictedTo "HereticPlayer";
    }
}

class HXDDCrossbowAmmo: CrossbowAmmo replaces CrossbowAmmo {
    Default {
        VisibleToPlayerClass "HereticPlayer";
        Inventory.RestrictedTo "HereticPlayer";
    }
}
class HXDDCrossbowHefty: CrossbowHefty replaces CrossbowHefty {
    Default {
        VisibleToPlayerClass "HereticPlayer";
        Inventory.RestrictedTo "HereticPlayer";
    }
}

class HXDDBlasterAmmo: BlasterAmmo replaces BlasterAmmo {
    Default {
        VisibleToPlayerClass "HereticPlayer";
        Inventory.RestrictedTo "HereticPlayer";
    }
}
class HXDDBlasterHefty: BlasterHefty replaces BlasterHefty {
    Default {
        VisibleToPlayerClass "HereticPlayer";
        Inventory.RestrictedTo "HereticPlayer";
    }
}

class HXDDSkullRodAmmo: SkullRodAmmo replaces SkullRodAmmo {
    Default {
        VisibleToPlayerClass "HereticPlayer";
        Inventory.RestrictedTo "HereticPlayer";
    }
}
class HXDDSkullRodHefty: SkullRodHefty replaces SkullRodHefty {
    Default {
        VisibleToPlayerClass "HereticPlayer";
        Inventory.RestrictedTo "HereticPlayer";
    }
}

class HXDDPhoenixRodAmmo: PhoenixRodAmmo replaces PhoenixRodAmmo {
    Default {
        VisibleToPlayerClass "HereticPlayer";
        Inventory.RestrictedTo "HereticPlayer";
    }
}
class HXDDPhoenixRodHefty: PhoenixRodHefty replaces PhoenixRodHefty {
    Default {
        VisibleToPlayerClass "HereticPlayer";
        Inventory.RestrictedTo "HereticPlayer";
    }
}

class HXDDMaceAmmo: MaceAmmo replaces MaceAmmo {
    Default {
        VisibleToPlayerClass "HereticPlayer";
        Inventory.RestrictedTo "HereticPlayer";
    }
}
class HXDDMaceHefty: MaceHefty replaces MaceHefty {
    Default {
        VisibleToPlayerClass "HereticPlayer";
        Inventory.RestrictedTo "HereticPlayer";
    }
}

// Hexen Ammo
class HXDDMana1: Mana1 replaces Mana1 {
    Default {
        VisibleToPlayerClass "FighterPlayer", "ClericPlayer", "MagePlayer", "PaladinPlayer", "CrusaderPlayer", "NecromancerPlayer", "AssassinPlayer", "SuccubusPlayer";
        Inventory.RestrictedTo "FighterPlayer", "ClericPlayer", "MagePlayer", "PaladinPlayer", "CrusaderPlayer", "NecromancerPlayer", "AssassinPlayer", "SuccubusPlayer";
    }
}
class HXDDMana2: Mana2 replaces Mana2 {
    Default {
        VisibleToPlayerClass "FighterPlayer", "ClericPlayer", "MagePlayer", "PaladinPlayer", "CrusaderPlayer", "NecromancerPlayer", "AssassinPlayer", "SuccubusPlayer";
        Inventory.RestrictedTo "FighterPlayer", "ClericPlayer", "MagePlayer", "PaladinPlayer", "CrusaderPlayer", "NecromancerPlayer", "AssassinPlayer", "SuccubusPlayer";
    }
}
class HXDDMana3: Mana3 replaces Mana3 {
    Default {
        VisibleToPlayerClass "FighterPlayer", "ClericPlayer", "MagePlayer", "PaladinPlayer", "CrusaderPlayer", "NecromancerPlayer", "AssassinPlayer", "SuccubusPlayer";
        Inventory.RestrictedTo "FighterPlayer", "ClericPlayer", "MagePlayer", "PaladinPlayer", "CrusaderPlayer", "NecromancerPlayer", "AssassinPlayer", "SuccubusPlayer";
    }
}