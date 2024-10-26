// Extend with classes and use mixins, this is just a base
class LemonTreeBranch : Thinker {
    bool _clearOnMapChange;

    LemonTreeBranch GetStore() {
        LemonTree ltInstance = LemonTree.GetInstance();
        if (ltInstance) {
            bool exists = false;
            LemonTreeBranch store;
            [store, exists] = ltInstance.stores.CheckValue(self.GetClassName());
            if (exists) {
                return store;
            }
        }

        // are we outside a map?
        return null;
    }

    virtual play void OnCreate() {
        console.printf("%s: OnCreate", self.GetClassName());
    }

    virtual play void OnReset() {
        // called on new game and data already exists
        // used for manually setting data between new games
        console.printf("%s: OnReset", self.GetClassName());
    }

    virtual play void OnNewGame() {
        console.printf("%s: OnNewGame", self.GetClassName());
    }

    // Map event handlers
    virtual play void OnMapEnter() {
        console.printf("%s: Map Enter", self.GetClassName());
    }

    virtual play void OnMapLeave() {
        console.printf("%s: Map Leave", self.GetClassName());
    }

    // Bound event handlers
    virtual play void WorldLoaded (WorldEvent e) {
        console.printf("%s: WorldLoaded", self.GetClassName());
    }
    virtual play void WorldUnloaded (WorldEvent e) {}

    virtual play void WorldTick () {}

    virtual play void WorldThingDamaged (WorldEvent e) {}
    virtual play void WorldThingGround (WorldEvent e) {}

	virtual play void WorldThingSpawned (WorldEvent e) {}
    virtual play void WorldThingDied (WorldEvent e) {}
    virtual play void WorldThingRevived (WorldEvent e) {}
    virtual play void WorldThingDestroyed (WorldEvent e) {}

    virtual play void WorldLightning (WorldEvent e) {}

    virtual play void WorldLinePreActivated (WorldEvent e) {}

    virtual play void WorldLineActivated (WorldEvent e) {}

    virtual play void PlayerEntered (PlayerEvent e) {}
    virtual play void PlayerSpawned (PlayerEvent e) {}
    virtual play void PlayerRespawned (PlayerEvent e) {}
    virtual play void PlayerDied (PlayerEvent e) {}
    virtual play void PlayerDisconnected (PlayerEvent e) {}
}