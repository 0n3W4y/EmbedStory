package;

typedef EntitySystemConfig = {
    
}

class InventorySystem{

    private var _parent:Entity;

    public function new( parent:Entity, params:EntitySystemConfig ):Void{
        this._parent = parent;
    }
}