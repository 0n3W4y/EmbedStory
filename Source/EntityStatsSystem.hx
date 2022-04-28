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

enum MainStats {
    Strength( _:Int ); // сила рукопашной атаки и\или ближний бой урон. + переносимый вес + шанс нокаута в ближнем бою выше
    Dexterity( _:Int ); // общая скорость увеличена + уворот от ближнего боя + обращение с оружием дальнего боя
    Endurance( _:Int ); // HP + сопротивление болезням/ядам + сопротивление боль и споротивление нокауту
    Intellect( _:Int ); // множитель обучения скилам
    MeleeAttack( _:Int );
    RangeAttack( _:Int );
}

enum MainResists {
    KineticResistance( _:Int );
    FireResistance( _:Int );
    ElectricResistance( _:Int );
    PlasmaResistance( _:Int );
    LaserResistance( _:Int );
    PoisonResistance( _:Int );
    KnockdownResistance( _:Int );
    DiseaseResistance( _:Int );
    BleedingResistance( _:Int );
}

class EntityStatsSystem {

    public var strength:MainStats;
    public var dexterity:MainStats;
    public var intellect:MainStats;
    public var endurance:MainStats;
    
    public var meleeAttack:MainStats;
    public var rangeAttack:MainStats;

    public var kineticResistance:MainResists;
    public var fireResistance:MainResists;
    public var electricResistance:MainResists;
    public var plasmaResistance:MainResists;
    public var laserResistance:MainResists;

    public var poisonResistance:MainResists;
    public var knockdownResistance:MainResists;
    public var diseaseResistance:MainResists;
    public var bleedingResistance:MainResists;


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

        if( this._baseStats.STR <= 0 || Math.isNaN( this._baseStats.STR ))
            throw '$msg STR not valid';

        if( this._baseStats.DEX <= 0 || Math.isNaN( this._baseStats.DEX ))
            throw '$msg DEX not valid';

        if( this._baseStats.END <= 0 || Math.isNaN( this._baseStats.END ))
            throw '$msg END not valid';

        if( this._baseStats.INT <= 0 || Math.isNaN( this._baseStats.INT ))
            throw '$msg INT not valid';

        if( this._baseStats.MATK <= 0 || Math.isNaN( this._baseStats.MATK ))
            throw '$msg MATK not valid';

        if( this._baseStats.RATK <= 0 || Math.isNaN( this._baseStats.RATK ))
            throw '$msg RATK not valid';

        if( this._baseStats.KiRes <= 0 || Math.isNaN( this._baseStats.KiRes ))
            throw '$msg Kinetic Res not valid';

        if( this._baseStats.FiRes <= 0 || Math.isNaN( this._baseStats.FiRes ))
            throw '$msg Fire Res not valid';

        if( this._baseStats.ElRes <= 0 || Math.isNaN( this._baseStats.ElRes ))
            throw '$msg Electric Res not valid';

        if( this._baseStats.PlRes <= 0 || Math.isNaN( this._baseStats.PlRes ))
            throw '$msg Plasma Res not valid';

        if( this._baseStats.LaRes <= 0 || Math.isNaN( this._baseStats.LaRes ))
            throw '$msg Laser Res not valid';

        if( this._baseStats.PoRes <= 0 || Math.isNaN( this._baseStats.PoRes ))
            throw '$msg Poison Res not valid';

        if( this._baseStats.KnRes <= 0 || Math.isNaN( this._baseStats.KnRes ))
            throw '$msg Knockdown Res not valid';

        if( this._baseStats.DiRes <= 0 || Math.isNaN( this._baseStats.DiRes ))
            throw '$msg Disease Res not valid';

        if( this._baseStats.BlRes <= 0 || Math.isNaN( this._baseStats.BlRes ))
            throw '$msg Bleeding Res not valid';

        this._inited = true;
    }

    public function postInit():Void{
        var msg:String = this._parent.errMsg();
        msg += 'EntityStatSystem.postInit. ';

        if( this._postInited )
            throw '$msg already inited!';

        this._postInited = true;
    }

    public function canChangeStat( stat:String, value:Int ):Bool{
        var statValue:Int;
        switch( stat ){
            case "str": statValue = this._getStatInt( this.strength );     
            case "int": statValue = this._getStatInt( this.intellect );
            case "dex": statValue = this._getStatInt( this.dexterity );
            case "end": statValue = this._getStatInt( this.endurance );
            case "matk": statValue = this._getStatInt( this.meleeAttack );
            case "ratk": statValue = this._getStatInt( this.rangeAttack );
            case "kinetic": statValue = this._getResistInt( this.kineticResistance );
            case "fire": statValue = this._getResistInt( this.fireResistance );
            case "electric": statValue = this._getResistInt( this.electricResistance );
            case "plasma": statValue = this._getResistInt( this.plasmaResistance );
            case "laser": statValue = this._getResistInt( this.laserResistance );
            case "poison": statValue = this._getResistInt( this.poisonResistance );
            case "knockdown": statValue = this._getResistInt( this.knockdownResistance );
            case "disease": statValue = this._getResistInt( this.diseaseResistance );
            case "bleeding": statValue = this._getResistInt( this.bleedingResistance );
            default: throw 'Error in EntityStatsSystem.canChangeStat. Can not check stat "$stat"';
        }
        if(( statValue + value ) <= 0 )
            return false;
        else
            return true;
    }

    public function changeStat( stat:String, value:Int ):Void {
        if( canChangeStat( stat, value ))
            throw 'Error in EntityStatsSystem.changeStat. Can not change $stat with value: $value; because <= 0';
       
        switch( stat ){
            case "str": {
                var statValue:Int = this._getStatInt( this.strength ) + value;            
                this.strength = Strength( statValue );
            };
            case "int": {
                var statValue:Int = this._getStatInt( this.intellect ) + value;
                this.intellect = Intellect( statValue );
            };
            case "dex": {
                var statValue:Int = this._getStatInt( this.dexterity ) + value;
                this.dexterity = Dexterity( statValue );
            };
            case "end": {
                var statValue:Int = this._getStatInt( this.endurance ) + value;
                this.endurance = Endurance( statValue );
            };
            case "matk": {
                var statValue:Int = this._getStatInt( this.meleeAttack ) + value;
                this.meleeAttack = MeleeAttack( statValue );
            };
            case "ratk": {
                var statValue:Int = this._getStatInt( this.rangeAttack ) + value;
                this.rangeAttack = RangeAttack( statValue );
            };
            case "kinetic": {
                var statValue:Int = this._getResistInt( this.kineticResistance ) + value;
                this.kineticResistance = KineticResistance( statValue );
            };
            case "fire": {
                var statValue:Int = this._getResistInt( this.fireResistance ) + value;
                this.fireResistance = FireResistance( statValue );
            };
            case "electric": {
                var statValue:Int = this._getResistInt( this.electricResistance ) + value;
                this.electricResistance = ElectricResistance( statValue );
            };
            case "plasma": {
                var statValue:Int = this._getResistInt( this.plasmaResistance ) + value;
                this.plasmaResistance = PlasmaResistance( statValue );
            };
            case "laser": {
                var statValue:Int = this._getResistInt( this.laserResistance ) + value;
                this.laserResistance = LaserResistance( statValue );
            };
            case "poison": {
                var statValue:Int = this._getResistInt( this.poisonResistance ) + value;
                this.poisonResistance = PoisonResistance( statValue );
            };
            case "knockdown": {
                var statValue:Int = this._getResistInt( this.knockdownResistance ) + value;
                this.knockdownResistance = KnockdownResistance( statValue );
            };
            case "disease": {
                var statValue:Int = this._getResistInt( this.diseaseResistance ) + value;
                this.diseaseResistance = DiseaseResistance( statValue );
            };
            case "bleeding": {
                var statValue:Int = this._getResistInt( this.bleedingResistance ) + value;
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



    private function _getStatInt( container:MainStats ):Int{
        switch( container ){
            case Strength( v ): return v;
            case Endurance( v ): return v;
            case Intellect( v ): return v;
            case Dexterity( v ): return v;
            case MeleeAttack( v ): return v;
            case RangeAttack( v ): return v;
        }
    }

    private function _getResistInt( container:MainResists ):Int{
        switch( container ){
            case KineticResistance( v ): return v;
            case FireResistance( v ): return v;
            case ElectricResistance( v ): return v;
            case PlasmaResistance( v ): return v;
            case LaserResistance( v ): return v;
            case PoisonResistance( v ): return v;
            case KnockdownResistance( v ): return v;
            case DiseaseResistance( v ): return v;
            case BleedingResistance( v ): return v;
        }
    }
}