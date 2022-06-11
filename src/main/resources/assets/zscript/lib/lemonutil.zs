// https://zdoom.org/wiki/ZScript_actor_functions

class LemonUtil {
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
        return (vec.x / mag, vec.y / mag);
    }
    
    static double v3magnatude(vector3 vec) {
        return sqrt(vec.x * vec.x + vec.y * vec.y + vec.z * vec.z);
    }
    static vector3 v3normalize(vector3 vec) {
        double mag = v3magnatude(vec);
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
}