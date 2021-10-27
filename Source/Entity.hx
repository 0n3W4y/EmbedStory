package;


enum EntityID{
    EntityID( _:Int );
}


class Entity{

    public var entityType:String;
    public var tileID:Int;
    public var tileMapID:Int;
    

    private var _ID:EntityID;

    public function new():Void{
        
    }

    public function update( time:Float ):Void{

    }

    public function getId():EntityID{
        return this._ID;
    }
}