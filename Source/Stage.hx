package;

class Stage{

    private var _parent:Game;

    public function new( parent:Game ):Void {
        this._parent = parent;
    }

    public function hourUp():Void{
        //TODO: update all entities on sceneSystem;
    }
}