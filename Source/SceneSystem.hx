package;

import TileMap.TileMapConfig;
import TileMap.BiomeDeployID;
import openfl.display.Sprite;
import Scene;

class SceneSystem {

    public var sceneSprite:Sprite;
    public var sceneStorage:Array<Scene>;

    private var _sceneId:Int;
    private var _parent:Game;

    public function new( parent:Game, sceneSprite:Sprite ):Void{
        this._parent = parent;
        this.sceneSprite = sceneSprite;

        this.sceneStorage = new Array<Scene>();
    }

    public function createScene( sceneDeploy:Int ):Scene{
        var newSceneId:SceneID = this._generateSceneId();
        var newSceneDeployID:SceneDeployID = SceneDeployID( sceneDeploy );

        var scene:Scene = null;

        switch( sceneDeploy ){
            case 401: scene = this._createBattleScene( newSceneId, newSceneDeployID );
            default: throw 'Error in SceneSystem.createScene. No scene with deploy ID: $sceneDeploy .';
        }

        this.sceneStorage.push( scene );
        return scene;
    }

    public function deleteScene( scene:Scene ):Void{

    }

    public function changeSceneTo( scene:Scene ):Void{
        var sceneType:String = scene.sceneType;
        switch( sceneType ){
            case "globalMap":{};
            case "dungeonMap": {};
            case "groundMap": {};
            default: throw 'Error in SceneSystem.changeSceneTo. There is no scene type "$sceneType" in switch/case!';
        }
    }

    public function getParent():Game{
        return this._parent;
    }

    private function _createBattleScene( sceneID: SceneID, sceneDeployID:SceneDeployID ):Scene{
        var sceneDeployConfig:Dynamic = this._parent.deploy.sceneConfig[ sceneDeployID ];
        var newSceneSprite = new Sprite();
        var sceneType:String = Reflect.getProperty( sceneDeployConfig, "sceneType" );

        var sceneConfig:SceneConfig = {
            ID: sceneID,
            SceneName: "Green plain",
            SceneType: sceneType,
            DeployID: sceneDeployID,
            SceneSprite: newSceneSprite
        }

        var scene:Scene = new Scene( this, sceneConfig );
        var tileMap:Int = Reflect.getProperty( sceneDeployConfig, "tileMap" );
        if( tileMap == 1 ){
            scene.generateTileMap();
        }
        return scene;
    }

    private function _generateSceneId():SceneID{
        this._sceneId++;
        var newSceneID:SceneID = SceneID( this._sceneId );
        return newSceneID;
    }

}