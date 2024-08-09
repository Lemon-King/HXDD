
// Parents standard Statusbars allowing runtime choice

class HXDDStatusBar : BaseStatusBar {
	BaseStatusBar active;
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
		if (self.active is self.selected) {
			self.active.Tick();
		} else {
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
			if (!sBarClass || !sbar) {
				console.printf("HXDDSelectorStatusBar: Failed to create StatusBar [%s]!", self.selected);
				LemonUtil.CVAR_SetString("hxdd_statusbar_class", "HXDDHereticSplitStatusBar", CPlayer);
			}
		}
	}

	override void Draw (int state, double TicFrac) {
		Super.Draw(state, TicFrac);

		if (self.active) {
			self.active.Draw(state, TicFrac);
		}
	}

	void InitStatusBar(BaseStatusBar sbar) {
		sbar.AttachToPlayer(CPlayer);
		sbar.Init();
		sbar.NewGame();
	}
}