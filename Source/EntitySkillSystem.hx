package;

typedef EntitySkillSystemConfig = {

}

enum Speed {
    MeleeAttack( _:Int );
    RangeAttack( _:Int );
}

class EntitySkillSystem {

    //speed;
    public var meleeAttackSpeed:Speed; // weaponspeed - (multiplier*weaponspeed/4); multiplier = 0.0004*meleeAttackSpeed-2; [-2;+2];
    public var rangeAttackSpeed:Speed;

    public var evade:Int;
    public var block:Int;



    //special;
    public var skillGrowupMultiplier:Int; // множитель для увелечения скилов, зависит от INT. ( формула int/3 );

    private var _inited:Bool;
    private var _postInited:Bool;
    private var _parent:Entity;

    private var _maxValueForSkill:Int = 10000;


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

    public function increaseSkillExperience( skill:String, value:Int ):Void{
        //this.skillGrowupMultiplier;
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