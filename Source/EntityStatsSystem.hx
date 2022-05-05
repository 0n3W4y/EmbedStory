package;

typedef EntityStatsSystemConfig = {
    var STR:Int;
    var END:Int;
    var INT:Int;
    var DEX:Int;
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
    var MATK:Int;
    var RATK:Int;
    var MoveSPD:Int;
}

typedef BaseStats = {
    var Strength:Int;
    var Endurance:Int;
    var Intellect:Int;
    var Dexterity:Int;
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
    var MeleeAttack:Int;
    var RangeAttack:Int;
    var MovementSpeed:Int;
}

enum MainStats {
    Strength( _:Int ); // сила рукопашной атаки и\или ближний бой урон. + переносимый вес + шанс нокаута в ближнем бою выше, сопротивление нокауту
    Dexterity( _:Int ); // общая скорость увеличена + уворот от ближнего боя + обращение с оружием дальнего боя
    Endurance( _:Int ); // HP + сопротивление болезням/ядам + сопротивление боль и уменьшение времени нахождения в нокауте.
    Intellect( _:Int ); // множитель обучения скилам
    
}

enum ExtraStats {
    MovementSpeed( _:Int ); // dex*15;
    MeleeDamage( _:Int ); // str + str/4;
    RangeDamage( _:Int ); // dex/2 + int/2;
}

enum Pain {
    Pain( _:Int ); // боль. при росте боли, уменьшаем все статы. чем больше боль, тем ниже статы. максимаьное значение 1000;
}

enum MainResists {
    Kinetic( _:Int );
    Fire( _:Int );
    Electric( _:Int );
    Plasma( _:Int );
    Laser( _:Int );
    Poison( _:Int ); // end*2
    Knockdown( _:Int ); // str*2 + str/5
    Disease( _:Int ); // end*2
    Bleeding( _:Int ); // end*2
    Pain( _:Int ); // str*2 + end;
}

class EntityStatsSystem {

    public var strength:MainStats;
    public var dexterity:MainStats;
    public var intellect:MainStats;
    public var endurance:MainStats;

    
    public var pain:Pain;

    public var movementSpeed:ExtraStats;
    public var meleeDamage:ExtraStats;
    public var rangeDamage:ExtraStats;

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
    private var _inited:Bool = false;
    private var _postInited:Bool= false;
    private var _baseStats:BaseStats;
    private var _resistanceMaxValue:Int = 95;
    private var _statsMaxValue:Int = 30;
    private var _painMaxValue:Int = 1000;

    public function new( parent:Entity, config:EntityStatsSystemConfig ){
        this._parent = parent;

        this.strength = Strength( config.STR );
        this.dexterity = Dexterity( config.DEX );
        this.endurance = Endurance( config.END );
        this.intellect = Intellect( config.INT );

        this.pain = Pain( 0 );
        
        this._baseStats = { 
            Strength: config.STR,
            Dexterity: config.DEX,
            Endurance: config.END,
            Intellect: config.INT,
            KineticRes: config.KiRes,
            FireRes: config.FiRes,
            ElectricRes: config.ElRes,
            PlasmaRes: config.PlRes,
            LaserRes: config.LaRes,
            PoisonRes: config.PoRes,
            KnockdownRes: config.KnRes,
            DiseaseRes: config.DiRes,
            BleedingRes: config.BlRes,
            PainRes: config.PaRes,
            MeleeAttack: config.MATK,
            RangeAttack: config.RATK,
            MovementSpeed: config.MoveSPD
        };

        this.kineticResistance = Kinetic( config.KiRes );
        this.fireResistance = Fire( config.FiRes );
        this.electricResistance = Electric( config.ElRes );
        this.plasmaResistance = Plasma( config.PlRes );
        this.laserResistance = Laser( config.LaRes );
        this.poisonResistance = Poison( this._calculateResist( "poisonRes" ));
        this.knockdownResistance = Knockdown( this._calculateResist( "knockdownRes" ));
        this.diseaseResistance = Disease( this._calculateResist( "diseaseRes" ));
        this.bleedingResistance = Bleeding( this._calculateResist( "bleedingRes" ));
        this.painResistance = Pain( this._calculateResist( "painRes" ));
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
        var statValue:Int = this._getStatInt( stat ) + value;
        if( statValue  <= 0 )
            return false;
        else
            return true;
    }

    public function changeStat( stat:String, value:Int ):Void {
        var msg:String = this._parent.errMsg();
        msg += 'EntityStatsSystem.changeStat. ';

        if( canChangeStat( stat, value ))
            throw '$msg. Can not change "$stat" on "$value".';

        var skillSystem:EntitySkillSystem = this._parent.skills;
       
        switch( stat ){
            case "str": {
                // от силы зависит: ближний бой. переносимый вес. шанс нокаута в ближнем бою, шанс получить нокаут;
                var statValue:Int = this._getStatInt( stat ) + value;
                if( statValue >= this._statsMaxValue )
                    statValue = this._statsMaxValue;

                this.strength = Strength( statValue );
                //calculate dependencies;
                this.knockdownResistance = Knockdown( this._calculateResist( "knockdownRes" )); // сопротивление нокауту.
                this.painResistance = Pain( this._calculateResist( "painRes" )); // сопротивление боли.
                //переносимый вес в инвентаре
                //шанс нокаута в скилах
                
            };
            case "int": {
                var statValue:Int = this._getStatInt( stat ) + value;
                if( statValue >= this._statsMaxValue )
                    statValue = this._statsMaxValue;

                this.intellect = Intellect( statValue );
                //calculate dependencies;
                skillSystem.skillGrowupMultiplier = Math.round( statValue / 3 );
                
                
            };
            case "dex": {
                var statValue:Int = this._getStatInt( stat ) + value;
                if( statValue >= this._statsMaxValue )
                    statValue = this._statsMaxValue;

                this.dexterity = Dexterity( statValue );

            };
            case "end": {
                var statValue:Int = this._getStatInt( stat ) + value;
                if( statValue >= this._statsMaxValue )
                    statValue = this._statsMaxValue;

                this.endurance = Endurance( statValue );
            };
            default: throw '$msg Can not set "$stat"';
        }
    }

    public function changeExtraStat( stat:String, value:Int ):Void{
        switch( stat ){
            case "movementSpeed":{};
            case "meleeDamage":{};
            case "rangeDamage":{};
            default: throw 'Error in EntityStatsSystem.changeExtraStat. Can not change stat "$stat".';
        }
    }

    public function changeResist( stat:String, value:Int ):Void{
        var statValue:Int = this._getResistInt( stat ) + value;
        statValue = this._checkResistValue( statValue );
        switch( stat ){
            case "kinetic": this.kineticResistance = Kinetic( statValue );
            case "fire": this.fireResistance = Fire( statValue );
            case "electric": this.electricResistance = Electric( statValue );
            case "plasma": this.plasmaResistance = Plasma( statValue );
            case "laser": this.laserResistance = Laser( statValue );
            case "poison": this.poisonResistance = Poison( statValue );
            case "knockdown": this.knockdownResistance = Knockdown( statValue );
            case "disease": this.diseaseResistance = Disease( statValue );
            case "bleeding": this.bleedingResistance = Bleeding( statValue );
            case "pain": this.painResistance = Pain( statValue );
            default: throw 'Error in EntityStatsSystem.changeResist. Can not change $stat on $value';
        }
    }

    public function changePain( value:Int ):Void{
        if( value < 0 )
            this._decreasePain( value );
        else
            this._increasePain( value );
    }

    public function getBaseStat( stat:String ):Int{
        switch( stat ){
            case "str": return this._baseStats.Strength;
            case "int": return this._baseStats.Intellect;
            case "dex": return this._baseStats.Dexterity;
            case "end": return this._baseStats.Endurance;          
            default: throw 'Error in EntityStatsSystem.getBaseStat. can not get stats "$stat"';
        }
    }

    public function getBaseExtraStat( stat:String ):Int{
        switch( stat ){
            case "movementSpeed": return this._baseStats.MovementSpeed;
            case "meleeDamage": return this._baseStats.MeleeAttack;
            case "rangeDamage": return this._baseStats.RangeAttack;
            default: throw 'Error in EntityStatsSystem.getBaseExtraStat. Can not get stat "$stat".';
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

    public function getFullStat( stat:String ):Int{
        var inventory:EntityInventorySystem = this._parent.inventory;
        var inventoryStatValue:Int = 0;
        if( inventory != null ){
            inventoryStatValue = inventory.getFullStat( stat );
        }
        var value:Int = -1;
        switch( stat ){
            case "str": value = this.getBaseStat( "str" );
            case "dex": value = this.getBaseStat( "dex" );
            case "int": value = this.getBaseStat( "int" );
            case "end": value = this.getBaseStat( "end" );
            default: 'Can not get full stat "$stat"';
        }

        value += inventoryStatValue;
        return value;
    }

    public function getCalculatedExtraStat( stat:String ):Int{
        switch( stat ){
            case "meleeDamage":{};
            case "rangeDamage":{};
            case "movementSpeed":{};
            default:{};
        }
    }

    public function getCalculatedResistance( stat:String ):Int {
        switch( stat ){
            case "kinetic":{};
            case "fire":{};
            case "electric":{};
            case "":{};
            default:{};
        }
    }




    private function _increasePain( value:Int ):Void {
        var currentValue:Int = switch( this.pain ){case Pain( v ): v; };
        if( currentValue > this._painMaxValue )
            return;

        currentValue += value;
        if( currentValue > this._painMaxValue ){
            this.pain = Pain( this._painMaxValue );
            //knockdownEntity;
        }else
            this.pain = Pain( currentValue );

        // Каждые 100 пунктов боли уменьшаем оснвоные статы.
        if( currentValue%100 == 0 ){
            if( this.canChangeStat( "str", -1 ))
                this.changeStat( "str", -1 );

            if( this.canChangeStat( "end", -1 ))
                this.changeStat( "end", -1 );

            if( this.canChangeStat( "int", -1 ))
                this.changeStat( "int", -1 );

            if( this.canChangeStat( "dex", -1 ))
                this.changeStat( "dex", -1 );
        }
        
    }

    private function _decreasePain( value:Int ):Void {
        var currentValue:Int = switch( this.pain ){case Pain( v ): v; };
        if( currentValue == 0 )
            return ;

        currentValue += value;
        if( currentValue < 0 )
            this.pain = Pain( 0 );
        else
            this.pain = Pain( currentValue );

        if( currentValue%100 == 0 ){
            //увеличиваем статы, когда боль спадает каждые 100 пунктов.
            if( this.getFullStat( "str" ) < this._getStatInt( "str" ))
                this.changeStat( "str", 1 );

            if( this.getFullStat( "end" ) < this._getStatInt( "end" ))
                this.changeStat( "end", 1 );

            if( this.getFullStat( "int" ) < this._getStatInt( "int" ))
                this.changeStat( "int", 1 );

            if( this.getFullStat( "dex" ) < this._getStatInt( "dex" ))
                this.changeStat( "dex", 1 );
        }
    }

    private function _calculateExtraStat( stat:String ):Int{
        var msg:String = this._errMsg();
        msg += '_calculateExtraStat. Can not calculate "$stat".';
        var value:Int = -1;
        var baseStat:Int = this._getExtraStatInt( stat );
        switch( stat ){
            case "meleeDamage":{
                //str + str/4;                
                var strValue:Int = this._getStatInt( "str" );
                value = baseStat + strValue + Math.round( strValue / 4 );
            }
            case "rangeDamage":{
                // dex/2 + int/2;
                var dexValue:Int = this._getStatInt( "dex" );
                var intValue:Int = this._getStatInt( "int" );
                value = baseStat + Math.round( dexValue / 2  + intValue / 2 );
            }
            case "movementSpeed":{
                var dexValue:Int = this._getStatInt( "dex" );
                value = baseStat + dexValue * 15;
            }
            default: throw '$msg';
        }
        if( value <= 0 )
            throw '$msg, value: "$value".';

        return value;
    }


    private function _calculateResist( stat:String ):Int{
        var msg:String = this._errMsg();
        msg += '_calculateResist. Can not calculate "$stat".';
        var value:Int = -1;
        switch( stat ){
            case "knockdownRes":{
                // Споротивление нокауту рассчитывается по формуле base + str*2 + str/2;
                var knResBaseStat:Int = this._baseStats.KnockdownRes;
                var strValue:Int = this._getStatInt( "str" );
                value = knResBaseStat + strValue * 2 + Math.round( strValue/2 );
            }
            case "diseaseRes":{
                //сопротивление болезням рассчитывается по формуле base + end*2;
                var diseaseBaseStat:Int = this._baseStats.DiseaseRes;
                var endValue:Int = this._getStatInt( "end" );
                value = diseaseBaseStat + endValue * 2;
            }
            case "poisonRes":{
                //сопротивление яду рассчитывается по формуле base + end*2;
                var poResBaseStat:Int = this._baseStats.PoisonRes;
                var endValue:Int = this._getStatInt( "end" );
                value = poResBaseStat + endValue * 2 ;
            }
            case "bleedingRes":{
                //сопротивление кровотечению рассчитывается по формуле base + end*2;
                var blResBaseStat:Int = this._baseStats.BleedingRes;
                var endValue:Int = this._getStatInt( "end" );
                value = blResBaseStat + endValue * 2;
            }
            case "painRes":{
                //сопротивление боли рассчитывается по формуле base + str*2 + end;
                var paResBaseStat:Int = this._baseStats.PainRes;
                var strValue:Int = this._getStatInt( "str" );
                var endValue:Int = this._getStatInt( "end" );
                value = paResBaseStat + strValue * 2 + endValue;
            }
        }
        if( value <= -1 )
            throw '$msg';

        value = this._checkResistValue( value );
        return value;
    }

    private function _checkResistValue( value:Int ):Int{
        if( value < 0 )
            return 0;
        else if( value >= this._resistanceMaxValue )
            return this._resistanceMaxValue;
        else
            return value;
    }

    private function _getStatInt( stat:String ):Int{
        var msg:String = this._errMsg();
        msg += '_getStatInt. there is no stat "$stat"';
        var container:MainStats;
        switch( stat ){
            case "str": container = this.strength;
            case "end": container = this.endurance;
            case "dex": container = this.dexterity;
            case "int": container = this.intellect;
            default: throw '$msg';
        }
        switch( container ){
            case Strength( v ): return v;
            case Endurance( v ): return v;
            case Intellect( v ): return v;
            case Dexterity( v ): return v;
        }
    }

    private function _getExtraStatInt( stat:String ):Int{
        var msg:String = this._errMsg();
        msg += '_getExtraStatInt. There is no stat "$stat".';
        var container:ExtraStats;
        switch( stat ){
            case "movementSpeed": container = this.movementSpeed;
            case "meleeDamage": container = this.meleeDamage;
            case "rangeDamage": container = this.rangeDamage;
            default: throw '$msg';
        }
        switch( container ){
            case MovementSpeed( v ): return v;
            case MeleeDamage( v ): return v;
            case RangeDamage( v ): return v;
        }
    }

    private function _getResistInt( stat:String ):Int{
        var container:MainResists;
        switch( stat ){
            case "kinetic": container = this.kineticResistance;
            case "fire": container = this.fireResistance;
            case "electcric": container = this.electricResistance;
            case "plasma": container = this.plasmaResistance;
            case "laser": container = this.laserResistance;
            case "poison": container = this.poisonResistance;
            case "knockdown": container = this.knockdownResistance;
            case "disease": container = this.diseaseResistance;
            case "bleeding": container = this.bleedingResistance;
            case "pain": container = this.painResistance;
        }
        switch( container ){
            case Kinetic( v ): return v;
            case Fire( v ): return v;
            case Electric( v ): return v;
            case Plasma( v ): return v;
            case Laser( v ): return v;
            case Poison( v ): return v;
            case Knockdown( v ): return v;
            case Disease( v ): return v;
            case Bleeding( v ): return v;
            case Pain( v ): return v;
        }
    }

    private function _errMsg():String{
        var msg:String = this._parent.errMsg();
        msg += "EntityStatSystem.";
        return msg;
    }
}