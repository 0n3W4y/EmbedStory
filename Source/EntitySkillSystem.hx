package;

typedef EntitySkillSystemConfig = {

}

class EntitySkillSystem {


    private var _inited:Bool;
    private var _postInited:Bool;
    private var _parent:Entity;


    public function new( parent: Entity, config:EntitySkillSystemConfig ):Void{
        this._parent = parent;


        this._inited = false;
        this._postInited = false;
    }

    public function init():Void{
        var msg:String = this._parent.errMsg();
        msg += 'EntitySkillSystem.init. ';
        if( this._inited )
            throw '$msg. already inited.';


        this._inited = true;
    }

    public function postInit():Void{
        
    }

    public function changeSkillValue( skill:String, value:Int ):Void{
        switch( skill ){
            case "": {
                
            }
            default:
        }
    }

    public function getSkillInt( skill:String ):Int{
        switch( skill ){
            case "matk": {};
            default: throw 'Error in EntitySkillSystem.getSkillInt can not get "$skill"';
        }
        return null;
    }
}