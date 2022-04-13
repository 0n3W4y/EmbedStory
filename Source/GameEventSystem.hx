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
        this._sceneEvents = [];
        this._sceneEventsQueue = [];
    }

    public function update( time:Int ):Void{
        if( this._sceneEventsQueue.length > 1 )
            this._updateSceneEvent( time, this._sceneEventsQueue[ 0 ] ); // Апдейт очереди ивентов. Апдейтится всегда 1-й ивент, потом удаляется.

        for( i in 0...this._sceneEvents.length ){
            var event:SceneEvent = this._sceneEvents[ i ];
            this._updateSceneEvent( time, event );
        }

    }

    public function createQueSceneEvent( eventType:String, scene:Scene ):Void{
        var actionTime:Int = 0;
        switch( eventType ){
            case "show":{
                scene.sceneGraphics.visible = true;

                if( scene.sceneType != "loader" )
                    actionTime = this._showSceneTime;

                this._sceneEventsQueue.push({ EventType: "show", CurrentTime: 0, ActionTime: actionTime, Scene: scene });
            }
            case "hide":{
                actionTime = this._hideSceneTime;
                this._sceneEventsQueue.push({ EventType: "hide", CurrentTime: 0, ActionTime: actionTime, Scene: scene });
            }
            case "doLoader":{
                this._sceneEventsQueue.push({ EventType: "doLoader", CurrentTime: 0, ActionTime: 1000, Scene: scene });
            }
            default: throw 'Error in GameEventSystem.createChangeSceneEvent. There is no event with type "$eventType".';
        }
    }



    private function _updateSceneEvent( time:Int, event:SceneEvent ):Void{
        var eventType:String = event.EventType;
        event.CurrentTime += time;
        var value:Float = 1.0;
        switch( eventType ){
            case "show": {
                if( event.ActionTime != 0 )
                    value = event.CurrentTime / event.ActionTime;

                this._showScene( value, event );
            }
            case "hide": {
                if( event.ActionTime != 0 )
                    value = event.CurrentTime / event.ActionTime;

                this._hideScene( value, event );
            }
            case "doLoader":{
                this._doLoader( event );
            }
            default: throw 'Error in GameEventSystem._updateSceneEvent. There is no event with type "$eventType".';
        }
    }

    private function _doLoader( event:SceneEvent ):Void{
        if( event.CurrentTime >= event.ActionTime ){
            var scene:Scene = this._parent.stage.nextScene;
            if( scene == null )
                throw 'Error in GameEventSystem._doLoader. Next scene from stage is NULL!';

            scene.prepare();
            this._parent.stage.nextScene = null;
            this._endQueSceneEvent();
            trace( 'doloader()');
        }
    }

    private function _showScene( value:Float, event:SceneEvent ):Void{
        event.Scene.sceneGraphics.alpha += value;
        if( event.Scene.sceneGraphics.alpha >= 1.0 ){
            event.Scene.sceneGraphics.alpha = 1.0;
            event.Scene.show();
            this._endQueSceneEvent();
        }
    }

    private function _hideScene( value:Float, event:SceneEvent ):Void{
        event.Scene.sceneGraphics.alpha -= value;
        if( event.Scene.sceneGraphics.alpha <= 0 ){
            event.Scene.sceneGraphics.alpha = 0.0;
            event.Scene.hide();
            this._endQueSceneEvent();
        } 
    }

    private function _endQueSceneEvent():Void{
        this._sceneEventsQueue.splice( 0, 1 ); // delete first index from array of que events
    }
}