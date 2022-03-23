package;

import EntitySystem.EntityDeployID;


enum EntityID{
    EntityID( _:Int );
}


class Entity{

    public var entityName:String;
    public var entityType:String;
    public var entitySubType:String;
    public var tileID:Int;
    public var tileMapID:Int;
    public var entityDeployID:EntityDeployID;

    public var age:EntityAgeSystem;
    //public var name:EntityNameSystem;
    public var HealthPoints:EntityHealthPointsSystem;
    

    private var _ID:EntityID;

    public function new():Void{
        
    }

    public function update( time:Int ):Void{
        if( age != null )
            age.update( time );
    }

    public function getId():EntityID{
        return this._ID;
    }

    public function errMsg():String{
        var entityName:String = this.entityName;
        var entityType:String = this.entityType;
        var entitySubType:String = this.entitySubType;
        var entityDeployId:EntityDeployID = this.entityDeployID;
        var entityID:EntityID = this._ID;
        return 'Error in EntityHealthPointSystem. "$entityName", "$entityType", "$entitySubType", "$entityID", "$entityDeployId".';
    }
}