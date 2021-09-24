package;

enum SceneID {
    SceneID( _:Int );
}

typedef SceneConfig = {
    var ID:SceneID;
    var Parent:SceneSystem;
}

class Scene {
    public var tileMap:TileMap;

    private var _sceneId:SceneID;
    private var _parent:SceneSystem;

    public function new( params:SceneConfig ):Void{
        
    }

    public function getParent():SceneSystem{
        return this._parent;
    }
}