
class W_KeyStatue ui {
    HXDD_ZF_Frame parent;
    HXDD_ZF_Frame frame;
    HXDD_ZF_Image imgStatue;
    HXDD_ZF_Image imgOrb;

    Array<String> orbs;
    double orbOffset;

    int tick;
    int tickFrame;
    int tickSwayFrame;

    void Create(HXDD_ZF_Frame parent, vector2 position, double scale, bool right_align = false) {
        vector2 prScale = (1.0, 1.2);
        Array<String> orbimages = {
            "KGZBA0",
            "KGZGA0",
            "KGZYA0",
            "assets/ui/M_UI_ORB.png"
        };
        self.orbs.Copy(orbimages);

        tickSwayFrame = random[orb](1, 10) * (random[orb2](1,10) * 3);

        int floatOffset = 4;
        self.frame = HXDD_ZF_Frame.create(
            (right_align ? position.x - (38 * scale) : position.x, position.y - floatOffset),
            (38 * scale, (53 + 19 + floatOffset) * scale * prScale.y)
        );
        self.frame.pack(parent);

        self.imgStatue = HXDD_ZF_Image.create(
            (0,floatOffset),
            (38 * scale, (53 + 19) * scale * prScale.y),
            image: "KGZ1A0",
            alignment: 2 | (3 << 4),
            imageScale: (scale, scale * prScale.y)
        );
        self.imgStatue.pack(self.frame);

        self.imgOrb = HXDD_ZF_Image.create(
            (0,floatOffset),
            (38 * scale, 19 * scale * prScale.y),
            image: self.orbs[0],
            alignment: 2 | (3 << 4),
            imageScale: (scale, scale * prScale.y)
        );
        self.imgOrb.pack(self.frame);
    }

    void SetOrb(int index) {
        self.imgOrb.setImage(self.orbs[index]);
    }

    void Update() {
        tickFrame += 3;
        tickSwayFrame += random[sway](1,5);

        self.imgOrb.setPosY((sin(tickFrame) * 4.0) + 3);
        self.imgOrb.setPosX((cos(tickSwayFrame) * sin(tickFrame * -0.5)) * 4.5);
    }

    int GetRandomOrb() {
        return random[ui_orb](0, self.orbs.size() - 1);
    }
}