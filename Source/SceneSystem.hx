package;

import Scene;

class SceneSystem {

    private var _sceneId:Int;
    private var _parent:Game;

    public function new():Void{

    }

    public function createScene( sceneName:String ):Scene{
        var newSceneId:SceneID = this._generateSceneId();
        var sceneConfig:SceneConfig = {
            ID: newSceneId
        }

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