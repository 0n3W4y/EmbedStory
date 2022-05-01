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
    var PaRes:Int;
}

typedef BaseStats = {
    var Strength:Int;
    var Endurance:Int;
    var Intellect:Int;
    var Dexterity:Int;
    var MAttack:Int;
    var RAttack:Int;
    var Pain:Int;
    var KineticRes:Int;
    var FireRes:Int;
    var ElectricRes:Int;
    var PlasmaRes:Int;
    var LaserRes:Int;
    var PoisonRes:Int;
    var KnockdownRes:Int;
    var DiseaseRes:Int;
    var BleedingRes:Int;
    var PainRes:Int;
}

enum MainStats {
    Strength( _:Int ); // сила рукопашной атаки и\или ближний бой урон. + переносимый вес + шанс нокаута в ближнем бою выше, сопротивление нокауту
    Dexterity( _:Int ); // общая скорость увеличена + уворот от ближнего боя + обращение с оружием дальнего боя
    Endurance( _:Int ); // HP + сопротивление болезням/ядам + сопротивление боль и уменьшение времени нахождения в нокауте.
    Intellect( _:Int ); // множитель обучения скилам
    MeleeAttack( _:Int ); // str + str/5;
    RangeAttack( _:Int ); // dex + int/4;
    Pain( _:Int ); // боль. при росте боли, уменьшаем все статы. чем больше боль, тем ниже статы. максимаьное значение 1000;
}

enum MainResists {
    KineticResistance( _:Int ); // str*2 + str/2;
    FireResistance( _:Int ); // end/2;
    ElectricResistance( _:Int ); // end/2 + str/4;
    PlasmaResistance( _:Int ); //end/4 + str/4;
    LaserResistance( _:Int ); // end/4 + str/4;
    PoisonResistance( _:Int ); // end*2
    KnockdownResistance( _:Int ); // str*2 + str/5
    DiseaseResistance( _:Int ); // end*2
    BleedingResistance( _:Int ); // end*2
    PainResistance( _:Int ); // str*2 + end;
}

class EntityStatsSystem {

    public var strength:MainStats;
    public var dexterity:MainStats;
    public var intellect:MainStats;
    public var endurance:MainStats;
    
    public var meleeAttack:MainStats;
    public var rangeAttack:MainStats;

    public var pain:MainStats;

    public var kineticResistance:MainResists;
    public var fireResistance:MainResists;
    public var electricResistance:MainResists;
    public var plasmaResistance:MainResists;
    public var laserResistance:MainResists;

    public var poisonResistance:MainResists;
    public var knockdownResistance:MainResists;
    public var diseaseResistance:MainResists;
    public var bleedingResistance:MainResists;
    public var painResistance:MainResists;


    private var _parent:Entity;
    private var _inited:Bool;
    private var _postInited:Bool;
    private var _baseStats:BaseStats;
    private var _maxValueForResistance:Int;

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

        this.pain = Pain( 0 );
        
        this.kineticResistance = KineticResistance( config.KiRes );
        this.fireResistance = FireResistance( config.FiRes );
        this.electricResistance = ElectricResistance( config.ElRes );
        this.plasmaResistance = PlasmaResistance( config.PlRes );
        this.laserResistance = LaserResistance( config.LaRes );
        this.poisonResistance = PoisonResistance( config.PoRes );
        this.knockdownResistance = KnockdownResistance( config.KnRes );
        this.diseaseResistance = DiseaseResistance( config.DiRes );
        this.bleedingResistance = BleedingResistance( config.BlRes );
        this.painResistance = PainResistance( config.PaRes );

        this._baseStats = { 
            Strength: config.STR,
            Dexterity: config.DEX,
            Endurance: config.END,
            Intellect: config.INT,
            MAttack: config.MATK,
            RAttack: config.RATK,
            Pain: 1000,
            KineticRes: config.KiRes,
            FireRes: config.FiRes,
            ElectricRes: config.ElRes,
            PlasmaRes: config.PlRes,
            LaserRes: config.LaRes,
            PoisonRes: config.PoRes,
            KnockdownRes: config.KnRes,
            DiseaseRes: config.DiRes,
            BleedingRes: config.BlRes,
            PainRes: config.PaRes
        };

        this._maxValueForResistance = 100;

    }

    public function init():Void{
        var msg:String = this._parent.errMsg();
        msg += 'EntityStatsSystem.init. ';

        if( this._inited )
            throw '$msg already inited!';

        if( this._baseStats.Strength <= 0 || Math.isNaN( this._baseStats.Strength ))
            throw '$msg STR not valid';

        if( this._baseStats.Dexterity <= 0 || Math.isNaN( this._baseStats.Dexterity ))
            throw '$msg DEX not valid';

        if( this._baseStats.Endurance <= 0 || Math.isNaN( this._baseStats.Endurance ))
            throw '$msg END not valid';

        if( this._baseStats.Intellect <= 0 || Math.isNaN( this._baseStats.Intellect ))
            throw '$msg INT not valid';

        if( this._baseStats.MAttack <= 0 || Math.isNaN( this._baseStats.MAttack ))
            throw '$msg MATK not valid';

        if( this._baseStats.RAttack <= 0 || Math.isNaN( this._baseStats.RAttack ))
            throw '$msg RATK not valid';

        if( this._baseStats.Pain < 0 || Math.isNaN( this._baseStats.Pain ))
            throw '$msg Pain not valid';

        if( this._baseStats.KineticRes < 0 || Math.isNaN( this._baseStats.KineticRes ))
            throw '$msg Kinetic Res not valid';

        if( this._baseStats.FireRes < 0 || Math.isNaN( this._baseStats.FireRes ))
            throw '$msg Fire Res not valid';

        if( this._baseStats.ElectricRes < 0 || Math.isNaN( this._baseStats.ElectricRes ))
            throw '$msg Electric Res not valid';

        if( this._baseStats.PlasmaRes < 0 || Math.isNaN( this._baseStats.PlasmaRes ))
            throw '$msg Plasma Res not valid';

        if( this._baseStats.LaserRes < 0 || Math.isNaN( this._baseStats.LaserRes ))
            throw '$msg Laser Res not valid';

        if( this._baseStats.PoisonRes < 0 || Math.isNaN( this._baseStats.PoisonRes ))
            throw '$msg Poison Res not valid';

        if( this._baseStats.KnockdownRes < 0 || Math.isNaN( this._baseStats.KnockdownRes ))
            throw '$msg Knockdown Res not valid';

        if( this._baseStats.DiseaseRes < 0 || Math.isNaN( this._baseStats.DiseaseRes ))
            throw '$msg Disease Res not valid';

        if( this._baseStats.BleedingRes < 0 || Math.isNaN( this._baseStats.BleedingRes ))
            throw '$msg Bleeding Res not valid';

        if( this._baseStats.PainRes < 0 || Math.isNaN( this._baseStats.PainRes ))
            throw '$msg Pain Res not valid';

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
            case "painRes": statValue = this._getResistInt( this.painResistance );
            default: throw 'Error in EntityStatsSystem.canChangeStat. Can not check stat "$stat"';
        }
        if(( statValue + value ) <= 0 )
            return false;
        else
            return true;
    }

    public function changeStat( stat:String, value:Int ):Bool {
        if( canChangeStat( stat, value ))
            return false;
       
        switch( stat ){
            case "str": {
                // от силы зависит: ближний бой. переносимый вес. шанс нокаута в ближнем бою, шанс получить нокаут;
                var statValue:Int = this._getStatInt( this.strength ) + value;          
                this.strength = Strength( statValue );
                this.meleeAttack = MeleeAttack( this._calculateStat( "matk" )); // ближний бой;
                this.knockdownResistance = KnockdownResistance( this._calculateStat( "knRes" )); // сопротивление нокауту.
                this.painResistance = PainResistance( this._calculateStat( "painRes" )); // сопротивление боли.
                //переносимый вес в инвентаре
                //шанс нокаута в скилах
                
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
            case "painRes": {
                var statValue:Int = this._getResistInt( this.painResistance ) + value;
                this.painResistance = PainResistance( statValue );
            }
            default: throw 'Error in EntityStatsSystem.changeStat. Can not set stat "$stat"';
        }
        return true;
    }

    public function getBaseStat( stat:String ):Int{
        switch( stat ){
            case "str": return this._baseStats.Strength;
            case "int": return this._baseStats.Intellect;
            case "dex": return this._baseStats.Dexterity;
            case "end": return this._baseStats.Endurance;
            case "matk": return this._baseStats.MAttack;
            case "ratk": return this._baseStats.RAttack;
            case "pain": return this._baseStats.Pain;            
            default: throw 'Error in EntityStatsSystem.getBaseStat. can not get stats "$stat"';
        }
    }

    public function getBaseResist( resist:String ):Int{
        switch( resist ){
            case "kinetic": return this._baseStats.KineticRes;
            case "fire": return this._baseStats.FireRes;
            case "electric": return this._baseStats.ElectricRes;
            case "plasma": return this._baseStats.PlasmaRes;
            case "laser": return this._baseStats.LaserRes;
            case "poison": return this._baseStats.PoisonRes;
            case "knockdown": return this._baseStats.KnockdownRes;
            case "disease": return this._baseStats.DiseaseRes;
            case "bleeding": return this._baseStats.BleedingRes;
            case "painRes": return this._baseStats.PainRes;
            default: throw 'Error in EntityStatsSystem.getBaseResist. can not get stats "$resist"';
        }
    }

    public function increasePain( value:Int ) {
        var currentValue:Int = this._getStatInt( this.pain );
        var maxValue:Int = this.getBaseStat( "pain" );
        if( currentValue > maxValue )
            return;

        currentValue += value;
        if( currentValue > maxValue ){
            this.pain = Pain( maxValue );
            //knockdownEntity;
        }else
            this.pain = Pain( currentValue );

        if( currentValue%100 == 0 ){
            this.changeStat( "str", -1 );
            this.changeStat( "end", -1 );
            this.changeStat( "int", -1 );
            this.changeStat( "dex", -1 );
        }
        
    }

    public function decreasePain( value:Int ){
        var currentValue:Int = this._getStatInt( this.pain );
        if( currentValue == 0 )
            return ;

        currentValue -= value;
        if( currentValue < 0 )
            this.pain = Pain( 0 );
        else
            this.pain = Pain( currentValue );

        if( currentValue%100 == 0 ){
            //увеличиваем статы, когда боль спадает.
            this.changeStat( "str", 1 );
            this.changeStat( "end", 1 );
            this.changeStat( "int", 1 );
            this.changeStat( "dex", 1 );
        }
    }


    private function _calculateStat( stat:String ):Int{
        var value:Int = -1;
        switch( stat ){
            case "matk":{
                // Урон в ближнем бою рассчитывается по формуле base melee attack + str + str/5 + inventoryItems;
                var mATKBaseStat = this._baseStats.MAttack;
                var strValue:Int = this._getStatInt( this.strength );
                var mATKFromInventory:Int = 0;
                if( this._parent.inventory != null ){
                    //TODO: collectStatsFromInventory;
                }

                value = mATKBaseStat + strValue + Math.round( strValue/5 ) + mATKFromInventory;
            }
            case "knRes":{
                // Споротивление нокауту рассчитывается по формуле base knockdown resist + str*2 + str/2 + inv;
                var knResBaseStat:Int = this._baseStats.KnockdownRes;
                var strValue:Int = this._getStatInt( this.strength );
                var knResFromInventory:Int = 0;
                if( this._parent.inventory != null ){
                    //TODO: collectStatsFromInventory;
                }

                value = knResBaseStat + strValue * 2 + Math.round( strValue/2 ) + knResFromInventory;
                if( value > _maxValueForResistance )
                    value = 100;
            }
            case "painRes":{
                //сопротивление боли рассчитывается по формуле base stat + str*2 + end + inventory;
                var paResBaseStat:Int = this._baseStats.PainRes;
                var strValue:Int = this._getStatInt( this.strength );
                var endValue:Int = this._getStatInt( this.endurance );
                var paResFromInventory:Int = 0;
                if( this._parent.inventory != null ){

                }

                value = paResBaseStat + strValue * 2 + endValue + paResFromInventory;
                if( value > this._maxValueForResistance )
                    value = 100;
            }
        }

        if( value == -1 )
            throw 'Error in EntityStatSystem._calculateStat. Can not calculate "$stat".';

        return value;
    }

    private function _getStatInt( container:MainStats ):Int{
        switch( container ){
            case Strength( v ): return v;
            case Endurance( v ): return v;
            case Intellect( v ): return v;
            case Dexterity( v ): return v;
            case MeleeAttack( v ): return v;
            case RangeAttack( v ): return v;
            case Pain( v ): return v;
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
            case PainResistance( v ): return v;
        }
    }
}