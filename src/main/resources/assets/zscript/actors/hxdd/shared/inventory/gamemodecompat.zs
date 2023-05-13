
/*
 * Lets Heretic and Hexen Classes scale in either map set.
 * Uses cvar hxdd_gamemode to force Heretic or Hexen.
 */

class GameModeCompat: Inventory {
    float DamageMult;

	Default {
		+INVENTORY.KEEPDEPLETED
        +INVENTORY.HUBPOWER
        +INVENTORY.UNDROPPABLE
        +INVENTORY.UNTOSSABLE
        +INVENTORY.UNCLEARABLE
        -INVENTORY.INVBAR
	}

	override void BeginPlay() {
		Super.BeginPlay();

        DamageMult = 1.0;
	}

	override void PostBeginPlay() {
		Super.PostBeginPlay();

		int cvarGameMode = LemonUtil.GetOptionGameMode();
        if (cvarGameMode == GAME_Heretic) {
            SetDamageScale_Heretic();
            SetPlayerSize_Heretic();
        } else if (cvarGameMode == GAME_Hexen) {
            SetDamageScale_Hexen();
            SetPlayerSize_Hexen();
        }
    }

    override void ModifyDamage(int damage, Name damageType, out int newdamage, bool passive, Actor inflictor, Actor source, int flags) {
        if (!passive && damage > 0) {
            newdamage = max(0, ApplyDamageFactors(GetClass(), damageType, damage, damage * DamageMult));
        }
    }

    void SetDamageScale_Heretic() {
        if (owner.player.mo is "DoomPlayer" || owner.player.mo is "HereticPlayer" || owner.player.mo is "HXDDHexenIIPlayerPawn") {
            DamageMult = 1.0;
        } else {
            DamageMult = 0.5;
        }
    }
    void SetDamageScale_Hexen() {
        if (owner.player.mo is "DoomPlayer" || owner.player.mo is "HereticPlayer" || owner.player.mo is "HXDDHexenIIPlayerPawn") {
            DamageMult = 2.0;
        } else {
            DamageMult = 1.0;
        }
    }
    void SetPlayerSize_Heretic() {
        PlayerPawn p = PlayerPawn(owner.player.mo);
        if (p.Height == 56) {
            return;
        }
        // Doom & Heretic Bounds
        p.A_SetSize(p.Radius, 56);
        //p.Viewheight = 41;
        //owner.player.ViewHeight = p.Viewheight;
        double nextScale = 56.0 / 64.0;
        p.A_SetScale(nextScale,nextScale);
        p.Viewheight = p.Viewheight * nextScale;
        owner.player.ViewHeight = p.Viewheight;
    }
    void SetPlayerSize_Hexen() {
        PlayerPawn p = PlayerPawn(owner.player.mo);
        if (p.Height == 64) {
            return;
        }
		// Hexen Bounds
        //p.Viewheight = 48
        //owner.player.ViewHeight = p.Viewheight;
        p.A_SetSize(p.Radius, 64);
        double nextScale = 64.0 / 56.0;
        p.Viewheight = p.Viewheight * nextScale;
        owner.player.ViewHeight = p.Viewheight;
        p.A_SetScale(nextScale,nextScale);
    }
}