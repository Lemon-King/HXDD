
// Parents standard Statusbars allowing runtime choice

class HXDDStatusBar : BaseStatusBar {
	BaseStatusBar active;
	Name selected;
	Name defaultStatusBar;


	override void Init() {
		Super.Init();
	}

	override void NewGame () {
		Super.NewGame();
		RefreshSelected();
	}

	override void Tick() {
		Super.Tick();

		if (self.active is self.selected) {
			self.active.Tick();
		} else {
			RefreshSelected();
		}
	}

	override void Draw (int state, double TicFrac) {
		Super.Draw(state, TicFrac);

		if (menuactive || paused) {
			RefreshSelected();
			if (self.active is self.selected) {
				self.active.Tick();
			}
		}

		if (self.active) {
			self.active.Draw(state, TicFrac);
		}
	}

	void InitStatusBar(BaseStatusBar sbar) {
		sbar.AttachToPlayer(CPlayer);
		sbar.Init();
		sbar.NewGame();
	}

	void RefreshSelected() {
		// Check CVAR
		if (CPlayer.mo) {
			PlayerSlot pSlot = HXDDPlayerStore.UI_GetPlayerSlot(CPlayer.mo.PlayerNumber());
			if (pSlot) {
				if (pSlot.defaultStatusBar) {
					self.defaultStatusBar = pSlot.defaultStatusBar;
				} else {
					//
					// Crashes loading SBarInfoWrapper, this is due to core C++ binding
					/*
					int lumpIndex = Wads.CheckNumForFullName("SBARINFO");
					if (lumpIndex == -1) {
						lumpIndex = Wads.CheckNumForFullName("sbarinfo");
					}
					if (lumpIndex != -1) {
						self.defaultStatusBar = "SBarInfoWrapper";
					}
					*/
					if (LemonUtil.IsGameType(GAME_Doom)) {
						self.defaultStatusBar = "DoomStatusBar";
					} else {
						self.defaultStatusBar = "HXDDHereticSplitStatusBar";
					}
				}
			}
		}
		Name cvarSelected = LemonUtil.CVAR_GetString("hxdd_statusbar_class", "HXDDHereticSplitStatusBar", CPlayer);
		if (cvarSelected == "default") {
			self.selected = self.defaultStatusBar;
		} else {
			self.selected = cvarSelected;
		}
		if (!(self.active is self.selected)) {
			// try creating?
        	BaseStatusBar sbar;
			Name sBarClass = self.selected;
			class<BaseStatusBar> cls = sBarClass;
			if (cls != null) {
				sbar = BaseStatusBar(new(cls));
				if (sbar) {
					self.active = sbar;
					self.InitStatusBar(self.active);
				}
			}
		}
	}
}