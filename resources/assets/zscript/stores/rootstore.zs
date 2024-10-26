
class HXDDRootStore : LemonTreeBranch {
    override void OnCreate() {
        console.printf("HXDDRootStore: OnCreate");
    }

    override void OnMapEnter() {
        console.printf("HXDDRootStore: Map Enter");
    }

    override void OnMapLeave() {
        console.printf("HXDDRootStore: Map Leave");
    }
}