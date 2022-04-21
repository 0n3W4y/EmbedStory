package;

import openfl.display.Sprite;
import Scene;
import haxe.EnumTools.EnumValueTools;

class SceneSystem {

    public var sceneSprite:Sprite;
    public var sceneStorage:Array<Scene>;
    public var activeScene:Scene;

    private var _sceneId:Int;
    private var _parent:Game;

    public function new( parent:Game, sceneSprite:Sprite ):Void{
        this._parent = parent;
        this.sceneSprite = sceneSprite;
        this.activeScene = null;

        this._sceneId = 0;

        this.sceneStorage = new Array<Scene>();
    }

    public function createScene( sceneDeploy:Int ):Scene{
        var sceneID:SceneID = this._generateSceneId();
        var sceneDeployID:SceneDeployID = SceneDeployID( sceneDeploy );
        var sceneDeployConfig:Dynamic = this._parent.deploy.sceneConfig[ sceneDeployID ];
        var newSceneSprite = new Sprite();
        var sceneType:String = Reflect.getProperty( sceneDeployConfig, "sceneType" );
        var sceneName:String = Reflect.getProperty( sceneDeployConfig, "name" );

        var sceneConfig:SceneConfig = {
            ID: sceneID,
            SceneName: sceneName,
            SceneType: sceneType,
            DeployID: sceneDeployID,
            SceneSprite: newSceneSprite
        }

        var scene:Scene = new Scene( this, sceneConfig );

        switch( sceneDeploy ){
            case 400: scene = this._createLoader( scene ); // loader
            case 401: scene = this._createGameStartScene( scene ); // Scene when game start;
            case 403: scene = this._createGroundMapScene( scene );
            default: throw 'Error in SceneSystem.createScene. No scene with deploy ID: $sceneDeploy .';
        }

        this.sceneStorage.push( scene );
        this.sceneSprite.addChild( scene.sceneGraphics );
        return scene;
    }

    public function deleteScene( scene:Scene ):Void{

        //TODO: check scene status;
        var sceneId:SceneID = scene.getSceneID();
        var index:Int = null;
        for( i in 0...this.sceneStorage.length ){
            var storagedScene:Scene = this.sceneStorage[ i ];
            var storagedSceneId:SceneID = storagedScene.getSceneID();
            if( EnumValueTools.equals( sceneId, storagedSceneId )){
                index = i;
                break;
            }
        }

        if( index == null )
            throw 'Error in SceneSystem.deleteScene. Can not find scene with scene ID "$sceneId" in sce estorage.';

        this.sceneStorage.splice( index, 1 ); // удаляет сцену раз и навсегда и все ее объекты.
    }

    public function getParent():Game{
        return this._parent;
    }

    public function getSceneByDeployID( ID:SceneDeployID ):Scene {
        var scene:Scene = null;
        for( i in 0...this.sceneStorage.length ){
            scene = this.sceneStorage[ i ];
            var sceneDeployID:SceneDeployID = scene.getSceneDeployID();
            if( EnumValueTools.equals( ID, sceneDeployID ))
                break;    
        }
        trace( scene );
        return scene;
    }

    public function loadScenesID( value:Int ):Void{
        this._sceneId = value;
    }

    public function update( time:Int ):Void{
        for( i in 0...this.sceneStorage.length ){
            this.sceneStorage[ i ].update( time );
        }
    }



    

    private function _createGroundMapScene( scene:Scene ):Scene{
        return scene;
    }

    private function _createLoader( scene:Scene ):Scene{
        return scene;
    }

    private function _createGameStartScene( scene:Scene ):Scene{
        return scene;
    }

    private function _generateSceneId():SceneID{
        this._sceneId++;
        var newSceneID:SceneID = SceneID( this._sceneId );
        return newSceneID;
    }

}