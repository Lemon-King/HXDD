

class ButtonPlayerClass ui {
    int tick;
    int walkframe;

    HXDD_ZF_Image imgWalk;

    Array<String> imgClassWalk;

    void Create(HXDD_ZF_Frame parent, HXDD_ZF_Handler handler, vector2 location, double scale, String name, string className, String pathBackground, Array<String> images) {
        tick = 0;

        self.imgClassWalk.Copy(images);

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
            image: self.imgClassWalk[0],
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
            command: className,
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

    void CreateHX2(HXDD_ZF_Frame parent, HXDD_ZF_Handler handler, vector2 location, double scale, String name, string className, String pathBackground) {
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
            command: className,
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
            self.imgWalk.setImage(self.imgClassWalk[walkframe]);
        }
    }
}