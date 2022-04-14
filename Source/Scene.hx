package;


import js.html.svg.Number;
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
        
        this.objectStorage = [];
        this.stuffStorage = [];
        this.effectStorage = [];
        this.characterStorage = [];

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
        var rocksArray:Array<Entity> = this.objectStorage;
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

        var top:Bool = false;
        var topCorrdX = x;
        var topCoordY = y - 1;

        var left:Bool = false;
        var leftCoordX = x - 1;
        var leftCoordY = y;

        var right:Bool = false;
        var rightCoordX = x + 1;
        var rightCoordY = y;

        var bottom:Bool = false;
        var bottomCoordX = x;
        var bottomCoordY = x + 1;


        for( i in 0...this.objectStorage.length ){
            var obj:Entity = this.objectStorage[ i ];
            if( obj.entityType != "rock" && ( obj.entitySubType != "rock" || obj.entitySubType != "sandrock" ))
                continue;

            var objX:Int = obj.gridX;
            var objY:Int = obj.gridY;
            if( objX == topCorrdX && objY == topCoordY )
                top = true;
            else if( objX == leftCoordX && objY == leftCoordY )
                left = true;
            else if( objX == rightCoordX && objY == rightCoordY )
                right = true;
            else if( objX == bottomCoordX && objY == bottomCoordY )
                bottom = true;
            else
                continue;
        }

        if( top && left && right && bottom ){
            //index 1; 4
            entity.graphicIndex = 1;
        }else if( top && left && right && !bottom ){
            //index 2; 3 top+left+right
            entity.graphicIndex = 2;
        }else if( top && left && !right && bottom ){
            //index 3; 3 top+left+bottom
            entity.graphicIndex = 3;
        }else if( top && !left && right && bottom ){
            //index 4; 3 top+right+bottom
            entity.graphicIndex = 4;
        }else if( !top && left && right && bottom ){
            //index 5; 3 left+right+bottom
            entity.graphicIndex = 5;
        }else if( top && left && !right && !bottom ){
            //index 6; 2 top+left
            entity.graphicIndex = 6;
        }else if( !top && left && right && !bottom ){
            //index 7; 2 left+right
            entity.graphicIndex = 7;
        }else if( !top && !left && right && bottom ){
            //index 8; 2 right+bottom
            entity.graphicIndex = 8;
        }else if( top && !left && !right && bottom ){
            //index 9; 2 top+bottom
            entity.graphicIndex = 9;
        }else if( top && !left && !right && bottom ){
            //index 10; 2 top+bottom
            entity.graphicIndex = 10;
        }else if( !top && left && !right && bottom ){
            //index 11; 2 bot+left
            entity.graphicIndex = 11;
        }else if( top && !left && right && !bottom ){
            //index 12; 2 top+right
            entity.graphicIndex = 12;
        }else if( top && !left && !right && !bottom ){
            //index 11; 1 top
            entity.graphicIndex = 13;
        }else if( !top && !left && right && !bottom ){
            //index 12; 1 right
            entity.graphicIndex = 14;
        }else if( !top && left && !right && !bottom ){
            //index 13; 1 left
            entity.graphicIndex = 15;
        }else if( !top && !left && !right && bottom ){
            //index 14; 1 bottom
            entity.graphicIndex = 16;
        }else if( !top && !left && !right && !bottom ){
            //index 15; 0
            entity.graphicIndex = 17;
        }else{
            trace( 'Top: $top, Bot: $bottom, Left: $left, Right: $right ');
            throw 'Error in Scene._spreadIndexForRockObject. Something wrong with function.';
        }
        trace( entity.graphicIndex );    
    }

    private function _generateTileMapID():TileMapID{
        this._tileID++;
        return TileMapID( this._tileID );
    }

}