package lemon.hxdd;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Properties;

public class Settings {
    private static Settings _instance = new Settings();

    private static Properties p_config;

    private Settings() {}

    public static Settings getInstance( ) {
        return _instance;
    }

    public void Initialize() {
        p_config = new Properties();
        this.SetDefaults();

        String fileName = "hxdd.settings";
        try (FileInputStream fis = new FileInputStream(fileName)) {
            p_config.load(fis);
            System.out.println("Settings: hxdd.settings loaded");
        } catch (FileNotFoundException ex) {
            // FileNotFoundException catch is optional and can be collapsed
            System.out.println("Settings: hxdd.settings not found, skipping");
        } catch (IOException ex) {
            System.out.println("Settings: hxdd.settings exception, did you break it?");
            ex.printStackTrace();
        }
    }

    private void SetDefaults() {
        // General Settings
        p_config.put("PathSourceWads", "./wads/");
        p_config.put("PathTemporary", "./temp/");

        p_config.put("MenuTheme", "heretic");
        //p_config.put("StartupMusic", "hexen");
        //p_config.put("Font", "heretic");

        p_config.put("AudioResample", false);
        p_config.put("AudioResampleRate", "44khz");
        p_config.put("AudioResampleInterpolation", "linear");

        // Per Wad Settings
        p_config.put("MapNameHeader_heretic", "");
        p_config.put("MapNameHeader_hexen", "");
        p_config.put("MapNameHeader_hexdd", "DD_");


        System.out.println("Settings: defaults loaded");
    }

    public Object Get(String key) {
        return p_config.get(key);
    }
}
