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
    var MeleeDamage:Int;
    var RangedDamage:Int;
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
    RangedDamage( _:Int ); // dex/2 + int/2;
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
    public var rangedDamage:ExtraStats;

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
            MeleeDamage: config.MATK,
            RangedDamage: config.RATK,
            MovementSpeed: config.MoveSPD
        };

        this.kineticResistance = Kinetic( config.KiRes );
        this.fireResistance = Fire( config.FiRes );
        this.electricResistance = Electric( config.ElRes );
        this.plasmaResistance = Plasma( config.PlRes );
        this.laserResistance = Laser( config.LaRes );
        this.poisonResistance = Poison( this._calculateBaseResistValue( "poisonRes" ));
        this.knockdownResistance = Knockdown( this._calculateBaseResistValue( "knockdownRes" ));
        this.diseaseResistance = Disease( this._calculateBaseResistValue( "diseaseRes" ));
        this.bleedingResistance = Bleeding( this._calculateBaseResistValue( "bleedingRes" ));
        this.painResistance = Pain( this._calculateBaseResistValue( "painRes" ));
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

    public function changeStat( stat:String, value:Int ):Void{
        var msg:String = this._errMsg();
        msg += 'changeStat. Can not find "$stat"';

        switch( stat ){
            case "str", "end", "dex", "int": this._changeMainStatValue( stat, value );
            case "pain":{
                if( value < 0 )
                    this._decreasePain( value );
                else
                    this._increasePain( value );
            }
            case "kineticRes", "fireRes", "electricRes", "poisonRes", "laserRes", "plasmaRes", "diseaseRes", "knockdownRes", "painRes", "bleedingRes": this._changeResistValue( stat, value );
            case "movementSpeed", "meleeDamage", "rangedDamage": this._changeExtraStatValue( stat, value );
            default: throw '$msg';
        }
    }

    public function changeBaseStat( stat:String, value:Int ):Void{

    }

    public function getBaseStatValue( stat:String ):Int{
        switch( stat ){
            case "str": return this._baseStats.Strength;
            case "int": return this._baseStats.Intellect;
            case "dex": return this._baseStats.Dexterity;
            case "end": return this._baseStats.Endurance;          
            default: throw 'Error in EntityStatsSystem.getBaseStat. can not get stats "$stat"';
        }
    }    

    public function getFullStatValueInt( stat:String ):Int{
        //TODO: add from effect system!!!!!!
        var inventoryStatValue:Int = 0;
        var effectStatValue:Int = 0;
        if( this._parent.inventory != null ){
            inventoryStatValue = this._parent.inventory.getFullStat( stat );
        }
        /*
        if( this._parent.effect != null ){
            effectStatValue = this._parent.effect.getFullStat( stat );
        }
        */
        var value:Int = -1;
        switch( stat ){
            case "str": value = this._baseStats.Strength;
            case "dex": value = this._baseStats.Dexterity;
            case "int": value = this._baseStats.Intellect;
            case "end": value = this._baseStats.Endurance;
            default: 'Can not get full stat "$stat"';
        }

        value += inventoryStatValue + effectStatValue;
        return value;
    }

    public function getCalculatedExtraStatInt( stat:String ):Int{
        return this._getExtraStatInt( stat );
    }

    public function getCalculatedResistanceInt( stat:String ):Int {
        return this._getResistInt( stat );
    }





    private function _changeMainStatValue( stat:String, value:Int ):Void {
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
                this.knockdownResistance = Knockdown( this._calculateResistValue( "knockdownRes" )); // сопротивление нокауту.
                this.painResistance = Pain( this._calculateResistValue( "painRes" )); // сопротивление боли.
                this.meleeDamage = MeleeDamage( this._calculateBaseExtraStatValue( "meleeDamage" ));
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
                this.rangedDamage = RangedDamage( this._calculateExtraStatValue( "rangedDamage" ));
            };
            case "dex": {
                var statValue:Int = this._getStatInt( stat ) + value;
                if( statValue >= this._statsMaxValue )
                    statValue = this._statsMaxValue;

                this.dexterity = Dexterity( statValue );
                //calculate dependencies;
                this.movementSpeed = MovementSpeed( this._calculateExtraStatValue( "movementSpeed" ));
                this.rangedDamage = RangedDamage( this._calculateExtraStatValue( "rangedDamege" ));
            };
            case "end": {
                var statValue:Int = this._getStatInt( stat ) + value;
                if( statValue >= this._statsMaxValue )
                    statValue = this._statsMaxValue;

                this.endurance = Endurance( statValue );
                //calculate dependencies;
                this.poisonResistance = Poison( this._calculateResistValue( "posionRes" ));
                this.diseaseResistance = Disease( this._calculateResistValue( "diseaseRes" ));
                this.bleedingResistance = Bleeding( this._calculateResistValue( "bleedingRes" ));
                this.painResistance = Pain( this._calculateResistValue( "painRes" ));
            };
            default: throw '$msg Can not set "$stat"';
        }
    }

    private function _changeExtraStatValue( stat:String, value:Int ):Void{
        var statValue:Int = this._getExtraStatInt( stat ) + value;
        if( statValue < 0 )
            statValue = 0;

        //NOTICE: No check for maximum value for this stats!!!!!;
        switch( stat ){
            case "movementSpeed":this.movementSpeed = MovementSpeed( statValue );
            case "meleeDamage":this.meleeDamage = MeleeDamage( statValue );
            case "rangeDamage": this.rangedDamage = RangedDamage( statValue );
        }
    }

    private function _changeResistValue( stat:String, value:Int ):Void{
        var statValue:Int = this._getResistInt( stat ) + value;
        statValue = this._checkResistValue( statValue );
        switch( stat ){
            case "kineticRes": this.kineticResistance = Kinetic( statValue );
            case "fireRes": this.fireResistance = Fire( statValue );
            case "electricRes": this.electricResistance = Electric( statValue );
            case "plasmaRes": this.plasmaResistance = Plasma( statValue );
            case "laserRes": this.laserResistance = Laser( statValue );
            case "poisonRes": this.poisonResistance = Poison( statValue );
            case "knockdownRes": this.knockdownResistance = Knockdown( statValue );
            case "diseaseRes": this.diseaseResistance = Disease( statValue );
            case "bleedingRes": this.bleedingResistance = Bleeding( statValue );
            case "painRes": this.painResistance = Pain( statValue );
        }
    }

    private function _increasePain( value:Int ):Void {
        var currentValue:Int = switch( this.pain ){case Pain( v ): v; };
        if( currentValue > this._painMaxValue )
            return;

        currentValue += value;
        if( currentValue > this._painMaxValue ){
            this.pain = Pain( this._painMaxValue );
            //knockdown effect add;
        }else
            this.pain = Pain( currentValue );

        // Каждые 100 пунктов боли уменьшаем оснвоные статы.
        if( currentValue%100 == 0 ){
            if( this.canChangeStat( "str", -1 ))
                this._changeMainStatValue( "str", -1 );

            if( this.canChangeStat( "end", -1 ))
                this._changeMainStatValue( "end", -1 );

            if( this.canChangeStat( "int", -1 ))
                this._changeMainStatValue( "int", -1 );

            if( this.canChangeStat( "dex", -1 ))
                this._changeMainStatValue( "dex", -1 );
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
            if( this.getFullStatValueInt( "str" ) < this._getStatInt( "str" ))
                this._changeMainStatValue( "str", 1 );

            if( this.getFullStatValueInt( "end" ) < this._getStatInt( "end" ))
                this._changeMainStatValue( "end", 1 );

            if( this.getFullStatValueInt( "int" ) < this._getStatInt( "int" ))
                this._changeMainStatValue( "int", 1 );

            if( this.getFullStatValueInt( "dex" ) < this._getStatInt( "dex" ))
                this._changeMainStatValue( "dex", 1 );
        }
    }

    private function _calculateResistValue( stat:String ):Int{
        var msg:String = this._errMsg();
        msg += '_calculateResist. Can not calculate "$stat".';

        var value:Int = -1;
        // находим разницу между текущим значением и базовым, что бы его добавить ( или вычесть )
        // чтобы не пересчитывать из инвентаря все данные. 
        var baseResistValue:Int = this._calculateBaseResistValue( stat );
        var totalResistValue:Int = this._getResistInt( stat );
        //var differenceValue:Int = totalResistValue - baseResistValue; 

        var strValue:Int = this._getStatInt( "str" );
        var endValue:Int = this._getStatInt( "end" );
        var endBaseValue:Int = this._baseStats.Endurance;
        var strBaseValue:Int = this._baseStats.Strength;
        
        switch( stat ){
            // Споротивление нокауту рассчитывается по формуле base + str*2 + str/2;  
            case "knockdownRes": {
                var baseValue:Int = this._baseStats.KnockdownRes;
                var difStrValue:Int = strValue - strBaseValue;
                if( difStrValue < 0 )
                    difStrValue += 1;
                else
                    difStrValue -= 1;

                var differentValue = baseValue + difStrValue * 2 + Math.round( difStrValue / 2 );
                value = totalResistValue - differentValue;
            }
            //сопротивление болезням рассчитывается по формуле base + end*2;
            case "diseaseRes": {
                var baseValue:Int = this._baseStats.DiseaseRes;
                value = baseValue + endValue * 2 + differenceValue;
            }
            //сопротивление яду рассчитывается по формуле base + end*2;
            case "poisonRes": {
                var baseValue:Int = this._baseStats.PoisonRes;
                value = baseValue + endValue * 2 + differenceValue;
            }
            //сопротивление кровотечению рассчитывается по формуле base + end*2;
            case "bleedingRes": {
                var baseValue:Int = this._baseStats.BleedingRes;
                value = baseValue + endValue * 2 + differenceValue;
            }
            //сопротивление боли рассчитывается по формуле base + str*2 + end;
            case "painRes": {
                var baseValue:Int = this._baseStats.PainRes;
                value = baseValue + strValue * 2 + endValue + differenceValue;
            }
        }
        if( value < 0 )
            throw '$msg';

        value = this._checkResistValue( value );
        return value;
    }

    private function _calculateExtraStatValue( stat:String ):Int{
        var value:Int = -1;
        var msg:String = this._errMsg();
        msg += '_calculateExtraStatValue. For "$stat" value is "$value"';

        var baseExtraStatValue:Int = this._calculateBaseExtraStatValue( stat );
        var currentExtraStatValue:Int = this._getExtraStatInt( stat );
        var differenceValue:Int = currentExtraStatValue - baseExtraStatValue;

        var strValue:Int = this._getStatInt( "str" );
        //var endValue:Int = this._getStatInt( "end" );
        var intValue:Int = this._getStatInt( "int" );
        var dexValue:Int = this._getStatInt( "dex" );
        switch( stat ){
            // dex*15;
            case "movementSpeed": {
                var baseValue:Int = this._baseStats.MovementSpeed;
                value = baseValue + dexValue * 15 + differenceValue;
            }
            //str + str/4;
            case "meleeDamage":{
                var baseValue:Int = this._baseStats.MeleeDamage;
                value = baseValue + strValue + Math.round( strValue / 4 ) + differenceValue;
            }
            // dex/2 + int/2;
            case "rangedDamage":{
                var baseValue:Int = this._baseStats.RangedDamage;
                value = baseValue + Math.round( dexValue / 2 + intValue / 2 ) + differenceValue;
            }
        }
        if( value < 0 )
            throw '$msg';
        
        return value;        
    }

    private function _calculateBaseResistValue( stat:String ):Int{
        var value:Int = -1;
        var msg:String = this._errMsg();
        msg += '_calculateBaseResistValue. For "$stat" value is "$value"';

        var strBaseValue:Int = this._baseStats.Strength;
        var endBaseValue:Int = this._baseStats.Endurance;
        
        switch( stat ){
            case "knockdownRes":{
                // Споротивление нокауту рассчитывается по формуле base + str*2 + str/2;
                var knockdownBaseValue:Int = this._baseStats.KnockdownRes;
                value = knockdownBaseValue + strBaseValue * 2 + Math.round( strBaseValue / 2 );
            }
            case "diseaseRes":{
                //сопротивление болезням рассчитывается по формуле base + end*2;
                var diseaseBaseValue:Int = this._baseStats.DiseaseRes;
                value = diseaseBaseValue + endBaseValue * 2;
            }
            case "posionRes":{
                //сопротивление яду рассчитывается по формуле base + end*2;
                var poResBaseValue:Int = this._baseStats.PoisonRes;
                value = poResBaseValue + endBaseValue * 2;
            }
            case "bleedingRes":{
                //сопротивление кровотечению рассчитывается по формуле base + end*2;
                var blResBaseValue:Int = this._baseStats.BleedingRes;
                value = blResBaseValue + endBaseValue * 2;
            }
            case "painRes":{
                //сопротивление боли рассчитывается по формуле base + str*2 + end;
                var paResBaseValue:Int = this._baseStats.PainRes;
                value = paResBaseValue + strBaseValue * 2 + endBaseValue;
            }
        }
        if( value < 0 )
            throw '$msg';

        return value;
    }

    private function _calculateBaseExtraStatValue( stat:String ):Int{
        var value:Int = -1;
        var msg:String = this._errMsg();
        msg += '_calculateBaseExtraStatValue. For "$stat" value is "$value"';

        var strBaseValue:Int = this._baseStats.Strength;
        //var endBaseValue:Int = this._baseStats.Endurance;
        var dexBaseValue:Int = this._baseStats.Dexterity;
        var intBaseValue:Int = this._baseStats.Intellect;

        switch( stat ){
            case "movementSpeed":{
                //dex * 15;
                var moveSpeedBaseValue:Int = this._baseStats.MovementSpeed;
                value = moveSpeedBaseValue + dexBaseValue * 15;
            };
            case "meleeDamage":{
                // str + str/4;
                var mDamageValue:Int = this._baseStats.MeleeDamage;
                value = mDamageValue + strBaseValue + Math.round( strBaseValue / 4 );
            };
            case "rangedDamage":{
                // dex/2 + int/2;
                var rDamageValue:Int = this._baseStats.RangedDamage;
                value = rDamageValue + Math.round( dexBaseValue / 2 + intBaseValue / 2 );
            };
        }
        if( value < 0 )
            throw '$msg';

        return value;
    }

    private function _checkResistValue( value:Int ):Int{
        if( value < -this._resistanceMaxValue )
            return -this._resistanceMaxValue;
        else if( value > this._resistanceMaxValue )
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
            case "rangeDamage": container = this.rangedDamage;
            default: throw '$msg';
        }
        switch( container ){
            case MovementSpeed( v ): return v;
            case MeleeDamage( v ): return v;
            case RangedDamage( v ): return v;
        }
    }

    private function _getResistInt( stat:String ):Int{
        var msg:String = this._errMsg();
        msg += '_getResistInt. Can not find "$stat" in.';

        var container:MainResists;
        switch( stat ){
            case "kineticRes": container = this.kineticResistance;
            case "fireRes": container = this.fireResistance;
            case "electcricRes": container = this.electricResistance;
            case "plasmaRes": container = this.plasmaResistance;
            case "laserRes": container = this.laserResistance;
            case "poisonRes": container = this.poisonResistance;
            case "knockdownRes": container = this.knockdownResistance;
            case "diseaseRes": container = this.diseaseResistance;
            case "bleedingRes": container = this.bleedingResistance;
            case "painRes": container = this.painResistance;
            default: throw '$msg';
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