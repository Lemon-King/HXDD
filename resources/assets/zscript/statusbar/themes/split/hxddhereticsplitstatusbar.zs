class HXDDHereticSplitStatusBar : BaseStatusBar {
	const BAR_SHIFT_RATE = 0.1;
	const BAR_SHIFT_DECAY = 0.8;
	
	const VIEW_SHIFT_RATE = 0.15;
	const VIEW_SHIFT_DECAY = 0.85;

	const BAR_SCREEN_WIDTH = 2560;
	const BAR_SCREEN_HEIGHT = 1440;

	const invAnimationDuration = 0.75;

	private double shiftX;
	private double shiftY;
	private vector3 vecFacing;
	private vector3 vecFacingLast;
	private vector3 vecMotion;
	private vector2 vecViewMotion;

	private vector3 vecLastPos;

	private vector2 vecView;
	private vector2 vecLastView;
	private double viewDist;
	private double viewDistLast;

	private vector2 screenScale;

	private double invTime;



	DynamicValueInterpolator mHealthInterpolator;
	DynamicValueInterpolator mHealthInterpolator2;
	DynamicValueInterpolator mArmorInterpolator;
	DynamicValueInterpolator mACInterpolator;
	DynamicValueInterpolator mXPInterpolator;
	DynamicValueInterpolator mAmmoInterpolator;
	DynamicValueInterpolator mAmmoInterpolator2;
	HUDFont mHUDFont;
	HUDFont mIndexFont;
	HUDFont mBigFont;
	InventoryBarState diparms;
	InventoryBarState diparms_sbar;
	private int hwiggle;

	private bool useHereticKeys;

	private int mHUDFontWidth;

	private int gemColorAssignment;

	private bool hasACArmor;

	Progression prog;

	float GetVelocityScale() {
		return LemonUtil.CVAR_GetFloat("hxdd_statusbar_velocity_scale", 1.0, CPlayer);
	}

	void UpdateProgression() {
		if (CPlayer.mo is "PlayerPawn") {
			prog = Progression(CPlayer.mo.FindInventory("Progression"));
		}
	}

	int GetPlayerLevel() {
		if (prog) {
			return prog.currlevel;
		}
		return 0;
	}

	String GetPlayerExperience() {
		if (prog) {
			return String.format("%.2f", mXPInterpolator.GetValue());
		}
		return "";
	}

	int GetPlayerProgressionType() {
		if (prog) {
			return prog.ProgressionType;
		}
		return PSP_NONE;
	}

	bool IsPlayerArmorAC() {
		if (prog) {
			return prog.ArmorType == PSAT_ARMOR_HXAC;
		}
		return false;
	}

	void SetFields() {
		SetSize(0, 320, 200);
		CompleteBorder = true;
	}

	override void Init() {
		Super.Init();

		BeginHUD();
		SetFields();

		// Create the font used for the fullscreen HUD
		Font fnt = "HUDFONT_RAVEN";
		mHUDFontWidth = fnt.GetCharWidth("0") + 1;
		mHUDFont = HUDFont.Create(fnt, mHUDFontWidth, Mono_CellLeft, 1, 1);
		fnt = "INDEXFONT_RAVEN";
		mIndexFont = HUDFont.Create(fnt, fnt.GetCharWidth("0"), Mono_CellLeft);
		fnt = "BigFontX";
		mBigFont = HUDFont.Create(fnt, fnt.GetCharWidth("0"), Mono_CellLeft, 2, 2);
		diparms = InventoryBarState.Create(mIndexFont);
		diparms_sbar = InventoryBarState.CreateNoBox(mIndexFont, boxsize:(31, 31), arrowoffs:(0,-10));
		mHealthInterpolator = DynamicValueInterpolator.Create(0, 0.25, 1, 8);
		mHealthInterpolator2 = DynamicValueInterpolator.Create(0, 0.25, 1, 6);	// the chain uses a maximum of 6, not 8.
		mArmorInterpolator = DynamicValueInterpolator.Create(0, 0.25, 1, 8);
		mACInterpolator = DynamicValueInterpolator.Create(0, 0.25, 1, 8);
		mXPInterpolator = DynamicValueInterpolator.Create(0, 0.25, 1, 8);
		mAmmoInterpolator = DynamicValueInterpolator.Create(0, 0.25, 1, 3);
		mAmmoInterpolator2 = DynamicValueInterpolator.Create(0, 0.25, 1, 3);

		useHereticKeys = LemonUtil.IsMapEpisodic();
	}

	override void NewGame () {
		Super.NewGame();
		mHealthInterpolator.Reset(0);
		mHealthInterpolator2.Reset(0);
		mArmorInterpolator.Reset(0);
		mACInterpolator.Reset(0);
		mXPInterpolator.Reset(0);
		mAmmoInterpolator.Reset(0);
		mAmmoInterpolator2.Reset(0);

		self.shiftX = 0;

		if (CPlayer.mo) {
			self.vecLastPos = CPlayer.mo.pos;
		}
	}

	override int GetProtrusion(double scaleratio) const {
		return 0;
	}

	override void Tick() {
		Super.Tick();
		mHealthInterpolator.Update(CPlayer.health);
		mHealthInterpolator2.Update(CPlayer.health);

		UpdateProgression();

		screenScale = (BAR_SCREEN_WIDTH, BAR_SCREEN_HEIGHT);
		screenScale = (Screen.GetWidth() / screenScale.x, Screen.GetHeight() / screenScale.y);

		if (prog) {
			if (prog.ProgressionType == PSP_LEVELS) {
				mXPInterpolator.Update(prog.levelpct);
			}
			if (prog.ArmorType == PSAT_ARMOR_HXAC) {
				mACInterpolator.Update(GetArmorSavePercent());
			} else {
				mArmorInterpolator.Update(GetArmorAmount());
			}
		}

		Ammo ammo1, ammo2;
		[ammo1, ammo2] = GetCurrentAmmo();
		if(ammo1) {
			mAmmoInterpolator.Update(ammo1.Amount);
		}
		if (ammo2) {
			mAmmoInterpolator2.Update(ammo2.Amount);
		}

		if (CPlayer.mo) {
			// Captures player motion, angle, and pitch without hacky input reading

			double angle = CPlayer.mo.angle;
			vector2 forward = (cos(angle), sin(angle));
			vector2 right = (cos(angle - 90), sin(angle - 90));

			if (abs(CPlayer.mo.pos.Length() - self.vecLastPos.Length()) > 80.0) {
				self.vecLastPos = CPlayer.mo.pos;
			}

			// Position comparison is a little more cycle intensive than capturing from mo.vel but allows me to capture motion from lifts and other actions on the player
			vector3 comp = CPlayer.mo.pos - self.vecLastPos;
			self.vecLastPos = CPlayer.mo.pos;
			double resultForward = (comp.x, comp.y) dot forward;
			double resultRight = (comp.x, comp.y) dot right;

			self.vecFacingLast = self.vecFacing;
			self.vecFacing = (resultForward, resultRight, comp.z);
			if (abs(self.vecFacing.Length() - self.vecFacingLast.Length()) > 5.0) {
				// Player camera latched to something (Hexen Melee), update coords to current and treat as 0 distance
				self.vecFacingLast = self.vecFacing;
			}

			// View Angle/Pitch capture and comparison
			self.vecLastView = self.vecView;
			self.vecView = (angle, CPlayer.mo.Pitch);
			//console.printf("Dist: %0.8f", abs(self.vecView.Length() - self.vecLastView.Length()));
			self.viewDistLast = self.viewDist;
			self.viewDist = abs(self.vecView.Length() - self.vecLastView.Length());
			if (abs(self.viewDistLast - self.viewDist) > 30.0) {
				//console.printf("Dist Jump: %0.8f", abs(self.vecView.Length() - self.vecLastView.Length()));
				// Player camera latched to something (Hexen Melee), update coords to current and treat as 0 distance
				self.vecLastView = self.vecView;
			}

			// motion computation
			self.vecMotion += (self.vecFacing / CPlayer.mo.speed) * BAR_SHIFT_RATE;
			self.vecMotion *= BAR_SHIFT_DECAY;

			self.vecViewMotion += (self.vecView.x - self.vecLastView.x, self.vecView.y - self.vecLastView.y) * VIEW_SHIFT_RATE;
			self.vecViewMotion *= VIEW_SHIFT_DECAY;

		}
	}

	override void Draw (int state, double TicFrac) {
		Super.Draw(state, TicFrac);

		BeginHud();
		SetFields();
		if (automapactive) {
			// draw automap stuff
		} else {
			DrawFullScreen();
		}
	}

	protected void DrawFullScreen() {
		// Simulates motion on the status bar depending on player movement speed, direction, angle, pitch, and mouse movement.

		double motionXWeight = self.vecMotion.x * 0.8;
		double motionZWeight = self.vecMotion.z * 0.25;
		double viewPitch = self.vecView.y / 90.0;
		double viewPitchInverse = 1.0 - abs(viewPitch);

		vector3 view = (0,0,0);

		// Left Side
		view.x = -motionXWeight + -motionZWeight;
		view.x *= viewPitchInverse;
		view.x += -self.vecMotion.y;
		view.x += self.vecViewMotion.x;

		// Vertical Motion
		view.y = motionXWeight;
		view.y *= viewPitchInverse;
		view.y += motionXWeight * (viewPitch);
		view.y += (self.vecMotion.z * 1.1) * viewPitchInverse;
		view.y += -self.vecViewMotion.y;

		// Right Side
		view.z = motionXWeight + motionZWeight;
		view.z *= viewPitchInverse;
		view.z += -self.vecMotion.y;
		view.z += self.vecViewMotion.x;

		view = (view.x * screenScale.x, view.y * screenScale.y, view.z * screenScale.x);
		view *= self.GetVelocityScale();

		vector2 v2Left = (view.x, view.y);
		vector2 v2Center = (-self.vecMotion.y + self.vecViewMotion.x, view.y);
		vector2 v2Right = (view.z, view.y);

		double anchorLeft = 128;
		double anchorRight = -128 - 12;	// offset by 12 to match pixel width of FS_HERETIC_SBAR_LEFT.png
		double anchorBottom = -15;


		String imgFrameLeft = "assets/ui/FS_HERETIC_SBAR_LEFT.png";
		if (prog && prog.ArmorType == PSAT_ARMOR_HXAC) {
			imgFrameLeft = "assets/ui/FS_HERETIC_SBAR_LEFT_AC.png";
		}
		DrawImage(imgFrameLeft, (anchorLeft, -15) + v2Left, DI_SCREEN_LEFT_BOTTOM | DI_ITEM_LEFT_BOTTOM);

		if (prog && prog.ProgressionType == PSP_LEVELS) {
			// draw xp bar
			DrawImage("assets/ui/FS_HERETIC_SBAR_LEFT_XP_LEFTSIDE.png", (anchorLeft - 63, anchorBottom) + v2Left, DI_SCREEN_LEFT_BOTTOM | DI_ITEM_LEFT_BOTTOM);

			DrawString(mIndexFont, FormatNumber(prog.currlevel), (anchorLeft - 46, anchorBottom - 15) + v2Left, DI_SCREEN_LEFT_BOTTOM | DI_TEXT_ALIGN_LEFT);
			DrawBarHXDD("assets/ui/FS_HERETIC_SBAR_LEFT_XP_BAR_FILL_SMALL.png", "", mXPInterpolator.GetValue(), 100, (anchorLeft - 57, anchorBottom - 5) + v2Left, 0, SHADER_HORZ, DI_SCREEN_LEFT_BOTTOM | DI_ITEM_LEFT_BOTTOM);
		}

		DrawImage("assets/ui/FS_HERETIC_SBAR_RIGHT_NOKEYS.png", (anchorRight, anchorBottom) + v2Right, DI_SCREEN_RIGHT_BOTTOM | DI_ITEM_RIGHT_BOTTOM);

		if (LemonUtil.IsGameType(GAME_Doom)) {
			// DOOM Keys
			DrawImage("assets/ui/FS_HERETIC_SBAR_RIGHT_KEYS_EMPTY.png", (anchorRight - 79, anchorBottom) + v2Right, DI_SCREEN_RIGHT_BOTTOM | DI_ITEM_RIGHT_BOTTOM);		bool locks[6];
			String image;
			for(int i = 0; i < 6; i++) locks[i] = CPlayer.mo.CheckKeys(i + 1, false, true);
			// key 1
			if (locks[1] && locks[4]) image = "STKEYS6";
			else if (locks[1]) image = "STKEYS0";
			else if (locks[4]) image = "STKEYS3";
			DrawImage(image, (anchorRight - 94, anchorBottom - 20) + v2Right, DI_SCREEN_RIGHT_BOTTOM | DI_ITEM_RIGHT_BOTTOM);
			// key 2
			if (locks[2] && locks[5]) image = "STKEYS7";
			else if (locks[2]) image = "STKEYS1";
			else if (locks[5]) image = "STKEYS4";
			else image = "";
			DrawImage(image, (anchorRight - 94, anchorBottom - 12) + v2Right, DI_SCREEN_RIGHT_BOTTOM | DI_ITEM_RIGHT_BOTTOM);
			// key 3
			if (locks[0] && locks[3]) image = "STKEYS8";
			else if (locks[0]) image = "STKEYS2";
			else if (locks[3]) image = "STKEYS5";
			else image = "";
			DrawImage(image, (anchorRight - 94, anchorBottom - 4) + v2Right, DI_SCREEN_RIGHT_BOTTOM | DI_ITEM_RIGHT_BOTTOM);
		} else if (LemonUtil.IsMapEpisodic()) {
			// Heretic Keys
			DrawImage("assets/ui/FS_HERETIC_SBAR_RIGHT_KEYS.png", (anchorRight - 79, anchorBottom) + v2Right, DI_SCREEN_RIGHT_BOTTOM | DI_ITEM_RIGHT_BOTTOM);
			if (CPlayer.mo.CheckKeys(3, false, true)) DrawImage("YKEYICON", (anchorRight - 94, anchorBottom - 20) + v2Right, DI_SCREEN_RIGHT_BOTTOM | DI_ITEM_RIGHT_BOTTOM);
			if (CPlayer.mo.CheckKeys(1, false, true)) DrawImage("GKEYICON", (anchorRight - 94, anchorBottom - 12) + v2Right, DI_SCREEN_RIGHT_BOTTOM | DI_ITEM_RIGHT_BOTTOM);
			if (CPlayer.mo.CheckKeys(2, false, true)) DrawImage("BKEYICON", (anchorRight - 94, anchorBottom - 4) + v2Right, DI_SCREEN_RIGHT_BOTTOM | DI_ITEM_RIGHT_BOTTOM);
		} else if (LemonUtil.IsMapLinear()) {
			// Hexen Keys
		}

		// draw all text
		String strHealthValue = String.format("%d", mHealthInterpolator.GetValue());
		int wStrHealthWidth = mHUDFontWidth * strHealthValue.Length();

		DrawString(mHUDFont, FormatNumber(mHealthInterpolator.GetValue()), ((anchorLeft + 81) - (wStrHealthWidth / strHealthValue.Length()), anchorBottom - 17) + v2Left, DI_SCREEN_LEFT_BOTTOM | DI_TEXT_ALIGN_CENTER | DI_ITEM_CENTER);

		double armorValue = mArmorInterpolator.GetValue();
		if (prog) {
			armorValue = prog.ArmorType == PSAT_ARMOR_HXAC ? mACInterpolator.GetValue() / 5.0 : mArmorInterpolator.GetValue();
		}
		String strArmorValue = String.format("%d", armorValue);
		int wStrArmorWidth = mHUDFontWidth * strArmorValue.Length();
		DrawString(mHUDFont, FormatNumber(armorValue), ((anchorLeft + 30) - (wStrArmorWidth / strArmorValue.Length()), anchorBottom - 17) + v2Left, DI_SCREEN_LEFT_BOTTOM | DI_TEXT_ALIGN_CENTER | DI_ITEM_CENTER);

		Ammo ammo1, ammo2;
		[ammo1, ammo2] = GetCurrentAmmo();
		if (ammo1 != null && ammo2 == null) {
			DrawString(mHUDFont, FormatNumber(mAmmoInterpolator.GetValue(), 3), (anchorRight - 50, anchorBottom - 28) + v2Right, DI_SCREEN_RIGHT_BOTTOM | DI_TEXT_ALIGN_RIGHT);
			DrawTexture(ammo1.icon, (anchorRight - 63, anchorBottom - 10) + v2Right, DI_SCREEN_RIGHT_BOTTOM | DI_ITEM_CENTER);
		} else if (ammo2 != null) {
			DrawString(mIndexFont, FormatNumber(mAmmoInterpolator.GetValue(), 3), (anchorRight - 50, anchorBottom - 28) + v2Right, DI_SCREEN_RIGHT_BOTTOM | DI_TEXT_ALIGN_RIGHT);
			DrawString(mIndexFont, FormatNumber(mAmmoInterpolator2.GetValue(), 3), (anchorRight - 50, anchorBottom - 14) + v2Right, DI_SCREEN_RIGHT_BOTTOM | DI_TEXT_ALIGN_RIGHT);
			DrawTexture(ammo1.icon, (anchorRight - 72, anchorBottom - 22) + v2Right, DI_SCREEN_RIGHT_BOTTOM | DI_ITEM_CENTER);
			DrawTexture(ammo2.icon, (anchorRight - 72, anchorBottom - 10) + v2Right, DI_SCREEN_RIGHT_BOTTOM | DI_ITEM_CENTER);
		}

		double posx = anchorRight + 67;
		double posy = anchorBottom;
		if (CPlayer.mo is "ClericPlayer") {
			DrawImage("WPSLOT1", (posx, posy) + v2Right, DI_SCREEN_RIGHT_BOTTOM | DI_ITEM_RIGHT_BOTTOM);
			if (CheckInventory("CWeapWraithverge")) DrawImage("WPFULL1", (posx, posy) + v2Right, DI_SCREEN_RIGHT_BOTTOM | DI_ITEM_RIGHT_BOTTOM);
			else
			{
				int pieces = GetWeaponPieceMask("CWeapWraithverge");
				if (pieces & 1) DrawImage("WPIECEC1", (posx - 34, posy) + v2Right, DI_SCREEN_RIGHT_BOTTOM | DI_ITEM_RIGHT_BOTTOM);
				if (pieces & 2) DrawImage("WPIECEC2", (posx - 21, posy) + v2Right, DI_SCREEN_RIGHT_BOTTOM | DI_ITEM_RIGHT_BOTTOM);
				if (pieces & 4) DrawImage("WPIECEC3", (posx + 1, posy) + v2Right, DI_SCREEN_RIGHT_BOTTOM | DI_ITEM_RIGHT_BOTTOM);
			}
			DrawImage("assets/ui/FS_HERETIC_SBAR_RIGHT_HX_WEAPON_PEICES_RIGHTSIDE.png", (posx + 2, posy) + v2Right, DI_SCREEN_RIGHT_BOTTOM | DI_ITEM_RIGHT_BOTTOM);
		} else if (CPlayer.mo is "MagePlayer") {
			DrawImage("WPSLOT2", (posx, posy) + v2Right, DI_SCREEN_RIGHT_BOTTOM | DI_ITEM_RIGHT_BOTTOM);
			if (CheckInventory("MWeapBloodscourge")) DrawImage("WPFULL2", (posx, posy) + v2Right, DI_SCREEN_RIGHT_BOTTOM | DI_ITEM_RIGHT_BOTTOM);
			else
			{
				int pieces = GetWeaponPieceMask("MWeapBloodscourge");
				if (pieces & 1) DrawImage("WPIECEM1", (posx - 43, posy) + v2Right, DI_SCREEN_RIGHT_BOTTOM | DI_ITEM_RIGHT_BOTTOM);
				if (pieces & 2) DrawImage("WPIECEM2", (posx - 23, posy) + v2Right, DI_SCREEN_RIGHT_BOTTOM | DI_ITEM_RIGHT_BOTTOM);
				if (pieces & 4) DrawImage("WPIECEM3", (posx, posy) + v2Right, DI_SCREEN_RIGHT_BOTTOM | DI_ITEM_RIGHT_BOTTOM);
			}
			DrawImage("assets/ui/FS_HERETIC_SBAR_RIGHT_HX_WEAPON_PEICES_RIGHTSIDE.png", (posx + 2, posy) + v2Right, DI_SCREEN_RIGHT_BOTTOM | DI_ITEM_RIGHT_BOTTOM);
		} else if (CPlayer.mo is "FighterPlayer") {
			DrawImage("WPSLOT0", (posx, posy) + v2Right, DI_SCREEN_RIGHT_BOTTOM | DI_ITEM_RIGHT_BOTTOM);
			if (CheckInventory("FWeapQuietus")) DrawImage("WPFULL0", (posx, posy) + v2Right, DI_SCREEN_RIGHT_BOTTOM | DI_ITEM_RIGHT_BOTTOM);
			else
			{
				int pieces = GetWeaponPieceMask("FWeapQuietus");
				if (pieces & 1) DrawImage("WPIECEF1", (posx - 22, posy) + v2Right, DI_SCREEN_RIGHT_BOTTOM | DI_ITEM_RIGHT_BOTTOM);
				if (pieces & 2) DrawImage("WPIECEF2", (posx - 13, posy) + v2Right, DI_SCREEN_RIGHT_BOTTOM | DI_ITEM_RIGHT_BOTTOM);
				if (pieces & 4) DrawImage("WPIECEF3", (posx, posy) + v2Right, DI_SCREEN_RIGHT_BOTTOM | DI_ITEM_RIGHT_BOTTOM);
			}
			DrawImage("assets/ui/FS_HERETIC_SBAR_RIGHT_HX_WEAPON_PEICES_RIGHTSIDE.png", (posx + 2, posy) + v2Right, DI_SCREEN_RIGHT_BOTTOM | DI_ITEM_RIGHT_BOTTOM);
		}
		
		if (!Level.NoInventoryBar && CPlayer.mo.InvSel != null) {
			if (isInventoryBarVisible()) {
				invTime = clamp(invTime + (1.0 / double(TICRATE)), 0.0,  invAnimationDuration);
			} else if (invTime != 0.0) {
				invTime = clamp(invTime - (1.0 / double(TICRATE)), 0.0,  invAnimationDuration);
			}
			if (invTime != 0.0) {
				double posInventory = LemonUtil.flerp(80.0, 0.0, LemonUtil.Easing_Quadradic_Out(invTime / invAnimationDuration));
				DrawInventoryBarHXDD(diparms_sbar, (0, anchorBottom + posInventory) + v2Center, 7, DI_SCREEN_CENTER_BOTTOM, HX_SHADOW);
			}
			DrawInventoryIcon(CPlayer.mo.InvSel, (anchorRight - 18.5, anchorBottom - 15.5) + v2Right, DI_SCREEN_RIGHT_BOTTOM|DI_ARTIFLASH|DI_ITEM_CENTER|DI_DIMDEPLETED, boxsize:(28, 28));
			if (CPlayer.mo.InvSel.Amount > 1)
			{
				DrawString(mIndexFont, FormatNumber(CPlayer.mo.InvSel.Amount, 3), (anchorRight - 4, anchorBottom - 8) + v2Right, DI_SCREEN_RIGHT_BOTTOM|DI_TEXT_ALIGN_RIGHT);
			}
		}
	}

	// Modified DrawBar and DrawInventory

	//============================================================================
	//
	// DrawBar
	//
	//============================================================================

	void DrawBarHXDD(String ongfx, String offgfx, double curval, double maxval, Vector2 position, int border, int vertical, int flags = 0, double alpha = 1.0, vector2 scale = (1.0,1.0))
	{
		let ontex = TexMan.CheckForTexture(ongfx, TexMan.TYPE_MiscPatch);
		if (!ontex.IsValid()) return;
		let offtex = TexMan.CheckForTexture(offgfx, TexMan.TYPE_MiscPatch);

		Vector2 texsize = TexMan.GetScaledSize(ontex);
		[position, flags] = AdjustPosition(position, flags, texsize.X, texsize.Y * scale.y);
		
		double value = (maxval != 0) ? clamp(curval / maxval, 0, 1) : 0;
		if(border != 0) value = 1. - value; //invert since the new drawing method requires drawing the bg on the fg.
		
		
		// {cx, cb, cr, cy}
		double Clip[4];
		Clip[0] = Clip[1] = Clip[2] = Clip[3] = 0;
		
		bool horizontal = !(vertical & SHADER_VERT);
		bool reverse = !!(vertical & SHADER_REVERSE);
		double sizeOfImage = (horizontal ? texsize.X - border*2 : texsize.Y - border*2);
		Clip[(!horizontal) | ((!reverse)<<1)] = sizeOfImage - sizeOfImage *value;
		
		// preserve the active clipping rectangle
		int cx, cy, cw, ch;
		[cx, cy, cw, ch] = screen.GetClipRect();

		if(border != 0)
		{
			for(int i = 0; i < 4; i++) Clip[i] += border;

			//Draw the whole foreground
			DrawTexture(ontex, position, flags | DI_ITEM_LEFT_TOP, alpha, scale: scale, style: STYLE_Add);
			SetClipRect(position.X + Clip[0], position.Y + Clip[1], texsize.X - Clip[0] - Clip[2], texsize.Y - Clip[1] - Clip[3], flags);
		}
		
		if (offtex.IsValid() && TexMan.GetScaledSize(offtex) == texsize) DrawTexture(offtex, position, flags | DI_ITEM_LEFT_TOP, alpha);
		else Fill(color(int(255*alpha),0,0,0), position.X + Clip[0], position.Y + Clip[1], texsize.X - Clip[0] - Clip[2], texsize.Y - Clip[1] - Clip[3]);
		
		if (border == 0)
		{
			SetClipRect(position.X + Clip[0], position.Y + Clip[1], texsize.X - Clip[0] - Clip[2], texsize.Y - Clip[1] - Clip[3], flags);
			DrawTexture(ontex, position, flags | DI_ITEM_LEFT_TOP, alpha, scale: scale, style: STYLE_Add);
		}
		// restore the previous clipping rectangle
		screen.SetClipRect(cx, cy, cw, ch);
	}
	
	//============================================================================
	//
	// DrawInventoryBar
	//
	// This function needs too many parameters, so most have been offloaded to
	// a struct to keep code readable and allow initialization somewhere outside
	// the actual drawing code.
	//
	//============================================================================
	
	// Except for the placement information this gets all info from the struct that gets passed in.
	void DrawInventoryBarHXDD(InventoryBarState parms, Vector2 position, int numfields, int flags = 0, double bgalpha = 1., vector2 scale = (1.0,1.0))
	{
		double width = parms.boxsize.X * numfields;
		[position, flags] = AdjustPosition(position, flags, width, parms.boxsize.Y * scale.y);
		
		CPlayer.mo.InvFirst = ValidateInvFirst(numfields);
		if (CPlayer.mo.InvFirst == null) return;	// Player has no listed inventory items.
		
		Vector2 boxsize = parms.boxsize;
		// First draw all the boxes
		for(int i = 0; i < numfields; i++)
		{
			DrawTexture(parms.box, position + (boxsize.X * i, 0), flags | DI_ITEM_LEFT_TOP, bgalpha, scale: scale);
		}
		
		// now the items and the rest
		
		Vector2 itempos = position + boxsize / 2;
		Vector2 textpos = position + boxsize - (1, 1 + parms.amountfont.mFont.GetHeight() * scale.y);

		int i = 0;
		Inventory item;
		for(item = CPlayer.mo.InvFirst; item != NULL && i < numfields; item = item.NextInv())
		{
			for(int j = 0; j < 2; j++)
			{
				if (j ^ !!(flags & DI_DRAWCURSORFIRST))
				{
					if (item == CPlayer.mo.InvSel)
					{
						double flashAlpha = bgalpha;
						if (flags & DI_ARTIFLASH) flashAlpha *= itemflashFade;
						DrawTexture(parms.selector, position + parms.selectofs + (boxsize.X * i, 0), flags | DI_ITEM_LEFT_TOP, flashAlpha, scale: scale);
					}
				}
				else
				{
					DrawInventoryIconHXDD(item, itempos + (boxsize.X * i, 0), flags | DI_ITEM_CENTER | DI_DIMDEPLETED, scale: scale);
				}
			}
			
			if (parms.amountfont != null && (item.Amount > 1 || (flags & DI_ALWAYSSHOWCOUNTERS)))
			{
				DrawString(parms.amountfont, FormatNumber(item.Amount, 0, 5), textpos + (boxsize.X * i, 0), flags | DI_TEXT_ALIGN_RIGHT, parms.cr, parms.itemalpha, scale: scale);
			}
			i++;
		}
		// Is there something to the left?
		if (CPlayer.mo.FirstInv() != CPlayer.mo.InvFirst)
		{
			DrawTexture(parms.left, position + (-parms.arrowoffset.X, parms.arrowoffset.Y), flags | DI_ITEM_RIGHT|DI_ITEM_VCENTER, scale: scale);
		}
		// Is there something to the right?
		if (item != NULL)
		{
			DrawTexture(parms.right, position + parms.arrowoffset + (width, 0), flags | DI_ITEM_LEFT|DI_ITEM_VCENTER, scale: scale);
		}
	}

	//============================================================================
	//
	//
	//
	//============================================================================

	void DrawInventoryIconHXDD(Inventory item, Vector2 pos, int flags = 0, double alpha = 1.0, Vector2 boxsize = (-1, -1), Vector2 scale = (1.,1.))
	{
		static const String flashimgs[]= { "USEARTID", "USEARTIC", "USEARTIB", "USEARTIA" };
		TextureID texture;
		Vector2 applyscale;
		[texture, applyscale] = GetIcon(item, flags, false);
		
		if((flags & DI_ARTIFLASH) && artiflashTick > 0)
		{
			DrawImage(flashimgs[artiflashTick-1], pos, flags, alpha, boxsize, scale);
		}
		else if (texture.IsValid())
		{
			if ((flags & DI_DIMDEPLETED) && item.Amount <= 0) flags |= DI_DIM;
			applyscale.X *= scale.X;
			applyscale.Y *= scale.Y;
			DrawTexture(texture, pos, flags, alpha, boxsize, applyscale);
		}
	}
}