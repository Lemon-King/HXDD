package lemon.hxdd;

import org.zeroturnaround.zip.ZipEntryCallback;
import org.zeroturnaround.zip.ZipUtil;

import java.io.*;
import java.net.URISyntaxException;
import java.util.Objects;
import java.util.Properties;
import java.util.zip.ZipEntry;

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
            String protocol = Objects.requireNonNull(this.getClass().getResource("")).getProtocol();
            if (protocol.equals("jar")) {
                File jarHXDD = new File(lemon.hxdd.Application.class.getProtectionDomain().getCodeSource().getLocation().toURI());
                ZipUtil.iterate(jarHXDD, new ZipEntryCallback() {
                    public void process(InputStream in, ZipEntry zipEntry) throws IOException {
                        if (!zipEntry.isDirectory() && zipEntry.getName().contains(fileName)) {
                            p_gitversion.load(in);
                        }
                    }
                });
            } else if (protocol.equals("file")) {
                FileInputStream fis = new FileInputStream("target/classes/" + fileName);
                p_gitversion.load(fis);
            }
        } catch (IOException | URISyntaxException e) {
            e.printStackTrace();
        }
    }

    public Properties GetProperties() {
        return p_gitversion;
    }
}
