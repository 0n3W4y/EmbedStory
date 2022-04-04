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

        this.sceneStorage = new Array<Scene>();
    }

    public function createScene( sceneDeploy:Int ):Scene{
        var newSceneId:SceneID = this._generateSceneId();
        var newSceneDeployID:SceneDeployID = SceneDeployID( sceneDeploy );

        var scene:Scene = null;

        switch( sceneDeploy ){
            case 401: scene = this._createGroundMapScene( newSceneId, newSceneDeployID );
            default: throw 'Error in SceneSystem.createScene. No scene with deploy ID: $sceneDeploy .';
        }

        this.sceneStorage.push( scene );
        return scene;
    }

    public function deleteScene( scene:Scene ):Void{
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

    public function changeSceneTo( scene:Scene ):Void{
        var sceneType:String = scene.sceneType;
        switch( sceneType ){
            case "globalMap":{};
            case "dungeonMap": {};
            case "groundMap": this._changeSceneToGroundMap( scene );
            default: throw 'Error in SceneSystem.changeSceneTo. There is no scene type "$sceneType" in switch/case!';
        }
    }

    private function _changeSceneToGroundMap( scene:Scene ):Void{
        if( this.activeScene == null ){
            this.activeScene = scene;
            scene.show();
        }else{
            //TODO: если сцена "временная". удаляем ее к чертям после того как зайхадим
        }
    }

    public function getParent():Game{
        return this._parent;
    }

    public function loadSceneIDs( value:Int ):Void{
        this._sceneId = value;
    }

    private function _createGroundMapScene( sceneID: SceneID, sceneDeployID:SceneDeployID ):Scene{
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