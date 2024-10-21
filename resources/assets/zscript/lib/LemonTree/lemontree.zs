// Cached store will be assigned data during world change, gameplay it is in a locked state
class LemonTree {
    static LemonTreeStatic GetStatic() {
        LemonTreeStatic handler = LemonTreeStatic(StaticEventHandler.Find("LemonTreeStatic"));
        if (handler == null) {
            //console.printf("LemonTreeStatic instance not found! Panic?");
        }
        return handler;
    }
    static LemonTreeSession GetSession() {
        LemonTreeSession handler = LemonTreeSession(EventHandler.Find("LemonTreeSession"));
        if (handler == null) {
            //console.printf("LemonTreeSession instance not found! Panic?");
        }
        return handler;
    }
    static LemonTreeBranch GetStore(String key) {
        LemonTreeSession ltSession = LemonTree.GetSession();
        if (ltSession) {
            bool exists = false;
            LemonTreeBranch store;
            [store, exists] = ltSession.stores.CheckValue(key);
            if (exists) {
                return store;
            }
        }

        // are we outside a map?
        return null;
    }
}

class LemonTreeStatic : StaticEventHandler {
    Map<String, LemonTreeBranch> stores;
    Array<String> storeClasses;

    // Singleton access method, should only be accessed by LemonTreeSession
    static LemonTreeStatic GetInstance() {
        LemonTreeStatic handler = LemonTreeStatic(StaticEventHandler.Find("LemonTreeStatic"));
        if (handler == null) {
            //console.printf("LemonTreeStatic instance not found! Panic?");
        }
        return handler;
    }

    static uint GetStoresCount() {
        return LemonTree.GetStatic().stores.CountUsed();
    }

    static void MoveStoresFromSession() {
        LemonTree.GetStatic().stores.Move(LemonTree.GetSession().stores);
    }
    static void MoveStoresToSession() {
        LemonTree.GetSession().stores.Move(LemonTree.GetStatic().stores);
    }

    static void GetStoreClasses(in out Array<String> ioStoreClasses) {
        ioStoreClasses.Copy(LemonTree.GetStatic().storeClasses);
    }

    override void OnRegister() {
        console.printf("LemonTree: Initialized");

        SetOrder(1000);

        String cvarDataStore = LemonUtil.CVAR_GetString("hxdd_lemontree_sessionstorage", "LemonTreeBranch");
        Array<String> dataStoreClasses;
        cvarDataStore.Substitute(" ", "");
        cvarDataStore.split(self.storeClasses, ",");
        if (self.storeClasses.Find("LemonTreeBranch") != -1) {
            console.printf("LemonTree.Static: The default storage class [LemonTreeBranch] is in use!");
        }
    }

    override void NewGame() {
        if (Level.MapName.MakeLower() == "titlemap") {
            return;
        }
        if (!!LemonTree.GetSession()) {
            LemonTree.GetStatic().MoveStoresFromSession();
        }
        Array<String> removal;
        foreach(key, store : self.stores) {
            if (store._persist) {
                console.printf("LemonTree.Static: NewGame, %s Store Persist", key);
                store.OnReset();
            } else {
                console.printf("LemonTree.Static: NewGame, %s Store Cleared", key);
                removal.Push(key);
            }
        }
        if (removal.Size() > 0) {
            for (int i = 0; i < removal.Size(); i++) {
                console.printf("LemonTree.Static: Removing %s for Reset", removal[i]);
                self.stores.Remove(removal[i]);
            }
        }
    }

    override void WorldLoaded(WorldEvent e) {
        console.printf("LemonTree.Static: WorldLoaded");
        if (e.IsSaveGame || Level.MapName.MakeLower() == "titlemap") {
            return;
        }
        self.stores.Clear();
    }

    override void WorldUnloaded(WorldEvent e) {
        console.printf("LemonTree.Static: WorldUnloaded");
        if (Level.MapName.MakeLower() == "titlemap") {
            return;
        }
    }
}

class LemonTreeSession : EventHandler {
    Map<String, LemonTreeBranch> stores;

    // Singleton access method
    static LemonTreeSession GetInstance() {
        LemonTreeSession handler = LemonTreeSession(EventHandler.Find("LemonTreeSession"));
        if (handler == null) {
            //console.printf("LemonTreeSession instance not found! Panic?");
        }
        return handler;
    }
    static void MoveStoresFromStatic() {
        if (LemonTree.GetStatic().stores.CountUsed() != 0) {
            LemonTree.GetSession().stores.Move(LemonTree.GetStatic().stores);
        }
    }
    static void MoveStoresToStatic() {
        LemonTree.GetStatic().stores.Move(LemonTree.GetSession().stores);
    }

    // Load data before game starts
    override void OnRegister() {
        if (Level.MapName.MakeLower() == "titlemap") {
            return;
        }
        if (self.stores.CountUsed() == 0) { // loading from a save if the value is > 0
            if (LemonTree.GetStatic().stores.CountUsed() != 0) {
                self.stores.Move(LemonTree.GetStatic().stores);
            }
            Array<String> storeNames;
            LemonTree.GetStatic().GetStoreClasses(storeNames);
            for (let i = 0; i < storeNames.Size(); i++) {
                String storeName = storeNames[i];
                if (storeName != "") {
                    LemonTreeBranch newStore = LemonTreeBranch(new(storeName));
                    if (newStore) {
                        newStore.Init();
                        self.stores.Insert(storeName, newStore);
                    }
                }
            }
        }
        foreach(store : self.stores) {
            store.OnMapEnter();
        }
    }

    override void OnUnregister() {
        foreach(store : self.stores) {
            store.OnMapLeave();
        }
        LemonTree.GetSession().MoveStoresToStatic();
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
            store.WorldThingDestroyed(e);
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