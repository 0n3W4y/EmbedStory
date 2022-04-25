package;

typedef EntityStatsSystemConfig = {

}

class EntityStatsSystem{

    private var _parent:Entity;
    private var _inited:Bool;
    private var _postInited:Bool;

    public function new( parent:Entity, config:EntityStatsSystemConfig ){
        this._parent = parent;
        this._inited = false;
        this._postInited = false;
    }

    public function init():Void{
        var msg:String = this._parent.errMsg();
        msg += 'EntityStatsSystem.init. ';

        if( this._inited )
            throw '$msg already inited!';

        this._inited = true;
    }

    public function postInit():Void{
        var msg:String = this._parent.errMsg();
        msg += 'EntityStatSystem.postInit. ';

        if( this._postInited )
            throw '$msg already inited!';

        this._postInited = true;
    }
}