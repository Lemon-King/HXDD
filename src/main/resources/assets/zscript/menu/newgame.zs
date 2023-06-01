
// TODO: Rewrite & Cleanup

class ZFPreGameSetupHandler : HXDD_ZF_Handler {
    // A reference to the menu we want to modify - the menu has to set this
    // to itself.
    ZFPreGameSetup menu;

    override void buttonClickCommand(HXDD_ZF_Button caller, Name command) {
        // Check if the command matches the button's command.
        if (command == "classic") {
            Menu.MenuSound("menu/choose");
            Menu.SetMenu("HXDDNewGameConfig");
        } else if (command == 'back') {
            if (menu.frame.getPosX() == 0) {
                Menu.MenuSound("menu/choose");
                Menu.SetMenu("MainMenu");
                menu.btnStart.SetPosY(1080 + 500);
            } else if (menu.frame.getPosX() == -1920) {
                Menu.MenuSound("menu/choose");
                menu.time = 0;
                menu.lastPosX = menu.frame.getPosX();
                menu.desiredPosX = 0;
                menu.btnStart.SetPosY(1080 + 500);
            }
        } else if (command == 'next') {
            if (menu.frame.getPosX() == 0) {
                Menu.MenuSound("menu/choose");
                Menu.SetMenu("MainMenu");
                menu.time = 0;
                menu.lastPosX = menu.frame.getPosX();
                menu.desiredPosX = -1920;
            } else if (menu.frame.getPosX() == -1920) {
                // start game with selected settings
                Menu.MenuSound("menu/choose");
                LemonUtil.CVAR_SetInt("hxdd_gamemode", menu.selectedGameMode);
                LemonUtil.CVAR_SetInt("hxdd_armor_mode", menu.selectedArmorMode);
                LemonUtil.CVAR_SetInt("hxdd_progression", menu.selectedProgressionMode);
                LemonUtil.CVAR_SetInt("hxdd_lavastyle", menu.selectedTextureStyleLava);
                LemonUtil.CVAR_SetInt("hxdd_waterstyle", menu.selectedTextureStyleWater);
                LemonUtil.CVAR_SetInt("hxdd_sludgestyle", menu.selectedTextureStyleSludge);
                LemonUtil.CVAR_SetInt("hxdd_icestyle", menu.selectedTextureStyleIce);
                Menu.SetMenu("EpisodeMenu", menu.selectedClass);    // Class Selection Response
                Menu.SetMenu("SkillMenu", menu.selectedEpisode);    // Episode Selection Response
                Menu.SetMenu("StartGame", menu.selectedSkill);      // Skill Selection Response (Starts Game), Use StartgameConfirm for Nightmare skills
            }
        }
    }
}

class ZFClassSelectHandler : HXDD_ZF_Handler {
    ZFPreGameSetup menu;
    override void buttonClickCommand(HXDD_ZF_Button caller, Name command) {
        if (menu.frame.getPosX() == 0) {
            Menu.MenuSound("menu/choose");
            String cmd = command;
            int choice = cmd.ToInt();
            menu.selectedClass = choice;
            menu.time = 0;
            menu.lastPosX = menu.frame.getPosX();
            menu.desiredPosX = -1920;

            menu.btnStart.SetPosY(1080 - 100);

            menu.frameGameOptions.Refresh();
        }
    }
}

class ZFGameOptionsHandler : HXDD_ZF_Handler {
    ZFPreGameSetup menu;
    ZFGameOptions optMenu;
    override void dropdownChanged(HXDD_ZF_DropdownList caller, Name command) {
        String cmd = command;
        if (cmd == "episode") {
            String choice = command;
            menu.selectedEpisode = caller.getSelection();
            elementHoverChanged(caller, command, false);
        } else if (cmd == "skill") {
            String choice = command;
            menu.selectedSkill = caller.getSelection();
        } else if (cmd == "hxdd_gamemode") {
            menu.selectedGameMode = caller.getSelection();
        } else if (cmd == "hxdd_armor_mode") {
            menu.selectedArmorMode = caller.getSelection();
        } else if (cmd == "hxdd_progression") {
            menu.selectedProgressionMode = caller.getSelection();
        } else if (cmd == "hxdd_lavastyle") {
            menu.selectedTextureStyleLava = caller.getSelection();
        } else if (cmd == "hxdd_waterstyle") {
            menu.selectedTextureStyleWater = caller.getSelection();
        } else if (cmd == "hxdd_sludgestyle") {
            menu.selectedTextureStyleSludge = caller.getSelection();
        } else if (cmd == "hxdd_icestyle") {
            menu.selectedTextureStyleIce = caller.getSelection();
        } else if (cmd.IndexOf("xswap") != -1) {
            // handle xswap cvars
            console.printf("%s %d", cmd, caller.getSelection());
            LemonUtil.CVAR_SetInt(command, caller.getSelection());
        }
    }

    override void elementHoverChanged(HXDD_ZF_Element caller, Name command, bool unhovered) {
        if (unhovered) {
            ShowEpisodeInformation();
            return;
        }
        if (command == "skill") {
            optMenu.SetInfoText("$MNU_HEADER_SKILLSELECTION", "$MNU_SKILLSELECTION");
        } else if (command == "episode") {
            ShowEpisodeInformation();
        } else if (command == "hxdd_gamemode") {
            optMenu.SetInfoText("$MNU_HEADER_GAMEMODE", "$MNU_GAMEMODE");
        } else if (command == "hxdd_armor_mode") {
            optMenu.SetInfoText("$MNU_HEADER_ARMORMODE", "$MNU_ARMORMODE");
        } else if (command == "hxdd_progression") {
            optMenu.SetInfoText("$MNU_HEADER_PROGRESSIONMODE", "$MNU_PROGRESSIONMODE");
        }
    }

    void ShowEpisodeInformation() {
        if (menu.selectedEpisode < 6) {
            optMenu.SetInfoText("$MNU_HEADER_HERETIC", "$MNU_STORY_HERETIC");
        } else if (menu.selectedEpisode == 6) {
            optMenu.SetInfoText("$MNU_HEADER_HEXEN", "$MNU_STORY_HEXEN");
        } else if (menu.selectedEpisode == 7) {
            optMenu.SetInfoText("$MNU_HEADER_HEXDD", "$MNU_STORY_HEXDD");
        } else {
            optMenu.SetInfoText("$MNU_HEADER_OTHER", "$MNU_STORY_OTHER");
        }
    }
}

class ZFPlayerClassSelection ui {
    HXDD_ZF_Frame frame;

    ButtonPlayerClass btnClassCorvus;
    ButtonPlayerClass btnClassFighter;
    ButtonPlayerClass btnClassCleric;
    ButtonPlayerClass btnClassMage;

    ButtonPlayerClass btnClassAssassin;
    ButtonPlayerClass btnClassCrusader;
    ButtonPlayerClass btnClassNecromancer;
    ButtonPlayerClass btnClassPaladin;
    ButtonPlayerClass btnClassSuccubus;

    W_DevilBraizer imgBrazierLeft;
    W_DevilBraizer imgBrazierRight;

    void Create(ZFPreGameSetup parent) {
        self.frame = HXDD_ZF_Frame.create(
            (0, 0),
            (1920, 1080)
        );
        frame.pack(parent.frame);

        let imgGameHTIC = HXDD_ZF_Image.create(
            (450, 1080 * 0.25),
            (142 * 2.5, 56 * 2.5),
            image: "Graphics/M_HTIC.png",
            imageScale: (2.5, 2.5)
        );
        // As before we pack it into `frame`.
        imgGameHTIC.pack(frame);

        let imgGameHTICX = HXDD_ZF_Image.create(
            (1920 - 450 - (144 * 2.5), 1080 * 0.250),
            (144 * 2.5, 52 * 2.5),
            image: "Graphics/M_HTICX.png",
            imageScale: (2.5, 2.5)
        );
        // As before we pack it into `frame`.
        imgGameHTICX.pack(frame);

        let header = HXDD_ZF_Label.create(
            ( 0 , 100),
            (1920, 24 * 4),
            text: "Class Selection",
            fnt: "BigFontX",
            alignment: 2,
            textScale: 4
        );
        // We put this in `frame`.
        header.pack(frame);

        self.imgBrazierLeft = new("W_DevilBraizer");
        self.imgBrazierLeft.Create(frame, (425, 10), 2.5);
        self.imgBrazierRight = new("W_DevilBraizer");
        self.imgBrazierRight.Create(frame, (1920 - 425, 10), 2.5, true);

        let cmdHandlerClassSelect = new("ZFClassSelectHandler");
        cmdHandlerClassSelect.menu = parent;

        double classLineX = (1080 * 0.25) + (56 * 2.5) + 50;
        double hereticPosY = 450 + ((142 * 2.5 * 0.5) - (112 * 1.5 * 0.5));

        Array<String> imagesCorvus = {"sprites/PLAYA1.png", "sprites/PLAYB1.png", "sprites/PLAYC1.png", "sprites/PLAYD1.png"};
        btnClassCorvus = new("ButtonPlayerClass");
        btnClassCorvus.Create(frame, cmdHandlerClassSelect, (hereticPosY, classLineX), 1.5, "Corvus", 0, "graphics/M_HBOX.png", imagesCorvus);

        double hexenPosY = 1920 - 450 - (144 * 2.5) + ((144 * 2.5 * 0.5) - (112 * 1.5 * 0.5));
        Array<String> imagesFighter = {"graphics/M_FWALK1.png", "graphics/M_FWALK2.png", "graphics/M_FWALK3.png", "graphics/M_FWALK4.png"};
        btnClassFighter = new("ButtonPlayerClass");
        btnClassFighter.Create(frame, cmdHandlerClassSelect, (hexenPosY - 200, classLineX), 1.5, "Fighter", 1, "graphics/M_FBOX.png", imagesFighter);

        Array<String> imagesCleric = {"graphics/M_CWALK1.png", "graphics/M_CWALK2.png", "graphics/M_CWALK3.png", "graphics/M_CWALK4.png"};
        btnClassCleric = new("ButtonPlayerClass");
        btnClassCleric.Create(frame, cmdHandlerClassSelect, (hexenPosY, classLineX), 1.5, "Cleric", 2, "graphics/M_CBOX.png", imagesCleric);

        Array<String> imagesMage = {"graphics/M_MWALK1.png", "graphics/M_MWALK2.png", "graphics/M_MWALK3.png", "graphics/M_MWALK4.png"};
        btnClassMage = new("ButtonPlayerClass");
        btnClassMage.Create(frame, cmdHandlerClassSelect, (hexenPosY + 200, classLineX), 1.5, "Mage", 3, "graphics/M_MBOX.png", imagesMage);

        // Cvar hxdd_installed_hexen2 is located in cvarinfo.installed_hexen2
        bool isDev = LemonUtil.CVAR_GetBool("hxdd_isdev_environment", false);
        bool cvarHexII = LemonUtil.CVAR_GetBool('hxdd_installed_hexen2', false);
        if (isDev && cvarHexII) {
            // display Hexen II classes
            double classLineXOffset = (136 * 1.5) + 50;
            btnClassAssassin = new("ButtonPlayerClass");
            btnClassAssassin.CreateHX2(frame, cmdHandlerClassSelect, (hexenPosY - 320, classLineX + classLineXOffset), 1.5, "Paladin", 4, "graphics/netp1.png");
            btnClassCrusader = new("ButtonPlayerClass");
            btnClassCrusader.CreateHX2(frame, cmdHandlerClassSelect, (hexenPosY - 160, classLineX + classLineXOffset), 1.5, "Crusader", 5, "graphics/netp2.png");
            btnClassNecromancer = new("ButtonPlayerClass");
            btnClassNecromancer.CreateHX2(frame, cmdHandlerClassSelect, (hexenPosY, classLineX + classLineXOffset), 1.5, "Necromancer", 6, "graphics/netp3.png");
            btnClassPaladin = new("ButtonPlayerClass");
            btnClassPaladin.CreateHX2(frame, cmdHandlerClassSelect, (hexenPosY + 160, classLineX + classLineXOffset), 1.5, "Assassin", 7, "graphics/netp4.png");

            // Cvar hxdd_installed_hexen2_expansion is located in cvarinfo.installed_hexen2_expansion
            bool cvarHexII_EX = LemonUtil.CVAR_GetBool('hxdd_installed_hexen2_expansion', false);
            if (cvarHexII_EX) {
                // display Hexen II Expansion classes
                btnClassSuccubus = new("ButtonPlayerClass");
                btnClassSuccubus.CreateHX2(frame, cmdHandlerClassSelect, (hexenPosY + 320, classLineX + classLineXOffset), 1.5, "Demoness", 8, "graphics/netp5.png");
            }
        }
    }

    void Update() {
        btnClassCorvus.Update();
        btnClassFighter.Update();
        btnClassCleric.Update();
        btnClassMage.Update();

        self.imgBrazierLeft.Update();
        self.imgBrazierRight.Update();
    }
}

class ZFGameOptions ui {
    ZFPreGameSetup parent;
    HXDD_ZF_Frame frame;
    DropDownCombo ddl_Difficulty;

    HXDD_ZF_Frame frameInfo;
    HXDD_ZF_Label headerInformation;
    HXDD_ZF_Label labelInformation;

    W_KeyStatue headerStatueLeft;
    W_KeyStatue headerStatueRight;

    Array<HXDD_ZF_DropdownItems> listClassDifficulty;

    void CreateDifficultyLists() {
        // Heretic
        HXDD_ZF_DropdownItems corvus = new("HXDD_ZF_DropdownItems");
        corvus.items.push("$MNU_WETNURSE");
        corvus.items.push("$MNU_YELLOWBELLIES");
        corvus.items.push("$MNU_BRINGEST");
        corvus.items.push("$MNU_SMITE");
        corvus.items.push("$MNU_BLACKPLAGUE");
        listClassDifficulty.push(corvus);

        // Hexen
        HXDD_ZF_DropdownItems fighter = new("HXDD_ZF_DropdownItems");
        fighter.items.push("$MNU_SQUIRE");
        fighter.items.push("$MNU_KNIGHT");
        fighter.items.push("$MNU_WARRIOR");
        fighter.items.push("$MNU_BERSERKER");
        fighter.items.push("$MNU_TITAN");
        listClassDifficulty.push(fighter);

        HXDD_ZF_DropdownItems cleric = new("HXDD_ZF_DropdownItems");
        cleric.items.push("$MNU_ALTARBOY");
        cleric.items.push("$MNU_ACOLYTE");
        cleric.items.push("$MNU_PRIEST");
        cleric.items.push("$MNU_CARDINAL");
        cleric.items.push("$MNU_POPE");
        listClassDifficulty.push(cleric);

        HXDD_ZF_DropdownItems mage = new("HXDD_ZF_DropdownItems");
        mage.items.push("$MNU_APPRENTICE");
        mage.items.push("$MNU_ENCHANTER");
        mage.items.push("$MNU_SORCERER");
        mage.items.push("$MNU_WARLOCK");
        mage.items.push("$MNU_ARCHMAGE");
        listClassDifficulty.push(mage);

        // Hexen II
        HXDD_ZF_DropdownItems paladin = new("HXDD_ZF_DropdownItems");
        paladin.items.push("$MNU_APPRENTICE");
        paladin.items.push("$MNU_KNIGHT");
        paladin.items.push("$MNU_ADEPT");
        paladin.items.push("$MNU_LORD");
        paladin.items.push("$MNU_JUSTICIAR");
        listClassDifficulty.push(paladin);

        HXDD_ZF_DropdownItems crusader = new("HXDD_ZF_DropdownItems");
        crusader.items.push("$MNU_GALLANT");
        crusader.items.push("$MNU_HOLYAVENGER");
        crusader.items.push("$MNU_DIVINEHERO");
        crusader.items.push("$MNU_LEGEND");
        crusader.items.push("$MNU_MYTH");
        listClassDifficulty.push(crusader);

        HXDD_ZF_DropdownItems necromancer = new("HXDD_ZF_DropdownItems");
        necromancer.items.push("$MNU_SORCERER");
        necromancer.items.push("$MNU_DARKSERVANT");
        necromancer.items.push("$MNU_WARLOCK");
        necromancer.items.push("$MNU_LICHKING");
        necromancer.items.push("$MNU_ARCHLICH");
        listClassDifficulty.push(necromancer);

        HXDD_ZF_DropdownItems assassin = new("HXDD_ZF_DropdownItems");
        assassin.items.push("$MNU_ROGUE");
        assassin.items.push("$MNU_CUTTHROAT");
        assassin.items.push("$MNU_EXECUTIONER");
        assassin.items.push("$MNU_WIDOWMAKER");
        assassin.items.push("$MNU_NIGHTSTALKER");
        listClassDifficulty.push(assassin);

        HXDD_ZF_DropdownItems succubus = new("HXDD_ZF_DropdownItems");
        succubus.items.push("$MNU_LARVA");
        succubus.items.push("$MNU_SPAWN");
        succubus.items.push("$MNU_FIEND");
        succubus.items.push("$MNU_SHEBITCH");
        succubus.items.push("$MNU_BROODMOTHER");
        listClassDifficulty.push(succubus);

    }
    
    void Create(ZFPreGameSetup parent) {
        CreateDifficultyLists();

        self.parent = parent;
        self.frame = HXDD_ZF_Frame.create(
            (1920, 0),
            (1920, 1080)
        );
        frame.pack(parent.frame);

        let labelOpt = HXDD_ZF_Label.create(
            ( 0 , 100),
            (1920, 24 * 4),
            text: "Gameplay Options",
            fnt: "BigFontX",
            alignment: 2,
            textScale: 4
        );
        labelOpt.pack(frame);

        self.frameInfo = HXDD_ZF_Frame.create(
            (1920 - (1920 * 0.45) + 150, 300),
            ((1920 * 0.45) - 300, (1080 * 0.6))
        );
        self.frameInfo.pack(self.frame);
        
        self.headerInformation = HXDD_ZF_Label.create(
            (0 , 0),
            (self.frameInfo.GetWidth(), 50),
            text: "",
            fnt: "BigFontX",
            alignment: (2 << 4) | 2,
            textScale: 2
        );
        self.headerInformation.pack(self.frameInfo);

        self.labelInformation = HXDD_ZF_Label.create(
            (0 , 50),
            (self.frameInfo.GetWidth(), self.frameInfo.GetHeight() - 50),
            text: "",
            //fnt: "BigFontX",
            alignment: (1 << 4) | 1,
            textScale: 2.5
        );
        self.labelInformation.pack(self.frameInfo);

        self.headerStatueLeft = new("W_KeyStatue");
        self.headerStatueLeft.Create(frame, (425, 40), 2.5);
        self.headerStatueRight = new("W_KeyStatue");
        self.headerStatueRight.Create(frame, (1920 - 425, 40), 2.5, true);
        int orbColor = self.headerStatueLeft.GetRandomOrb();
        self.headerStatueLeft.SetOrb(orbColor);
        self.headerStatueRight.SetOrb(orbColor);
        
        let scrollbar_n = HXDD_ZF_BoxTextures.createTexturePixels(
            "assets/ui/scrollbar_n.png",
            (2, 2),
            (27, 27),
            true,
            false
        );
        let scrollbar_h = HXDD_ZF_BoxTextures.createTexturePixels(
            "assets/ui/scrollbar_h.png",
            (2, 2),
            (27, 27),
            true,
            false
        );
        let scrollbar_c = HXDD_ZF_BoxTextures.createTexturePixels(
            "assets/ui/scrollbar_c.png",
            (2, 2),
            (27, 27),
            true,
            false
        );



        let background = HXDD_ZF_BoxTextures.createTexturePixels(
            "assets/ui/groupbox_shadow.png",
            (3, 3),
            (60, 60),
            false,
            false
        );

        let optionGroupBackground = HXDD_ZF_BoxImage.create(
            (50, 300),
            (1920 * 0.55, 1080 * 0.6),
            background
        );
        optionGroupBackground.pack(frame);

        let optionArea = HXDD_ZF_Frame.create(
            (0, 0),
            (1920 * 0.55 - (32 + 4), 1080 * 0.8)
        );

        let scrollContainer = HXDD_ZF_ScrollContainer.create(
            (50 + 2, 300 + 2),
            (1920 * 0.55 - 4, 1080 * 0.6 - 4),
            32,
            optionArea.GetHeight(),
            (1920 * 0.55 - 4) * 0.1,
            scrollbar_n,
            scrollBarHover: scrollbar_h,
            scrollBarClick: scrollbar_c,
            //scrollBg: scrollbar_n,
            scrollArea: optionArea
        );
        scrollContainer.pack(frame);

        let cmdHandler = new("ZFGameOptionsHandler");
        cmdHandler.menu = parent;
        cmdHandler.optMenu = self;

        HXDD_ZF_DropdownItems listEpisodes = new("HXDD_ZF_DropdownItems");
        listEpisodes.items.push("$MNU_COTD");
        listEpisodes.items.push("$MNU_HELLSMAW");
        listEpisodes.items.push("$MNU_DOME");
        listEpisodes.items.push("$MNU_OSSUARY");
        listEpisodes.items.push("$MNU_DEMESNE");
        listEpisodes.items.push("$MNU_FATEPTH");
        listEpisodes.items.push("$MNU_HEXEN");
        listEpisodes.items.push("$MNU_HEXDD");
        if (LemonUtil.CVAR_GetBool("hxdd_isdev_environment", false)) {
            listEpisodes.items.push("Heretic: Modder Test Map");
            listEpisodes.items.push("Hexen: Modder Test Map");
        }
        DropDownCombo ddl_Episodes = new ("DropDownCombo");
        ddl_Episodes.Create(optionArea, (0, 25), (optionArea.GetWidth() - 32, 50), "Episode", listEpisodes, parent.selectedEpisode, "episode", cmdHandler);

        self.ddl_Difficulty = new ("DropDownCombo");
        self.ddl_Difficulty.Create(optionArea, (0, 25 + 75), (optionArea.GetWidth() - 32, 50), Stringtable.Localize("$MNU_HEADER_SKILLSELECTION"), listClassDifficulty[0], parent.selectedSkill, "skill", cmdHandler);

        HXDD_ZF_DropdownItems listArmorMode = new("HXDD_ZF_DropdownItems");
        listArmorMode.items.push("$OPT_CLASS_DEFAULT");
        listArmorMode.items.push("$OPT_ARMOR_SIMPLE");
        listArmorMode.items.push("$OPT_ARMOR_AC");
        listArmorMode.items.push("$OPT_RANDOM");
        //listArmorMode.items.push("Custom");
        DropDownCombo ddl_ArmorMode = new ("DropDownCombo");
        ddl_ArmorMode.Create(optionArea, (0, 25 + 150), (optionArea.GetWidth() - 32, 50), Stringtable.Localize("$MNU_HEADER_ARMORMODE"), listArmorMode, 0, "hxdd_armor_mode", cmdHandler);

        HXDD_ZF_DropdownItems listProgression = new("HXDD_ZF_DropdownItems");
        listProgression.items.push("$OPT_CLASS_DEFAULT");
        listProgression.items.push("$OPT_NONE");
        listProgression.items.push("$OPT_PROG_LEVELS");
        listProgression.items.push("$OPT_RANDOM");
        //listProgression.items.push("Custom");
        DropDownCombo ddl_Progression = new ("DropDownCombo");
        ddl_Progression.Create(optionArea, (0, 25 + 225), (optionArea.GetWidth() - 32, 50), Stringtable.Localize("$MNU_HEADER_PROGRESSIONMODE"), listProgression, 0, "hxdd_progression", cmdHandler);

        HXDD_ZF_DropdownItems listMapSet = new("HXDD_ZF_DropdownItems");
        listMapSet.items.push("$OPT_AUTO_DETECT");
        listMapSet.items.push("$OPT_HERETIC");
        listMapSet.items.push("$OPT_HEXEN");
        DropDownCombo ddl_GameMode = new ("DropDownCombo");
        ddl_GameMode.Create(optionArea, (0, 25 + 300), (optionArea.GetWidth() - 32, 50), Stringtable.Localize("$MNU_HEADER_GAMEMODE"), listMapSet, 0, "hxdd_gamemode", cmdHandler);

        
        let labelTex = HXDD_ZF_Label.create(
            (0, 25 + 450),
            (optionArea.GetWidth(), 50),
            text: "$MNU_TEXTURE_SOURCES",
            alignment: 2,
            textScale: 3.5
        );
        labelTex.pack(optionArea);

        HXDD_ZF_DropdownItems listMapSetTex = new("HXDD_ZF_DropdownItems");
        listMapSetTex.items.push("Default");
        listMapSetTex.items.push("Heretic");
        listMapSetTex.items.push("Hexen");
        DropDownCombo ddl_LavaStyle = new ("DropDownCombo");
        ddl_LavaStyle.Create(optionArea, (0, 25 + 525), (optionArea.GetWidth() - 32, 50), Stringtable.Localize("$MNU_TEXTURE_LAVA_STYLE"), listMapSetTex, 0, "hxdd_lavastyle", cmdHandler);

        DropDownCombo ddl_WaterStyle = new ("DropDownCombo");
        ddl_WaterStyle.Create(optionArea, (0, 25 + 600), (optionArea.GetWidth() - 32, 50), Stringtable.Localize("$MNU_TEXTURE_WATER_STYLE"), listMapSetTex, 0, "hxdd_waterstyle", cmdHandler);

        DropDownCombo ddl_SludgeStyle = new ("DropDownCombo");
        ddl_SludgeStyle.Create(optionArea, (0, 25 + 675), (optionArea.GetWidth() - 32, 50), Stringtable.Localize("$MNU_TEXTURE_SLUDGE_STYLE"), listMapSetTex, 0, "hxdd_sludgestyle", cmdHandler);

        DropDownCombo ddl_IceStyle = new ("DropDownCombo");
        ddl_IceStyle.Create(optionArea, (0, 25 + 750), (optionArea.GetWidth() - 32, 50), Stringtable.Localize("$MNU_TEXTURE_ICE_STYLE"), listMapSetTex, 0, "hxdd_icestyle", cmdHandler);

        //self.CreateXSwapsOptions(optionArea, 25 + 300 + 150, cmdHandler);
    }

    void SetInfoText(String newHeader, String newText) {
        self.headerInformation.SetText(Stringtable.Localize(newHeader));
        self.labelInformation.SetText(Stringtable.Localize(newText));
    }

    void Refresh() {
        int selected = parent.selectedClass;
        if (selected > listClassDifficulty.Size() - 1) {
            selected = 0;
        }
        self.ddl_Difficulty.GetDropDownElement().setItems(listClassDifficulty[selected]);

        int orbColor = self.headerStatueLeft.GetRandomOrb();
        self.headerStatueLeft.SetOrb(orbColor);
        self.headerStatueRight.SetOrb(orbColor);
    }

    void Update() {
        self.headerStatueLeft.Update();
        self.headerStatueRight.Update();
    }

    /*

    void CreateXSwapsOptions(HXDD_ZF_Frame optionArea, int pos, ZFGameOptionsHandler cmdHandler) {
        int lumpIndex = Wads.CheckNumForFullName("xgt/xswap.xgt");
        if (lumpIndex == -1) {
            // try json
            lumpIndex = Wads.CheckNumForFullName("xgt/xswap.json");
        }

        if (lumpIndex != -1) {
            String lumpData = Wads.ReadLump(lumpIndex);
            let json = HXDD_JSON.parse(lumpData, false);
            if (json is "HXDD_JsonElement") {
                HXDD_JsonObject jsonObject = HXDD_JsonObject(json);
                if (jsonObject) {
                    String ver = GetString(jsonObject, "version");
                    //if (ver) {
                    //    console.printf("XGameTranslation.CreateXSwapTranslation: Target Version %s", ver);
                    //}
                    HXDD_JsonArray arrListItems = HXDD_JsonArray(jsonObject.get("list"));
                    if (arrListItems) {
                        int size = arrListItems.Size();
						for (let i = 0; i < size; i++) {
					        HXDD_JsonObject objListItem = HXDD_JsonObject(arrListItems.Get(i));
                            if (objListItem) {
                                String valKey = GetString(objListItem, "key");
                                String valCategory = GetString(objListItem, "category");
                                HXDD_JsonArray valLabels = GetArray(objListItem, "labels");
                                HXDD_JsonArray valActors = GetArray(objListItem, "actors");
                                if (valKey && valActors) {
                                    int size = valActors.Size();

                                    HXDD_ZF_DropdownItems list = new("HXDD_ZF_DropdownItems");
                                    list.items.push("Default");
                                    list.items.push("Random");
                                    for (int j = 0; j < size; j++) {
                                        list.items.push(HXDD_JsonString(valLabels.get(j)).s);
                                    }

                                    String label = HXDD_JsonString(valLabels.get(0)).s;
                                    for (int j = 1; j < size; j++) {
                                        label = String.format("%s %s", label, HXDD_JsonString(valLabels.get(j)).s);
                                    }
                                    String cvarKey = String.format("hxdd_xswap_%s", valKey);
                                    DropDownCombo newDDL = new ("DropDownCombo");
                                    newDDL.Create(optionArea, (0, pos + (i * 75)), (optionArea.GetWidth() - 32, 50), label, list, 0, cvarKey, cmdHandler);
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    String GetString(HXDD_JsonObject jo, String key) {
        HXDD_JsonElement type_elem = jo.get(key);
        if (!type_elem) {
            return "";
        }
        HXDD_JsonString type_str = HXDD_JsonString(type_elem);
        return type_str.s;
    }
    HXDD_JsonArray GetArray(HXDD_JsonObject jo, String key) {
        HXDD_JsonElement type_elem = jo.get(key);
        if (!type_elem) {
            return null;
        }
		HXDD_JsonArray type_arr = HXDD_JsonArray(type_elem);
		return type_arr;
    }

    */
}


class ZFPreGameSetup : HXDD_ZF_GenericMenu {
    // Player Selection
    int selectedClass;
    int selectedEpisode;
    int selectedSkill;

    int selectedGameMode;
    int selectedArmorMode;
    int selectedProgressionMode;

    int selectedTextureStyleLava;
    int selectedTextureStyleWater;
    int selectedTextureStyleSludge;
    int selectedTextureStyleIce;


    HXDD_ZF_Frame frame;
    HXDD_ZF_Frame frameClass;
    HXDD_ZF_Frame frameOptions;
    HXDD_ZF_Frame frameScrollOptions;

    HXDD_ZF_Button btnBack;
    HXDD_ZF_Button btnStart;
    HXDD_ZF_Button btnUseClassicUI;

    ZFPlayerClassSelection framePlayerClassSelection;
    ZFGameOptions frameGameOptions;

    double lastPosX;
    double desiredPosX;
    double time;

    // intro
    bool intro;
    double lastPosY;
    double desiredPosY;

    override void init(Menu parent) {
        Super.init(parent);

        selectedClass = 0;
        selectedEpisode = 0;
        selectedSkill = 2;

        lastPosX = 0;
        desiredPosX = 0;
        time = 0;

        intro = false;

        let baseRes = (1920, 1080);
        setBaseResolution(baseRes);

        self.frame = HXDD_ZF_Frame.create(
            (0, 0),
            (1920 * 2, 1080)
        );
        self.desiredPosX = self.frame.getPosX();
        frame.pack(mainFrame);

        let normal = HXDD_ZF_BoxTextures.createTexturePixels(
            "Graphics/M_FSLOT.png",
            (3, 3),
            (187, 14),
            true,
            true
        );



        let cmdHandler = new("ZFPreGameSetupHandler");
        cmdHandler.menu = self;

        btnStart = HXDD_ZF_Button.create(
            ((1920 * 0.5) - 100, 1080 + 500),
            (200, 50),
            text: "Start",
            cmdHandler: cmdHandler,
            command: 'next',
            inactive: normal,
            hover: normal,
            click: normal,
            textScale: 2.0
        );
        btnStart.pack(mainFrame);
        btnBack = HXDD_ZF_Button.create(
            (50, 1080 - 100),
            (200, 50),
            text: "Back",
            cmdHandler: cmdHandler,
            command: 'back',
            inactive: normal,
            hover: normal,
            click: normal,
            textScale: 2.0
        );
        btnBack.pack(mainFrame);
        /*
        btnUseClassicUI = HXDD_ZF_Button.create(
            (1920 - 350, 1080 - 100),
            (300, 50),
            text: "Original Menu",
            cmdHandler: cmdHandler,
            command: 'classic',
            inactive: normal,
            hover: normal,
            click: normal,
            textScale: 2.0
        );
        btnUseClassicUI.pack(mainFrame);
        */

        framePlayerClassSelection = new("ZFPlayerClassSelection");
        framePlayerClassSelection.Create(self);
        frameGameOptions = new("ZFGameOptions");
        frameGameOptions.Create(self);

        //framePlayerClassSelection.frame.setPosY(-1920);
        //self.lastPosY = -1920;
        //self.desiredPosY = 0;
        intro = true;
        self.lastPosX = 1920;
        self.desiredPosX = 0;
    }

    override void ticker() {
        if (!intro) {
            let duration = 1.5;
            if (time <= duration) {
                time = clamp(time + (1.0 / 35.0), 0, duration);
                let result = LemonUtil.flerp(self.lastPosY, self.desiredPosY, LemonUtil.Easing_Bounce_Out(time / duration));
                self.framePlayerClassSelection.frame.setPosY(result);

                if (time / duration == 1.0) {
                    time = 0;
                    intro = true;
                }
            }
            return;
        }
        let duration = 0.750;
        if (time <= duration) {
            time = clamp(time + (1.0 / 35.0), 0, duration);
            let result = LemonUtil.flerp(self.lastPosX, self.desiredPosX, LemonUtil.Easing_Quadradic_Out(time / duration));
            self.frame.setPosX(result);
        }

        framePlayerClassSelection.Update();
        frameGameOptions.Update();
    }
}
