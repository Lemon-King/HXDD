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
        // HXDD Mode only modifies 6 keys, so we should be looking for those keys in lines
        if (!LemonUtil.IsGameType(GAME_Doom) || LemonUtil.CVAR_GetBool("HXDD_USE_KEYDEF_MODE", true)) {
            int gameMode = LemonUtil.GetOptionGameMode();
            int offset = 0;
            if  (gameMode == GAME_Heretic) {
                offset = 1000;
            } else if (gameMode == GAME_Hexen) {
                offset = 2000;
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
                                args[2] = key + offset;
                            }
                            break;
                        case Door_LockedRaise:
                        case Door_Animated:
                            key = args[3] - 128;
                            if (key > 0 && key < 4) {
                                args[3] = key + offset;
                            }
                            break;
                        case ACS_LockedExecute:
                        case ACS_LockedExecuteDoor:
                        case Generic_Door:
                            key = args[4] - 128;
                            if (key > 0 && key < 4) {
                                args[4] = key + offset;
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