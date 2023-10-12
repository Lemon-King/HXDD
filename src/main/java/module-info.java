module lemon.hxdd {
    requires java.desktop;

    requires javafx.controls;
    requires javafx.fxml;
    requires javafx.graphics;
    requires javafx.base;

    requires com.google.gson;

    opens lemon.hxdd to javafx.fxml;
    exports lemon.hxdd;
    exports lemon.hxdd.builder;
    opens lemon.hxdd.builder to javafx.fxml;
    exports lemon.hxdd.gui;
    opens lemon.hxdd.gui to javafx.fxml;
    exports lemon.hxdd.shared;
    opens lemon.hxdd.shared to javafx.fxml;
}