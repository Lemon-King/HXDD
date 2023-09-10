package lemon.hxdd.builder;

import javafx.util.Pair;
import lemon.hxdd.Application;

import java.io.File;
import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.nio.file.*;
import java.util.*;

// REF: https://stackoverflow.com/a/28057735
public class ResourceWalker {
    public ArrayList<Pair<String, File>> files;

    String root;

    public ResourceWalker(String path) throws URISyntaxException, IOException {
        this.files = new ArrayList<Pair<String, File>>();

        URL urlPath = Application.class.getResource(path);
        URI uri = urlPath.toURI();
        Path targetPath;
        if (uri.getScheme().equals("jar")) {
            FileSystem fileSystem = FileSystems.newFileSystem(uri, Collections.<String, Object>emptyMap());
            targetPath = fileSystem.getPath(path);
            fileSystem.close();
        } else {
            targetPath = Paths.get(uri);
        }

        this.root = urlPath.getPath().substring(1).replace("\\", "/");
        this.ScanDirectory(targetPath);
    }

    private void ScanDirectory(Path nextPath) throws IOException {
        DirectoryStream<Path> directoryStream = Files.newDirectoryStream(nextPath);
        for (Path p: directoryStream) {
            File n = new File(p.toUri());
            String key = n.getPath().replace("\\", "/").replace(this.root, "");
            this.files.add(new Pair(key, n));
            if (n.isDirectory()) {
                this.ScanDirectory(n.toPath());
            }
        }
    }
}