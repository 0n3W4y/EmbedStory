package;

typedef SceneEvent = {
    var EventType:String;
    var CurrentTime:Int;
    var ActionTime:Int;
    var Scene:Scene;
}

class GameEventSystem{

    private var _parent:Game;
    private var _sceneEvents:Array<SceneEvent>;
    private var _sceneEventsQueue:Array<SceneEvent>;
    private var _showSceneTime:Int = 2000; // ~ 2 seconds;
    private var _hideSceneTime:Int = 2000; // ~ 2 seconds;

    public function new( parent:Game ):Void{
        this._parent = parent;
    }

    public function update( time:Int ):Void{
        this._updateSceneEvent( this._sceneEventsQueue[ 0 ] ); // Апдейт очереди ивентов. Апдейтится всегда 1-й ивент, потом удаляется.
        for( i in 0...this._sceneEvents.length ){
            var event:SceneEvent = this._sceneEvents[ i ];
            this._updateSceneEvent( event );
        }

    }

    public function createChangeSceneEvent( eventType:String, oldScene:Scene, newScene:Scene ):Void{
        switch( eventType ){
            case "hideSceneAndShowNext":{
                this._sceneEventsQueue.push({ EventType: "hide", CurrentTime: 0, ActionTime: this._hideSceneTime, Scene: oldScene });
                this._sceneEventsQueue.push({ EventType: "show", CurrentTime: 0, ActionTime: this._showSceneTime, Scene: newScene });
                //TODO: we can use Loader :)
            }
            default: throw 'Error in GameEventSystem.createChangeSceneEvent. There is no event with type "$eventType".';
        }
    }



    private function _updateSceneEvent( event:SceneEvent ):Void{
        var eventType:String = event.EventType;
        switch( eventType ){
            case "show":{};
            case "hide":{};
            default: throw 'Error in GameEventSystem._updateSceneEvent. There is no event with type "$eventType".';
        }
    }

    private function _showScene( event:SceneEvent ):Void{
        var numberToIncreaseAlpha:Float =  time / this.showHideTime;
        this.sceneGraphics.alpha += numberToIncreaseAlpha;
        if( this.sceneGraphics.alpha >= 1.0 ){
            this.sceneGraphics.alpha = 1.0;
            this.isShowing = false;
            this.isShow = true;
            // UI.graphics.visible = true;
        }
    }

    private function _hideScene( event:SceneEvent ):Void{
        var numberToDecreaseAlpha:Float =  time / this._hideSceneTime;
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