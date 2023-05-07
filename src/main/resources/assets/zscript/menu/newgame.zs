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
            } else if (menu.frame.getPosX() == -1920) {
                Menu.MenuSound("menu/choose");
                menu.time = 0;
                menu.lastPosX = menu.frame.getPosX();
                menu.desiredPosX = 0;
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

            menu.btnNext.SetText("Start");

            menu.frameGameOptions.Refresh();
        }
    }
}
class ZFGameOptionsHandler : HXDD_ZF_Handler {
    ZFPreGameSetup menu;
    override void dropdownChanged(HXDD_ZF_DropdownList caller, Name command) {
        if (command == "episode") {
            String choice = command;
            menu.selectedEpisode = caller.getSelection();
        } else if (command == "skill") {
            String choice = command;
            menu.selectedSkill = caller.getSelection();
        } else {
            let cvarGameMode = Cvar.FindCVar(command);
            if (cvarGameMode) {
                cvarGameMode.SetInt(caller.getSelection());
            }
        }
    }
}

class PlayerClassButton ui {
    int tick;
    int walkframe;

    HXDD_ZF_Image imgWalk;

    String pathTexWalk1;
    String pathTexWalk2;
    String pathTexWalk3;
    String pathTexWalk4;

    void Create(HXDD_ZF_Frame parent, HXDD_ZF_Handler handler, vector2 location, double scale, String name, int classid, String pathBackground, String pathWalk1, String pathWalk2, String pathWalk3, String pathWalk4) {
        tick = 0;

        self.pathTexWalk1 = pathWalk1;
        self.pathTexWalk2 = pathWalk2;
        self.pathTexWalk3 = pathWalk3;
        self.pathTexWalk4 = pathWalk4;

        HXDD_ZF_Frame frameChrClass = HXDD_ZF_Frame.create(
            location,
            (112 * scale, 160 * scale)
        );
        frameChrClass.pack(parent);

        // artwork
        let imgClassBackground = HXDD_ZF_Image.create(
            (0, 0),
            (112 * scale, 136 * scale),
            image: pathBackground,
            imageScale: (scale, scale)
        );
        imgClassBackground.pack(frameChrClass);
        
        
        imgWalk = HXDD_ZF_Image.create(
            // This argument controls the position - 50 pixels under the label.
            (0, 15 * scale),
            // This argument controls the size. Here we match STARTAN2.
            (112 * scale, 68 * scale),
            // The texture name.
            image: pathWalk1,
            alignment: 2 | (3 << 4),
            imageScale: (scale, scale)
        );
        // As before we pack it into `frame`.
        imgWalk.pack(frameChrClass);

        let hoverOutline = HXDD_ZF_BoxTextures.createTexturePixels(
            "graphics/SELECTBO.png",
            (1, 1),
            (27, 28),
            true,
            false
        );
        // Here we create our fourth element, a button.
        // We'll put it under the box image, with the box textures we just created.
        let btnSelect = HXDD_ZF_Button.create(
            (0, 0),
            (112 * scale, 136 * scale),
            cmdHandler: handler,
            command: String.format("%d", classid),
            hover: hoverOutline,
            click: hoverOutline
        );
        btnSelect.pack(frameChrClass);

        let label = HXDD_ZF_Label.create(
            (0, 136 * scale),
            (112 * scale, 18 * scale),
            text: name,
            alignment: 2 | (3 << 4),
            textScale: 1.5 * scale
        );
        label.pack(frameChrClass);

    }

    void CreateHX2(HXDD_ZF_Frame parent, HXDD_ZF_Handler handler, vector2 location, double scale, String name, int classid, String pathBackground) {
        HXDD_ZF_Frame frameChrClass = HXDD_ZF_Frame.create(
            location,
            (112 * scale, 130 * scale)
        );
        frameChrClass.pack(parent);

        // artwork
        let imgClassBackground = HXDD_ZF_Image.create(
            (22 * scale, 0),
            (68 * scale, 114 * scale),
            image: pathBackground,
            imageScale: (scale, scale)
        );
        imgClassBackground.pack(frameChrClass);

        let hoverOutline = HXDD_ZF_BoxTextures.createTexturePixels(
            "graphics/SELECTBO.png",
            (1, 1),
            (27, 28),
            true,
            false
        );
        // Here we create our fourth element, a button.
        // We'll put it under the box image, with the box textures we just created.
        let btnSelect = HXDD_ZF_Button.create(
            (22 * scale, 0),
            (68 * scale, 114 * scale),
            cmdHandler: handler,
            command: String.format("%d", classid),
            hover: hoverOutline,
            click: hoverOutline
        );
        btnSelect.pack(frameChrClass);

        let label = HXDD_ZF_Label.create(
            (0, 110 * scale),
            (114 * scale, 18 * scale),
            text: name,
            alignment: 2 | (3 << 4),
            textScale: 1.15 * scale
        );
        label.pack(frameChrClass);

    }

    void Update() {
        tick = ++tick % 8;
        if (tick == 0) {
            // update frame
            walkframe = ++walkframe % 4;
            if (walkframe == 0) {
                imgWalk.setImage(self.pathTexWalk1);
            } else if (walkframe == 1) {
                imgWalk.setImage(self.pathTexWalk2);
            } else if (walkframe == 2) {
                imgWalk.setImage(self.pathTexWalk3);
            } else if (walkframe == 3) {
                imgWalk.setImage(self.pathTexWalk4);
            }
        }
    }
}

class ZFPlayerClassSelection ui {
    HXDD_ZF_Frame frame;

    PlayerClassButton btnClassCorvus;
    PlayerClassButton btnClassFighter;
    PlayerClassButton btnClassCleric;
    PlayerClassButton btnClassMage;

    PlayerClassButton btnClassAssassin;
    PlayerClassButton btnClassCrusader;
    PlayerClassButton btnClassNecromancer;
    PlayerClassButton btnClassPaladin;
    PlayerClassButton btnClassSuccubus;

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
            ( 0 , 50),
            (1920, 24 * 4),
            text: "Class Selection",
            fnt: "BIGFONT",
            alignment: 2,
            textScale: 4
        );
        // We put this in `frame`.
        header.pack(frame);

        let cmdHandlerClassSelect = new("ZFClassSelectHandler");
        cmdHandlerClassSelect.menu = parent;

        double classLineX = (1080 * 0.25) + (56 * 2.5) + 50;
        double hereticPosY = 450 + ((142 * 2.5 * 0.5) - (112 * 1.5 * 0.5));
        btnClassCorvus = new("PlayerClassButton");
        btnClassCorvus.Create(frame, cmdHandlerClassSelect, (hereticPosY, classLineX), 1.5, "Corvus", 0, "graphics/M_HBOX.png", "sprites/PLAYA1.png", "sprites/PLAYB1.png", "sprites/PLAYC1.png", "sprites/PLAYD1.png");

        double hexenPosY = 1920 - 450 - (144 * 2.5) + ((144 * 2.5 * 0.5) - (112 * 1.5 * 0.5));
        btnClassFighter = new("PlayerClassButton");
        btnClassFighter.Create(frame, cmdHandlerClassSelect, (hexenPosY - 200, classLineX), 1.5, "Fighter", 1, "graphics/M_FBOX.png", "graphics/M_FWALK1.png", "graphics/M_FWALK2.png", "graphics/M_FWALK3.png", "graphics/M_FWALK4.png");

        btnClassCleric = new("PlayerClassButton");
        btnClassCleric.Create(frame, cmdHandlerClassSelect, (hexenPosY, classLineX), 1.5, "Cleric", 2, "graphics/M_CBOX.png", "graphics/M_CWALK1.png", "graphics/M_CWALK2.png", "graphics/M_CWALK3.png", "graphics/M_CWALK4.png");

        btnClassMage = new("PlayerClassButton");
        btnClassMage.Create(frame, cmdHandlerClassSelect, (hexenPosY + 200, classLineX), 1.5, "Mage", 3, "graphics/M_MBOX.png", "graphics/M_MWALK1.png", "graphics/M_MWALK2.png", "graphics/M_MWALK3.png", "graphics/M_MWALK4.png");


        // Cvar hxdd_installed_hexen2 is located in cvarinfo.installed_hexen2
        CVar cvarHexII = CVar.FindCVar('hxdd_installed_hexen2');
        if (cvarHexII && cvarHexII.GetBool()) {
            // display Hexen II classes
            double classLineXOffset = (136 * 1.5) + 50;
            btnClassAssassin = new("PlayerClassButton");
            btnClassAssassin.CreateHX2(frame, cmdHandlerClassSelect, (hexenPosY - 320, classLineX + classLineXOffset), 1.5, "Paladin", 4, "graphics/netp1.png");
            btnClassCrusader = new("PlayerClassButton");
            btnClassCrusader.CreateHX2(frame, cmdHandlerClassSelect, (hexenPosY - 160, classLineX + classLineXOffset), 1.5, "Crusader", 5, "graphics/netp2.png");
            btnClassNecromancer = new("PlayerClassButton");
            btnClassNecromancer.CreateHX2(frame, cmdHandlerClassSelect, (hexenPosY, classLineX + classLineXOffset), 1.5, "Necromancer", 6, "graphics/netp3.png");
            btnClassPaladin = new("PlayerClassButton");
            btnClassPaladin.CreateHX2(frame, cmdHandlerClassSelect, (hexenPosY + 160, classLineX + classLineXOffset), 1.5, "Assassin", 7, "graphics/netp4.png");

            // Cvar hxdd_installed_hexen2_expansion is located in cvarinfo.installed_hexen2_expansion
            CVar cvarHexII_EX = CVar.FindCVar('hxdd_installed_hexen2_expansion');
            if (cvarHexII_EX && cvarHexII_EX.GetBool()) {
                // display Hexen II Expansion classes
                btnClassSuccubus = new("PlayerClassButton");
                btnClassSuccubus.CreateHX2(frame, cmdHandlerClassSelect, (hexenPosY + 320, classLineX + classLineXOffset), 1.5, "Demoness", 8, "graphics/netp5.png");
            }
        }
    }

    void Update() {
        btnClassCorvus.Update();
        btnClassFighter.Update();
        btnClassCleric.Update();
        btnClassMage.Update();
    }
}

class ZFGameOptionsScrollContainerHandler : HXDD_ZF_Handler {
    ZFPreGameSetup menu;
}
class ZFGameOptions ui {
    ZFPreGameSetup parent;
    HXDD_ZF_Frame frame;
    HXDD_ZF_DropdownList ddlDifficulty;

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
            ( 0 , 50),
            (1920, 24 * 4),
            text: "Gameplay Options",
            fnt: "BIGFONT",
            alignment: 2,
            textScale: 4
        );
        labelOpt.pack(frame);
        
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
            "assets/ui/groupbox.png",
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
            (1920 * 0.55 - (32 + 4), 1080 * 1.2)
        );
        let optionGroupBackground2 = HXDD_ZF_BoxImage.create(
            (0, 0),
            (1920 * 0.55 - (32 + 4), 1080 * 0.6),
            background
        );
        optionGroupBackground2.pack(optionArea);

        let scrollContainer = HXDD_ZF_ScrollContainer.create(
            (50 + 2, 300 + 2),
            (1920 * 0.55 - 4, 1080 * 0.6 - 4),
            32,
            1080 * 1.2,
            (1920 * 0.55 - 4) * 0.1,
            scrollbar_n,
            scrollBarHover: scrollbar_h,
            scrollBarClick: scrollbar_c,
            //scrollBg: scrollbar_n,
            scrollArea: optionArea
        );
        scrollContainer.pack(frame);


        let btNormal = HXDD_ZF_BoxTextures.createTexturePixels(
            "assets/ui/zforms/CommonBackgroundNormal.png",
            (7, 7),
            (14, 14),
            true,
            true
        );


        let btHover = HXDD_ZF_BoxTextures.createTexturePixels(
            "assets/ui/zforms/CommonBackgroundHover.png",
            (7, 7),
            (14, 14),
            true,
            true
        );


        let btClick = HXDD_ZF_BoxTextures.createTexturePixels(
            "assets/ui/zforms/CommonBackgroundClick.png",
            (7, 7),
            (14, 14),
            true,
            true
        );

        let labelEpisode = HXDD_ZF_Label.create(
            (  25,   25),
            (350, 50),
            text: "Episode",
            alignment: 2 << 4,
            textScale: 4.0
        );
        labelEpisode.pack(optionArea);

        let cmdHandler = new("ZFGameOptionsHandler");
        cmdHandler.menu = parent;
        HXDD_ZF_DropdownItems listEpisodes = new("HXDD_ZF_DropdownItems");
        listEpisodes.items.push("$MNU_COTD");
        listEpisodes.items.push("$MNU_HELLSMAW");
        listEpisodes.items.push("$MNU_DOME");
        listEpisodes.items.push("$MNU_OSSUARY");
        listEpisodes.items.push("$MNU_DEMESNE");
        listEpisodes.items.push("$MNU_FATEPTH");
        listEpisodes.items.push("$MNU_HEXEN");
        listEpisodes.items.push("$MNU_HEXDD");
        listEpisodes.items.push("DEV: HERETIC TEST");
        listEpisodes.items.push("DEV: HEXEN TEST");
        let ddlEpisodes = HXDD_ZF_DropdownList.create(
            ((1920 * 0.55 - 4) - (550 + 32 + 25),25),    
            (550, 50),
            listEpisodes,
            textScale: 2.5,
            boxBg: btNormal,
            listBg: btNormal,
            highlightBg: btHover,
            defaultSelection: parent.selectedEpisode,
            cmdHandler: cmdHandler,
            command: "episode"
        );
        ddlEpisodes.pack(optionArea);

        let labelDifficulty = HXDD_ZF_Label.create(
            (  25,   25 + 75),
            (350, 50),
            text: "Difficulty",
            alignment: 2 << 4,
            textScale: 4.0
        );
        labelDifficulty.pack(optionArea);

        ddlDifficulty = HXDD_ZF_DropdownList.create(
            ((1920 * 0.55 - 4) - (550 + 32 + 25),25 + 75),    
            (550, 50),
            listClassDifficulty[0],
            textScale: 2.5,
            boxBg: btNormal,
            listBg: btNormal,
            highlightBg: btHover,
            defaultSelection: parent.selectedSkill,
            cmdHandler: cmdHandler,
            command: "skill"
        );
        ddlDifficulty.pack(optionArea);

        let labelGameMode = HXDD_ZF_Label.create(
            (  25,   25 + 150),
            (350, 50),
            text: "Game Mode",
            alignment: 2 << 4,
            textScale: 4.0
        );
        labelGameMode.pack(optionArea);

        HXDD_ZF_DropdownItems listMapSet = new("HXDD_ZF_DropdownItems");
        listMapSet.items.push("Auto-Detect");
        listMapSet.items.push("Heretic");
        listMapSet.items.push("Hexen");
        let ddlGameMode = HXDD_ZF_DropdownList.create(
            ((1920 * 0.55 - 4) - (550 + 32 + 25),25 + 150),    
            (550, 50),
            listMapSet,
            textScale: 2.5,
            boxBg: btNormal,
            listBg: btNormal,
            highlightBg: btHover,
            defaultSelection: 0,
            cmdHandler: cmdHandler,
            command: "hxdd_gamemode"
        );
        ddlGameMode.pack(optionArea);

        let labelArmor = HXDD_ZF_Label.create(
            (  25,   25 + 225),
            (350, 50),
            text: "Armor Mode",
            alignment: 2 << 4,
            textScale: 4.0
        );
        labelArmor.pack(optionArea);

        HXDD_ZF_DropdownItems listArmorMode = new("HXDD_ZF_DropdownItems");
        listArmorMode.items.push("Default");
        listArmorMode.items.push("Heretic (Simple)");
        listArmorMode.items.push("Hexen & Hexen II (Class Defined)");
        listArmorMode.items.push("Random");
        //listArmorMode.items.push("User Defined");
        let ddlArmorMode = HXDD_ZF_DropdownList.create(
            ((1920 * 0.55 - 4) - (550 + 32 + 25),25 + 225),    
            (550, 50),
            listArmorMode,
            textScale: 2.5,
            boxBg: btNormal,
            listBg: btNormal,
            highlightBg: btHover,
            defaultSelection: 0,
            cmdHandler: cmdHandler,
            command: "hxdd_armor_mode"
        );
        ddlArmorMode.pack(optionArea);

        let labelProgression = HXDD_ZF_Label.create(
            (  25,   25 + 300),
            (350, 50),
            text: "Progression",
            alignment: 2 << 4,
            textScale: 4.0
        );
        labelProgression.pack(optionArea);

        HXDD_ZF_DropdownItems listProgression = new("HXDD_ZF_DropdownItems");
        listProgression.items.push("Default");
        listProgression.items.push("None (Heretic & Hexen)");
        listProgression.items.push("Levels (Hexen II)");
        listProgression.items.push("Random");
        //listProgression.items.push("User Defined");
        let ddlProgression = HXDD_ZF_DropdownList.create(
            ((1920 * 0.55 - 4) - (550 + 32 + 25),25 + 300),    
            (550, 50),
            listProgression,
            textScale: 2.5,
            boxBg: btNormal,
            listBg: btNormal,
            highlightBg: btHover,
            defaultSelection: 0,
            cmdHandler: cmdHandler,
            command: "hxdd_progression"
        );
        ddlProgression.pack(optionArea);
    }

    void Refresh() {
        int selected = parent.selectedClass;
        if (selected > listClassDifficulty.Size() - 1) {
            selected = 0;
        }
        ddlDifficulty.setItems(listClassDifficulty[selected]);
    }
}


class ZFPreGameSetup : HXDD_ZF_GenericMenu {
    // Player Selection
    int selectedClass;
    int selectedEpisode;
    int selectedSkill;

    HXDD_ZF_Frame frame;
    HXDD_ZF_Frame frameClass;
    HXDD_ZF_Frame frameOptions;
    HXDD_ZF_Frame frameScrollOptions;

    HXDD_ZF_Button btnBack;
    HXDD_ZF_Button btnNext;
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

        btnNext = HXDD_ZF_Button.create(
            (1920 - 250, 1080 - 100),
            (200, 50),
            text: "Next",
            cmdHandler: cmdHandler,
            command: 'next',
            inactive: normal,
            hover: normal,
            click: normal,
            textScale: 2.0
        );
        btnNext.pack(mainFrame);
        btnBack = HXDD_ZF_Button.create(
            (1920 - 500, 1080 - 100),
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
        btnUseClassicUI = HXDD_ZF_Button.create(
            (50, 1080 - 100),
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
    }
}
