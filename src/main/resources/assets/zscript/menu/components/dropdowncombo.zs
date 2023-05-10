class DropDownCombo ui {
    HXDD_ZF_Frame parent;
    HXDD_ZF_Frame frame;
    HXDD_ZF_Label label;
    HXDD_ZF_DropdownList ddl;
    void Create(HXDD_ZF_Frame parent, vector2 position, vector2 dims, String text, HXDD_ZF_DropdownItems items, int defaultSelection, String command, HXDD_ZF_Handler handler) {
        int indent = 25;
        double labelWidth = dims.x * 0.45;
        double ddlWidth = dims.x * 0.55;

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

        self.parent = parent;
        self.frame = HXDD_ZF_Frame.create(
            position,
            dims
        );
        self.frame.pack(self.parent);
        double width = self.frame.GetWidth();

        self.label = HXDD_ZF_Label.create(
            (indent,   0),
            (labelWidth, dims.y),
            text: text,
            alignment: 2 << 4,
            textScale: 3.5
        );
        self.label.pack(self.frame);

        self.ddl = HXDD_ZF_DropdownList.create(
            (indent + labelWidth, 0),    
            (ddlWidth - indent, dims.y),
            items,
            textScale: 2.5,
            boxBg: btNormal,
            listBg: btNormal,
            highlightBg: btHover,
            defaultSelection: defaultSelection,
            cmdHandler: handler,
            command: command
        );
        self.ddl.pack(self.frame);
    }

    HXDD_ZF_Label GetDropDownLabel() {
        return self.label;
    }
    HXDD_ZF_DropdownList GetDropDownElement() {
        return self.ddl;
    }
}