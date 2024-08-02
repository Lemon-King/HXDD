
// Parents standard Statusbars allowing runtime choice

class HXDDStatusBar : BaseStatusBar {
    Map<String,BaseStatusBar> mStatusBars;

	String selected;

	override void Init() {
		Super.Init();
	}

	override void NewGame () {
		Super.NewGame();
	}

	override void Tick() {
		Super.Tick();

		// Check CVAR
		self.selected = LemonUtil.CVAR_GetString("hxdd_statusbar_class", "HXDDHereticSplitStatusBar", CPlayer);

        BaseStatusBar sbar;
        bool exists = false;
        [sbar, exists] = self.mStatusBars.CheckValue(self.selected);
		if (exists) {
			sbar.Tick();
		} else {
			// try creating?
			sbar = BaseStatusBar(new(self.selected));
			if (sbar) {
				self.mStatusBars.Insert(self.selected, sbar);
				self.InitStatusBar(sbar);
			} else {
				console.printf("HXDDSelectorStatusBar: Failed to create StatusBar [%s]!", self.selected);
				LemonUtil.CVAR_SetString("hxdd_statusbar_class", "HXDDHereticSplitStatusBar", CPlayer);
			}
		}
	}

	override void Draw (int state, double TicFrac) {
		Super.Draw(state, TicFrac);
    
        BaseStatusBar sbar;
        bool exists = false;
        [sbar, exists] = self.mStatusBars.CheckValue(self.selected);
		if (exists) {
			sbar.Draw(state, TicFrac);
		}
	}

	void InitStatusBar(BaseStatusBar sbar) {
		sbar.Init();
		sbar.AttachToPlayer(CPlayer);
		sbar.NewGame();
	}
}