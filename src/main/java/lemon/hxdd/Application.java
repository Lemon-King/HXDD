package lemon.hxdd;

// You could modify this and merge all DOOM Engine games into one giant package.

// Hexen II requires Noesis v4.464 or higher.

// TODO: Add Post Extraction PNG Processing to fix transparencies
// TODO: https://stackoverflow.com/questions/665406/how-to-make-a-color-transparent-in-a-bufferedimage-and-save-as-png

public class Application {
    public static void main(String[] args) {
        GITVersion.getInstance().Initialize();
        String version = GITVersion.getInstance().GetProperties().getProperty("git.closest.tag.name");
        if (version.equals("")) {
            version = GITVersion.getInstance().GetProperties().getProperty("git.build.version");
        }
        String BuildDate = GITVersion.getInstance().GetProperties().getProperty("git.build.time");
        System.out.println("HXDD: A Heretic, Hexen, and DeathKings WAD Merger");
        System.out.println("v" + version + " " + BuildDate);
        System.out.println("By Lemon King\n");
        System.out.println("DoomStruct by MTrop: https://github.com/MTrop/DoomStruct");
        System.out.println("zt-zip by ZeroTurnaround: https://github.com/zeroturnaround/zt-zip");
        Settings.getInstance().Initialize();
        if (Noesis.CheckAndInstall()) {
            System.out.println("Noesis by Rich Whitehouse: https://richwhitehouse.com\n");                  // only show if noesis files exist
        }
        System.out.println("Updates and source are available at: https://github.com/Lemon-King/HXDD\n");

        PK3Builder ipk3 = new PK3Builder();
        ipk3.Assemble();
    }
}