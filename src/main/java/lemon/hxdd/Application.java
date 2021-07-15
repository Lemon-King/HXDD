package lemon.hxdd;

// You could modify this and merge all DOOM Engine games into one giant package.

public class Application {
    public static void main(String[] args) {
        System.out.println("HXDD: A Heretic, Hexen, and DeathKings WAD Merger");
        System.out.println("Written by Lemon King\n");
        System.out.println("DoomStruct by MTrop: https://github.com/MTrop/DoomStruct");
        System.out.println("zt-zip by ZeroTurnaround: https://github.com/zeroturnaround/zt-zip\n");
        System.out.println("Updates and source are available at: https://github.com/Lemon-King/HXDD\n");

        Settings.getInstance().Initialize();

        PK3Builder ipk3 = new PK3Builder();
        ipk3.Assemble();
    }
}