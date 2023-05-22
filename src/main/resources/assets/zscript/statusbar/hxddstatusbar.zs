class HXDDStatusBar : BaseStatusBar
{
	DynamicValueInterpolator mHealthInterpolator;
	DynamicValueInterpolator mHealthInterpolator2;
	DynamicValueInterpolator mXPInterpolator;
	DynamicValueInterpolator mAmmoInterpolator;
	DynamicValueInterpolator mAmmoInterpolator2;
	HUDFont mHUDFont;
	HUDFont mIndexFont;
	HUDFont mBigFont;
	InventoryBarState diparms;
	InventoryBarState diparms_sbar;
	private int hwiggle;

	int gemColorAssignment;
	
	Progression GetProgression() {
		Progression prog = Progression(CPlayer.mo.FindInventory("Progression"));
		return prog;
	}

	int GetPlayerLevel() {
		Progression prog = GetProgression();
		if (prog) {
			return prog.currlevel;
		}
		return 0;
	}

	String GetPlayerExperience() {
		Progression prog = GetProgression();
		if (prog) {
			return String.format("%.2f", mXPInterpolator.GetValue());
		}
		return "";
	}

	override void Init()
	{
		Super.Init();
		SetSize(38, 320, 200);

		// Create the font used for the fullscreen HUD
		Font fnt = "HUDFONT_RAVEN";
		mHUDFont = HUDFont.Create(fnt, fnt.GetCharWidth("0") + 1, Mono_CellLeft, 1, 1);
		fnt = "INDEXFONT_RAVEN";
		mIndexFont = HUDFont.Create(fnt, fnt.GetCharWidth("0"), Mono_CellLeft);
		fnt = "BIGFONT";
		mBigFont = HUDFont.Create(fnt, fnt.GetCharWidth("0"), Mono_CellLeft, 2, 2);
		diparms = InventoryBarState.Create(mIndexFont);
		diparms_sbar = InventoryBarState.CreateNoBox(mIndexFont, boxsize:(31, 31), arrowoffs:(0,-10));
		mHealthInterpolator = DynamicValueInterpolator.Create(0, 0.25, 1, 8);
		mHealthInterpolator2 = DynamicValueInterpolator.Create(0, 0.25, 1, 6);	// the chain uses a maximum of 6, not 8.
		mXPInterpolator = DynamicValueInterpolator.Create(0, 0.25, 1, 8);
		mAmmoInterpolator = DynamicValueInterpolator.Create(0, 0.25, 1, 3);
		mAmmoInterpolator2 = DynamicValueInterpolator.Create(0, 0.25, 1, 3);
	}
	
	override void NewGame ()
	{
		Super.NewGame();
		mHealthInterpolator.Reset (0);
		mHealthInterpolator2.Reset (0);
		mXPInterpolator.Reset (0);
		mAmmoInterpolator.Reset (0);
		mAmmoInterpolator2.Reset (0);
	}

	override int GetProtrusion(double scaleratio) const
	{
		return scaleratio > 0.85? 28 : 12;	// need to get past the gargoyle's wings
	}

	override void Tick()
	{
		Super.Tick();
		mHealthInterpolator.Update(CPlayer.health);
		mHealthInterpolator2.Update(CPlayer.health);
		
		Progression prog = GetProgression();
		if (prog && prog.currlevel > 0) {
			mXPInterpolator.Update(prog.levelpct);
		}

		Ammo ammo1, ammo2;
		[ammo1, ammo2] = GetCurrentAmmo();
		if(ammo1) {
			mAmmoInterpolator.Update(ammo1.Amount);
		}
		if (ammo2) {
			mAmmoInterpolator2.Update(ammo2.Amount);
		}
		
		if (Level.time & 1)
		{
		}
	}

	override void Draw (int state, double TicFrac)
	{
		Super.Draw (state, TicFrac);

		if (state == HUD_StatusBar)
		{
			BeginStatusBar();
			if (CPlayer.mo is "HereticPlayer") {
				DrawMainBarHeretic (TicFrac);
			} else {
				DrawMainBar (TicFrac);
			}
		}
		else if (state == HUD_Fullscreen)
		{
			BeginHUD();
			DrawFullScreenStuff ();
		}
	}

	protected void DrawFullScreenStuff ()
	{
		//health
		DrawImage("PTN2A0", (60, -3));
		DrawString(mBigFont, FormatNumber(mHealthInterpolator.GetValue()), (41, -21), DI_TEXT_ALIGN_RIGHT);

		//armor
		DrawImage("AR_1A0", (60, -23));
		DrawString(mBigFont, FormatNumber(GetArmorSavePercent() / 5, 2), (41, -41), DI_TEXT_ALIGN_RIGHT);

		//frags/keys
		if (deathmatch)
		{
			DrawString(mHUDFont, FormatNumber(CPlayer.FragCount, 3), (70, -16));
		}
		
		if (!isInventoryBarVisible() && !Level.NoInventoryBar && CPlayer.mo.InvSel != null)
		{
			// This code was changed to always fit the item into the box, regardless of alignment or sprite size.
			// Heretic's ARTIBOX is 30x30 pixels. 
			DrawImage("ARTIBOX", (-66, -1), 0, HX_SHADOW);
			DrawInventoryIcon(CPlayer.mo.InvSel, (-66, -15), DI_ARTIFLASH|DI_ITEM_CENTER|DI_DIMDEPLETED, boxsize:(28, 28));
			if (CPlayer.mo.InvSel.Amount > 1)
			{
				DrawString(mIndexFont, FormatNumber(CPlayer.mo.InvSel.Amount, 3), (-52, -2 - mIndexFont.mFont.GetHeight()), DI_TEXT_ALIGN_RIGHT);
			}
		}
		
		Ammo ammo1, ammo2;
		[ammo1, ammo2] = GetCurrentAmmo();
		if ((ammo1 is "Mana1") || (ammo2 is "Mana1") || (ammo1 is "Mana2") || (ammo2 is "Mana2")) {
			if ((ammo1 is "Mana1") || (ammo2 is "Mana1")){
				DrawImage("MANABRT1", (-17, -30), DI_ITEM_OFFSETS);
			} else {
				DrawImage("MANADIM1", (-17, -30), DI_ITEM_OFFSETS);
			}
			if ((ammo1 is "Mana2") || (ammo2 is "Mana2")) {
				DrawImage("MANABRT2", (-17, -15), DI_ITEM_OFFSETS);
			} else {
				DrawImage("MANADIM2", (-17, -15), DI_ITEM_OFFSETS);
			}
			DrawString(mHUDFont, FormatNumber(mAmmoInterpolator.GetValue(), 3), (-21, -30), DI_TEXT_ALIGN_RIGHT);
			DrawString(mHUDFont, FormatNumber(mAmmoInterpolator2.GetValue(), 3), (-21, -15), DI_TEXT_ALIGN_RIGHT);
		} else {
			int y = -22;
			if (ammo1 != null)
			{
				DrawTexture(ammo1.Icon, (-17, y));
				DrawString(mHUDFont, FormatNumber(mAmmoInterpolator.GetValue(), 3), (-3, y+7), DI_TEXT_ALIGN_RIGHT);
				y -= 40;
			}
			if (ammo2 != null)
			{
				DrawTexture(ammo2.Icon, (-14, y));
				DrawString(mHUDFont, FormatNumber(mAmmoInterpolator2.GetValue(), 3), (-3, y+7), DI_TEXT_ALIGN_RIGHT);
				y -= 40;
			}
		}

		Progression prog = GetProgression();
		if (prog.currlevel > 0) {
			DrawString(mHUDFont, FormatNumber(mXPInterpolator.GetValue()), (-21, -60), DI_TEXT_ALIGN_RIGHT);
			DrawString(mHUDFont, GetPlayerExperience(), (-21, -45), DI_TEXT_ALIGN_RIGHT);
		}
		
		if (isInventoryBarVisible() && !Level.NoInventoryBar && CPlayer.mo.InvSel != null)
		{
			// This code was changed to always fit the item into the box, regardless of alignment or sprite size.
			// Heretic's ARTIBOX is 30x30 pixels. 
			DrawImage("ARTIBOX", (-46, -1), 0, HX_SHADOW);
			DrawInventoryIcon(CPlayer.mo.InvSel, (-46, -15), DI_ARTIFLASH|DI_ITEM_CENTER|DI_DIMDEPLETED, boxsize:(28, 28));
			if (CPlayer.mo.InvSel.Amount > 1)
			{
				DrawString(mIndexFont, FormatNumber(CPlayer.mo.InvSel.Amount, 3), (-32, -2 - mIndexFont.mFont.GetHeight()), DI_TEXT_ALIGN_RIGHT);
			}
		}
	}
	
	protected void DrawMainBar (double TicFrac)
	{
		DrawImage("H2BAR", (0, 134), DI_ITEM_OFFSETS);


		
		if (!gemColorAssignment) {
			if (CPlayer.mo is "ClericPlayer") {
				gemColorAssignment = 1;
			} else if (CPlayer.mo is "MagePlayer") {
				gemColorAssignment = 2;
			} else if (CPlayer.mo is "FighterPlayer") {
				gemColorAssignment = 3;
			} else {
				gemColorAssignment = random(1,3);
			}
		}

		String Gem, Chain;
		if (gemColorAssignment == 1) {
			Gem = "LIFEGMC2";
			Chain = "CHAIN2";
		} else if (gemColorAssignment == 2) {
			Gem = "LIFEGMM2";
			Chain = "CHAIN3";
		} else if (gemColorAssignment == 3) {
			Gem = "LIFEGMF2";
			Chain = "CHAIN1";
		}

		int maxValue = 100;
		int value = 0;
		int wiggle = 0;
		Progression prog = GetProgression();
		if (prog.currlevel > 0) {
			value = mXPInterpolator.GetValue();
			wiggle = (floor(mXPInterpolator.GetValue()) != floor(prog.levelpct)) && Random[ChainWiggle](0, 1);
		} else {
			value =  mHealthInterpolator2.GetValue();
			maxValue = CPlayer.mo.GetMaxHealth(true);
			// wiggle isn't used on HX health
		}
		DrawGem(Chain, Gem, value, maxValue, (30, 193 + wiggle), -23, 49, 15, (multiplayer? DI_TRANSLATABLE : 0) | DI_ITEM_LEFT_TOP); 
		
		DrawImage("LFEDGE", (0, 193), DI_ITEM_OFFSETS);
		DrawImage("RTEDGE", (277, 193), DI_ITEM_OFFSETS);
		
		if (!automapactive)
		{
			if (isInventoryBarVisible())
			{
				DrawImage("INVBAR", (38, 162), DI_ITEM_OFFSETS);
				DrawInventoryBar(diparms_sbar, (52, 163), 7, DI_ITEM_LEFT_TOP, HX_SHADOW);
			}
			else
			{
				DrawImage("HXSTATBAR", (38, 162), DI_ITEM_OFFSETS);

				//inventory box
				if (CPlayer.mo.InvSel != null)
				{
					DrawInventoryIcon(CPlayer.mo.InvSel, (159.5, 177), DI_ARTIFLASH|DI_ITEM_CENTER|DI_DIMDEPLETED, boxsize:(28, 28));
					if (CPlayer.mo.InvSel.Amount > 1)
					{
						DrawString(mIndexFont, FormatNumber(CPlayer.mo.InvSel.Amount, 3), (174, 184), DI_TEXT_ALIGN_RIGHT);
					}
				}
				
				if (deathmatch || teamplay)
				{
					DrawImage("KILLS", (38, 163), DI_ITEM_OFFSETS);
					DrawString(mHUDFont, FormatNumber(CPlayer.FragCount, 3), (66, 176), DI_TEXT_ALIGN_RIGHT);
				}
				else
				{
					DrawImage("ARMCLS", (41, 178), DI_ITEM_OFFSETS);
					// Note that this has been changed to use red only if the REAL health is below 25, not when an interpolated value is below 25!
					DrawString(mHUDFont, FormatNumber(mHealthInterpolator.GetValue(), 3), (66, 176), DI_TEXT_ALIGN_RIGHT, CPlayer.Health < 25? Font.CR_RED : Font.CR_UNTRANSLATED);
				}
				
				//armor
				DrawImage("ARMCLS", (255, 178), DI_ITEM_OFFSETS);
				DrawString(mHUDFont, FormatNumber(GetArmorSavePercent() / 5, 2), (276, 176), DI_TEXT_ALIGN_RIGHT);
				
				Ammo ammo1, ammo2;
				[ammo1, ammo2] = GetCurrentAmmo();
				
				if (ammo1 != null && !(ammo1 is "Mana1") && !(ammo1 is "Mana2"))
				{
					DrawImage("HAMOBACK", (77, 164), DI_ITEM_OFFSETS);
					if (ammo2 != null)
					{
						DrawTexture(ammo1.icon, (89, 172), DI_ITEM_CENTER);
						DrawTexture(ammo2.icon, (113, 172), DI_ITEM_CENTER);
						DrawString(mIndexFont, FormatNumber(ammo1.amount, 3), ( 98, 182), DI_TEXT_ALIGN_RIGHT);
						DrawString(mIndexFont, FormatNumber(ammo2.amount, 3), (122, 182), DI_TEXT_ALIGN_RIGHT);
					}
					else
					{
						DrawTexture(ammo1.icon, (100, 172), DI_ITEM_CENTER);
						DrawString(mIndexFont, FormatNumber(ammo1.amount, 3), (109, 182), DI_TEXT_ALIGN_RIGHT);
					}
				}
				else
				{
					int amt1, maxamt1, amt2, maxamt2;
					[amt1, maxamt1] = GetAmount("Mana1");
					[amt2, maxamt2] = GetAmount("Mana2");
					if ((ammo1 is "Mana1") || (ammo2 is "Mana1")) 
					{
						DrawImage("MANABRT1", (77, 164), DI_ITEM_OFFSETS);
						DrawBar("MANAVL1", "", amt1, maxamt1, (94, 164), 1, SHADER_VERT, DI_ITEM_OFFSETS);
					}
					else 
					{
						DrawImage("MANADIM1", (77, 164), DI_ITEM_OFFSETS);
						DrawBar("MANAVL1D", "", amt1, maxamt1, (94, 164), 1, SHADER_VERT, DI_ITEM_OFFSETS);
					}
					if ((ammo1 is "Mana2") || (ammo2 is "Mana2")) 
					{
						DrawImage("MANABRT2", (110, 164), DI_ITEM_OFFSETS);
						DrawBar("MANAVL2", "", amt2, maxamt2, (102, 164), 1, SHADER_VERT, DI_ITEM_OFFSETS);
					}
					else 
					{
						DrawImage("MANADIM2", (110, 164), DI_ITEM_OFFSETS);
						DrawBar("MANAVL2D", "", amt2, maxamt2, (102, 164), 1, SHADER_VERT, DI_ITEM_OFFSETS);
					}
					DrawString(mIndexFont, FormatNumber(amt1, 3), ( 92, 181), DI_TEXT_ALIGN_RIGHT);
					DrawString(mIndexFont, FormatNumber(amt2, 3), (124, 181), DI_TEXT_ALIGN_RIGHT);
				}

				if (CPlayer.mo is "ClericPlayer")
				{
					DrawImage("WPSLOT1", (190, 162), DI_ITEM_OFFSETS);
					if (CheckInventory("CWeapWraithverge")) DrawImage("WPFULL1", (190, 162), DI_ITEM_OFFSETS);
					else
					{
						int pieces = GetWeaponPieceMask("CWeapWraithverge");
						if (pieces & 1) DrawImage("WPIECEC1", (190, 162), DI_ITEM_OFFSETS);
						if (pieces & 2) DrawImage("WPIECEC2", (212, 162), DI_ITEM_OFFSETS);
						if (pieces & 4) DrawImage("WPIECEC3", (225, 162), DI_ITEM_OFFSETS);
					}
				}
				else if (CPlayer.mo is "MagePlayer")
				{
					DrawImage("WPSLOT2", (190, 162), DI_ITEM_OFFSETS);
					if (CheckInventory("MWeapBloodscourge")) DrawImage("WPFULL2", (190, 162), DI_ITEM_OFFSETS);
					else
					{
						int pieces = GetWeaponPieceMask("MWeapBloodscourge");
						if (pieces & 1) DrawImage("WPIECEM1", (190, 162), DI_ITEM_OFFSETS);
						if (pieces & 2) DrawImage("WPIECEM2", (205, 162), DI_ITEM_OFFSETS);
						if (pieces & 4) DrawImage("WPIECEM3", (224, 162), DI_ITEM_OFFSETS);
					}
				}
				else
				{
					DrawImage("WPSLOT0", (190, 162), DI_ITEM_OFFSETS);
					if (CheckInventory("FWeapQuietus")) DrawImage("WPFULL0", (190, 162), DI_ITEM_OFFSETS);
					else
					{
						int pieces = GetWeaponPieceMask("FWeapQuietus");
						if (pieces & 1) DrawImage("WPIECEF1", (190, 162), DI_ITEM_OFFSETS);
						if (pieces & 2) DrawImage("WPIECEF2", (225, 162), DI_ITEM_OFFSETS);
						if (pieces & 4) DrawImage("WPIECEF3", (234, 162), DI_ITEM_OFFSETS);
					}
				}
			}
		}
		else // automap
		{
			DrawImage("KEYBAR", (38, 162), DI_ITEM_OFFSETS);
			int cnt = 0;
			Vector2 keypos = (46, 164);
			for(let i = CPlayer.mo.Inv; i != null; i = i.Inv)
			{
				if (i is "Key" && i.Icon.IsValid())
				{
					DrawTexture(i.Icon, keypos, DI_ITEM_OFFSETS);
					keypos.X += 20;
					if (++cnt >= 5) break;
				}
			}
			DrawHexenArmor(HEXENARMOR_ARMOR, "ARMSLOT1", (150, 164), DI_ITEM_OFFSETS);
			DrawHexenArmor(HEXENARMOR_SHIELD, "ARMSLOT2", (181, 164), DI_ITEM_OFFSETS);
			DrawHexenArmor(HEXENARMOR_HELM, "ARMSLOT3", (212, 164), DI_ITEM_OFFSETS);
			DrawHexenArmor(HEXENARMOR_AMULET, "ARMSLOT4", (243, 164), DI_ITEM_OFFSETS);
		}
	}

	protected void DrawMainBarHeretic (double TicFrac)
	{
		DrawImage("BARBACK", (0, 158), DI_ITEM_OFFSETS);
		DrawImage("LTFCTOP", (0, 148), DI_ITEM_OFFSETS);
		DrawImage("RTFCTOP", (290, 148), DI_ITEM_OFFSETS);
		if (isInvulnerable())
		{
			//god mode
			DrawImage("GOD1", (16, 167), DI_ITEM_OFFSETS);
			DrawImage("GOD2", (287, 167), DI_ITEM_OFFSETS);
		}
		//health
		DrawImage("CHAINBAC", (0, 190), DI_ITEM_OFFSETS);
		// wiggle the chain if it moves
		int maxValue = 100;
		int value = 0;
		int wiggle = 0;
		Progression prog = GetProgression();
		if (prog.currlevel > 0) {
			value = mXPInterpolator.GetValue();
			wiggle = (floor(mXPInterpolator.GetValue()) != floor(prog.levelpct)) && Random[ChainWiggle](0, 1);
		} else {
			value =  mHealthInterpolator2.GetValue();
			maxValue = CPlayer.mo.GetMaxHealth(true);
			wiggle = (value != CPlayer.health) && Random[ChainWiggle](0, 1);
		}
		DrawGem("CHAIN", "LIFEGEM2",value, maxValue, (2, 191 + wiggle), 15, 25, 16, (multiplayer? DI_TRANSLATABLE : 0) | DI_ITEM_LEFT_TOP); 
		DrawImage("LTFACE", (0, 190), DI_ITEM_OFFSETS);
		DrawImage("RTFACE", (276, 190), DI_ITEM_OFFSETS);
		DrawShader(SHADER_HORZ, (19, 190), (16, 10));
		DrawShader(SHADER_HORZ|SHADER_REVERSE, (278, 190), (16, 10));

		if (!isInventoryBarVisible())
		{
			//statbar
			if (!deathmatch)
			{
				DrawImage("LIFEBAR", (34, 160), DI_ITEM_OFFSETS);
				DrawImage("ARMCLEAR", (57, 171), DI_ITEM_OFFSETS);
				DrawString(mHUDFont, FormatNumber(mHealthInterpolator.GetValue(), 3), (88, 170), DI_TEXT_ALIGN_RIGHT);
			}
			else
			{
				DrawImage("STATBAR", (34, 160), DI_ITEM_OFFSETS);
				DrawImage("ARMCLEAR", (57, 171), DI_ITEM_OFFSETS);
				DrawString(mHUDFont, FormatNumber(CPlayer.FragCount, 3), (88, 170), DI_TEXT_ALIGN_RIGHT);
			}
			DrawString(mHUDFont, FormatNumber(GetArmorAmount(), 3), (255, 170), DI_TEXT_ALIGN_RIGHT);

			//ammo
			Ammo ammo1, ammo2;
			[ammo1, ammo2] = GetCurrentAmmo();
			if (ammo1 != null && ammo2 == null)
			{
				DrawString(mHUDFont, FormatNumber(ammo1.Amount, 3), (136, 162), DI_TEXT_ALIGN_RIGHT);
				DrawTexture(ammo1.icon, (123, 180), DI_ITEM_CENTER);
			}
			else if (ammo2 != null)
			{
				DrawString(mIndexFont, FormatNumber(ammo1.Amount, 3), (137, 165), DI_TEXT_ALIGN_RIGHT);
				DrawString(mIndexFont, FormatNumber(ammo2.Amount, 3), (137, 177), DI_TEXT_ALIGN_RIGHT);
				DrawTexture(ammo1.icon, (115, 169), DI_ITEM_CENTER);
				DrawTexture(ammo2.icon, (115, 180), DI_ITEM_CENTER);
			}

			//keys
			if (CPlayer.mo.CheckKeys(3, false, true)) DrawImage("YKEYICON", (153, 164), DI_ITEM_OFFSETS);
			if (CPlayer.mo.CheckKeys(1, false, true)) DrawImage("GKEYICON", (153, 172), DI_ITEM_OFFSETS);
			if (CPlayer.mo.CheckKeys(2, false, true)) DrawImage("BKEYICON", (153, 180), DI_ITEM_OFFSETS);

			//inventory box
			if (CPlayer.mo.InvSel != null)
			{
				DrawInventoryIcon(CPlayer.mo.InvSel, (194, 175), DI_ARTIFLASH|DI_ITEM_CENTER|DI_DIMDEPLETED, boxsize:(28, 28));
				if (CPlayer.mo.InvSel.Amount > 1)
				{
					DrawString(mIndexFont, FormatNumber(CPlayer.mo.InvSel.Amount, 3), (209, 182), DI_TEXT_ALIGN_RIGHT);
				}
			}
		}
		else
		{
			DrawImage("INVBAR", (34, 160), DI_ITEM_OFFSETS);
			DrawInventoryBar(diparms_sbar, (49, 160), 7, DI_ITEM_LEFT_TOP, HX_SHADOW);
		}
	}
}