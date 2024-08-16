
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

		self.RefreshGameMode();
    }

    override void Travelled() {
        self.RefreshGameMode();
    }

    override void ModifyDamage(int damage, Name damageType, out int newdamage, bool passive, Actor inflictor, Actor source, int flags) {
        if (!passive && damage > 0) {
            newdamage = max(0, ApplyDamageFactors(GetClass(), damageType, damage, damage * DamageMult));
        }
    }

    void RefreshGameMode() {
		int cvarGameMode = LemonUtil.GetOptionGameMode();
        if (LemonUtil.IsGameType(GAME_Doom) || cvarGameMode == GAME_Heretic) {
            SetDamageScale_Standard();
            SetPlayerSize_Standard();
        } else if (cvarGameMode == GAME_Hexen) {
            SetDamageScale_Hexen();
            SetPlayerSize_Hexen();
        }
    }

    void SetDamageScale_Standard() {
        if (!(owner.player.mo is "DoomPlayer" || owner.player.mo is "HereticPlayer" || owner.player.mo is "HXDDHexenIIPlayerPawn")) {
            DamageMult = 0.5;
        }
    }
    void SetDamageScale_Hexen() {
        if (owner.player.mo is "DoomPlayer" || owner.player.mo is "HereticPlayer" || owner.player.mo is "HXDDHexenIIPlayerPawn") {
            DamageMult = 1.5;
        }
    }
    void SetPlayerSize_Standard() {
        // Doom / Heretic Bounds
        int targetHeight = 56;
        PlayerClass primaryPlayerClass;
        primaryPlayerClass = PlayerClasses[0];
        let playerDefaults = GetDefaultByType(primaryPlayerClass.Type);
        if (playerDefaults) {
            targetHeight = playerDefaults.Height;
        }
        self.ScalePlayerPawn(targetHeight);
    }
    void SetPlayerSize_Hexen() {
		// Hexen Bounds
        self.ScalePlayerPawn(64);
    }

    void ScalePlayerPawn(int targetHeight) {
        PlayerPawn pp = PlayerPawn(owner.player.mo);
        if (pp.Height == targetHeight) {
            return;
        }

        let ppDefault = GetDefaultByType(pp.GetClass());
        double nextScale = targetHeight / ppDefault.height;
        pp.A_SetSize(ppDefault.Radius, targetHeight);
        pp.A_SetScale(nextScale,nextScale);
        pp.Viewheight = ppDefault.Viewheight * nextScale;
        owner.player.ViewHeight = ppDefault.Viewheight;
    }
}