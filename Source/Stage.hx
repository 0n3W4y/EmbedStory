package;

class Stage{

    public var nextScene:Scene;
    private var _parent:Game;

    public function new( parent:Game ):Void {
        this._parent = parent;
    }

    public function changeSceneTo( scene:Scene ):Void{
        var eventSystem:GameEventSystem = this._parent.gameEventSystem;
        var sceneType:String = scene.sceneType;
        var activeScene:Scene = this._parent.sceneSystem.activeScene;
        if( scene.prepared ){
            this.switchSceneTo( scene );
            return;
        }

        this._parent.ui.hide();
        //TODO: check for loader scene; create it
        var loaderScene:Scene = this._parent.sceneSystem.getSceneByDeployID( SceneDeployID( 400 ) );
        if( loaderScene == null ){
            loaderScene = this._parent.sceneSystem.createScene( 400 );
            loaderScene.prepare();
        }

        switch( sceneType ){
            case "globalMap":{};
            case "undergroundMap": {};
            case "groundMap": {
                if( activeScene != null ){
                    eventSystem.createQueSceneEvent( "hide", activeScene );
                    eventSystem.createQueSceneEvent( "show", loaderScene );
                    eventSystem.createQueSceneEvent( "doLoader", loaderScene );
                    this.nextScene = scene;
                    eventSystem.createQueSceneEvent( "hide", loaderScene );
                    eventSystem.createQueSceneEvent( "show", scene );
                }
            }
            default: throw 'Error in SceneSystem.changeSceneTo. There is no scene type "$sceneType" in it';
        }
    }

    public function switchSceneTo( scene:Scene ):Void{
        var eventSystem:GameEventSystem = this._parent.gameEventSystem;
        var activeScene:Scene = this._parent.sceneSystem.activeScene;
        if( activeScene == null )
            eventSystem.createQueSceneEvent( "show", scene );
        else{
            eventSystem.createQueSceneEvent( "hide", activeScene );
            eventSystem.createQueSceneEvent( "show", scene );
        }
    }

}