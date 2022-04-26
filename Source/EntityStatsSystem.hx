package;

typedef EntityStatsSystemConfig = {

}

enum Strength {
    Strength( _:Int ); // сила рукопашной атаки и\или ближний бой урон. + переносимый вес + сопротивление нокауту
}

enum Dexterity {
    Dexterity( _:Int ); // общая скорость передвижения + уворот от ближнего боя + обращение с оружием дальнего боя
}

enum Endurance {
    Endurance( _:Int ); // HP + сопротивление болезням/ядам + сопротивление больи
}

enum Intellect {
    Intellect( _:Int ); // множитель обучения скилам
}

enum KineticResistance {
    KineticResistance( _:Int );
}

enum FireResistance {
    FireResistance( _:Int );
}

enum ElectricResistance {
    ElectricResistance( _:Int );
}

enum PlasmaResistance {
    PlasmaResistance( _:Int );
}

enum LaserResistance {
    LaserResistance( _:Int );
}

enum PoisonResistance {
    PoisonResistance( _:Int );
}

enum KnockdownResistance {
    KnockdaownResistance( _:Int );
}

enum DiseaseResistance {
    DesiaseResistance( _:Int );
}

enum BleedingResistance {
    BleedingResistance( _:Int );
}


typedef BaseStats = {
    var STR: Strength;
    var DEX: Dexterity;
    var END: Endurance;
    var INT: Intellect;
}

typedef BaseResistance = {
    var Kinetic: KineticResistance;
    var Fire: FireResistance;
    var Electric: ElectricResistance;
    var Plasma: PlasmaResistance;
    var Laser: LaserResistance;
}

typedef ExtraResistance = {
    var Poison: PoisonResistance;
    var Knockdown: KnockdownResistance;
    var Disease: DiseaseResistance;
    var Bleeding: BleedingResistance;
}

class EntityStatsSystem {

    public var baseStats:BaseStats;
    public var baseResistance:BaseResistance;

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