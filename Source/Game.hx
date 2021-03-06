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

    public var stage:Stage;
    public var deploy:Deploy;
    public var sceneSystem:SceneSystem;
    public var gameTimeSystem:GameTimeSystem;
    public var gameEventSystem:GameEventSystem;
    public var entitySystem:EntitySystem;
    public var ui:UserInterface;

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
        this._lastTime = Date.now().getTime();

        //create all systems;
        this._preStartGame();
        startGame();
    }

    public function startGame():Void {
        this.gameStart = Date.now().getTime();
        this.calculateDelta();

        this.startMainLoop();
        //sceneSystem.createScene( "startingScene" ); // new game, load game, options, exit;
        var scene:Scene = this.sceneSystem.createScene( 403 );
        scene.prepare();
        this.stage.changeSceneTo( scene );
        //scene.traceScene();
        var rabbit:Entity = this.entitySystem.createEntity( "animal", "rabbit" );
        rabbit.init();
        //var lynx:Entity = this.entitySystem.createEntity( "animal", "lynx" );
        //lynx.init();
        scene.addEntity( rabbit );
        //scene.addEntity( lynx);
        rabbit.stats.traceStats();
        trace( 'change STR 10');
        rabbit.stats.changeStatModifierValue( "strength", 10 );
        rabbit.stats.traceStats();
        rabbit.healthPoints.traceInfo();

        trace( 'change STR -5');
        rabbit.stats.changeStatModifierValue( "strength", -5 );
        rabbit.stats.traceStats();
        rabbit.healthPoints.traceInfo();
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

    public function calculateDelta():Void{
        this._delta = Math.round( 1000 / this.fps );
        this._doubleDelta = this._delta * 2;
    }


    private function _tick():Void{
        this._currentTime = Date.now().getTime();
        var delta:Int = Std.int( this._currentTime - this._lastTime );
        if ( delta >= this._delta ){
            if( delta >= this._doubleDelta ){
                delta = this._doubleDelta; // ???????????? ???? ?????????????? ?????????????? ????????????.
            }
            this._update( delta );
            this._lastTime = this._currentTime;
        }
        this._sUpdate(); // special update; ???????????????????? ???????????????? ???????? ???? ?????????????????????? ????????????.
    }

    private function _update( time:Int ):Void {
        if( !onPause ) {
            this.gameTimeSystem.update( time );
            this.gameEventSystem.update( time );
            this.sceneSystem.update( time );
        }        
    }

    private function _sUpdate():Void {
        //?????????????????????? ???????????? ???? ?????????????????? ( ?? ?????????????? )
    }

    private function _preStartGame():Void{

        var config:DeployConfig = this._parseData();
        this.deploy = new Deploy( this, config );

        this.gameTimeSystem = new GameTimeSystem( this );
        this.gameEventSystem = new GameEventSystem( this );
        this.entitySystem = new EntitySystem( this );
        this.stage = new Stage( this );        
        
        var spriteForScenes:Sprite = new Sprite();
        var spriteForUI:Sprite = new Sprite();
        mainSprite.addChild( spriteForScenes );
        mainSprite.addChild( spriteForUI );
        this.sceneSystem = new SceneSystem( this, spriteForScenes );
        this.ui = new UserInterface( this, spriteForUI );  
        
    }

    private function _parseData():DeployConfig
    {
        var biomeConfig:Dynamic = ConfigJSON.json( "Source/DeployBiomeConfig.json" );
        var floorTypeConfig:Dynamic = ConfigJSON.json( "Source/DeployFloorTypeConfig.json" );
        var groundTypeConfig:Dynamic = ConfigJSON.json( "Source/DeployGroundTypeConfig.json" );
        var sceneConfig:Dynamic = ConfigJSON.json( "Source/DeploySceneConfig.json" );
        var entityConfig:Dynamic = ConfigJSON.json( "Source/deployEntity.json" );
        

        return { BiomeConfig: biomeConfig, GroundTypeConfig: groundTypeConfig, FloorTypeConfig: floorTypeConfig, SceneConfig: sceneConfig, EntityConfig: entityConfig};
    }

}