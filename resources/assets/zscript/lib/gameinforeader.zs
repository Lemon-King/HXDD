
/*
 *
 *  GameInfoReader
 *  Parses MapInfo lumps for skill and episode information
 *
 */

class GameInfoReader {
    Array<String> classes;
    Array<SkillInfo> skills;
    Array<EpisodeInfo> episodes;

    void Find() {
        for (int i = 0; i < Wads.GetNumLumps(); i++) {
            String name = Wads.GetLumpName(i);
            String fullname = Wads.GetLumpFullName(i);
            if (name.MakeLower().IndexOf("mapinfo") != -1 || fullname.MakeLower().IndexOf("mapinfo.") != -1) {
                String info = Wads.ReadLump(i);
                self.ParsePlayerClassList(info);
                self.ParseEpisodeInfo(info);
                self.ParseSkillInfo(info);
            }
        }
    }

    void ParsePlayerClassList(String info) {
        if (info.IndexOf("PlayerClasses") != -1) {
            Array<String> lines;
            info.split(lines, "\n");

            for (let i = 0; i < lines.Size(); i++) {
                String line = lines[i];
                if (line.IndexOf("PlayerClasses") != -1) {
                    line.Substitute('"', "");  // remove quotes
                    line.Substitute(" ", "");  // remove spaces

                    Array<String> split;
                    line.split(split, "=");

                    String lineClasses = split[split.Size() - 1];
                    lineClasses.split(classes, ",");
                    break;
                }
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

                    String strBlock = minfo.Mid(idxBraceOpen, idxBraceClose);

                    Array<String> lines;
                    strBlock.split(lines, "\n");
                    for (let i = 0; i < lines.Size(); i++) {
                        String line = lines[i];
                        if (line.MakeLower().IndexOf("playerclassname") != -1) {
                            line.Substitute('"', "");  // remove quotes
                            line.Substitute(" ", "");  // remove spaces

                            Array<String> split;
                            line.split(split, "=");

                            String details = split[split.Size() - 1];
                            
                            split.Clear();
                            details.split(split, ",");
                            skInfo.classes.push(split[0]);
                            skInfo.names.push(split[1]);
                        } else if (line.MakeLower().IndexOf("name") != -1) {
                            line.Substitute('"', "");  // remove quotes
                            line.Substitute(" ", "");  // remove spaces

                            Array<String> split;
                            line.split(split, "=");
                            skInfo.name = split[1];
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

                    String strBlock = minfo.Mid(idxBraceOpen, idxBraceClose);

                    Array<String> lines;
                    strBlock.split(lines, "\n");
                    for (int i = 0; i < lines.Size(); i++) {
                        String line = lines[i];

                        line.Substitute('"', "");  // remove quotes
                        line.Substitute(" ", "");  // remove spaces

                        Array<String> split;
                        line.split(split, "=");

                        if (line.IndexOf("name") != -1) {
                            epInfo.name = split[1];
                        } else if (line.IndexOf("header") != -1) {
                            epInfo.header = split[1];
                        } else if (line.IndexOf("description") != -1) {
                            epInfo.description = split[1];
                        } else if (line.IndexOf("gametype") != -1) {
                            epInfo.gametype = split[1];
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
    String header;
    String description;
    bool extended;
    bool development;
}