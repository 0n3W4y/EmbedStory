package;

import TileMap.TileMapID;
import Tile.TileID;
import EntityHealthPointsSystem.EntityHealthPointsSystemConfig;
import EntityAgeSystem.EntityAgeSystemConfig;
import EntityNameSystem.EntityNameSystemConfig;
import EntitySystem.EntityDeployID;


typedef EntityConfig = {
    var EntityType:String;
    var EntitySubType:String;
    var EntityID:EntityID;
    var DeployID:EntityDeployID;
    var AgeSystemConfig:EntityAgeSystemConfig;
    var NameSystemConfig:EntityNameSystemConfig;
    var HPSystemConfig:EntityHealthPointsSystemConfig;
}

enum EntityID{
    EntityID( _:Int );
}


class Entity{

    public var entityType:String;
    public var entitySubType:String;
    public var tileID:TileID;
    public var tileMapID:TileMapID;
    public var entityDeployID:EntityDeployID;

    public var canUse:Bool;
    public var canDestroy:Bool;

    public var gridX:Int;
    public var gridY:Int;
    public var graphicIndex:Int;

    public var age:EntityAgeSystem;
    public var name:EntityNameSystem;
    public var healthPoints:EntityHealthPointsSystem;
    

    private var _ID:EntityID;
    private var _inited:Bool;
    private var _postInited:Bool;

    public function new( config:EntityConfig ):Void{
        this._inited = false;
        this._postInited = false;
        this.entityType = config.EntityType;
        this.entitySubType = config.EntitySubType;
        this._ID = config.EntityID;
        this.entityDeployID = config.DeployID;
        //this.canUse = false;
        //this.canDestroy = false;
    }

    public function init():Void{
        var msg:String = this.errMsg();

        if( this._inited )
            throw '$msg already inited';

        if( this.age != null )
            this.age.init();

        if( this.name != null )
            this.name.init();

        if( this.healthPoints != null )
            this.healthPoints.init();

        this._inited = true;

    }

    public function postInit():Void{
        var msg:String = this.errMsg();
        this._postInited = true;
    }

    public function update( time:Int ):Void{
        if( age != null )
            age.update( time );
    }

    public function getId():EntityID{
        return this._ID;
    }

    public function errMsg():String{
        var entityType:String = this.entityType;
        var entitySubType:String = this.entitySubType;
        var entityDeployId:EntityDeployID = this.entityDeployID;
        var entityID:EntityID = this._ID;
        return 'Error in EntityHealthPointSystem. "$entityType", "$entitySubType", "$entityID", "$entityDeployId".';
    }
}