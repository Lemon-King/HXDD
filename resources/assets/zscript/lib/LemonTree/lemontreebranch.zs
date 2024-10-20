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

    virtual void Init() {
        console.printf("%s: Init", self.GetClassName());
    }

    virtual void OnReset() {
        // called on new game and data already exists
        // used for manually setting data between new games
        console.printf("%s: OnReset", self.GetClassName());
    }

    virtual void OnNewGame() {
        console.printf("%s: OnNewGame", self.GetClassName());
    }

    // Map event handlers
    virtual void OnMapEnter() {
        console.printf("%s: Map Enter", self.GetClassName());
    }

    virtual void OnMapLeave() {
        console.printf("%s: Map Leave", self.GetClassName());
    }

    // Bound event handlers
    virtual void WorldLoaded (WorldEvent e) {
        console.printf("%s: WorldLoaded", self.GetClassName());
    }
    virtual void WorldUnloaded (WorldEvent e) {}

    virtual void WorldThingDamaged (WorldEvent e) {}
    virtual void WorldThingGround (WorldEvent e) {}

	virtual void WorldThingSpawned (WorldEvent e) {}
    virtual void WorldThingDied (WorldEvent e) {}
    virtual void WorldThingRevived (WorldEvent e) {}
    virtual void WorldThingDestroyed (WorldEvent e) {}

    virtual void WorldLightning (WorldEvent e) {}

    virtual void WorldLinePreActivated (WorldEvent e) {}

    virtual void WorldLineActivated (WorldEvent e) {}

    virtual void PlayerEntered (PlayerEvent e) {}
    virtual void PlayerSpawned (PlayerEvent e) {}
    virtual void PlayerRespawned (PlayerEvent e) {}
    virtual void PlayerDied (PlayerEvent e) {}
    virtual void PlayerDisconnected (PlayerEvent e) {}
}