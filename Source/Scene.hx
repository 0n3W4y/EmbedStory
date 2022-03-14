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
    public var isShowing:Bool;
    public var isHiding:Bool;


    private var _sceneId:SceneID;
    private var _parent:SceneSystem;
    private var _sceneDeployID:SceneDeployID;
    private var _tileID:Int;

    private var _deleteAfterHiding:Bool;

    private var showHideTime:Int = 2000; // ~  2 seconds;

    public function new( parent:SceneSystem, params:SceneConfig ):Void{
        this._parent = parent;
        this._sceneId = params.ID;        
        this.sceneName = params.SceneName;
        this.sceneType = params.SceneType;
        this._sceneDeployID = params.DeployID;
        this.isHide = false;
        this.isShow = false;
        this.isShowing = false;
        this.isHiding = false;

        this._deleteAfterHiding = false;

        this.tileMapStorage = new Array<TileMap>();
        this._tileID = 0;
    }

    public function show():Void{
        if( isShow )
            throw 'Error in Scene.show. Scene already shown';

        this.isShowing = true;
        this.sceneGraphics.alpha = 0.0;
        this.sceneGraphics.visible = true;

    }

    public  function hide():Void{
        if( isHide )
            throw 'Error in Scene.hide. Scene Already hided';

        this.isHiding = true;
        //UI.graphics.visible = false;
    }

    public function hideAndDelete():Void{
        if( isHide )
            throw 'Error in Scene.hide. Scene Already hided';

        this.isHiding = true;
        this._deleteAfterHiding = true;
        //UI.graphics.visible = false;
    }

    public function update( time:Int ):Void{
        if( this.isShowing )
            this._showingScene( time );

        if( this.isHiding )
            this._hidingScene( time );
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

    public function generateTileMap():Void{
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

    private function _generateTileMapID():TileMapID{
        this._tileID++;
        return TileMapID( this._tileID );
    }

    private function _showingScene( time:Int ):Void{
        var numberToIncreaseAlpha:Float =  time / this.showHideTime;
        this.sceneGraphics.alpha += numberToIncreaseAlpha;
        if( this.sceneGraphics.alpha >= 1.0 ){
            this.sceneGraphics.alpha = 1.0;
            this.isShowing = false;
            this.isShow = true;
            // UI.graphics.visible = true;
        }
    }

    private function _hidingScene( time:Int ):Void{
        var numberToDecreaseAlpha:Float =  time / this.showHideTime;
        this.sceneGraphics.alpha -= numberToDecreaseAlpha;
        if( this.sceneGraphics.alpha<= 0 ){
            this.sceneGraphics.alpha = 0.0;
            this.sceneGraphics.visible = false;
            this.isHiding = false;
            this.isHide = true;
            if( this._deleteAfterHiding )
                this._parent.deleteScene( this );
        }
        
    }
}