class LemonTree : EventHandler {
    Map<String, LemonTreeBranch> stores;

    // Singleton access method
    static LemonTree GetInstance() {
        LemonTree handler = LemonTree(EventHandler.Find("LemonTree"));
        if (handler == null) {
            //console.printf("LemonTree instance not found! Panic?");
        }
        return handler;
    }

    static LemonTreeBranch GetStore(String key) {
        LemonTree ltInstance = LemonTree.GetInstance();
        if (ltInstance) {
            bool exists = false;
            LemonTreeBranch store;
            [store, exists] = ltInstance.stores.CheckValue(key);
            if (exists) {
                return store;
            }
        }

        // are we outside a map?
        return null;
    }

    // Load data before game starts
    override void OnRegister() {
        if (Level.MapName.MakeLower() == "titlemap") {
            return;
        }

        // Recover Branches
        if (self.stores.CountUsed() == 0) {
            Array<String> storeNames;
            String cvarDataStore = LemonUtil.CVAR_GetString("hxdd_lemontree_sessionstorage", "LemonTreeBranch");
            cvarDataStore.Substitute(" ", "");
            cvarDataStore.split(storeNames, ",");
            for (let i = 0; i < storeNames.Size(); i++) {
                String storeName = storeNames[i];
                if (storeName != "") {
                    ThinkerIterator it = ThinkerIterator.Create(storeName, Thinker.STAT_STATIC);
                    let foundStore = LemonTreeBranch(it.Next());
                    if (foundStore && !foundStore._clearOnMapChange) {
                        self.stores.Insert(storeName, foundStore);
                    } else {
                        if (foundStore) {
                            foundStore.Destroy();
                        }
                        LemonTreeBranch newStore = LemonTreeBranch(new(storeName));
                        if (newStore) {
                            newStore.ChangeStatNum(Thinker.STAT_STATIC);
                            newStore.Init();
                            self.stores.Insert(storeName, newStore);
                        }
                    }
                }
            }
        }
        foreach(store : self.stores) {
            store.OnMapEnter();
        }
    }

    override void NewGame() {
        if (Level.MapName.MakeLower() == "titlemap") {
            return;
        }
        foreach(store : self.stores) {
            store.OnNewGame();
        }
    }

    override void OnUnregister() {
        if (Level.MapName.MakeLower() == "titlemap") {
            return;
        }
        foreach(store : self.stores) {
            if (store) {
                store.OnMapLeave();
            }
        }
    }

    // Event handlers
    override void WorldLoaded (WorldEvent e) {
        foreach(store : self.stores) {
            store.WorldLoaded(e);
        }
    }
    override void WorldUnloaded (WorldEvent e) {
        foreach(store : self.stores) {
            store.WorldUnloaded(e);
        }
    }

    override void WorldThingDamaged (WorldEvent e) {
        foreach(store : self.stores) {
            store.WorldThingDamaged(e);
        }
    }
    override void WorldThingGround (WorldEvent e) {
        foreach(store : self.stores) {
            store.WorldThingGround(e);
        }
    }

	override void WorldThingSpawned (WorldEvent e) {
        foreach(store : self.stores) {
            store.WorldThingSpawned(e);
        }
    }
    override void WorldThingDied (WorldEvent e) {
        foreach(store : self.stores) {
            store.WorldThingDied(e);
        }
    }
    override void WorldThingRevived (WorldEvent e) {
        foreach(store : self.stores) {
            store.WorldThingRevived(e);
        }
    }
    override void WorldThingDestroyed (WorldEvent e) {
        foreach(store : self.stores) {
            if (store) {
                store.WorldThingDestroyed(e);
            }
        }
    }

    override void WorldLightning (WorldEvent e) {
        foreach(store : self.stores) {
            store.WorldLightning(e);
        }
    }

    override void WorldLinePreActivated (WorldEvent e) {
        foreach(store : self.stores) {
            store.WorldLinePreActivated(e);
        }
    }

    override void WorldLineActivated (WorldEvent e) {
        foreach(store : self.stores) {
            store.WorldLineActivated(e);
        }
    }

    override void PlayerEntered (PlayerEvent e) {
        foreach(store : self.stores) {
            store.PlayerEntered(e);
        }
    }
    override void PlayerSpawned (PlayerEvent e) {
        foreach(store : self.stores) {
            store.PlayerSpawned(e);
        }
    }
    override void PlayerRespawned (PlayerEvent e) {
        foreach(store : self.stores) {
            store.PlayerRespawned(e);
        }
    }
    override void PlayerDied (PlayerEvent e) {
        foreach(store : self.stores) {
            store.PlayerDied(e);
        }
    }
    override void PlayerDisconnected (PlayerEvent e) {
        foreach(store : self.stores) {
            store.PlayerDisconnected(e);
        }
    }
}