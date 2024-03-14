package lemon.hxdd.builder;

import lemon.hxdd.Application;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

import java.io.*;
import java.util.*;

// Automate creation of Game Unique MapInfo DoomEdNums and SpawnNums.
public class GameActorNums {
    Application app;
    String pathTemp;

    private static final List<String> TypeOrder = Arrays.asList("doomednums", "spawnnums");
    private static final List<String> GameOrder = Arrays.asList("heretic", "hexen", "doom");

    GameActorNums(Application app) {
        this.app = app;
        this.pathTemp = this.app.settings.GetPath("temp");
    }

    public void Create() {
        // Merge DoomEdNums and SpawnNums

        ZipAssets za = new ZipAssets(this.app);
        za.SetFile(this.app.settings.fileResources);
        ArrayList<String> listGameInfo = za.GetFolderContents("gameinfo/");

        TypeOrder.forEach((type) -> {
            List<Properties> lists = new ArrayList<>(Collections.emptyList());
            GameOrder.forEach((game) -> {
                // System.out.println("Creating " + game + "." + type + " actors");
                // Properties matches GZDOOM's format and does the job.
                Properties p = new Properties();
                //String filePath = "gameinfo/" + type + "." + game;
                for (int i = 0; i < listGameInfo.size(); i++) {
                    String name = listGameInfo.get(i).toLowerCase().replace("gameinfo/", "");
                    if (name.startsWith(type) && name.endsWith(game)) {
                        try {
                            String data = za.ReadFileAsString(listGameInfo.get(i));
                            p.load(new StringReader(data));
                        } catch (IOException e) {
                            System.out.println("Error: " + e);
                        }
                    }
                }

                lists.add(p);
            });

            // Merge Hexen keys with Heretic Keys, if missing add.
            Properties p_hxdd = new Properties();
            Properties p_heretic = lists.get(0);
            Properties p_hexen = lists.get(1);
            Properties p_doom = lists.get(2);
            SortedSet<String> actorKeys = new TreeSet<>();
            for (int i = 0; i < lists.size(); i++) {
                lists.get(i).forEach((k,v) -> {
                    if (!actorKeys.equals(k)) {
                        actorKeys.add((String) k);
                    }
                });
            }

            JsonArray actorsJSON = new JsonArray();
            actorKeys.forEach((key) -> {
                JsonObject lutActors = new JsonObject();
                String valueHeretic = (String) p_heretic.get(key);
                String valueHexen = (String) p_hexen.get(key);
                String valueDoom = (String) p_doom.get(key);      // pwad mode, NYI
                if (valueDoom != null) {
                    lutActors.addProperty("Doom", valueDoom);
                }
                if (valueHeretic != null) {
                    lutActors.addProperty("Heretic", valueHeretic);
                }
                if (valueHexen != null) {
                    lutActors.addProperty("Hexen", valueHexen);
                }
                if (!lutActors.isEmpty()) {
                    actorsJSON.add(lutActors);
                }

                String newValue = valueHexen;
                if (newValue == null) {
                    newValue = valueHeretic;
                }
                if (newValue == null) {
                    newValue = valueDoom;
                }
                if (newValue != null) {
                    p_hxdd.put(key, newValue);
                }
            });
            CreateXGT(actorsJSON, type);

            try {
                File pathTarget = new File(this.pathTemp + "/gameinfo/");
                if (!pathTarget.exists()) {
                    pathTarget.mkdirs();
                }

                Map<String, String> actorMap = (Map)p_hxdd;
                SortedSet<String> keys = new TreeSet<>(actorMap.keySet());

                String mapInfoFileName = type + ".mapinfo";
                PrintWriter file_mapinfo = new PrintWriter(this.pathTemp + "/gameinfo/" + mapInfoFileName);

                AddGeneratedByTag(file_mapinfo);
                if (Objects.equals(type, "doomednums")) {
                    file_mapinfo.print("\nDoomEdNums\n");
                } else if (Objects.equals(type, "spawnnums")) {
                    file_mapinfo.print("\nSpawnNums\n");
                }
                file_mapinfo.print("{\n");
                for (String key : keys) {
                    String value = actorMap.get(key);
                    file_mapinfo.print(key + " = " + value + "\n");
                }
                file_mapinfo.print("}\n");
                file_mapinfo.close();

            } catch (FileNotFoundException ex) {
                // FileNotFoundException catch is optional and can be collapsed
                System.out.println("GameActorNums: gameinfo files not found, skipping");
            }
        });
    }

    private void CreateXGT(JsonArray list, String type) {
        String path = this.pathTemp + "/xgt";
        File dirFile = new File(path);
        if (!dirFile.exists()) {
            dirFile.mkdirs();
        }

        try {
            PrintWriter out = new PrintWriter(path + "/" + type + ".xgt");
            out.print(list);
            out.close();
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
    }

    private void AddGeneratedByTag(PrintWriter writer) {
        writer.print("\n//\n// Generated by HXDD\n//\n\n");
    }
}
