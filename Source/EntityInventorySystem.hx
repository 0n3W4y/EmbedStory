package;

typedef EntityInventorySystemConfig = {
    
}

class EntityInventorySystem{

    private var _parent:Entity;

    public function new( parent:Entity, params:EntityInventorySystemConfig ):Void{
        this._parent = parent;
    }
}