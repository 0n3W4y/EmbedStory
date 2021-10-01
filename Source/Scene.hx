package;

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
    public var objectStorage:Array<Entity>;
    public var stuffStorage:Array<Stuff>;
    public var effectStorage:Array<Effect>;
    public var characterStorage:Array<Character>;
    public var sceneName:String;
    public var sceneType:String; // globalMap, groundMap, dungeonMap, 

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

    public function generateTileMap( params:TileMapConfig ):Void{
        var id:TileMapID = this._generateTileMapID();
        params.TileMapID = id;
        var tileMap:TileMap = new TileMap( this, params );
        tileMap.generateMap();

        this.tileMapStorage.push( tileMap );
    }

    private function _generateTileMapID():TileMapID{
        this._tileID++;
        return TileMapID( this._tileID );
    }
}