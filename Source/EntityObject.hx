package;

enum EntityObjectDeployID{
    EntityObjectDeployID( _:Int );
}

class EntityObject extends Entity{

    private var _deployID:EntityObjectDeployID;

    public function new():Void{
        super();
    }

    public function getDeployID():EntityObjectDeployID{
        return this._deployID;
    }
}