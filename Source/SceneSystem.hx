package;

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
        var newSceneDeployID:SceneDeployID = SceneDeployID( sceneDeploy );
        var newSceneId:SceneID = this._generateSceneId();
        var newSceneSprite = new Sprite();
        //var sceneName:String = "Green plane";
        var sceneDeployConfig:Dynamic = this._parent.deploy.sceneConfig[ newSceneDeployID ];
        trace( sceneDeployConfig );
    /*    var sceneType:String = sceneDeployConfig[ "sceneType" ];
        var sceneConfig:SceneConfig = {
            ID: newSceneId,
            SceneName: null,
            SceneType: sceneType,
            DeployID: sceneDeployID,
            SceneSprite: newSceneSprite
        }

        var scene:Scene = new Scene( this, sceneConfig );
        this.sceneStorage.push( scene );
        return scene;
    */
    return null;
    }

    public function deleteScene( scene:Scene ):Void{

    }

    public function getParent():Game{
        return this._parent;
    }

    private function _generateSceneId():SceneID{
        this._sceneId++;
        return SceneID( this._sceneId );
    }

}