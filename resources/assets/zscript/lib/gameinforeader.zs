
/*
 *
 *  GameInfoReader
 *  Parses MapInfo lumps for skill and episode information
 *
 */



class GameInfoReader {
    Array<SkillInfo> skills;
    Array<EpisodeInfo> episodes;

    void Find() {
        for (int i = 0; i < Wads.GetNumLumps(); i++) {
            //Wads.CheckNumForName(i)
            String name = Wads.GetLumpName(i);
            String fullname = Wads.GetLumpFullName(i);
            if (name.MakeLower().IndexOf("mapinfo") != -1 || fullname.MakeLower().IndexOf("mapinfo.") != -1) {
                Console.printf("Lump %d %d: %s %s", i, Wads.GetLumpNamespace(i), name, fullname);
                String info = Wads.ReadLump(i);
                String skInfo = Wads.ReadLump(i);
                self.ParseEpisodeInfo(info);
                self.ParseSkillInfo(skInfo);
            }
        }
    }

    void ParseSkillInfo(String info) {
        int CLEARSKILLS_SIZE = "clearskills".Length();
        int SKILL_SIZE = "skill".Length();

        int pos = 0;
        String minfo = info;
        while (minfo.IndexOf("clearskills") != -1 || minfo.IndexOf("skill") != -1) {
            pos++;
            // valid
            if (minfo.IndexOf("clearskills") != -1) {
                int nextPos = info.IndexOf("clearskills");
                console.printf("clearskills");
                self.skills.Clear();

                minfo = minfo.Mid(nextPos + CLEARSKILLS_SIZE);
            } else if (minfo.IndexOf("skill") != -1) {
                int idxSkill = minfo.IndexOf("skill");
                minfo = minfo.Mid(idxSkill);
                int idxBraceOpen = minfo.IndexOf("{");
                int idxBraceClose = minfo.IndexOf("}");

                // Sanity check if the skill is defined incorrectly
                String skillName;
                if (idxSkill != -1 && idxBraceOpen != -1 && idxBraceClose != -1) {
                    SkillInfo skInfo = new("SkillInfo");

                    String between = minfo.Mid(idxBraceOpen, idxBraceClose);

                    //console.printf("info %s", between);

                    Array<String> split;
                    between.split(split, "\n");
                    for (int i = 0; i < split.Size(); i++) {
                        String line = split[i];

                        int idxQuoteOpen = line.IndexOf('"');
                        String value = line.Mid(idxQuoteOpen + 1);
                        int idxQuoteClosed = value.IndexOf('"');
                        value = value.Mid(0, idxQuoteClosed);

                        if (line.MakeLower().IndexOf("playerclassname") != -1) {
                            String className = value;

                            Array<String> splitLine;
                            line.split(splitLine, ",");
                            
                            String section = splitLine[splitLine.Size() - 1];
                            idxQuoteOpen = section.IndexOf('"');
                            String classSkill = section.Mid(idxQuoteOpen + 1);
                            idxQuoteClosed = classSkill.IndexOf('"');
                            classSkill = classSkill.Mid(0, idxQuoteClosed);
                            console.printf("classSkill %s", classSkill);

                            skInfo.classes.push(className);
                            skInfo.names.push(classSkill);
                            console.printf("class %s, skill %s", className, classSkill);
                        } else if (line.MakeLower().IndexOf("name") != -1) {
                            skInfo.name = value;
                            console.printf("skill %s", value);
                        }
                        
                    }

                    self.skills.Push(skInfo);

                    minfo = minfo.Mid(idxBraceClose + 1);
                }
            }
        }
    }

    void ParseEpisodeInfo(String info) {
        int CLEAREPISODES_SIZE = "clearepisodes".Length();
        int EPISODE_SIZE = "episode".Length();

        int pos = 0;
        String minfo = info;
        while (minfo.IndexOf("clearepisodes") != -1 || minfo.IndexOf("episode") != -1) {
            pos++;
            // valid
            if (minfo.IndexOf("clearepisodes") != -1) {
                int nextPos = info.IndexOf("clearepisodes");
                console.printf("clearepisodes");
                self.episodes.Clear();

                minfo = minfo.Mid(nextPos + CLEAREPISODES_SIZE);
            } else if (minfo.IndexOf("episode") != -1) {
                int idxEpisode = minfo.IndexOf("episode");
                minfo = minfo.Mid(idxEpisode);
                int idxBraceOpen = minfo.IndexOf("{");
                int idxBraceClose = minfo.IndexOf("}");

                // Sanity check if the episode is defined incorrectly
                String episodeName;
                if (idxEpisode != -1 && idxBraceOpen != -1 && idxBraceClose != -1) {
                    EpisodeInfo epInfo = new("EpisodeInfo");

                    String between = minfo.Mid(idxBraceOpen, idxBraceClose);

                    Array<String> split;
                    between.split(split, "\n");
                    for (int i = 0; i < split.Size(); i++) {
                        String line = split[i];

                        int idxQuoteOpen = line.IndexOf('"');
                        String value = line.Mid(idxQuoteOpen + 1);
                        int idxQuoteClosed = value.IndexOf('"');

                        value = value.Mid(0, idxQuoteClosed);
                        if (line.IndexOf("name") != -1) {
                            epInfo.name = value;
                        } else if (line.IndexOf("description") != -1) {
                            epInfo.description = value;
                        } else if (line.IndexOf("gametype") != -1) {
                            epInfo.gametype = value;
                        } else if (line.IndexOf("development")) {
                            epInfo.development = true;
                        }
                    }

                    self.episodes.Push(epInfo);

                    minfo = minfo.Mid(idxBraceClose + 1);
                }
            }
        }
    }
}

class SkillInfo {
    String name;    // default
    Array<String> classes;  // keys for list
    Array<String> names;

    String Get(String playerClass) {
        let p = (class<PlayerPawn>)(playerClass);
        String v;
        if (p != null) {
            v = PlayerPawn.GetPrintableDisplayName(playerClass);
            v = v.MakeLower();
        }
        int idx = self.classes.Find(v);
        if (idx == self.classes.Size()) {
            return name;
        } else {
            return self.names[idx];
        }
    }
}

class EpisodeInfo {
    String name;
    String gametype;
    String description;
    bool extended;
    bool development;
}