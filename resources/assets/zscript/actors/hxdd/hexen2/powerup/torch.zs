
// ref: https://github.com/videogamepreservation/hexen2/blob/eac5fd50832ce2509226761b3b1a387c468e7a50/H2MP/hcode/WORLD.hc#L236
// ref: https://github.com/videogamepreservation/hexen2/blob/master/H2MP/hcode/artifact.hc#L429
// Setup light animation tables. 'a' is total darkness, 'z' is maxbright.

class HX2PowerTorch : Powerup {
    String lightStyle;
    String styleDefs;

    Property lightStyle: LightStyle;
    Property styleDefs: StyleDefs;

    PointLight light;

    int lightIdx;

    int lifeTime;

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

        self.lifeTime = -30;

        PlayerPawn pp = PlayerPawn(self.owner);
        self.owner.A_AttachLight("hx2torch", DynamicLight.PointLight, color(255, 255, 165, 0), 200, 200, DYNAMICLIGHT.LF_ATTENUATE, (0,0, pp.viewheight + 5));

        self.owner.A_StartSound("hexen2/raven/littorch", CHAN_6, CHANF_DEFAULT | CHANF_OVERLAP, 1, ATTN_NORM);
        self.owner.A_StartSound("hexen2/raven/fire1", CHAN_7, CHANF_LOOPING | CHANF_OVERLAP, 1, ATTN_NORM);
    }

	override void DoEffect () {
		Super.DoEffect ();

        self.lifeTime += (1 / 35);

        String idxChar = self.lightStyle.mid(lightIdx, 1);
        int val = self.styleDefs.indexOf(idxChar);
        double power = double(val) / double(self.styleDefs.Length());

        double radius = 200;
        if (self.lifeTime >= -7) {
            radius += random(0,32767) % 31;
        }

        PlayerPawn pp = PlayerPawn(self.owner);
        Vector3 col = (255,165,0) * power;
        self.owner.A_AttachLight("hx2torch", DynamicLight.PointLight, color(255, int(col.x), int(col.y), int(col.z)), radius, radius, DYNAMICLIGHT.LF_ATTENUATE, (0,0, pp.viewheight + 5));

        self.lightIdx = (lightIdx + 1) % self.lightStyle.Length();
	}

	override void EndEffect () {
		Super.EndEffect();

        if (!self.owner) {
            return;
        }

        self.owner.A_RemoveLight ("hx2torch");

        self.owner.A_StopSound(CHAN_7);
        self.owner.A_StartSound("hexen2/raven/kiltorch", CHAN_6 | CHANF_OVERLAP, CHANF_DEFAULT, 1, ATTN_NORM);
	}

    override void OnDestroy() {
        EndEffect();
        Super.OnDestroy();
    }
}