Class HXDDLevelCompatibility : LevelPostProcessor {
    // ref: https://github.com/jekyllgrim/Beautiful-Doom/blob/53974b963c5f85c904808e7069a6b2d91bb5dd00/Z_BDoom/bd_events.zc#L66
    int GetLineLockNumber(Line l) {
        if ( !l.locknumber ) {
            // check the special
            switch ( l.special ) {
            case FS_Execute:
                return l.Args[2];
                break;
            case Door_LockedRaise:
            case Door_Animated:
                return l.Args[3];
                break;
            case ACS_LockedExecute:
            case ACS_LockedExecuteDoor:
            case Generic_Door:
                return l.Args[4];
                break;
            }
        }
        return l.locknumber;
    }

    protected void Apply(Name checksum, String mapname) {
        // HXDD only modifies 6 keys, so we should be looking for those keys in lines
        if (!LemonUtil.IsGameType(GAME_Doom) && LemonUtil.CVAR_GetBool("HXDD_USE_KEYDEF_MODE", true)) {
            let nextLump = 0;
            Array<int> keySlots;
            keySlots.Resize(3);
            while (nextLump != -1 || nextLump != Wads.GetNumLumps()) {
                int lumpIndex = Wads.FindLump("lockdefs", nextLump + 1);
                if (lumpIndex == -1) {
                    String lumpData = Wads.ReadLump(nextLump);
                    bool isHXDD = lumpData.mid(0,7) == "// HXDD";
                    if (isHXDD) {
                        break;
                    }
                    String lumpDataLower = lumpData.MakeLower();
                    bool isCleared = lumpDataLower.IndexOf("clearlocks") != -1;
                    if (isCleared) {
                        // all new keys set, no need to make changes
                        return;
                    }

                    // partial or all
                    bool altersLock1 = lumpDataLower.IndexOf("lock 1\n{") != -1 || lumpDataLower.IndexOf("lock 1 {") != -1;
                    bool altersLock2 = lumpDataLower.IndexOf("lock 2\n{") != -1 || lumpDataLower.IndexOf("lock 2 {") != -1;
                    bool altersLock3 = lumpDataLower.IndexOf("lock 3\n{") != -1 || lumpDataLower.IndexOf("lock 3 {") != -1;
                    if (altersLock1) {
                        keySlots.insert(0, 1);
                    }
                    if (altersLock2) {
                        keySlots.insert(1, 2);
                    }
                    if (altersLock3) {
                        keySlots.insert(2, 3);
                    }
                }
                nextLump = lumpIndex;
            }

            int gameMode = LemonUtil.GetOptionGameMode();
            if  (gameMode == GAME_Heretic) {
                if (!keySlots[0]) {
                    keySlots.insert(0, 1001);
                }
                if (!keySlots[1]) {
                    keySlots.insert(1, 1002);
                }
                if (!keySlots[2]) {
                    keySlots.insert(2, 1003);
                }
            } else if (gameMode == GAME_Hexen) {
                if (!keySlots[0]) {
                    keySlots.insert(0, 2001);
                }
                if (!keySlots[1]) {
                    keySlots.insert(1, 2002);
                }
                if (!keySlots[2]) {
                    keySlots.insert(2, 2003);
                }
            }
            for (int i = 0; i < Level.lines.Size(); i++) {
                Line l = Level.lines[i];
                int locknum = GetLineLockNumber(l);
                if (locknum > 0) {
                    Array<int> args;
                    args.Resize(l.Args.Size());
                    for (int i = 0; i < l.Args.Size(); i++) {
                        args[i] = l.Args[i];
                    }
                    if ( !l.locknumber ) {
                        // check the special
                        int key;
                        switch ( l.special ) {
                        case FS_Execute:
                            key = args[2] - 128;
                            if (key > 0 && key < 4) {
                                args[2] = keySlots[key-1];
                            }
                            break;
                        case Door_LockedRaise:
                        case Door_Animated:
                            key = args[3] - 128;
                            if (key > 0 && key < 4) {
                                args[3] = keySlots[key-1];
                            }
                            break;
                        case ACS_LockedExecute:
                        case ACS_LockedExecuteDoor:
                        case Generic_Door:
                            key = args[4] - 128;
                            if (key > 0 && key < 4) {
                                args[4] = keySlots[key-1];
                            }
                            break;
                        }
                    }
                    SetLineSpecial(i, l.special, args[0], args[1], args[2], args[3], args[4]);
                }
            }
        }
    }
}