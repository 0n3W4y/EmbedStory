package;

import Scene.SceneDeployID;
import Tile.FloorTypeDeployID;
import Tile.GroundTypeDeployID;
import TileMap.BiomeDeployID;
import EntitySystem.EntityDeployID;



typedef DeployConfig = {
    var FloorTypeConfig:Dynamic;
    var BiomeConfig:Dynamic;
    var GroundTypeConfig:Dynamic;
    var SceneConfig:Dynamic;
    var EntityConfig:Dynamic;
}

class Deploy{

    public var floorTypeConfig:Map<FloorTypeDeployID, Dynamic>;
    public var groundTypeConfig:Map<GroundTypeDeployID, Dynamic>;
    public var biomeConfig:Map<BiomeDeployID, Dynamic>;
    public var sceneConfig:Map<SceneDeployID, Dynamic>;
    public var entityConfig:Map<EntityDeployID, Dynamic>;

    private var _parent:Game;

    public function new( parent:Game, params:DeployConfig ):Void{
        this._parent = parent;

        this.floorTypeConfig = new Map<FloorTypeDeployID, Dynamic>();
		for( key in Reflect.fields( params.FloorTypeConfig )){
			var intKey:Int = Std.parseInt( key );
			this.floorTypeConfig[ FloorTypeDeployID( intKey )] = Reflect.getProperty( params.FloorTypeConfig, key );
		}

        this.groundTypeConfig = new Map<GroundTypeDeployID, Dynamic>();
        for( key in Reflect.fields( params.GroundTypeConfig )){
            var intKey:Int = Std.parseInt( key );
            this.groundTypeConfig[ GroundTypeDeployID( intKey )] = Reflect.getProperty( params.GroundTypeConfig, key );
        }

        this.biomeConfig = new Map<BiomeDeployID, Dynamic>();
        for( key in Reflect.fields( params.BiomeConfig )){
            var intKey:Int = Std.parseInt( key );
            this.biomeConfig[ BiomeDeployID( intKey )] = Reflect.getProperty( params.BiomeConfig, key );
        }

        this.sceneConfig = new Map<SceneDeployID, Dynamic>();
        for( key in Reflect.fields( params.SceneConfig )){
            var intKey:Int = Std.parseInt( key );
            this.sceneConfig[ SceneDeployID( intKey )] = Reflect.getProperty( params.SceneConfig, key );
        }

        this.entityConfig = new Map<EntityDeployID, Dynamic>();
        for( key in Reflect.fields( params.EntityConfig )){
            var intKey:Int = Std.parseInt( key );
            this.entityConfig[ EntityDeployID( intKey )] = Reflect.getProperty( params.EntityConfig, key );
        }
    }

    public function getParent():Game{
        return this._parent;
    }

    public function getFloorTypeDeployID( name:String ):FloorTypeDeployID{
        for( key in this.floorTypeConfig.keys() ){
            var value:Map<String, Dynamic> = this.floorTypeConfig[ key ];
            var floorTypeName:String = Reflect.getProperty( value, "name" );
            if( name == floorTypeName )
                return key;
        }

        throw 'Error in Deploy.getFloorTypeDeployID. No ID for floor type with name: $name .';
        return null;
    }

    public function getGroundTypeDeployID( name:String ):GroundTypeDeployID{
        for( key in this.groundTypeConfig.keys() ){
            var value:Map<String, Dynamic> = this.groundTypeConfig[ key ];
            var groundTypeName:String = Reflect.getProperty( value, "name" );
            if( name == groundTypeName )
                return key;
        }

        throw 'Error in Deploy.getGroundTypeDeployID. No ID for ground type with name: $name .';
        return null;
    }

    public function getSceneDeployID( sceneType:String ):SceneDeployID{
        for( key in this.sceneConfig.keys() ){
            var value:Dynamic = this.sceneConfig[ key ];
            var sceneTypeInConfig:String = Reflect.getProperty( value, "sceneType" );
            if( sceneType == sceneTypeInConfig )
                return key;
        }

        throw 'Error in Deploy.getSceneDeployID. No ID for scene type: $sceneType ';
        return null;
    }

    public function getBiomeDeployID( biomeType:String ):BiomeDeployID{
        for( key in this.biomeConfig.keys() ){
            var value:Dynamic = this.biomeConfig[ key ];
            var biomeTypeInConfig:String = Reflect.getProperty( value, "biomeType" );
            if( biomeType == biomeTypeInConfig )
                return key;
        }

        throw 'Error in Deploy.getBiomeDeployID. No ID for biome type: $biomeType ';
        return null;
    }

    public function getEntityDeployID( type:String, subType:String ):EntityDeployID{
        for( key in this.entityConfig.keys() ){
            var value:Dynamic = this.entityConfig[ key ];
            var entityType:String = Reflect.getProperty( value, "type" );
            var entitySubType:String = Reflect.getProperty( value, "subType" );
            if( type == entityType && subType == entitySubType )
                return key;
        }

        throw 'Error in Deploy.getEntityDeployID. No ID for Entity with type: $type and subtype: $subType.';
        return null;
    }
}