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
    public var tileMapStorage:Array<TileMap>;
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

    public var isShow:Bool;
    public var isHide:Bool;


    private var _sceneId:SceneID;
    private var _parent:SceneSystem;
    private var _sceneDeployID:SceneDeployID;
    private var _tileID:Int;

    private var _deleteAfterHiding:Bool;

    public function new( parent:SceneSystem, params:SceneConfig ):Void{
        this._parent = parent;
        this._sceneId = params.ID;        
        this.sceneName = params.SceneName;
        this.sceneType = params.SceneType;
        this._sceneDeployID = params.DeployID;
        this.isHide = false;
        this.isShow = false;

        this.tileMapStorage = new Array<TileMap>();
        this._tileID = 0;
        this.sceneGraphics = new Sprite();
    }

    public function show():Void{
        if( isShow )
            throw 'Error in Scene.show. Scene already shown';

        this.isShow = true;
        this.sceneGraphics.alpha = 0.0;
        //UI.graphics.visible = true;

    }

    public  function hide():Void{
        if( isHide )
            throw 'Error in Scene.hide. Scene Already hided';

        this.isHide = true;
        this.sceneGraphics.visible = false;        
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
        return this._sceneId;
    }

    public function getTileMapWithID( tileMapID:TileMapID ):TileMap{
        for( i in 0...this.tileMapStorage.length ){
            var tileMap:TileMap = this.tileMapStorage[ i ];
            if( EnumValueTools.equals( tileMap.getTileMpaID(), tileMapID ))
                return tileMap;
        }

        throw 'Error in Scene.getTileMapWithID. No tile map with ID: $tileMapID .';
        return null;
    }

    public function generate():Void{
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
            Biome: biome,
            TileSize: tileSize,
            DeployID: biomeDeployID,
            TileMapID: id,
            Name: "TEST"
        }
        var tileMap:TileMap = new TileMap( this, tileMapConfig );
        tileMap.init();
        tileMap.generateMap();

        this.tileMapStorage.push( tileMap );
    }

    private function _generateObjects():Void{
        this._createRockObjects();
    }

    private function _createRockObjects():Void{
        for( i in 0...this.tileMapStorage.length ){
            var tileMap:TileMap = this.tileMapStorage[ i ];
            var newTileStorage:Array<Tile> = tileMap.tileStorage;
            for( j in 0...newTileStorage.length ){
                var tile:Tile = newTileStorage[ j ];
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