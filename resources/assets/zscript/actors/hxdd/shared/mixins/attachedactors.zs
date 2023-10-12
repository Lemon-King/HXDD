mixin class AttachedActors {
    Array<Actor> attActors;

    void AttachedActorsAdd(Actor newActor) {
        newActor.target = self;
        attActors.push(newActor);
    }

    void AttachedActorsRemoveAll() {
        for (let i = 0; i < attActors.Size(); i++) {
            attActors[i].Destroy();
        }
        attActors.Clear();
    }
}