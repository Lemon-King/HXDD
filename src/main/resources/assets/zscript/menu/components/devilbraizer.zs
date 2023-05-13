
class W_DevilBraizer ui {
    HXDD_ZF_Frame parent;
    HXDD_ZF_Frame frame;
    HXDD_ZF_Image img;

    Array<String> images;

    int tick;
    int tickFrame;

    void Create(HXDD_ZF_Frame parent, vector2 position, double scale, bool right_align = false) {
        Array<String> animatedImages = {
            "KFR1A0",
            "KFR1B0",
            "KFR1C0",
            "KFR1D0",
            "KFR1E0",
            "KFR1F0",
            "KFR1G0",
            "KFR1H0"
        };
        self.images.Copy(animatedImages);

        self.frame = HXDD_ZF_Frame.create(
            (right_align ? position.x - (41 * scale) : position.x, position.y),
            (41 * scale, 82 * scale)
        );
        self.frame.pack(parent);

        self.img = HXDD_ZF_Image.create(
            (0,0),
            (41 * scale, 82 * scale),
            image: self.images[0],
            alignment: 2 | (3 << 4),
            imageScale: (scale, scale)
        );
        self.img.pack(self.frame);
    }

    void Update() {
        tick = ++tick % 4;
        if (tick == 0) {
            // update frame
            tickFrame = ++tickFrame % self.images.Size();
            self.img.setImage(self.images[tickFrame]);
        }
    }
}