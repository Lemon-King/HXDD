
class LemonActor {
    // ref: https://github.com/videogamepreservation/hexen2/blob/eac5fd50832ce2509226761b3b1a387c468e7a50/H2W/Client/r_alias.c#L958
    // Emulates the Pickup Glow from Hexen II
    static int HX2RenderPickupGlow(Actor source) {
        double quakeOverbright = 2.0;
        int curLightLevel = source.cursector.GetLightLevel();
        int ambLightLevel = clamp(5, (60.0 + 34.0 + sin((source.pos.x + source.pos.y + (level.MapTime * 3.8))) * 34.0), 255);
        return curLightLevel + ambLightLevel;
    }
}