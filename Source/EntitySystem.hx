package;

enum EntityDeployID{
    EntityDeployID( _:Int );
}

class EntitySystem{

    private var _parent:Game;

    public function new( parent:Game ):Void{
        this._parent = parent;
    }

    public function createEntity( name:String ):Entity{
        return null;
    }
}