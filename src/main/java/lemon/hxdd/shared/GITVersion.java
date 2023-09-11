package lemon.hxdd.shared;

import java.io.*;
import java.util.Properties;

public class GITVersion {
    private static GITVersion _instance = new GITVersion();

    private static Properties p_gitversion;

    private GITVersion() {}

    public static GITVersion getInstance( ) {
        return _instance;
    }

    public void Initialize() {
        p_gitversion = new Properties();

        String fileName = "git.properties";

        try {
            InputStream is = ClassLoader.getSystemResourceAsStream(fileName);
            p_gitversion.load(is);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public Properties GetProperties() {
        return p_gitversion;
    }
}
