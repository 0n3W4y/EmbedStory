package;

import Scene.SceneDeployID;
import Tile.FloorTypeDeployID;
import Tile.GroundTypeDeployID;
import TileMap.BiomeDeployID;


typedef DeployConfig = {
    var FloorTypeConfig:Dynamic;
    var BiomeConfig:Dynamic;
    var GroundTypeConfig:Dynamic;
    var SceneConfig:Dynamic;
}

class Deploy{

    public var floorTypeConfig:Map<FloorTypeDeployID, Dynamic>;
    public var groundTypeConfig:Map<GroundTypeDeployID, Dynamic>;
    public var biomeConfig:Map<BiomeDeployID, Dynamic>;
    public var sceneConfig:Map<SceneDeployID, Dynamic>;

    private var _parent:Game;

    public function new( parent:Game, params:DeployConfig ):Void{
        this._parent = parent;
        //this.floorTypeConfig = params.FloorTypeConfig;
        //this.groundTypeConfig = params.GroundTypeConfig;
        //this.biomeConfig = params.BiomeConfig;

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
    }

    public function getParent():Game{
        return this._parent;
    }

    public function getFloorTypeDeployID( name:String ):FloorTypeDeployID{
        for( key in this.floorTypeConfig.keys() ){
            var value:Map<String, Dynamic> = this.floorTypeConfig[ key ];
            var floorTypeName:String = value[ "name" ];
            if( name == floorTypeName )
                return key;
        }

        throw 'Error in Deploy.getFloorTypeDeployID. No ID for floor type with name: $name .';
        return null;
    }

    public function getGroundTypeDeployID( name:String ):GroundTypeDeployID{
        for( key in this.groundTypeConfig.keys() ){
            var value:Map<String, Dynamic> = this.groundTypeConfig[ key ];
            var groundTypeName:String = value[ "name" ];
            if( name == groundTypeName )
                return key;
        }

        throw 'Error in Deploy.getGroundTypeDeployID. No ID for ground type with name: $name .';
        return null;
    }

    public function getSceneDeployID( sceneType:String ):SceneDeployID{
        for( key in this.sceneConfig.keys() ){
            var value:Map<String, Dynamic> = this.sceneConfig[ key ];
            var sceneTypeInConfig:String = value[ "sceneType "];
            if( sceneType == sceneTypeInConfig )
                return key;
        }

        throw 'Error in Deploy.getSceneDeployID. No ID for scene type: $sceneType ';
        return null;
    }

    public function getBiomeDeployID( biomeType:String ):BiomeDeployID{
        for( key in this.biomeConfig.keys() ){
            var value:Map<String, Dynamic> = this.biomeConfig[ key ];
            var biomeTypeInConfig:String = value[ "biomeType "];
            if( biomeType == biomeTypeInConfig )
                return key;
        }

        throw 'Error in Deploy.getBiomeDeployID. No ID for biome type: $biomeType ';
        return null;
    }
}