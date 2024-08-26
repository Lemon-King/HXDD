
// ref: https://github.com/videogamepreservation/hexen2/blob/eac5fd50832ce2509226761b3b1a387c468e7a50/H2MP/hcode/WORLD.hc#L236
// Setup light animation tables. 'a' is total darkness, 'z' is maxbright.
// lightstyle(EF_TORCHLIGHT, "knmonqnmolm");

// ref: https://github.com/videogamepreservation/hexen2/blob/master/H2MP/hcode/artifact.hc#L429

class HX2PowerTorch : Powerup {
    String lightStyle;
    String styleDefs;

    Property lightStyle: LightStyle;
    Property styleDefs: StyleDefs;

    PointLight light;

    int lightIdx;

    double lifeTime;

	Default {
		Powerup.Duration -30;
        HX2PowerTorch.LightStyle "knmonqnmolm";
        HX2PowerTorch.StyleDefs "abcdefghijklmnopqrstuvwxyz";
	}

    override void InitEffect() {
        Super.InitEffect();

        if (!self.owner) {
            return;
        }

        self.lifeTime = -30.0;

        PlayerPawn pp = PlayerPawn(self.owner);
        self.owner.A_AttachLight("hx2torch", DynamicLight.PointLight, color(255, 255, 165, 0), 200, 200, 0, (0,0, pp.viewheight));

        self.owner.A_StartSound("hexen2/raven/littorch", CHAN_7, CHANF_DEFAULT | CHANF_OVERLAP, 1, ATTN_NORM);
        self.owner.A_StartSound("hexen2/raven/fire1", CHAN_7, CHANF_LOOPING | CHANF_OVERLAP, 1, ATTN_NORM);
    }

	override void DoEffect () {
		Super.DoEffect ();

        // Doesn't seem to trigger in a WaterZone
        // BUG? https://discord.com/channels/268086704961748992/268877450652549131/619193631022120960
        if (CurSector.MoreFlags & Sector.SECMF_UNDERWATER) {
            EffectKillTorch();
            self.Destroy();
            return;
        }

        self.lifeTime += (1 / TICRATEF);

        String idxChar = self.lightStyle.mid(lightIdx, 1);
        int val = self.styleDefs.indexOf(idxChar);
        double power = double(val) / double(self.styleDefs.Length());

        int lightMode = 0;
        double radius = 200;
        if (self.lifeTime >= -7.0) {
            radius += random(0,32767) % 31;
            lightMode = DYNAMICLIGHT.LF_ATTENUATE;
        }

        PlayerPawn pp = PlayerPawn(self.owner);
        Vector3 col = (255,165,0) * power;
        self.owner.A_AttachLight("hx2torch", DynamicLight.PointLight, color(255, int(col.x), int(col.y), int(col.z)), radius, radius, lightMode, (0,0, pp.viewheight));

        self.lightIdx = (lightIdx + 1) % self.lightStyle.Length();
	}

	override void EndEffect () {
		Super.EndEffect();

        EffectKillTorch();
	}

    override void OnDestroy() {
        Super.OnDestroy();
    }

    void EffectKillTorch() {
        if (!self.owner) {
            return;
        }

        String sfx = "hexen2/raven/kiltorch";
        if (CurSector.MoreFlags & Sector.SECMF_UNDERWATER || CurSector.MoreFlags & Sector.SECMF_FORCEDUNDERWATER) {
            sfx = "hexen2/raven/douse";
        }
        self.owner.A_RemoveLight ("hx2torch");

        self.owner.A_StopSound(CHAN_7);
        self.owner.A_StartSound(sfx, CHAN_7, CHANF_DEFAULT | CHANF_OVERLAP, 1, ATTN_NORM);
    }

}