package lemon.hxdd.builder;

import lemon.hxdd.Application;

import java.io.*;
import java.net.URISyntaxException;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.Collections;
import java.util.concurrent.atomic.AtomicReference;

import static java.nio.file.StandardCopyOption.REPLACE_EXISTING;

public class SoundInfo {
    Application app;

    SoundInfo(Application app) {
        this.app = app;
    }
    public void Export() {
        String SettingPathTemp = this.app.settings.GetPath("temp");
        try {
            ZipAssets za = new ZipAssets(this.app);
            za.SetFile(new File("resources.zip"));
            String sndinfohx2 = za.ReadFileAsString("pakdata/hexen2/sndinfo.hx2");

            FileWriter fw = new FileWriter(SettingPathTemp + "/sndinfo.hx2", true);
            PrintWriter out = new PrintWriter(fw);
            AddGeneratedByTag(out);
            ListFiles(out);
            out.println("\n");
            out.println(sndinfohx2);
            out.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private void ListFiles(PrintWriter out) {
        String path = this.app.settings.GetPath("hexen2") + "/sound";
        File directory = new File(path);

        File[] fileList = directory.listFiles();
        if (fileList != null) {
            for (File file : fileList) {
                if (file.isFile()) {
                    try {
                        String p = file.getCanonicalPath();
                        p = p.replace("\\", "/");

                        String[] s = p.split("hexen2_data");
                        String logicalname = (String) s[1].subSequence(1, s[1].length() - 4);
                        String lumpname = (String) s[1].subSequence(1, s[1].length());

                        // Setup naming convention and folder paths
                        logicalname = logicalname.replace("sound", "hexen2");
                        lumpname = lumpname.replace("sound", "sounds/hexen2");

                        String space = String.join("", Collections.nCopies(32 - logicalname.length(), " "));    // dumb, but it works
                        out.println(logicalname + space + "\"" + lumpname + "\"");
                    } catch (IOException ignored) {

                    }
                } else if (file.isDirectory()) {
                    out.println("");
                    //ListFiles(file.getAbsolutePath(), out);
                }
            }
        }
    }

    private void AddGeneratedByTag(PrintWriter writer) {
        writer.print("\n//\n// Generated by HXDD\n//\n\n");
    }
}
