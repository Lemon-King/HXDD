module lemon.hxdd.hxdd {
    requires javafx.controls;
    requires javafx.fxml;
            
    requires org.controlsfx.controls;
    requires com.dlsc.formsfx;
    requires java.desktop;
    requires zt.zip;
    requires org.json;

    opens lemon.hxdd to javafx.fxml;
    exports lemon.hxdd;
    exports lemon.hxdd.builder;
    opens lemon.hxdd.builder to javafx.fxml;
    exports lemon.hxdd.gui;
    opens lemon.hxdd.gui to javafx.fxml;
    exports lemon.hxdd.shared;
    opens lemon.hxdd.shared to javafx.fxml;
}