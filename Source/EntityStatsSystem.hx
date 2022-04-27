package;


typedef EntityStatsSystemConfig = {
    var STR:Int;
    var END:Int;
    var INT:Int;
    var DEX:Int;
    var MATK:Int;
    var RATK:Int;
    var KiRes:Int;
    var FiRes:Int;
    var ElRes:Int;
    var PlRes:Int;
    var LaRes:Int;
    var PoRes:Int;
    var KnRes:Int;
    var DiRes:Int;
    var BlRes:Int;
}

typedef BaseStats = {
    var STR:Int;
    var END:Int;
    var INT:Int;
    var DEX:Int;
    var MATK:Int;
    var RATK:Int;
    var KiRes:Int;
    var FiRes:Int;
    var ElRes:Int;
    var PlRes:Int;
    var LaRes:Int;
    var PoRes:Int;
    var KnRes:Int;
    var DiRes:Int;
    var BlRes:Int;
}

enum Strength {
    Strength( _:Int ); // сила рукопашной атаки и\или ближний бой урон. + переносимый вес + шанс нокаута в ближнем бою выше
}

enum Dexterity {
    Dexterity( _:Int ); // общая скорость увеличена + уворот от ближнего боя + обращение с оружием дальнего боя
}

enum Endurance {
    Endurance( _:Int ); // HP + сопротивление болезням/ядам + сопротивление боль и споротивление нокауту
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
    KnockdownResistance( _:Int );
}

enum DiseaseResistance {
    DiseaseResistance( _:Int );
}

enum BleedingResistance {
    BleedingResistance( _:Int );
}

enum MeleeAttack {
    MeleeAttack( _:Int );
}

enum RangeAttack {
    RangeAttack( _:Int );
}


class EntityStatsSystem {

    public var strength:Strength;
    public var dexterity:Dexterity;
    public var intellect:Intellect;
    public var endurance:Endurance;
    
    public var meleeAttack:MeleeAttack;
    public var rangeAttack:RangeAttack;

    public var kineticResistance:KineticResistance;
    public var fireResistance:FireResistance;
    public var electricResistance:ElectricResistance;
    public var plasmaResistance:PlasmaResistance;
    public var laserResistance:LaserResistance;

    public var poisonResistance:PoisonResistance;
    public var knockdownResistance:KnockdownResistance;
    public var diseaseResistance:DiseaseResistance;
    public var bleedingResistance:BleedingResistance;


    private var _parent:Entity;
    private var _inited:Bool;
    private var _postInited:Bool;
    private var _baseStats:BaseStats;

    public function new( parent:Entity, config:EntityStatsSystemConfig ){
        this._parent = parent;
        this._inited = false;
        this._postInited = false;

        this.strength = Strength( config.STR );
        this.dexterity = Dexterity( config.DEX );
        this.endurance = Endurance( config.END );
        this.intellect = Intellect( config.INT );
        this.meleeAttack = MeleeAttack( config.MATK );
        this.rangeAttack = RangeAttack( config.RATK );
        
        this.kineticResistance = KineticResistance( config.KiRes );
        this.fireResistance = FireResistance( config.FiRes );
        this.electricResistance = ElectricResistance( config.ElRes );
        this.plasmaResistance = PlasmaResistance( config.PlRes );
        this.laserResistance = LaserResistance( config.LaRes );
        this.poisonResistance = PoisonResistance( config.PoRes );
        this.knockdownResistance = KnockdownResistance( config.KnRes );
        this.diseaseResistance = DiseaseResistance( config.DiRes );
        this.bleedingResistance = BleedingResistance( config.BlRes );

        this._baseStats = { 
            STR: config.STR, DEX: config.DEX, END: config.END, INT: config.INT, 
            MATK: config.MATK, RATK: config.RATK, 
            KiRes: config.KiRes, FiRes: config.FiRes, ElRes: config.ElRes, PlRes: config.PlRes, LaRes: config.LaRes,
            PoRes: config.PoRes, KnRes: config.KnRes, DiRes: config.DiRes, BlRes: config.BlRes 
        };

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

    public function changeStat( stat:String, value:Int ):Void {
        var msg:String = 'Error in EntityStatsSystem.changeStat. Can not change $stat with value: $value; because <= 0';
        switch( stat ){
            case "str": {
                var statValue:Int = switch( this.strength ){ case Strength( v ): v; };
                statValue += value;
                if( statValue <= 0 )
                    throw '$msg';

                this.strength = Strength( statValue );
            };
            case "int": {
                var statValue:Int = switch( this.intellect ){ case Intellect( v ): v; };
                statValue += value;
                if( statValue <= 0 )
                    throw '$msg';

                this.intellect = Intellect( statValue );
            };
            case "dex": {
                var statValue:Int = switch( this.dexterity ){ case Dexterity( v ): v; };
                statValue += value;
                if( statValue <= 0 )
                    throw '$msg';

                this.dexterity = Dexterity( statValue );
            };
            case "end": {
                var statValue:Int = switch( this.endurance ){ case Endurance( v ): v; };
                statValue += value;
                if( statValue <= 0 )
                    throw '$msg';

                this.endurance = Endurance( statValue );
            };
            case "matk": {
                var statValue:Int = switch( this.meleeAttack ){ case MeleeAttack( v ): v; };
                statValue += value;
                if( statValue <= 0 )
                    throw '$msg';

                this.meleeAttack = MeleeAttack( statValue );
            };
            case "ratk": {
                var statValue:Int = switch( this.rangeAttack ){ case RangeAttack( v ): v; };
                statValue += value;
                if( statValue <= 0 )
                    throw '$msg';

                this.rangeAttack = RangeAttack( statValue );
            };
            case "kinetic": {
                var statValue:Int = switch( this.kineticResistance ){ case KineticResistance( v ): v; };
                statValue += value;
                if( statValue <= 0 )
                    throw '$msg';

                this.kineticResistance = KineticResistance( statValue );
            };
            case "fire": {
                var statValue:Int = switch( this.fireResistance ){ case FireResistance( v ): v; };
                statValue += value;
                if( statValue <= 0 )
                    throw '$msg';

                this.fireResistance = FireResistance( statValue );
            };
            case "electric": {
                var statValue:Int = switch( this.electricResistance ){ case ElectricResistance( v ): v; };
                statValue += value;
                if( statValue <= 0 )
                    throw '$msg';

                this.electricResistance = ElectricResistance( statValue );
            };
            case "plasma": {
                var statValue:Int = switch( this.plasmaResistance ){ case PlasmaResistance( v ): v; };
                statValue += value;
                if( statValue <= 0 )
                    throw '$msg';

                this.plasmaResistance = PlasmaResistance( statValue );
            };
            case "laser": {
                var statValue:Int = switch( this.laserResistance ){ case LaserResistance( v ): v; };
                statValue += value;
                if( statValue <= 0 )
                    throw '$msg';

                this.laserResistance = LaserResistance( statValue );
            };
            case "poison": {
                var statValue:Int = switch( this.poisonResistance ){ case PoisonResistance( v ): v; };
                statValue += value;
                if( statValue <= 0 )
                    throw '$msg';

                this.poisonResistance = PoisonResistance( statValue );
            };
            case "knockdown": {
                var statValue:Int = switch( this.knockdownResistance ){ case KnockdownResistance( v ): v; };
                statValue += value;
                if( statValue <= 0 )
                    throw '$msg';

                this.knockdownResistance = KnockdownResistance( statValue );
            };
            case "disease": {
                var statValue:Int = switch( this.diseaseResistance ){ case DiseaseResistance( v ): v; };
                statValue += value;
                if( statValue <= 0 )
                    throw '$msg';

                this.diseaseResistance = DiseaseResistance( statValue );
            };
            case "bleeding": {
                var statValue:Int = switch( this.bleedingResistance ){ case BleedingResistance( v ): v; };
                statValue += value;
                if( statValue <= 0 )
                    throw '$msg';

                this.bleedingResistance = BleedingResistance( statValue );
            };
            default: throw 'Error in EntityStatsSystem.changeStat. Can not set stat "$stat"';
        }
        //TODO change dependencies;
    }

    public function getBaseStat( stat:String ):Int{
        switch( stat ){
            case "str": return this._baseStats.STR;
            case "int": return this._baseStats.INT;
            case "dex": return this._baseStats.DEX;
            case "end": return this._baseStats.END;
            case "matk": return this._baseStats.MATK;
            case "ratk": return this._baseStats.RATK;
            case "kinetic": return this._baseStats.KiRes;
            case "fire": return this._baseStats.FiRes;
            case "electric": return this._baseStats.ElRes;
            case "plasma": return this._baseStats.PlRes;
            case "laser": return this._baseStats.LaRes;
            case "poison": return this._baseStats.PoRes;
            case "knockdown": return this._baseStats.KnRes;
            case "disease": return this._baseStats.DiRes;
            case "bleeding": return this._baseStats.BlRes;
            default: throw 'Error in EntityStatsSystem.getBaseStat. can not get stats "$stat"';
        }
    }
}