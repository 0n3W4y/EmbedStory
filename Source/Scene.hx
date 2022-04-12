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
    public var effectStorage:Array<Dynamic>;
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
        this._spreadIndexesForRocksObjects();
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

            if( rockEntity == null )
                throw 'Error in Scene._createRockObject. Created Entity is NULL! $tileGroundType';

            rockEntity.gridX = tile.gridX;
            rockEntity.gridY = tile.gridY;
            rockEntity.tileID = tile.getID();
            rockEntity.tileMapID = this.tileMap.getID();
            rockEntity.init();
            this.objectStorage.push( rockEntity );       
        }
    }

    private function _spreadIndexesForRocksObjects():Void{
        var rocksArray:Array<Entity> = [];
        for( i in 0...rocksArray.length ){
            var entity:Entity = rocksArray[ i ];
            var entityType:String = entity.entityType;
            var entitySubType:String = entity.entitySubType;
            if( entityType == "rock" && ( entitySubType == "rock" || entitySubType == "sandrock" )){
                this._spreadIndexForRockObject( entity );
            }
        }
    }

    private function _spreadIndexForRockObject( entity:Entity ):Void{
        //for walls;
        var x:Int = entity.gridX;
        var y:Int = entity.gridY;
        //index 1 - solo struct; 1 
        //index 2 - only on top; 1
        //index 3 - only on left; 1
        //index 4 - only on right; 1
        //index 5 - left+top; 2
        //index 6 - right+top; 2
        //index 7 - left+bottom; 2
        //index 8 - right+bottom; 2
        //index 9 - top+bottom; 2
        //index 10 - right+left; 2
        //index 10 - left+top+right; 3
        //index 11 - left+bottom+right; 3
        //index 12 - left+top+bottom; 3
        //index 13 - right+top+bottom; 3
        //index 14 - bottom+bottomleft+left; 3
        //index 15 - bottom+bottomright+right; 3
        //index 15 - top+lefttop+left; 3
        //index 16 - top+righttop+right; 3
        //index 17 - right+top+bottom+left; 4
        //index 18 - top+lefttop+left+bottom; 4
        //index 19 - top+righttop+right+bottom; 4
        //index -- - top+righttop+right+left; 4
        //index -- - top+lefttop+left+right; 4
        //index -- - bottom+bottomright+right+top; 4
        //index -- - bottom+bottomright+right+left; 4
        //index -- - bottom+bottmleft+left+top; 4
        //index -- - bottom+bottomleft+left+right; 4
        //index 20 - top+righttop+right+lefttop+left; 5
        //index 21 - bottom+rightbottom+right+leftbottom+left; 5
        //index 22 - top+lefttop+left+leftbottom+bottom; 5
        //index 23 - top+righttop+right+rightbottom+bottom; 5
        //index -- - top+lefttop+left+leftbottom+bottom; 5
        //index 24 - left+lefttop+top+right+bottom; 5
        //index -- - top+topright+right+bottom+left; 5
        //index -- - right+rightbottom+bottom+left+top; 5
        //index -- - bottom+leftbottom+left+top+right; 5
        //index -- - top+righttop+right+left+leftbottom+bottom; 6
        //index -- - top+lefttop+left+right+rightbottom+bottom; 6
        //index -- - left+lefttop+top+righttop+right+bottom; 6
        //index -- - top+righttop+right+rightbottom+bottom+left; 6
        //index -- - right+rightbottom+bottom+leftbottom+left+top; 6
        //index -- - bottom+rightbottom+right
        //index xx - left+lefttop+top+righttop+right+rightbottom+bottom; 7
        //index xx - right+righttop+top+lefttop+left+leftbottom+bottom; 7
        //index xx - top+lefttop+left+leftbottom+bottom+bottomright+right; 7
        //index xx - top+righttop+right+rightbottom+bottom+leftbottom+left; 7
        //index xx - all;
    }

    private function _generateTileMapID():TileMapID{
        this._tileID++;
        return TileMapID( this._tileID );
    }

}