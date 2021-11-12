package;


enum EntityID{
    EntityID( _:Int );
}


class Entity{

    public var entityName:String;
    public var entityType:String;
    public var entitySubType:String;
    public var tileID:Int;
    public var tileMapID:Int;

    public var age:AgeSystem;
    public var name:NameSystem;   
    

    private var _ID:EntityID;

    public function new():Void{
        
    }

    public function update( time:Int ):Void{
        
    }

    public function getId():EntityID{
        return this._ID;
    }
}