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

        var leftTop:Bool = false;
        var leftTopCoordX = x - 1;
        var leftTopCoordY = y - 1;

        var top:Bool = false;
        var topCorrdX = x;
        var topCoordY = y - 1;

        var rightTop:Bool = false;
        var rightTopCoordX = x + 1;
        var rightTopCoordY = y - 1;

        var left:Bool = false;
        var leftCoordX = x - 1;
        var leftCoordY = y;

        var right:Bool = false;
        var rightCoordX = x + 1;
        var rightCoordY = y;

        var leftBottom:Bool = false;
        var leftBottomCoordX = x - 1;
        var leftBottomCoordY = y + 1;

        var bottom:Bool = false;
        var bottomCoordX = x;
        var bottomCoordY = x + 1;

        var rightBottom:Bool = false;
        var rightBottomCoordX = x + 1;
        var rightBorromCoordY = y + 1;

        for( i in 0...this.objectStorage.length ){
            var obj:Entity = this.objectStorage[ i ];
            var objX:Int = obj.gridX;
            var objY:Int = obj.gridY;
            if( objX == leftTopCoordX && objY == leftTopCoordY )
                leftTop = true;
            else if( objX == topCorrdX && objY == topCoordY )
                top = true;
            else if( objX == rightTopCoordX && objY == rightTopCoordY )
                rightTop = true;
            else if( objX == leftCoordX && objY == leftCoordY )
                left = true;
            else if( objX == rightCoordX && objY == rightCoordY )
                right = true;
            else if( objX == leftBottomCoordX && objY == leftBottomCoordY )
                leftBottom = true;
            else if( objX == bottomCoordX && objY == bottomCoordY )
                bottom = true;
            else if( objX == rightBottomCoordX && objY == rightBorromCoordY )
                rightBottom = true;
            else
                continue;
        }        

        if( !leftTop && !top && !rightTop && !left && !right && !leftBottom && !bottom && !rightBottom ){
            //index 1 - solo struct; 0        
            entity.graphicIndex = 1;
        }else if( !leftTop && top && !rightTop && !left && !right && !leftBottom && !bottom && !rightBottom ){
            //index 2 - only on top; 1
            entity.graphicIndex = 2;
        }else if( !leftTop && !top && !rightTop && left && !right && !leftBottom && !bottom && !rightBottom ){
            //index 3 - only on left; 1
            entity.graphicIndex = 3;
        }else if( !leftTop && !top && !rightTop && !left && right && !leftBottom && !bottom && !rightBottom ){
            //index 4 - only on right; 1        
            entity.graphicIndex = 4;
        }else if( !leftTop && !top && !rightTop && !left && !right && !leftBottom && bottom && !rightBottom ){
            //index 5 - only on bottom; 1
            entity.graphicIndex = 5;
        }else if( !leftTop && top && !rightTop && left && !right && !leftBottom && !bottom && !rightBottom ){
            //index 6 - left+top; 2
            entity.graphicIndex = 6;
        }else if( !leftTop && top && !rightTop && !left && right && !leftBottom && !bottom && !rightBottom ){
            //index 7 - right+top; 2
            entity.graphicIndex = 7;
        }else if( !leftTop && !top && !rightTop && left && !right && !leftBottom && bottom && !rightBottom ){
            //index 8 - left+bottom; 2
            entity.graphicIndex = 8;
        }else if( !leftTop && !top && !rightTop && !left && right && !leftBottom && bottom && !rightBottom ){
            //index 9 - right+bottom; 2
            entity.graphicIndex = 9;
        }else if( !leftTop && top && !rightTop && !left && !right && !leftBottom && bottom && !rightBottom ){
            //index 10 - top+bottom; 2
            entity.graphicIndex = 10;
        }else if( !leftTop && !top && !rightTop && left && right && !leftBottom && !bottom && !rightBottom ){
            //index 11 - right+left; 2
            entity.graphicIndex = 11;
        }else if( !leftTop && top && !rightTop && left && right && !leftBottom && !bottom && !rightBottom ){
            //index 12 - left+top+right; 3
            entity.graphicIndex = 12;
        }else if( !leftTop && !top && !rightTop && !left && !right && !leftBottom && !bottom && !rightBottom ){
            //index 13 - left+bottom+right; 3
            entity.graphicIndex = 13;
        }else if( !leftTop && top && !rightTop && left && !right && !leftBottom && bottom && !rightBottom ){
             //index 14 - left+top+bottom; 3
            entity.graphicIndex = 14;
        }else if( !leftTop && top && !rightTop && !left && right && !leftBottom && bottom && !rightBottom ){
            //index 15 - right+top+bottom; 3
            entity.graphicIndex = 15;
        }else if( !leftTop && !top && !rightTop && left && !right && leftBottom && bottom && !rightBottom ){
            //index 16 - bottom+bottomleft+left; 3
            entity.graphicIndex = 16;
        }else if( !leftTop && !top && !rightTop && !left && right && !leftBottom && bottom && rightBottom ){
            //index 17 - bottom+bottomright+right; 3
            entity.graphicIndex = 17;
        }else if( leftTop && top && !rightTop && left && !right && !leftBottom && !bottom && !rightBottom ){
            //index 18 - top+lefttop+left; 3
            entity.graphicIndex = 18;
        }else if( !leftTop && top && rightTop && !left && right && !leftBottom && !bottom && !rightBottom ){
            //index 19 - top+righttop+right; 3
            entity.graphicIndex = 19;
        }else if( !leftTop && top && !rightTop && left && right && !leftBottom && bottom && !rightBottom ){
            //index 20 - right+top+bottom+left; 4
            entity.graphicIndex = 20;
        }else if( leftTop && top && !rightTop && left && !right && !leftBottom && bottom && !rightBottom ){
            //index 21 - top+lefttop+left+bottom; 4
            entity.graphicIndex = 21;
        }else if( !leftTop && top && rightTop && !left && right && !leftBottom && bottom && !rightBottom ){
            //index 22 - top+righttop+right+bottom; 4
            entity.graphicIndex = 22;
        }else if( !leftTop && top && rightTop && left && right && !leftBottom && !bottom && !rightBottom ){
            //index 23 - top+righttop+right+left; 4
            entity.graphicIndex = 23;
        }else if( leftTop && top && !rightTop && left && right && !leftBottom && !bottom && !rightBottom ){
            //index 24 - top+lefttop+left+right; 4
            entity.graphicIndex = 24;
        }else if( !leftTop && top && !rightTop && !left && right && !leftBottom && bottom && rightBottom ){
            //index 25 - bottom+bottomright+right+top; 4
            entity.graphicIndex = 25;
        }else if( !leftTop && !top && !rightTop && left && right && !leftBottom && bottom && rightBottom ){
            //index 26 - bottom+bottomright+right+left; 4
            entity.graphicIndex = 26;
        }else if( !leftTop && top && !rightTop && left && !right && leftBottom && bottom && !rightBottom ){
            //index 27 - bottom+bottmleft+left+top; 4
            entity.graphicIndex = 27;
        }else if( !leftTop && !top && !rightTop && left && right && leftBottom && bottom && !rightBottom ){
            //index 28 - bottom+bottomleft+left+right; 4
            entity.graphicIndex = 28;
        }else if( leftTop && top && rightTop && left && right && !leftBottom && !bottom && !rightBottom ){
            //index 29 - top+righttop+right+lefttop+left; 5
            entity.graphicIndex = 29;
        }else if( !leftTop && !top && !rightTop && left && right && leftBottom && bottom && rightBottom ){
            //index 30 - bottom+rightbottom+right+leftbottom+left; 5
            entity.graphicIndex = 30;
        }else if( leftTop && top && !rightTop && left && !right && leftBottom && bottom && !rightBottom ){
             //index 31 - top+lefttop+left+leftbottom+bottom; 5
            entity.graphicIndex = 31;
        }else if( !leftTop && top && rightTop && !left && right && !leftBottom && bottom && rightBottom ){
            //index 32 - top+righttop+right+rightbottom+bottom; 5
            entity.graphicIndex = 32;
        }else if( leftTop && top && !rightTop && left && !right && leftBottom && bottom && !rightBottom ){
            //index 33 - top+lefttop+left+leftbottom+bottom; 5
            entity.graphicIndex = 33;
        }else if( leftTop && top && !rightTop && left && right && !leftBottom && bottom && !rightBottom ){
            //index 34 - left+lefttop+top+right+bottom; 5
            entity.graphicIndex = 34;
        }else if( !leftTop && top && rightTop && left && right && !leftBottom && bottom && !rightBottom ){
            //index 35 - top+topright+right+bottom+left; 5
            entity.graphicIndex = 35;
        }else if( !leftTop && top && !rightTop && left && right && !leftBottom && bottom && rightBottom ){
            //index 36 - right+rightbottom+bottom+left+top; 5
            entity.graphicIndex = 36;
        }else if( !leftTop && top && !rightTop && left && right && leftBottom && bottom && !rightBottom ){
            //index 37 - bottom+leftbottom+left+top+right; 5
            entity.graphicIndex = 37;
        }else if( !leftTop && top && rightTop && left && right && leftBottom && bottom && !rightBottom ){
            //index 38 - top+righttop+right+left+leftbottom+bottom; 6
            entity.graphicIndex = 38;
        }else if( leftTop && top && !rightTop && !left && right && !leftBottom && bottom && rightBottom ){
            //index 39 - top+lefttop+left+right+rightbottom+bottom; 6
            entity.graphicIndex = 39;
        }else if( leftTop && top && rightTop && left && right && !leftBottom && bottom && !rightBottom ){
            //index 40 - left+lefttop+top+righttop+right+bottom; 6
            entity.graphicIndex = 40;
        }else if( !leftTop && top && rightTop && left && right && !leftBottom && bottom && rightBottom ){
            //index 41 - top+righttop+right+rightbottom+bottom+left; 6
            entity.graphicIndex = 41;
        }else if( !leftTop && top && !rightTop && left && right && leftBottom && bottom && rightBottom ){
            //index 42 - right+rightbottom+bottom+leftbottom+left+top; 6
            entity.graphicIndex = 42;
        }else if( leftTop && top && !rightTop && left && right && leftBottom && bottom && !rightBottom ){
            //index 43 - bottom+leftbottom+left+lefttop+top+right; 6
            entity.graphicIndex = 43;
        }else if( leftTop && top && rightTop && left && right && !leftBottom && bottom && rightBottom ){
            //index 44 - left+lefttop+top+righttop+right+rightbottom+bottom; 7
            entity.graphicIndex = 44;
        }else if( leftTop && top && rightTop && left && right && leftBottom && bottom && !rightBottom ){
            //index 45 - right+righttop+top+lefttop+left+leftbottom+bottom; 7
            entity.graphicIndex = 45;
        }else if( leftTop && top && !rightTop && left && right && leftBottom && bottom && rightBottom ){
            //index 46 - top+lefttop+left+leftbottom+bottom+bottomright+right; 7
            entity.graphicIndex = 46;
        }else if( !leftTop && top && rightTop && left && right && leftBottom && bottom && rightBottom ){
            //index 47 - top+righttop+right+rightbottom+bottom+leftbottom+left; 7
            entity.graphicIndex = 47;
        }else if( leftTop && top && rightTop && left && right && leftBottom && bottom && rightBottom ){
            //index 48 - all; 8
            entity.graphicIndex = 48;
        }else if( leftTop && top && rightTop && left && right && leftBottom && bottom && rightBottom ){

        }else if( leftTop && top && rightTop && left && right && leftBottom && bottom && rightBottom ){

        }else if( leftTop && top && rightTop && left && right && leftBottom && bottom && rightBottom ){

        }else if( leftTop && top && rightTop && left && right && leftBottom && bottom && rightBottom ){
            
        }else{
            throw 'Error in Scene._spreadIndexForRockObject. Something wrong with function.';
        }
        trace( entity.graphicIndex );    
    }

    private function _generateTileMapID():TileMapID{
        this._tileID++;
        return TileMapID( this._tileID );
    }

}