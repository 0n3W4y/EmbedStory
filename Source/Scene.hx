package;

import haxe.EnumTools;
import TileMap;
import openfl.display.Sprite;

enum SceneID{
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
    public var tileMap:TileMap;
    public var objectStorage:Array<Entity>;
    public var stuffStorage:Array<Entity>;
    public var effectStorage:Array<Effect>;
    public var characterStorage:Array<Entity>;

    public var groundTileMapGraphics:Sprite;
    public var floorTileMapGraphics:Sprite;
    public var objectGraphics:Sprite;
    public var stuffGraphics:Sprite;
    public var characterGraphics:Sprite;
    public var effectGraphics:Sprite;

    public var sceneName:String;
    public var sceneType:String; // globalMap, battle;
    public var sceneGraphics:Sprite;

    public var showed:Bool;
    public var hided:Bool;
    public var prepared:Bool;
    public var drawed:Bool;


    private var _sceneID:SceneID;
    private var _parent:SceneSystem;
    private var _sceneDeployID:SceneDeployID;
    private var _tileID:Int;

    private var _deleteAfterHiding:Bool;

    public function new( parent:SceneSystem, params:SceneConfig ):Void{
        this._parent = parent;
        this._sceneID = params.ID;        
        this.sceneName = params.SceneName;
        this.sceneType = params.SceneType;
        this._sceneDeployID = params.DeployID;

        this.hided = false;
        this.showed = false;
        this.prepared = false;
        this.drawed = false;

        this._tileID = 0;
        this.sceneGraphics = new Sprite();
        this.groundTileMapGraphics = new Sprite();
        this.floorTileMapGraphics = new Sprite();
        this.objectGraphics = new Sprite();
        this.stuffGraphics = new Sprite();
        this.characterGraphics = new Sprite();
        this.effectGraphics = new Sprite();

        this.sceneGraphics.addChild(  this.groundTileMapGraphics );
        this.sceneGraphics.addChild(  this.floorTileMapGraphics );
        this.sceneGraphics.addChild(  this.objectGraphics );
        this.sceneGraphics.addChild(  this.stuffGraphics );
        this.sceneGraphics.addChild(  this.characterGraphics );
        this.sceneGraphics.addChild(  this.effectGraphics );
        

        //by default scene not visible and transperent;
        this.sceneGraphics.visible = false;
        this.sceneGraphics.alpha = 0.0;
    }

    public function show():Void{
        if( this.showed )
            throw 'Error in Scene.show. Scene already shown';

        this._parent.activeScene = this;
        this._parent.getParent().ui.show();
        this.showed = true;
    }

    public  function hide():Void{
        if( this.hided )
            throw 'Error in Scene.hide. Scene Already hided';

        this._parent.activeScene = null;
        this.sceneGraphics.visible = false;
        this.hided = true;       
    }

    public function prepare():Void{
        // this function prepare scene like generate map, add grphics etc.
        if( this.prepared )
            throw 'Error in scene $sceneName, $_sceneID, $_sceneDeployID';

        this.prepared = true;

        if( this.sceneType == "groundMap" || this.sceneType == "globalMap" )
            this._generate();        

    }

    public function delete():Void{
        this._parent.deleteScene( this );
    }

    public function update( time:Int ):Void{

    }

    public function getParent():SceneSystem{
        return this._parent;
    }

    public function getSceneDeployID():SceneDeployID{
        return this._sceneDeployID;
    }

    public function getSceneID():SceneID{
        return this._sceneID;
    }






    private function _generate():Void{
        this._generateTileMap();
        this._generateObjects();
    }   

    private function _generateTileMap():Void{
        var id:TileMapID = this._generateTileMapID();
        var sceneDeployConfig:Dynamic = this._parent.getParent().deploy.sceneConfig[ this._sceneDeployID ];
        var biome:String = Reflect.getProperty( sceneDeployConfig, "tileMapBiome" );
        var height:Int = Reflect.getProperty( sceneDeployConfig, "height" );
        var width:Int = Reflect.getProperty( sceneDeployConfig, "width" );
        var tileSize:Int = Reflect.getProperty( sceneDeployConfig, "tileSize" );
        var biomeDeployID:BiomeDeployID = this._parent.getParent().deploy.getBiomeDeployID( biome );

        var tileMapConfig:TileMapConfig = {
            Height: height,
            Width: width,
            TileSize: tileSize,
            DeployID: biomeDeployID,
            TileMapID: id
        }
        this.tileMap = new TileMap( this, tileMapConfig );
        this.tileMap.init();
        this.tileMap.generateMap();
    }

    private function _generateObjects():Void{
        this._createRockObjects();
    }

    private function _createRockObjects():Void{
        var newTileStorage:Array<Tile> = this.tileMap.tileStorage;
        for( i in 0...newTileStorage.length ){
            var tile:Tile = newTileStorage[ i ];
            var tileGroundType:String = tile.groundType;
            var rockEntity:Entity = null;
            switch( tileGroundType ){
                case "rock": rockEntity = this._parent.getParent().entitySystem.createEntityByDeployID( EntityDeployID( 1020 )); // 1020 - type "rock", subtype "rock";
                case "sandrock": rockEntity = this._parent.getParent().entitySystem.createEntityByDeployID( EntityDeployID( 1021 )); // 1021 - type "rock", subtype "sandrock";
                default: continue;
            }

            if( rockEntity != null )
                this.objectStorage.push( rockEntity );
                
        }
        this._spreadIndexesForRocksObjects( );
    }

    private function _spreadIndexesForRocksObjects():Void{
        var rocksArray:Array<Entity> = [];
        for( i in 0...rocksArray.length ){
            var rockEntity:Entity = rocksArray[ i ];
        }
    }

    private function _generateTileMapID():TileMapID{
        this._tileID++;
        return TileMapID( this._tileID );
    }

}