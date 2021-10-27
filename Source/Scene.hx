package;

import haxe.EnumTools;
import TileMap;
import openfl.display.Sprite;

enum SceneID {
    SceneID( _:Int );
}

enum SceneDeployID{
    SceneDeployID( _:Int );
}

typedef SceneConfig = {
    var ID:SceneID;
    var SceneName:String;
    var SceneType:String;
    var DeployID:SceneDeployID;
    var SceneSprite:Sprite;
}

class Scene {
    public var tileMapStorage:Array<TileMap>;
    public var objectStorage:Array<EntityObject>;
    public var stuffStorage:Array<EntityStuff>;
    public var effectStorage:Array<Effect>;
    public var characterStorage:Array<EntityCharacter>;

    public var groundTileMapGraphics:Sprite;
    public var floorTileMapGraphics:Sprite;
    public var objectGraphics:Sprite;
    public var stuffGraphics:Sprite;
    public var characterGraphics:Sprite;
    public var effectGraphics:Sprite;

    public var sceneName:String;
    public var sceneType:String; // globalMap, groundMap, dungeonMap,
    public var sceneGraphics:Sprite;

    private var _sceneId:SceneID;
    private var _parent:SceneSystem;
    private var _sceneDeployID:SceneDeployID;
    private var _tileID:Int;

    public function new( parent:SceneSystem, params:SceneConfig ):Void{
        this._parent = parent;
        this._sceneId = params.ID;        
        this.sceneName = params.SceneName;
        this.sceneType = params.SceneType;

        this.tileMapStorage = new Array<TileMap>();
        this._tileID = 0;
    }

    public function getParent():SceneSystem{
        return this._parent;
    }

    public function getSceneDeployID():SceneDeployID{
        return this._sceneDeployID;
    }

    public function getSceneID():SceneID{
        return this._sceneId;
    }

    public function getTileMapWithID( tileMapID:TileMapID ):TileMap{
        for( i in 0...this.tileMapStorage.length ){
            var tileMap:TileMap = this.tileMapStorage[ i ];
            if( EnumValueTools.equals( tileMap.gettileMpaID(), tileMapID ))
                return tileMap;
        }

        throw 'Error in Scene.getTileMapWithID. No tile map with ID: $tileMapID .';
        return null;
    }

    public function generateTileMap():Void{
        var id:TileMapID = this._generateTileMapID();
        var sceneDeployConfig:Dynamic = this._parent.getParent().deploy.sceneConfig[ this._sceneDeployID ];
        var biome:String = Reflect.getProperty( sceneDeployConfig, "biome" );
        var height:Int = Reflect.getProperty( sceneDeployConfig, "height" );
        var width:Int = Reflect.getProperty( sceneDeployConfig, "width" );
        var tileSize:Int = Reflect.getProperty( sceneDeployConfig, "tileSize" );
        var biomeDeployID:BiomeDeployID = this._parent.getParent().deploy.getBiomeDeployID( biome );
        var tileMapConfig:TileMapConfig = {
            Height: height,
            Width: width,
            Biome: biome,
            TileSize: tileSize,
            DeployID: biomeDeployID,
            TileMapID: id,
            Name: null
        }
        var tileMap:TileMap = new TileMap( this, tileMapConfig );
        tileMap.generateMap();

        this.tileMapStorage.push( tileMap );
    }

    private function _generateTileMapID():TileMapID{
        this._tileID++;
        return TileMapID( this._tileID );
    }
}