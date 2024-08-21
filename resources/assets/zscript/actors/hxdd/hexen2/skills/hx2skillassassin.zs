class HX2SkillAssassinPlayer: HXDDSkillBase {
	override void Tick() {
		Super.Tick();

		// NYI: Just testing tech
		// TODO: Move into a permanant powerup / item
        if (!owner) {
            return;
        }
		Progression prog = Progression(Owner.mo.FindInventory("Progression"));
		if (prog) {
			if (Player && prog.currlevel >= 0) {
				//GetActorLightLevel
				// Check Player Light level, update stealth state
				if (!(self.owner.mo.InStateSequence(self.owner.mo.CurState, Owner.mo.FindState("Death")) || self.owner.mo.InStateSequence(self.owner.mo.CurState, Owner.mo.FindState("XDeath")))) {
					int curLightLevel = self.owner.cursector.GetLightLevel();
					double stealthChange = 0;
					double lightHigh = 100;
					if (curLightLevel <= lightHigh) {
						stealthChange = -curLightLevel * 0.00075f;
					} else {
						stealthChange = (255.0f - curLightLevel) * 0.00025f;
					}

					stealthLevel = Clamp(stealthLevel + stealthChange, 0.0f, 1.0f);

					int style = STYLE_Fuzzy; //STYLE_Shaded;
					if (LemonUtil.IsGameType(GAME_Doom)) {
						style = STYLE_Fuzzy;
					}
					if (stealthLevel == 1.0) {
						self.owner.Alpha = 1.0f;
						A_SetRenderStyle(1, STYLE_Normal);
					} else {
						self.owner.Alpha = 1.0f;
						A_SetRenderStyle(1, style);
					}
				}
			}
		}
	}
}