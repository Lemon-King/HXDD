class RecoilController: Inventory {
    vector2 recoil;
    void AddRecoil(vector2 value) {
        double cvarRecoilScale = LemonUtil.CVAR_GetFloat("hxdd_recoil_scale", 1.0, self.owner.player);
        if (cvarRecoilScale > 0.0) {
            vector2 scaledValue = value * cvarRecoilScale;
            self.recoil += scaledValue;
            owner.pitch += scaledValue.x;
            owner.angle += scaledValue.y;
        }
    }

    override void DoEffect() {
        if (self.recoil.x != 0.0 || self.recoil.y != 0.0) {
            vector2 dir = LemonUtil.v2normalize(self.recoil);
            vector2 amount = dir * -10.0 / TICRATEF;  // scale by drop speed

            if (abs(self.recoil.x) <= abs(amount.x)) {
                amount.x = -self.recoil.x;
            }
            if (abs(self.recoil.y) <= abs(amount.y)) {
                amount.y = -self.recoil.y;
            }

            self.recoil.x += amount.x;
            self.recoil.y += amount.y;

            owner.pitch += amount.x;
            owner.angle += amount.y;
        }
    }
}