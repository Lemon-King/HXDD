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
    static clearscope LemonTree DATA_GetInstance() {
        LemonTree handler = LemonTree(EventHandler.Find("LemonTree"));
        if (handler == null) {
            //console.printf("LemonTree instance not found! Panic?");
        }
        return handler;
    }
    static ui LemonTree UI_GetInstance() {
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
    static clearscope LemonTreeBranch DATA_GetStore(String key) {
        LemonTree ltInstance = LemonTree.DATA_GetInstance();
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
    static ui LemonTreeBranch UI_GetStore(String key) {
        LemonTree ltInstance = LemonTree.UI_GetInstance();
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
                            newStore.OnCreate();
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
            if (store) {
                store.WorldLoaded(e);
            }
        }
    }
    override void WorldUnloaded (WorldEvent e) {
        foreach(store : self.stores) {
            if (store) {
                store.WorldUnloaded(e);
            }
        }
    }

    override void WorldTick () {
        foreach(store : self.stores) {
            if (store) {
                store.WorldTick();
            }
        }
    }


    override void WorldThingDamaged (WorldEvent e) {
        foreach(store : self.stores) {
            if (store) {
                store.WorldThingDamaged(e);
            }
        }
    }
    override void WorldThingGround (WorldEvent e) {
        foreach(store : self.stores) {
            if (store) {
                store.WorldThingGround(e);
            }
        }
    }

	override void WorldThingSpawned (WorldEvent e) {
        foreach(store : self.stores) {
            if (store) {
                store.WorldThingSpawned(e);
            }
        }
    }
    override void WorldThingDied (WorldEvent e) {
        foreach(store : self.stores) {
            if (store) {
                store.WorldThingDied(e);
            }
        }
    }
    override void WorldThingRevived (WorldEvent e) {
        foreach(store : self.stores) {
            if (store) {
                store.WorldThingRevived(e);
            }
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
            if (store) {
                store.WorldLightning(e);
            }
        }
    }

    override void WorldLinePreActivated (WorldEvent e) {
        foreach(store : self.stores) {
            if (store) {
                store.WorldLinePreActivated(e);
            }
        }
    }

    override void WorldLineActivated (WorldEvent e) {
        foreach(store : self.stores) {
            if (store) {
                store.WorldLineActivated(e);
            }
        }
    }

    override void PlayerEntered (PlayerEvent e) {
        foreach(store : self.stores) {
            if (store) {
                store.PlayerEntered(e);
            }
        }
    }
    override void PlayerSpawned (PlayerEvent e) {
        foreach(store : self.stores) {
            if (store) {
                store.PlayerSpawned(e);
            }
        }
    }
    override void PlayerRespawned (PlayerEvent e) {
        foreach(store : self.stores) {
            if (store) {
                store.PlayerRespawned(e);
            }
        }
    }
    override void PlayerDied (PlayerEvent e) {
        foreach(store : self.stores) {
            if (store) {
                store.PlayerDied(e);
            }
        }
    }
    override void PlayerDisconnected (PlayerEvent e) {
        foreach(store : self.stores) {
            if (store) {
                store.PlayerDisconnected(e);
            }
        }
    }
}