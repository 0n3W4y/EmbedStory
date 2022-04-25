package;

typedef EntityAISystemConfig = {

}

class EntityAISystem{

    private var _parent:Entity;
    private var _inited:Bool;
    private var _postInited:Bool;

    public function new( parent:Entity, config:EntityAISystemConfig ):Void{
        this._parent = parent;
        this._inited = false;
        this._postInited = false;
    }

    public function init():Void{
        var msg:String = this._parent.errMsg();
        msg += 'EntityAISystem.init. ';

        if( this._inited )
            throw '$msg already inited!';

        this._inited = true;
    }

    public function postInited():Void{
        var msg:String = this._parent.errMsg();
        msg += 'EntityAISystem.postInit. ';

        if( this._postInited )
            throw '$msg already inited!';

        this._postInited = true;
    }
}