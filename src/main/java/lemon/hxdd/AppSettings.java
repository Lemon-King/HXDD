package lemon.hxdd;

import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Path;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

public class AppSettings {
    static String pathSettings = "./hxdd.settings";
    static String pathResources = "./resources.zip";

    public File fileResources;
    Properties prop;
    HashMap<String, String> prop_defaults = new HashMap<String, String>();
    public Map<String, String> paths = new HashMap<>();

    public AppSettings() {
        fileResources = new File(pathResources);

        Path dir = Path.of("").toAbsolutePath();
        this.paths.put("root", dir.toString());
        this.paths.put("cache", dir + "/cache");
        this.paths.put("temp", dir + "/temp");
        this.paths.put("hexen2", dir + "/hexen2_data");
        this.paths.put("noesis", dir + "/noesis");
        this.paths.put("hexen2music", dir + "/hexen2music");

        prop_defaults.put("PATH_GZDOOM", "./");
        prop_defaults.put("PATH_HERETIC", "./");
        prop_defaults.put("PATH_HEXEN", "./");
        prop_defaults.put("PATH_HEXDD", "./");
        prop_defaults.put("PATH_HEXENII_PAK0", "./");
        prop_defaults.put("PATH_HEXENII_PAK1", "./");
        prop_defaults.put("PATH_HEXENII_PAK2", "./");
        prop_defaults.put("PATH_HEXENII_PAK3", "./");
        prop_defaults.put("PATH_HEXENII_PAK4", "./");

        prop_defaults.put("USE_DEVELOPMENT_RESOURCES", "false");

        prop_defaults.put("OPTION_TITLE_ARTWORK", "heretic");
        prop_defaults.put("OPTION_TITLE_MUSIC", "heretic");
        prop_defaults.put("OPTION_USE_STEAM_ARTWORK", "false");
        prop_defaults.put("OPTION_KORAX_LOCALIZATION", "en");
        prop_defaults.put("OPTION_ENABLE_H2", "false");
        prop_defaults.put("OPTION_ENABLE_HX2", "false");
        prop_defaults.put("OPTION_USE_HX2_TITLE_MUSIC", "");

        this.prop = new Properties();
        try {
            FileReader reader = new FileReader(pathSettings);
            this.prop.load(reader);
            reader.close();
        } catch (IOException e) {
            System.out.println("AppSettings file not found!");
        }
    }

    public String Get(String key) {
        return this.prop.getProperty(key, prop_defaults.get(key));
    }

    public void Set(String key, String value) {
        this.prop.setProperty(key, value);
        this.Save();
    }

    public String GetPath(String key) {
        return this.paths.get(key);
    }

    private void Save() {
        try {
            FileWriter writer = new FileWriter(pathSettings);
            this.prop.store(writer, "HXDD User Settings");
            writer.close();
        } catch (IOException e) {
        }
    }
}
