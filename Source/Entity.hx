package;

import EntityStatsSystem.EntityStatsSystemConfig;
import EntityAISystem.EntityAISystemConfig;
import Scene.SceneID;
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
    var AISystemConfig:EntityAISystemConfig;
    var StatsSystemConfig:EntityStatsSystemConfig;
}

enum EntityID{
    EntityID( _:Int );
}


class Entity{

    public var entityType:String;
    public var entitySubType:String;
    public var tileIndex:Int;
    public var sceneID:SceneID;
    public var entityDeployID:EntityDeployID;

    public var canUse:Bool;
    public var canDestroy:Bool;

    public var gridX:Int;
    public var gridY:Int;
    public var graphicIndex:Int;

    public var age:EntityAgeSystem;
    public var name:EntityNameSystem;
    public var healthPoints:EntityHealthPointsSystem;
    public var stats:EntityStatsSystem;
    public var aI:EntityAISystem;
    

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

        if( config.AgeSystemConfig != null )
            this.age = new EntityAgeSystem( this, config.AgeSystemConfig );

        if( config.HPSystemConfig != null )
            this.healthPoints = new EntityHealthPointsSystem( this, config.HPSystemConfig );

        if( config.NameSystemConfig != null )
            this.name = new EntityNameSystem( this, config.NameSystemConfig );

        if( config.AISystemConfig != null )
            this.aI = new EntityAISystem( this, config.AISystemConfig );

        if( config.StatsSystemConfig != null )
            this.stats = new EntityStatsSystem( this, config.StatsSystemConfig );
        
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

        if( this.aI != null )
            this.aI.init();

        if( this.stats != null )
            this.stats.init();

        this._inited = true;

    }

    public function postInit():Void{
        var msg:String = this.errMsg();
        this._postInited = true;
    }

    public function update( time:Int ):Void{
        if( this.age != null ){
            this.age.update( time );
        }
    }

    public function getID():EntityID{
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