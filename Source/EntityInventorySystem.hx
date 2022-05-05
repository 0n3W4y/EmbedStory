package;

typedef EntityInventorySystemConfig = {
    
}

class EntityInventorySystem{

    private var _parent:Entity;

    public function new( parent:Entity, params:EntityInventorySystemConfig ):Void{
        this._parent = parent;
    }

    public function init():Void{

    }

    public function postInit():Void{

    }

    public function getFullStat( stat:String ):Int{
        return 0;
    }
}