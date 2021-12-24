package lemon.hxdd;

import org.zeroturnaround.zip.ZipUtil;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;

// http://richwhitehouse.com/noesis/nms/index.php?content=userman

public class Noesis {
    static final boolean SHOW_LOGS = true;

    // TODO: Figure out how to make Noesis work with wine on Linux/MacOS via CLI?

    static public boolean CheckAndInstall() {
        String Settings_PathNoesis = (String) Settings.getInstance().Get("PathNoesis");
        boolean hasNoesis = false;
        File pathNoesis = new File(Settings_PathNoesis);
        if (pathNoesis.exists()) {
            File pathNoesisExe = new File("./noesis/noesis.exe");
            hasNoesis = pathNoesisExe.exists();
        }
        if (!hasNoesis) {
            File folder = new File("./");
            File[] files = folder.listFiles();
            for ( File f : files) {
                String fileName = f.getName();
                if (fileName.startsWith("noesis") && fileName.endsWith(".zip")) {
                    ZipUtil.unpack(f, pathNoesis);
                    return true;
                }
            }
        }
        return hasNoesis;
    }

    static public void ExtractPak(String file, String destination) {
        // Example: "pak0.pak" "./wads/hexen2/data1"
        //System.out.printf("Dumping Pak File %s\n", file);
        String args = String.format("\"wads/%s\" \"%s\"", file, destination);
        Run(args);
    }

    static public void ExportAsset(String assetPath, String outputFolder, String[] options) {
        String fileName = new File(assetPath).getName();
        String target = "";
        String textpre = "";
        if (fileName.endsWith(".mdl")) {
            target = fileName.replace("mdl", "md3");
            textpre = fileName.replace(".mdl", "_");
        } else if (fileName.endsWith(".spr")) {
            target = fileName.replace(".spr", ".png");
        } else if (fileName.endsWith(".lmp")) {
            // Could also be handled by net.mtrop.doom with the Hexen 2 Palette
            target = fileName.replace(".lmp", ".png");
        } else {
            // unknown file
            return;
        }
        File outFolder = new File("temp/" + outputFolder);
        if (!outFolder.exists()) {
            outFolder.mkdirs();
        }

        String joinedOptions = String.format(String.join(" ", options), textpre);
        String args = String.format("\"%s\" \"temp/%s%s\" %s", assetPath, outputFolder, target, joinedOptions);
        Run(args);
    }

    static private void Run(String args) {
        try {
            boolean SETTING_USE32BITNOESIS = (boolean) Settings.getInstance().Get("Use32bitNoesis");

            String exeNoesis = "noesis/Noesis64.exe";
            if (SETTING_USE32BITNOESIS) {
                exeNoesis = "noesis/Noesis.exe";
            }
            String exec = String.format("%s ?cmode %s", exeNoesis, args);
            Process process = Runtime.getRuntime().exec(exec);

            if (SHOW_LOGS) {
                new Thread(new Runnable() {
                    public void run() {
                        BufferedReader input = new BufferedReader(new InputStreamReader(process.getInputStream()));

                        try {
                            String line = null;
                            while ((line = input.readLine()) != null) {
                                System.out.println(line);
                            }
                        } catch (IOException e) {
                            e.printStackTrace();
                        }
                    }
                }).start();
            }

            process.waitFor();
        } catch (IOException | InterruptedException e) {
            e.printStackTrace();
        }
    }
}
