package lemon.hxdd.shared;

import java.io.File;

public class Util {
    public static final String TAB_SPACE = "    ";
    public static final String TAB_SPACE_DOUBLE = TAB_SPACE + TAB_SPACE;

    public static void CreateDirectory(String path) {
        File dirFile = new File(path);
        if (!dirFile.exists()) {
            dirFile.mkdirs();
        }
    }
    /*
    public static Palette GetHexen2BrightmapPalette() {
        Palette pal = GetHexen2Palette();
        Palette newPal = new Palette();
        for (int i = 0; i < Palette.NUM_COLORS; i++) {
            int[] cv = new int[3];
            int argb = pal.getColorARGB(i);
            cv[0] = (0x00ff0000 & argb) >> 16;
            cv[1] = (0x0000ff00 & argb) >> 8;
            cv[2] = (0x000000ff & argb);
            int cvmax = Arrays.stream(cv).max().getAsInt();
            int color = 0;
            if (i == 255) {        // only color 255 is considered bright
                color = cvmax;
            }
            newPal.setColor(i, color, color, color);
        }
        return newPal;
    }
    */
}
