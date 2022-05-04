package;

typedef EntitySkillSystemConfig = {

}

enum Speed {
    Movement( _:Int );
    WeaponReload( _:Int );
    MeleeAttack( _:Int );
}

enum Attack {
    Melee( _:Int ); // str + str/5;
    Range( _:Int ); // dex + int/4;
}

class EntitySkillSystem {

    //speed;
    public var movementSpeed:Speed;
    public var weaponReloadSpeed:Speed;
    public var meleeAttackSpeed:Speed;
    public var rangeAttackSpeed:Speed;

    //attack;
    public var meleeAttack:Attack;
    public var rangeAttack:Attack;

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

        if( this._baseStats.MAttack <= 0 || Math.isNaN( this._baseStats.MAttack ))
            throw '$msg MATK not valid';

        if( this._baseStats.RAttack <= 0 || Math.isNaN( this._baseStats.RAttack ))
            throw '$msg RATK not valid';

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