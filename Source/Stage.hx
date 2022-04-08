package;

class Stage{

    private var _parent:Game;

    public function new( parent:Game ):Void {
        this._parent = parent;
    }

    public function changeSceneTo( scene:Scene ):Void{
        var sceneType:String = scene.sceneType;
        var activeScene:Scene = this._parent.sceneSystem.activeScene;
        switch( sceneType ){
            case "globalMap":{};
            case "dungeonMap": {};
            case "groundMap": this._parent.gameEventSystem.createChangeSceneEvent( "hideSceneAndShowNext", activeScene, scene );
            default: throw 'Error in SceneSystem.changeSceneTo. There is no scene type "$sceneType" in it';
        }
    }

}