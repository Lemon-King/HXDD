package lemon.hxdd;

// You could modify this and merge all DOOM Engine games into one giant package.

// Hexen II requires Noesis v4.464 or higher.

// TODO: Add Post Extraction PNG Processing to fix transparencies
// TODO: https://stackoverflow.com/questions/665406/how-to-make-a-color-transparent-in-a-bufferedimage-and-save-as-png

public class Application {
    public static void main(String[] args) {
        Settings.getInstance().Initialize();

        String version = Application.class.getPackage().getImplementationVersion();
        if (version.equals(null)) {
            version = "0.0-Development";
        }
        System.out.println("HXDD v" + version);
        System.out.println("A Heretic, Hexen, and DeathKings WAD Merger");
        System.out.println("Written by Lemon King\n");
        System.out.println("DoomStruct by MTrop: https://github.com/MTrop/DoomStruct");
        System.out.println("zt-zip by ZeroTurnaround: https://github.com/zeroturnaround/zt-zip");
        if (Noesis.CheckAndInstall()) {
            System.out.println("Noesis by Rich Whitehouse: https://richwhitehouse.com\n");                  // only show if noesis files exist
        }
        System.out.println("Updates and source are available at: https://github.com/Lemon-King/HXDD\n");

        PK3Builder ipk3 = new PK3Builder();
        ipk3.Assemble();

        //final String[] a = {};
        //NoesisManager nm = new NoesisManager("", a);

        //PAKData.ExportAssets();

        //n.RunCommand();
        //SoundInfo s = new SoundInfo();
        //s.Write();

        //XMLModelDef xmd = new XMLModelDef();
        //xmd.Export();
    }
}