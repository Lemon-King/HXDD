package lemon.hxdd.shared;

import java.io.File;
import java.io.IOException;
import java.nio.file.*;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.stream.Stream;

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


    public static void CopyDirectory(Path source, Path target) throws IOException {

        if (Files.isDirectory(source)) {
            if (Files.notExists(target)) {
                Files.createDirectories(target);
                //System.out.println("Directory created : " + target);
            }
            try (Stream<Path> paths = Files.list(source)) {
                paths.forEach(p -> CopyDirectoryWrapper(p, target.resolve(source.relativize(p))));

            }
        } else {
            Files.copy(source, target, StandardCopyOption.REPLACE_EXISTING);
            //System.out.println(
            //        String.format("Copy File from \t'%s' to \t'%s'", source, target)
            //);
        }
    }

    public static void CopyDirectoryWrapper(Path source, Path target) {
        try {
            CopyDirectory(source, target);
        } catch (IOException e) {
            System.err.println("IO errors : " + e.getMessage());
        }

    }
}
