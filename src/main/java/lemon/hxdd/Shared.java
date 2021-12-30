package lemon.hxdd;

import net.mtrop.doom.graphics.Palette;

import java.awt.*;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.Arrays;

public class Shared {
    public static final String TAB_SPACE = "    ";
    public static final String TAB_SPACE_DOUBLE = TAB_SPACE + TAB_SPACE;

    public static Palette GetHexen2Palette() {
        String pathHexen2Gfx = Settings.getInstance().Get("PathHexen2") + "/data1/gfx/";
        Palette pal = new Palette();
        try {
            File filePal = new File(pathHexen2Gfx + "palette.lmp");
            FileInputStream fis = new FileInputStream(filePal);
            pal.readBytes(fis);
            fis.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return pal;
    }
    public static Palette GetHexen2TransparencyPalette() {
        Palette pal = GetHexen2Palette();
        pal.setColor(0, 100, 100, 100);
        return pal;
    }
    public static Palette GetHexen2BrightmapPalette() {
        Palette pal = GetHexen2Palette();
        Palette palBrightmap = new Palette();
        for (int i = 0; i < Palette.NUM_COLORS; i++) {
            int[] cv = new int[3];
            int argb = pal.getColorARGB(i);
            cv[0] = (0x00ff0000 & argb) >> 16;
            cv[1] = (0x0000ff00 & argb) >> 8;
            cv[2] = (0x000000ff & argb);
            int cvmax = Arrays.stream(cv).max().getAsInt();
            int color = 0;
            if (i >= Palette.NUM_COLORS - 17) {
                color = cvmax;
            }
            palBrightmap.setColor(i, color, color, color);
        }
        return palBrightmap;
    }
}
