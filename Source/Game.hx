package;

import haxe.Timer;
import openfl.system.System;
import openfl.display.Sprite;

import Deploy;

class Game {
    public var fps:Int;
    public var width:Int;
    public var height:Int;

    public var mainSprite:Sprite;
    public var sceneSprite:Sprite;
    public var uiSprite:Sprite;

    public var stage:Stage;
    public var deploy:Deploy;
    public var sceneSystem:SceneSystem;
    public var gameTimeSystem:GameTimeSystem;
    public var eventSystem:EventSystem;

    public var gameStart:Float;
    public var onPause:Bool;
    public var mainLoop:Timer;

    private var _currentTime:Float;
	private var _lastTime:Float;
	private var _delta:Int;
	private var _doubleDelta:Int;


    public function new( width:Int, height:Int, fps:Int, mainSprite:Sprite ):Void {
        this.fps = fps;
        this.width = width;
        this.height = height;
        this.mainSprite = mainSprite;

        this.onPause = false;
        this._lastTime = 0;

        //create all systems;
        this._preStartGame();
        startGame();
    }

    public function startGame():Void {
        this.gameStart = Date.now().getTime();
        this.calculateDelta();

        this.startMainLoop();
        //sceneSystem.createScene( "startingScene" ); // new game, load game, options, exit;
    }

    public function stopGame():Void{
        //save game;
        this.stopMainLoop();
        this.exit();
    }

    public function startMainLoop():Void {
        var time:Int = Std.int( Math.ffloor( this._delta ));
    
        this.mainLoop = new Timer( time );
        this.mainLoop.run = function() {
            this._tick();
        };
    }
    
    public function stopMainLoop():Void {
        this.mainLoop.stop();
    }
    
    public function pause():Void {
        if( this.onPause )
           this.onPause = false;
        else
           this.onPause = true;
    }
    
    public function exit():Void {
        System.exit( 0 );
    }

    public function calculateDelta():Void
    {
        this._delta = Math.round( 1000 / this.fps );
        this._doubleDelta = this._delta * 2;
    }

    private function _tick():Void
    {
        this._currentTime = Date.now().getTime();
        var delta:Int = Std.int( this._currentTime - this._lastTime );

        if ( delta >= this._delta ){
            if( delta >= this._doubleDelta ){
                delta = this._doubleDelta; // Защита от скачков времени вперед.
            }
            this._update( delta );
            this._lastTime = this._currentTime;
        }
        this._sUpdate(); // special update; обновление дейсвтий мыши на графические объкты.
    }

    private function _update( time:Int ):Void {
        if( !onPause ) {
            this.gameTimeSystem.update( time );
            this.eventSystem.update( time );
        }
    }

    private function _sUpdate():Void {

    }

    private function _preStartGame():Void{

        this.gameTimeSystem = new GameTimeSystem( this );
        this.eventSystem = new EventSystem( this );
        this.stage = new Stage( this );
        var spriteForScenes:Sprite = new Sprite();
        var spriteForUI:Sprite = new Sprite();

        mainSprite.addChild( spriteForScenes );
        mainSprite.addChild( spriteForUI );
        
        var config:DeployConfig = this._parseData();
        this.deploy = new Deploy( this, config );
        this.sceneSystem = new SceneSystem( this, spriteForScenes );


        var scene:Scene = this.sceneSystem.createScene( 401 );
        trace( scene.tileMapStorage[ 0 ].tileStorage );
    }

    private function _parseData():DeployConfig
    {
        var biomeConfig:Dynamic = ConfigJSON.json( "Source/DeployBiomeConfig.json" );
        var floorTypeConfig:Dynamic = ConfigJSON.json( "Source/DeployFloorTypeConfig.json" );
        var groundTypeConfig:Dynamic = ConfigJSON.json( "Source/DeployGroundTypeConfig.json" );
        var sceneConfig:Dynamic = ConfigJSON.json( "Source/DeploySceneConfig.json" );
        

        return { BiomeConfig: biomeConfig, GroundTypeConfig: groundTypeConfig, FloorTypeConfig: floorTypeConfig, SceneConfig:sceneConfig };
    }

}