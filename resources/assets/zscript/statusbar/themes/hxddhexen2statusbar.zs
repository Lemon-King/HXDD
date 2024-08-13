// ref: https://github.com/videogamepreservation/hexen2/blob/master/H2MP/code/Sbar.c

class HXDDHexen2StatusBar : BaseStatusBar {
	// Hexen II Constants
	const BAR_TOP_HEIGHT = 46;
	const BAR_TOP_WIDTH = 160;
	const BAR_BOTTOM_HEIGHT = 98;
	const BAR_TOTAL_HEIGHT = (BAR_TOP_HEIGHT+BAR_BOTTOM_HEIGHT);
	const BAR_BUMP_HEIGHT = 23;

	const INV_NUM_FIELDS = 7;

	const invAnimationDuration = 0.75;
	const INV_FADE_DURATION = 0.35;
	private double invTime;

	Ammo ammo1, ammo2;
	int amt1, maxamt1, amt2, maxamt2;

	DynamicValueInterpolator mHealthInterpolator;
	DynamicValueInterpolator mHealthInterpolator2;
	DynamicValueInterpolator mArmorInterpolator;
	DynamicValueInterpolator mXPInterpolator;
	DynamicValueInterpolator mAmmo1Interpolator;
	DynamicValueInterpolator mAmmo2Interpolator;
	HUDFont mHUDFont;
	HUDFont mIndexFont;
	HUDFont mTinyFont;
	HUDFont mBigFont;
	InventoryBarState diparms;
	InventoryBarState diparms_sbar;
	private int hwiggle;

	private bool useHereticKeys;

	private int mHUDFontWidth;
	private int mIndexFontWidth;
	private int mTinyFontWidth;

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
        SetSize(38, 320, 200);
		//CompleteBorder = true;
	}

	override void Init() {
		Super.Init();

		BeginStatusBar();
		SetFields();

		// Create the font used for the fullscreen HUD
		Font fnt = "HX2_BIGNUM";
		mHUDFontWidth = fnt.GetCharWidth("0") + 1;
		mHUDFont = HUDFont.Create(fnt, mHUDFontWidth, Mono_CellLeft, 1, 1);
		fnt = "INDEXFONT_RAVEN";
		mIndexFontWidth = fnt.GetCharWidth("0") + 1;
		mIndexFont = HUDFont.Create(fnt, fnt.GetCharWidth("0"), Mono_CellLeft);
		fnt = "HX2_TINYFONT";
		mTinyFontWidth = fnt.GetCharWidth("0") - 2;
		mTinyFont = HUDFont.Create(fnt, fnt.GetCharWidth("0") - 2, Mono_CellLeft);
		fnt = "BigFontX";
		mBigFont = HUDFont.Create(fnt, fnt.GetCharWidth("0"), Mono_CellLeft, 2, 2);
		diparms = InventoryBarState.Create(mIndexFont);
		diparms_sbar = InventoryBarState.CreateNoBox(mIndexFont, boxsize:(31, 31), arrowoffs:(0,-10));
		mHealthInterpolator = DynamicValueInterpolator.Create(0, 0.25, 1, 8);
		mHealthInterpolator2 = DynamicValueInterpolator.Create(0, 0.25, 1, 6);	// the chain uses a maximum of 6, not 8.
		mArmorInterpolator = DynamicValueInterpolator.Create(0, 0.25, 1, 8);
		mXPInterpolator = DynamicValueInterpolator.Create(0, 0.25, 1, 8);
		mAmmo1Interpolator = DynamicValueInterpolator.Create(0, 0.25, 1, 3);
		mAmmo2Interpolator = DynamicValueInterpolator.Create(0, 0.25, 1, 3);

		useHereticKeys = LemonUtil.IsMapEpisodic();
	}

	override void NewGame () {
		Super.NewGame();
		mHealthInterpolator.Reset(0);
		mHealthInterpolator2.Reset(0);
		mArmorInterpolator.Reset(0);
		mXPInterpolator.Reset(0);
		mAmmo1Interpolator.Reset(0);
		mAmmo2Interpolator.Reset(0);
	}

	override int GetProtrusion(double scaleratio) const {
		return scaleratio > 0.85? 28 : 12;
	}

	override void Tick() {
		Super.Tick();

		RefreshValues();
	}

	override void Draw (int state, double TicFrac) {
		Super.Draw(state, TicFrac);

		SetFields();
		if (automapactive) {
			// draw automap stuff
		} else {
			if (state == HUD_StatusBar) {
				BeginStatusBar();
				DrawBar(TicFrac);

			} else if (state == HUD_Fullscreen) {
				// We treat this as a status bar for auto centering and positioning
				BeginStatusBar();
				DrawFullScreen();
			}
		}
	}

	protected void RefreshValues() {
		mHealthInterpolator.Update(CPlayer.health);
		mHealthInterpolator2.Update(CPlayer.health);

		UpdateProgression();

		if (prog) {
			if (prog.ProgressionType == PSP_LEVELS) {
				mXPInterpolator.Update(prog.levelpct);
			}
			if (prog.ArmorType == PSAT_ARMOR_BASIC) {
				mArmorInterpolator.Update(GetArmorAmount());
			} else {
				mArmorInterpolator.Update(GetArmorSavePercent() / 5.0);
			}
		}

		[ammo1, ammo2] = GetCurrentAmmo();
		if (ammo1 is "Mana1" || ammo1 is "Mana2") {
			[amt1, maxamt1] = GetAmount("Mana1");
			[amt2, maxamt2] = GetAmount("Mana2");
			mAmmo1Interpolator.Update(amt1);
			mAmmo2Interpolator.Update(amt2);
		} else {
			if(ammo1) {
				[amt1, maxamt1] = GetAmount(ammo1.GetClass());
				mAmmo1Interpolator.Update(ammo1.Amount);
			}
			if (ammo2) {
				[amt2, maxamt2] = GetAmount(ammo2.GetClass());
				mAmmo2Interpolator.Update(ammo2.Amount);
			}
			/*
			if (!ammo1 && !ammo2) {
				let m1 = Ammo(CPlayer.mo.FindInventory("Mana1"));
				let m2 = Ammo(CPlayer.mo.FindInventory("Mana2"));
				if (m1 && m2) {
					ammo1 = m1;
					ammo2 = m2;
					[amt1, maxamt1] = GetAmount("Mana1");
					[amt2, maxamt2] = GetAmount("Mana2");
				}
			}
			*/
		}
	}

	protected void DrawFullScreen() {
		let y = 200 - 37;
		DrawImage("graphics/hexen2/bmmana.png", (3, y), DI_ITEM_OFFSETS);
		DrawImage("graphics/hexen2/gmmana.png", (3, y+18), DI_ITEM_OFFSETS);

		String sAmmo1 = String.Format("\cu%03d", min(mAmmo1Interpolator.GetValue(), 999));
		String sAmmo2 = String.Format("\cu%03d", min(mAmmo2Interpolator.GetValue(), 999));
		DrawString(mTinyFont, sAmmo1, (10, y+6), DI_TEXT_ALIGN_LEFT);
		DrawString(mTinyFont, sAmmo2, (10, y+18+6), DI_TEXT_ALIGN_LEFT);

		// Health
		String strHealthValue = String.format("%d", mHealthInterpolator.GetValue());
		int wStrHealthWidth = mHUDFontWidth * strHealthValue.Length();
		double xOffset = wStrHealthWidth * 0.5;

		DrawString(mHUDFont, FormatNumber(mHealthInterpolator.GetValue()), (38, y+18), DI_TEXT_ALIGN_LEFT);

		if (!Level.NoInventoryBar && CPlayer.mo.InvSel != null) {
			if (isInventoryBarVisible()) {
				invTime = clamp(invTime + (1.0 / 35.0), 0.0,  INV_FADE_DURATION);
			} else if (invTime != 0.0) {
				invTime = clamp(invTime - (1.0 / 35.0), 0.0,  INV_FADE_DURATION);
			}
			if (invTime != 0.0) {
				int width = diparms_sbar.boxsize.X * INV_NUM_FIELDS;
				double alpha = LemonUtil.flerp(0.0, 1.0, LemonUtil.Easing_Quadradic_Out(invTime / INV_FADE_DURATION));
				DrawInventoryBarHXDD(diparms_sbar, (320 * 0.5 - (width * 0.5), y - 18), INV_NUM_FIELDS, DI_ITEM_OFFSETS | DI_ITEM_LEFT_BOTTOM, HX_SHADOW, alpha: alpha);
			}
			vector2 iconPos = (288, y+7);
			DrawInventoryIcon(CPlayer.mo.InvSel, iconPos, DI_ITEM_OFFSETS|DI_ITEM_LEFT_BOTTOM|DI_ARTIFLASH|DI_DIMDEPLETED, boxsize:(28, 28));
			if (CPlayer.mo.InvSel.Amount > 1)
			{
				iconPos += (24, 21);
				DrawString(mIndexFont, FormatNumber(CPlayer.mo.InvSel.Amount, 3), iconPos, DI_ITEM_OFFSETS|DI_ITEM_LEFT_BOTTOM|DI_TEXT_ALIGN_RIGHT);
			}
		}
	}

	protected void DrawBar(double TicFrac) {
        // Bar Frame Art
		let y = 200 - BAR_TOP_HEIGHT;
        DrawImage("graphics/hexen2/topbar1.png", (0, y), DI_ITEM_OFFSETS);
        DrawImage("graphics/hexen2/topbar2.png", (BAR_TOP_WIDTH, y), DI_ITEM_OFFSETS);
        DrawImage("graphics/hexen2/topbumpl.png", (0, y - 23), DI_ITEM_OFFSETS | DI_ITEM_LEFT_BOTTOM);
        DrawImage("graphics/hexen2/topbumpm.png", (138, y - 8), DI_ITEM_OFFSETS | DI_ITEM_CENTER_BOTTOM);
        DrawImage("graphics/hexen2/topbumpr.png", (269, y - 23), DI_ITEM_OFFSETS | DI_ITEM_RIGHT_BOTTOM);

        DrawImage("assets/ui/HEXEN2_BUMP_LEFT.png", (-65, y - 19), DI_ITEM_OFFSETS | DI_ITEM_LEFT_BOTTOM);
        DrawImage("assets/ui/HEXEN2_BUMP_RIGHT.png", (BAR_TOP_WIDTH * 2, y - 19), DI_ITEM_OFFSETS | DI_ITEM_RIGHT_BOTTOM);

		int inthealth =  mHealthInterpolator2.GetValue();
		DrawGemEx("graphics/hexen2/hpchain.png", "graphics/hexen2/hpgem.png", inthealth, CPlayer.mo.GetMaxHealth(true), (45 + 6, y + 37), (224 - 7, 10), 12, (multiplayer? DI_TRANSLATABLE : 0) | DI_ITEM_LEFT_TOP);

        DrawImage("graphics/hexen2/chnlcov.png", (43 - 2, y + 46 - 10), DI_ITEM_OFFSETS);
        DrawImage("graphics/hexen2/chnrcov.png", (267 + 2, y + 46 - 10), DI_ITEM_OFFSETS);

		// Health
		String strHealthValue = String.format("%d", mHealthInterpolator.GetValue());
		int wStrHealthWidth = mHUDFontWidth * strHealthValue.Length();
		double xOffset = wStrHealthWidth * 0.5;

		DrawString(mHUDFont, FormatNumber(mHealthInterpolator.GetValue()), (77 + xOffset, y + 14), DI_TEXT_ALIGN_RIGHT);

		// Armor
		double armorValue = mArmorInterpolator.GetValue();
		String strArmorValue = String.format("%d", armorValue);
		int wStrArmorWidth = mHUDFontWidth * strArmorValue.Length();
		xOffset = wStrArmorWidth * 0.5;
		DrawString(mHUDFont, FormatNumber(armorValue), (117 + xOffset, y + 14), DI_TEXT_ALIGN_RIGHT);


		String assetLeftVial;
		String assetRightVial;
		Color altColor1 = 0xFFFFFFFFFF;
		Color altColor2 = 0xFFFFFFFFFF;
		if (ammo1 != null || ammo2 != null) {
			if (!(ammo1 is "Mana1") && !(ammo1 is "Mana2")) {
				DrawImage("assets/ui/HEXEN2_TOPBAR_COVER.png", (160, y), DI_ITEM_OFFSETS);
				assetLeftVial = "assets/ui/lvial.png";
				assetRightVial = "assets/ui/rvial.png";

				int r,g,b;
				[r,g,b] = LemonUtil.GetNormalizedPlayerColor(CPlayer);
				altColor1 = Color(255, r, g, b);
				altColor2 = Color(255, b, r, g);

				if (ammo1) {
					DrawTexture(ammo1.icon, (219 - 10, y + 13), DI_SCREEN_RIGHT_BOTTOM | DI_ITEM_CENTER, scale: (0.75, 0.75));
				}
				if (ammo2) {
					DrawTexture(ammo2.icon, (261 - 10, y + 13), DI_SCREEN_RIGHT_BOTTOM | DI_ITEM_CENTER, scale: (0.75, 0.75));
				}
			} else if (ammo1 is "Mana1" || ammo1 is "Mana2") {
				assetLeftVial = "graphics/hexen2/bmana.png";
				assetRightVial = "graphics/hexen2/gmana.png";
			}

			String sAmmo1 = String.Format("\cu%03d", min(mAmmo1Interpolator.GetValue(), 999));
			String sAmmo2 = String.Format("\cu%03d", min(mAmmo2Interpolator.GetValue(), 999));
			DrawString(mTinyFont, sAmmo1, (219, y + 22), DI_ITEM_OFFSETS | DI_TEXT_ALIGN_RIGHT);
			DrawString(mTinyFont, sAmmo2, (261, y + 22), DI_ITEM_OFFSETS | DI_TEXT_ALIGN_RIGHT);
		} else {
			DrawImage("assets/ui/HEXEN2_TOPBAR_COVER.png", (BAR_TOP_WIDTH, y), DI_ITEM_OFFSETS);
		}
		DrawBarEx(assetLeftVial, "", mAmmo1Interpolator.GetValue(), maxamt1, (190, y + 8), 0, SHADER_VERT | SHADER_REVERSE, DI_ITEM_OFFSETS | DI_ITEM_RIGHT_BOTTOM, col: altColor1);
		DrawBarEx(assetRightVial, "", mAmmo2Interpolator.GetValue(), maxamt2, (232, y + 8), 0, SHADER_VERT | SHADER_REVERSE, DI_ITEM_OFFSETS | DI_ITEM_RIGHT_BOTTOM, col: altColor2);
		DrawImage("graphics/hexen2/bmanacov.png", (190, y + 8), DI_ITEM_OFFSETS | DI_ITEM_RIGHT_BOTTOM, 1, style: STYLE_ColorBlend);
		DrawImage("graphics/hexen2/gmanacov.png", (232, y + 8), DI_ITEM_OFFSETS | DI_ITEM_RIGHT_BOTTOM, 1, style: STYLE_ColorBlend);

		if (!Level.NoInventoryBar && CPlayer.mo.InvSel != null) {
			if (isInventoryBarVisible()) {
				invTime = clamp(invTime + (1.0 / 35.0), 0.0,  INV_FADE_DURATION);
			} else if (invTime != 0.0) {
				invTime = clamp(invTime - (1.0 / 35.0), 0.0,  INV_FADE_DURATION);
			}
			if (invTime != 0.0) {
				int width = diparms_sbar.boxsize.X * INV_NUM_FIELDS;
				double alpha = LemonUtil.flerp(0.0, 1.0, LemonUtil.Easing_Quadradic_Out(invTime / INV_FADE_DURATION));
				DrawInventoryBarHXDD(diparms_sbar, (320 * 0.5 - (width * 0.5), y + 0 - BAR_TOP_HEIGHT), INV_NUM_FIELDS, DI_ITEM_OFFSETS | DI_ITEM_LEFT_BOTTOM, HX_SHADOW, alpha: alpha);
			}
			//vector2 iconPos = (288, y+7);
			DrawInventoryIcon(CPlayer.mo.InvSel, (158.5, y + 17), DI_ARTIFLASH|DI_ITEM_CENTER|DI_DIMDEPLETED, boxsize:(28, 28));
			if (CPlayer.mo.InvSel.Amount > 1)
			{
				//iconPos += (24, 21);
				DrawString(mIndexFont, FormatNumber(CPlayer.mo.InvSel.Amount, 3), (172, y + 24), DI_TEXT_ALIGN_RIGHT);
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
	void DrawInventoryBarHXDD(InventoryBarState parms, Vector2 position, int numfields, int flags = 0, double bgalpha = 1., vector2 scale = (1.0,1.0), double alpha = 1.0)
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
						DrawImage("graphics/hexen2/artisel.png", position + parms.selectofs + (boxsize.X * i, 0) + ((boxsize.X * 0.5) - 6, -11), DI_ITEM_OFFSETS | DI_ITEM_CENTER_BOTTOM, alpha, scale: scale);
					}
				}
				else
				{
					DrawInventoryIconHXDD(item, itempos + (boxsize.X * i, 0), flags | DI_ITEM_CENTER | DI_DIMDEPLETED, alpha: alpha, scale: scale);
				}
			}

			if (parms.amountfont != null && (item.Amount > 1 || (flags & DI_ALWAYSSHOWCOUNTERS)))
			{
				DrawString(parms.amountfont, FormatNumber(item.Amount, 0, 5), textpos + (boxsize.X * i, 0), flags | DI_TEXT_ALIGN_RIGHT, parms.cr, alpha, scale: scale);
			}
			i++;
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


	// Extended DrawBar with color support
	void DrawBarEx(String ongfx, String offgfx, double curval, double maxval, Vector2 position, int border, int vertical, int flags = 0, double alpha = 1.0, Color col = 0xffffffff)
	{
		let ontex = TexMan.CheckForTexture(ongfx, TexMan.TYPE_MiscPatch);
		if (!ontex.IsValid()) return;
		let offtex = TexMan.CheckForTexture(offgfx, TexMan.TYPE_MiscPatch);

		Vector2 texsize = TexMan.GetScaledSize(ontex);
		[position, flags] = AdjustPosition(position, flags, texsize.X, texsize.Y);
		
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
			DrawTexture(ontex, position, flags | DI_ITEM_LEFT_TOP, alpha, col: col);
			SetClipRect(position.X + Clip[0], position.Y + Clip[1], texsize.X - Clip[0] - Clip[2], texsize.Y - Clip[1] - Clip[3], flags);
		}
		
		if (offtex.IsValid() && TexMan.GetScaledSize(offtex) == texsize) DrawTexture(offtex, position, flags | DI_ITEM_LEFT_TOP, alpha, col: col);
		else Fill(color(int(255*alpha),0,0,0), position.X + Clip[0], position.Y + Clip[1], texsize.X - Clip[0] - Clip[2], texsize.Y - Clip[1] - Clip[3]);
		
		if (border == 0)
		{
			SetClipRect(position.X + Clip[0], position.Y + Clip[1], texsize.X - Clip[0] - Clip[2], texsize.Y - Clip[1] - Clip[3], flags);
			DrawTexture(ontex, position, flags | DI_ITEM_LEFT_TOP, alpha, col: col);
		}
		// restore the previous clipping rectangle
		screen.SetClipRect(cx, cy, cw, ch);
	}

	// Improved DrawGem, uses one more texture draw, doesn't need chainmod math
	void DrawGemEx(String chain, String gem, int displayvalue, int maxrange, Vector2 pos, Vector2 bounds, int gemwidth = 0, int flags = 0) {
		TextureID chaintex = TexMan.CheckForTexture(chain, TexMan.TYPE_MiscPatch);
		if (!chaintex.IsValid()) return;
		Vector2 chainsize = TexMan.GetScaledSize(chaintex);
		
		TextureID gemtex = TexMan.CheckForTexture(gem, TexMan.TYPE_MiscPatch);
		if (!gemtex.IsValid()) return;
		Vector2 gemsize = TexMan.GetScaledSize(gemtex);

		int height = max(chainsize.y, gemsize.y);
		bounds.y = height;

		int cx, cy, cw, ch;
		[cx, cy, cw, ch] = screen.GetClipRect();

		double clip[4];
		clip[0] = pos.x;
		clip[1] = pos.y;
		clip[2] = bounds.x;
		clip[3] = bounds.y;

		[pos, flags] = AdjustPosition(pos, flags, chainsize.x, chainsize.y);

		double gemPct = gemwidth / bounds.x;
		double gemDiff = gemsize.x - gemwidth;

		displayvalue = clamp(displayvalue, 0, maxrange);
		double pct = double(displayvalue) / double(maxrange);
		pct *= 1.0 - gemPct;

		double offsetX = (bounds.x * pct);
		double chainoffsetY = (bounds.y - chainsize.y) * 0.5;
		double gemoffsetY = (bounds.y - gemsize.y) * 0.5;
	
		SetClipRect(clip[0], clip[1], clip[2], clip[3], flags);
		DrawTexture(chaintex, (pos.x - chainsize.x, pos.y) + (offsetX, chainoffsetY), flags | DI_ITEM_LEFT_TOP);
		DrawTexture(chaintex, (pos.x - 1.0, pos.y) + (offsetX, chainoffsetY), flags | DI_ITEM_LEFT_TOP);
		DrawImage(gem, pos + (offsetX - ((gemsize.x - gemwidth) * 0.5), gemoffsetY), flags | DI_ITEM_LEFT_TOP);

		screen.SetClipRect(cx, cy, cw, ch);
	}
}