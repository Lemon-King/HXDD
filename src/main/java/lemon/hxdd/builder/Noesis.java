package lemon.hxdd.builder;

import lemon.hxdd.Application;

import java.io.*;
import java.util.ArrayList;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

// http://richwhitehouse.com/noesis/nms/index.php?content=userman

public class Noesis {
    Application app;
    final boolean SHOW_LOGS = true;

    // TODO: Figure out how to make Noesis work with wine on Linux/MacOS?

    Noesis(Application app) {
        this.app = app;
    }

    public boolean CheckAndInstall() {
        boolean hasNoesis = false;
        String SETTINGS_PATH_ROOT = this.app.settings.GetPath("root");
        String SETTINGS_PATH_NOESIS = this.app.settings.GetPath("noesis");
        System.out.println(SETTINGS_PATH_NOESIS);
        File pathNoesis = new File(SETTINGS_PATH_NOESIS);

        if (pathNoesis.exists()) {
            File pathNoesisExe = new File(SETTINGS_PATH_NOESIS + "/noesis.exe");
            hasNoesis = pathNoesisExe.exists();
        }
        if (!hasNoesis) {
            File folderRoot = new File(SETTINGS_PATH_ROOT);
            File[] files = folderRoot.listFiles();

            File zipNoesis = null;
            for (File f : files) {
                String fileName = f.getName();
                if (fileName.startsWith("noesis") && fileName.endsWith(".zip")) {
                    zipNoesis = f;
                    break;
                }
            }
            if (zipNoesis != null) {
                if (!pathNoesis.exists()) {
                    pathNoesis.mkdirs();
                }

                try {
                    FileInputStream fis = new FileInputStream(zipNoesis);
                    ZipInputStream zis = new ZipInputStream(fis);
                    ZipEntry entry;
                    while ((entry = zis.getNextEntry()) != null) {
                        File target = new File(pathNoesis, entry.getName());
                        if (entry.isDirectory() && !target.exists()) {
                            target.mkdirs();
                        } else {
                            OutputStream os = new FileOutputStream(target);
                            os.write(zis.readAllBytes());
                            os.close();
                        }
                    }
                    zis.close();
                    fis.close();
                } catch (IOException e) {
                    throw new RuntimeException(e);
                }
            }
        }
        return hasNoesis;
    }

    public void ExtractPak(File pak, File destination) {
        // Example: "pak0.pak" "./wads/hexen2/data1"
        //System.out.printf("Dumping Pak File %s\n", file);
        String args = String.format("\"%s\" \"%s/\"", pak.getAbsolutePath(), destination.getAbsolutePath());
        Run(args);
    }

    public void ExportAsset(String assetPath, String outputFolder, ArrayList<String> options) {
        String fileName = new File(assetPath).getName();
        String target = "";
        String textpre = "";
        if (fileName.endsWith(".mdl")) {
            target = fileName.replace("mdl", "md3");
            //target = fileName.replace("mdl", "iqm");
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

    private void Run(String args) {
        String SETTINGS_PATH_NOESIS = this.app.settings.GetPath("noesis");

        try {
            //boolean SETTING_USE32BITNOESIS = (boolean) Settings.getInstance().Get("Use32bitNoesis");

            String exeNoesis = SETTINGS_PATH_NOESIS + "/Noesis64.exe";
            //if (SETTING_USE32BITNOESIS) {
            //    exeNoesis = "noesis/Noesis.exe";
            //}
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
