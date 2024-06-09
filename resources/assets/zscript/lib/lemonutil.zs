// https://zdoom.org/wiki/ZScript_actor_functions

class LemonUtil {
    // Used only with NEWGAME Menu
    static int ClassNameToID(string className) {
        Array<string> classes = {
            "HXDDCorvusPlayer",
            "HXDDFighterPlayer",
            "HXDDClericPlayer",
            "HXDDMagePlayer",
            "HX2PaladinPlayer",
            "HX2ClericPlayer",
            "HX2NecromancerPlayer",
            "HX2AssassinPlayer",
            "HX2SuccubusPlayer",
            "H2CorvusPlayer"
        };
        return classes.Find(className);
    }
    
    // Used only with NEWGAME Menu
    static string IDToClassName(int id) {
        Array<string> classes = {
            "HXDDCorvusPlayer",
            "HXDDFighterPlayer",
            "HXDDClericPlayer",
            "HXDDMagePlayer",
            "HX2PaladinPlayer",
            "HX2ClericPlayer",
            "HX2NecromancerPlayer",
            "HX2AssassinPlayer",
            "HX2SuccubusPlayer",
            "H2CorvusPlayer"
        };
        return classes[id];
    }
    static int ClassNameToSimple(string className) {
        Array<string> simple = {
            "corvus",
            "fighter",
            "cleric",
            "mage",
            "paladin",
            "cleric",
            "necromancer",
            "assassin",
            "succubus",
            "corvus"
        };
        return simple.Find(className);
    }

    static void LaunchMap(String mapId, int skill) {
        LemonUtil.CVAR_SetString("hxdd_map_select", String.format("%s,%d", mapId, skill));
    }

    static bool TryOpenMapByName() {
        String mapOverride = LemonUtil.CVAR_GetString("hxdd_map_select", "");
        if (mapOverride.IndexOf(",") != -1) {
            LemonUtil.CVAR_Reset("hxdd_map_select");
            //LemonUtil.CVAR_SetString("hxdd_map_select", "111");
            Array<String> selected;
            mapOverride.Split(selected, ",");
            Console.printf("Map: %s, Skill: %s", selected[0], selected[1]);
            LevelLocals.ChangeLevel(selected[0], 0, CHANGELEVEL_NOINTERMISSION|CHANGELEVEL_RESETINVENTORY|CHANGELEVEL_RESETHEALTH|CHANGELEVEL_CHANGESKILL, selected[1].ToInt());
            return true;
        }
        return false;
    }

    static Class<Object> GetPlayerClass() {
        // Hardcoded for single player atm
        PlayerInfo p = players[0];
        int playerClassNum = p.CurrentPlayerClass;
		for (int i = 0; i < PlayerClasses.Size(); ++i) {
            String className = PlayerClasses[i].type.GetClassName();
            if (playerClassNum == i) {
                String className = PlayerClasses[i].type.GetClassName();
		        if (className.IndexOf("HXDD") != -1) {
			        return PlayerClasses[i].type.GetParentClass();
                }
                return PlayerClasses[i].type;
            }
        }
        return null;
    }

    static String GetPlayerClassName() {
        // Hardcoded for single player atm
        PlayerInfo p = players[0];
        int playerClassNum = p.CurrentPlayerClass;
		for (int i = 0; i < PlayerClasses.Size(); ++i) {
            String className = PlayerClasses[i].type.GetClassName();
            if (playerClassNum == i) {
                String className = PlayerClasses[i].type.GetClassName();
		        if (className.IndexOf("HXDD") != -1) {
			        className = PlayerClasses[i].type.GetParentClass().GetClassName();
                }
                return className.MakeLower();
            }
        }
        return "";
    }

    // Determine Map Type
    static bool IsMapEpisodic() {
        String mapName = Level.MapName.MakeLower();
        return (mapName.Left(1) == "e" && mapName.Mid(2, 1) == "m");
    }
    static bool IsMapLinear() {
        String mapName = Level.MapName.MakeLower();
        return (mapName.IndexOf("map") != -1 || mapName.IndexOf("&wt") != -1);
    }
    static int GetMapNumber() {
        String mapName = Level.MapName.MakeLower();
        if (mapName.IndexOf("map") != -1) {
            String number = mapName.Mid(3, mapName.Length() - 3);
            return number.ToInt();
        }
        return -1;
    }

    static int GetGameType(String type) {
        String gametype = type.MakeLower();
        if (gametype == "heretic") {
            return 1;
        } else if (gametype == "hexen") {
            return 2;
        } else if (gametype == "doom") {
            return 3;
        } else {
            return 0;
        }
    }

    static bool IsGameType(int type) {
        return gameinfo.gametype & type;
    }

    static int GetOptionGameMode() {
        int cvarGameMode = LemonUtil.CVAR_GetInt("hxdd_gamemode", 0);
        int gameType = gameinfo.gametype;
        if (gameType & GAME_Doom) {
            // PWAD Mode
            return GAME_Doom;
        }
        int mode = GAME_Heretic;
        if (cvarGameMode == 1) {
            mode = GAME_Heretic;
        } else if (cvarGameMode == 2) {
            mode = GAME_Hexen;
        } else if (LemonUtil.IsMapEpisodic()) {
            mode = GAME_Heretic;
        } else if (LemonUtil.IsMapLinear()) {
            mode = GAME_Hexen;
        }
        return mode;
    }

    static int GetLineLockNumber(Line l) {
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

    static void ChangeLineLockNumber(Line l, int newLockNumber) {
        if ( !l.locknumber ) {
            // check the special
            switch ( l.special ) {
            case FS_Execute:
                //l.Args[2] = newLockNumber;
                break;
            case Door_LockedRaise:
            case Door_Animated:
                //l.Args[3] = newLockNumber;
                break;
            case ACS_LockedExecute:
            case ACS_LockedExecuteDoor:
            case Generic_Door:
                //l.Args[4] = newLockNumber;
                break;
            }
        }
        //l.locknumber = newLockNumber;
    }

    // CVAR user / server null safe get/find
    static cvar GetCVAR(string name, PlayerInfo player = null) {
        return player ? CVar.GetCvar(name, player) : CVar.FindCVar(name);
    }
    static int CVAR_GetInt(string name, int default_value, PlayerInfo player = null) {
        cvar cv = GetCVAR(name, player);
        return cv ? cv.GetInt() : default_value;
    }
    static float CVAR_GetFloat(string name, float default_value, PlayerInfo player = null) {
        cvar cv = GetCVAR(name, player);
        return cv ? cv.GetFloat() : default_value;
    }
    static bool CVAR_GetBool(string name, bool default_value, PlayerInfo player = null) {
        cvar cv = GetCVAR(name, player);
        return cv ? cv.GetBool() : default_value;
    }
    static string CVAR_GetString(string name, string default_value, PlayerInfo player = null) {
        cvar cv = GetCVAR(name, player);
        return cv ? cv.GetString() : default_value;
    }
    static string CVAR_GetColor(string name, string default_value, PlayerInfo player = null) {
        return CVAR_GetString(name, default_value, player);
    }
    static void CVAR_SetInt(string name, int value, PlayerInfo player = null) {
        cvar cv = GetCVAR(name, player);
        if (cv) {
            cv.SetInt(value);
        }
    }
    static void CVAR_SetFloat(string name, float value, PlayerInfo player = null) {
        cvar cv = GetCVAR(name, player);
        if (cv) {
            cv.SetFloat(value);
        }
    }
    static void CVAR_SetBool(string name, bool value, PlayerInfo player = null) {
        cvar cv = GetCVAR(name, player);
        if (cv) {
            cv.SetBool(value);
        }
    }
    static void CVAR_SetString(string name, string value, PlayerInfo player = null) {
        cvar cv = GetCVAR(name, player);
        if (cv) {
            cv.SetString(value);
        }
    }
    static void CVAR_SetColor(string name, string value, PlayerInfo player = null) {
        CVAR_SetString(name, value, player);
    }
    static void CVAR_Reset(string name, PlayerInfo player = null) {
        cvar cv = GetCVAR(name, player);
        if (cv) {
            cv.ResetToDefault();
        }
    }
    // General Math
    static vector3 RandomVector3(double x, double y, double z) {
        return (frandom(0.0-x,x), frandom(0.0-y,y), frandom(0.0-z,z));
    }

    static vector3 GetRandVector3(vector3 low, vector3 high) {
        return (frandom(low.x, high.x), frandom(low.y, high.y), frandom(low.z, high.z));
    }

    static vector3 v3Lerp(vector3 a, vector3 b, float f) {
        return (a * (1.0 - f)) + (b * f);
    }

    static double flerp(double a, double b, double f) {
        return (a * (1.0 - f)) + (b * f);
    }

    static vector2 v2normalize(vector2 vec) {
        double mag = sqrt(vec.x * vec.x + vec.y * vec.y);
        if (mag == 0) {
            return (0,0);
        }
        return (vec.x / mag, vec.y / mag);
    }
    
    static double v3magnatude(vector3 vec) {
        return sqrt(vec.x * vec.x + vec.y * vec.y + vec.z * vec.z);
    }
    static vector3 v3normalize(vector3 vec) {
        double mag = v3magnatude(vec);
        if (mag == 0) {
            return (0,0,0);
        }
        return (vec.x / mag, vec.y / mag, vec.z / mag);
    }

    static double v3Angle(vector3 from, vector3 to) {
        double dotProduct = from dot to;
        dotProduct /= v3magnatude(from) * v3magnatude(to);
        return acos(dotProduct) * 180.0 / M_PI;
    }

    static double v3Distance(vector3 from, vector3 to) {
        vector3 dv = from - to;
        return sqrt(dv.x * dv.x + dv.y * dv.y + dv.z * dv.z);
    }
    static vector3 v3Direction(vector3 from, vector3 to) {
        vector3 dv = to - from;
        return v3normalize(dv);
    }

    static vector3 v3Bounce(vector3 point, vector3 normal) {
        vector3 scaled = (-2.0 * normal dot point) * normal;
        return scaled + point;
    }

    static double GetHeading(vector3 a, vector3 b) {
        double x = b.x - a.x;
        double y = b.y - a.y;
        return atan2(y, x) * (180.0 / M_PI);
    }

    static vector3 Vector3ToEularAngles(Vector3 v) {
        double angle = atan2(v.y, v.x);
        double pitch = atan2(-v.z, sqrt(v.x ** 2 + v.y ** 2));
        double roll = atan2(
            v.x * sin(angle) - v.y * cos(angle),
            v.x * cos(angle) + v.y * sin(angle)
        );

        return (angle, pitch, roll);
    }

    // Used to convert Velocity to Facing Angle, Pitch, and Roll
    static vector3 GetEularFromVelocity(Vector3 v) {
        vector3 norm = LemonUtil.v3normalize(v);
        return Vector3ToEularAngles(norm);
    }


    // Easings
    static double Easing_Quadradic_In(double val) {
        return val*val;
    }
    static double Easing_Quadradic_Out(double val) {
        return val * ( 2.0 - val);
    }

    static double Easing_Bounce_Out(double val) {		
        if (val < (1.0/2.75)) {
            return 7.5625*val*val;				
        }
        else if (val < (2.0/2.75)) {
            return 7.5625*(val -= (1.5/2.75f))*val + 0.75;
        }
        else if (val < (2.5/2.75)) {
            return 7.5625 *(val -= (2.25/2.75))*val + 0.9375;
        }
        else {
            return 7.5625*(val -= (2.625/2.75))*val + 0.984375;
        }
    }

    static double MathPI() {
        return 3.141592653589793238462643383279502884197;
    }

    static double GetDegrees() {
        return 180.0 / LemonUtil.MathPI();
    }
}