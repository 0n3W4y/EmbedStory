package;

enum EntityDeployID{
    EntityDeployID( _:Int );
}

class EntitySystem{

    private var _parent:Game;
    private var _deploy:Deploy;

    public function new( parent:Game ):Void{
        this._parent = parent;
        this._deploy = parent.deploy;
    }

    public function createEntity( type:String, subType:String ):Entity{
        return null;
    }

    public function createEntityDyID( id:EntityDeployID ):Entity{
        var config:Dynamic = this._deploy.entityConfig[ id ];
        return null;
    }

}