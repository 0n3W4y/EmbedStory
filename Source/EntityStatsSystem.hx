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

typedef Stat = {
    var Current:Stats;
    var Modifier:Stats;
    var Base:Stats;
};

enum Stats {
    Strength( _:Int ); // сила рукопашной атаки и\или ближний бой урон. + переносимый вес + шанс нокаута в ближнем бою выше, сопротивление нокауту
    Dexterity( _:Int ); // общая скорость увеличена + уворот от ближнего боя + обращение с оружием дальнего боя
    Endurance( _:Int ); // HP + сопротивление болезням/ядам + сопротивление боль и уменьшение времени нахождения в нокауте.
    Intellect( _:Int ); // множитель обучения скилам
    MovementSpeed( _:Int ); // dex*15;
    MeleeDamage( _:Int ); // str + str/4;
    RangedDamage( _:Int ); // dex/2 + int/2;
    KineticResistance( _:Int );
    FireResistance( _:Int );
    ElectricResistance( _:Int );
    PlasmaResistance( _:Int );
    LaserResistance( _:Int );
    PoisonResistance( _:Int ); // end*2
    KnockdownResistance( _:Int ); // str*2 + str/5
    DiseaseResistance( _:Int ); // end*2
    BleedingResistance( _:Int ); // end*2
    PainResistance( _:Int ); // str*2 + end;
}

enum Pain {
    Pain( _:Int ); // боль. при росте боли, уменьшаем все статы. чем больше боль, тем ниже статы. максимаьное значение 1000;
}

class EntityStatsSystem {

    public var strength:Stat;
    public var dexterity:Stat;
    public var intellect:Stat;
    public var endurance:Stat;

    public var movementSpeed:Stat;
    public var meleeDamage:Stat;
    public var rangedDamage:Stat;

    public var kineticResistance:Stat;
    public var fireResistance:Stat;
    public var electricResistance:Stat;
    public var plasmaResistance:Stat;
    public var laserResistance:Stat;

    public var poisonResistance:Stat;
    public var knockdownResistance:Stat;
    public var diseaseResistance:Stat;
    public var bleedingResistance:Stat;
    public var painResistance:Stat;

    public var pain:Pain;


    private var _parent:Entity;
    private var _inited:Bool = false;
    private var _postInited:Bool= false;
    private var _resistanceMaxValue:Int = 95;
    private var _statsMaxValue:Int = 30;
    private var _painMaxValue:Int = 1000;

    public function new( parent:Entity, config:EntityStatsSystemConfig ){
        this._parent = parent;
        this.pain = Pain( 0 );

        this.strength = { Current: Strength( config.STR ), Modifier: Strength( 0 ), Base: Strength( config.STR )};
        this.dexterity = { Current: Dexterity( config.DEX ), Modifier: Dexterity( 0 ), Base: Dexterity( config.DEX )};
        this.endurance = { Current: Endurance( config.END ), Modifier: Endurance( 0 ), Base: Endurance( config.END )};
        this.intellect = { Current: Intellect( config.INT ), Modifier: Intellect( 0 ), Base: Intellect( config.INT )};
        
        this.movementSpeed = { Current: MovementSpeed( 0 ), Modifier: MovementSpeed( 0 ), Base: MovementSpeed( config.MoveSPD )};
        this.meleeDamage = { Current: MeleeDamage( 0 ), Modifier: MeleeDamage( 0 ), Base: MeleeDamage( config.MATK )};
        this.rangedDamage = { Current: RangedDamage( 0 ), Modifier: RangedDamage( 0 ), Base: RangedDamage( config.RATK )};

        this.kineticResistance = { Current: KineticResistance( config.KiRes ), Modifier: KineticResistance( 0 ), Base: KineticResistance( config.KiRes )};
        this.fireResistance = { Current: FireResistance( config.FiRes ), Modifier: FireResistance( 0 ), Base: FireResistance( config.FiRes )};
        this.electricResistance = { Current: ElectricResistance( config.ElRes ), Modifier: ElectricResistance( 0 ), Base: ElectricResistance( config.ElRes )};
        this.plasmaResistance = { Current: PlasmaResistance( config.PlRes ), Modifier: PlasmaResistance( 0 ), Base: PlasmaResistance( config.PlRes )};
        this.laserResistance = { Current: LaserResistance( config.LaRes ), Modifier: LaserResistance( 0 ), Base: LaserResistance( config.LaRes )};

        this.poisonResistance = { Current: PoisonResistance( 0 ), Modifier: PoisonResistance( 0 ), Base: PoisonResistance( config.PoRes )};
        this.knockdownResistance = { Current: KnockdownResistance( 0 ), Modifier: KnockdownResistance( 0 ), Base: KnockdownResistance( config.KnRes )};
        this.diseaseResistance = { Current: DiseaseResistance( 0 ), Modifier: DiseaseResistance( 0 ), Base: DiseaseResistance( config.DiRes )};
        this.bleedingResistance = { Current: BleedingResistance( 0 ), Modifier: BleedingResistance( 0 ), Base: BleedingResistance( config.BlRes )};
        this.painResistance = { Current: PainResistance( 0 ), Modifier: PainResistance( 0 ), Base: PainResistance( config.PaRes )};

        this.movementSpeed.Current = MovementSpeed( this._calculateStatValue( "movementSpeed" ));
        this.meleeDamage.Current = MeleeDamage( this._calculateStatValue( "meleeDamage" ));
        this.rangedDamage.Current = RangedDamage( this._calculateStatValue( "rangedDamage" ));
        this.poisonResistance.Current = PoisonResistance( this._calculateStatValue( "posionresistance" ));
        this.knockdownResistance.Current = KnockdownResistance( this._calculateStatValue( "knockdownResistance" ));
        this.diseaseResistance.Current = DiseaseResistance( this._calculateStatValue( "diseaseResistance" ));
        this.bleedingResistance.Current = BleedingResistance( this._calculateStatValue( "bleedingResistance" ));
        this.painResistance.Current = PainResistance( this._calculateStatValue( "painResistance" ));
    }

    public function init():Void{
        var msg:String = this._parent.errMsg();
        msg += 'EntityStatsSystem.init. ';

        if( this._inited )
            throw '$msg already inited!';

        if( this.getStatValueInt( "strength", "base" ) <= 0 || Math.isNaN( this.getStatValueInt( "strength", "base" )))
            throw '$msg STR not valid';

        if( this.getStatValueInt( "dexterity", "base" ) <= 0 || Math.isNaN( this.getStatValueInt( "dexterity", "base" )))
            throw '$msg DEX not valid';

        if( this.getStatValueInt( "endurance", "base" ) <= 0 || Math.isNaN( this.getStatValueInt( "endurance", "base" )))
            throw '$msg END not valid';

        if( this.getStatValueInt( "intellect", "base" ) <= 0 || Math.isNaN( this.getStatValueInt( "intellect", "base" )))
            throw '$msg INT not valid';

        if( this.getStatValueInt( "movementSpeed", "base" ) <= 0 || Math.isNaN( this.getStatValueInt( "movementSpeed", "base" )))
            throw '$msg Movement Speed not valid';

        if( this.getStatValueInt( "meleeDamage", "base" ) < 0 || Math.isNaN( this.getStatValueInt( "meleeDamage", "base" )))
            throw '$msg Melee Damage not valid';

        if( this.getStatValueInt( "rangedDamage", "base" ) < 0 || Math.isNaN( this.getStatValueInt( "rangedDamage", "base" )))
            throw '$msg Ranged Damage not valid';

        if( this.getStatValueInt( "kineticResistance", "base" ) < 0 || Math.isNaN( this.getStatValueInt( "kineticResistance", "base" )))
            throw '$msg Kinetic Res not valid';

        if( this.getStatValueInt( "fireResistance", "base" ) < 0 || Math.isNaN( this.getStatValueInt( "fireResistance", "base" )))
            throw '$msg Fire Res not valid';

        if( this.getStatValueInt( "electricResisnatce", "base" ) < 0 || Math.isNaN( this.getStatValueInt( "electricResistance", "base" )))
            throw '$msg Electric Res not valid';

        if( this.getStatValueInt( "plasmaResistance", "base" ) < 0 || Math.isNaN( this.getStatValueInt( "plasmaResistance", "base" )))
            throw '$msg Plasma Res not valid';

        if( this.getStatValueInt( "laserResistance", "base" ) < 0 || Math.isNaN( this.getStatValueInt( "laserResistance", "base" )))
            throw '$msg Laser Res not valid';

        if( this.getStatValueInt( "poisonResistance", "base" ) < 0 || Math.isNaN( this.getStatValueInt( "poisonResistance", "base" )))
            throw '$msg Poison Res not valid';

        if( this.getStatValueInt( "knockdownResistance", "base" ) < 0 || Math.isNaN( this.getStatValueInt( "knockdownResistance", "base" )))
            throw '$msg Knockdown Res not valid';

        if( this.getStatValueInt( "diseaseResistance", "base" ) < 0 || Math.isNaN( this.getStatValueInt( "diseaseResistance", "base" )))
            throw '$msg Disease Res not valid';

        if( this.getStatValueInt( "bleedingResistance", "base" ) < 0 || Math.isNaN( this.getStatValueInt( "bleedingResistance", "base" )))
            throw '$msg Bleeding Res not valid';

        if( this.getStatValueInt( "painResistance", "base" ) < 0 || Math.isNaN( this.getStatValueInt( "painResistance", "base" )))
            throw '$msg Pain Res not valid';

        this._parent.healthPoints.changeHPModifierForAllBodyParts( this.getModifierForBodyPart() );

        this._inited = true;
    }

    public function postInit():Void{
        var msg:String = this._parent.errMsg();
        msg += 'EntityStatSystem.postInit. ';

        if( this._postInited )
            throw '$msg already inited!';

        this._postInited = true;
    }


    public function getStatValueInt( stat:String, place:String ):Int{
        var msg:String = this._errMsg();
        msg += 'getStatValuInt. Can not find "$stat" "$place"';

        var statContainer:Stat;
        switch( stat ){
            case "strength": statContainer = this.strength;
            case "dexterity": statContainer = this.dexterity;
            case "intellect": statContainer = this.intellect;
            case "endurance": statContainer = this.endurance;
            case "movementSpeed": statContainer = this.movementSpeed;
            case "meleeDamage": statContainer = this.meleeDamage;
            case "rangedDamage": statContainer = this.rangedDamage;
            case "kineticResistance": statContainer = this.kineticResistance;
            case "electricresistance": statContainer = this.electricResistance;
            case "fireResistance": statContainer = this.fireResistance;
            case "plasmaResistance": statContainer = this.plasmaResistance;
            case "laserResistance": statContainer = this.laserResistance;
            case "poisonResistance": statContainer = this.poisonResistance;
            case "diseaseResistance": statContainer = this.diseaseResistance;
            case "bleedingResistance": statContainer = this.bleedingResistance;
            case "painResistance": statContainer = this.painResistance;
            case "knockdownResistance": statContainer = this.knockdownResistance;
            default: throw '$msg';
        }
        var container:Stats;
        switch( place ){
            case "current": statContainer.Current;
            case "modifier": statContainer.Modifier;
            case "base": statContainer.Base;
            default: throw '$msg';
        }
        return this._getIntFromStats( container );
    }


    public function getModifierForBodyPart():Int{
        return this._getIntFromStats( this.endurance.Current ) * 2;
    }

    public function canChangeStatValue( stat:String, place:String, value:Int ):Bool {
        var statValue:Int;

        if( place == "modifier" )
            statValue = this.getStatValueInt( stat, "current" ) + value;
        else if( place == "base" )
            statValue = this.getStatValueInt( stat, place ) + value;
        else
            throw 'Error in EntityStatSystem.canChangeStatValue. "$place" is not valid.';

        switch( stat ){
            case "strength", "dexterity", "intellect", "endurance":{
                if( statValue <=0 || statValue > this._statsMaxValue )
                    return false;
                else
                    return true;
            }
            case "movementSpeed", "meleeDamage", "rangedDamage":{
                if( statValue <= 0 )
                    return false;
                else
                    return true;
            }
            case "kineticResistance", "electricResistance", "fireResistance", "plasmaResistance", "laserResistance", "poisonResistance", "knockdownResistance", "diseaseResistance", "painResistance", "bleedingResistance":{
                return true;
            }
        }
        throw 'Error in EntityStatsSystem.canChangeStatValue. "$stat" is not in list.';
        return false;
    }

    public function changeStatModifierValue( stat:String, value:Int ):Void{
        //function change "modifier" in stat. and calculating "current";
        var statModifierValue:Int = this.getStatValueInt( stat, "modifier" );
        statModifierValue += value;
        this._setValueToStat( stat, "modifier", statModifierValue );

        var calculatedValue:Int = this._calculateStatValue( stat );
        var container:Stat = this._getStatContainer( stat );
        if( this._getIntFromStats( container.Current ) == calculatedValue )
            return;

        this._setValueToStat( stat, "current", calculatedValue );
        this._autoCalculateDependencies( stat, value );
    }

    public function changeStatBaseValue( stat:String, value:Int ):Void{
        //change "base" in stat and calculating "current";
        var statBaseValue:Int = this.getStatValueInt( stat, "base" );
        statBaseValue += value;
        this._setValueToStat( stat, "base", statBaseValue );

        var calculatedValue:Int = this._calculateStatValue( stat );
        this._setValueToStat( stat, "current", calculatedValue);
        this._autoCalculateDependencies( stat, value );
    }

    public function changePain( value:Int ):Void {
        var currentValue:Int = switch( this.pain ){case Pain( v ): v; };
        if( currentValue == this._painMaxValue || currentValue == 0 )
            return;

        currentValue += value;
        if( currentValue > this._painMaxValue ){
            this.pain = Pain( this._painMaxValue );
            //knockdown effect add;
        }else if( currentValue < 0 )
            this.pain = Pain( 0 );
        else
            this.pain = Pain( currentValue );

        // Каждые 200 пунктов боли уменьшаем оснвоные статы.
        var statModifier = 1;
        if( value < 0 )
            statModifier = -1;

        if( currentValue%200 == 0 ){
            this.changeStatModifierValue( "strength", statModifier );
            this.changeStatModifierValue( "dexterity", statModifier );
            this.changeStatModifierValue( "intellect", statModifier );
            this.changeStatModifierValue( "endurance", statModifier );
        }        
    }
    








    private function _autoCalculateDependencies( stat:String, value:Int ):Void{
        switch( stat ){
            case "strength": {
                // от силы зависит: ближний бой. переносимый вес. шанс нокаута в ближнем бою, шанс получить нокаут;
                this.knockdownResistance.Current = KnockdownResistance( this._calculateStatValue( "knockdownResistance"));
                this.painResistance.Current = PainResistance( this._calculateStatValue( "painResistance" )); // сопротивление боли.
                this.meleeDamage.Current = MeleeDamage( this._calculateStatValue( "meleeDamage" ));
                //переносимый вес в инвентаре
                //шанс нокаута в скилах                
            };
            case "intellect": {
                var statValue:Int = this.getStatValueInt( stat, "current" );
                this._parent.skills.skillGrowupMultiplier = Math.round( statValue / 3 );
                this.rangedDamage.Current = RangedDamage( this._calculateStatValue( "rangedDamage" ));
            };
            case "dexterity": {
                this.movementSpeed.Current = MovementSpeed( this._calculateStatValue( "movementSpeed" ));
                this.rangedDamage.Current = RangedDamage( this._calculateStatValue( "rangedDamege" ));
            };
            case "endurance": {
                this.poisonResistance.Current = PoisonResistance( this._calculateStatValue( "poisonResistance" ));
                this.diseaseResistance.Current = DiseaseResistance( this._calculateStatValue( "diseaseResistance" ));
                this.bleedingResistance.Current = BleedingResistance( this._calculateStatValue( "bleedingResistance" ));
                this.painResistance.Current = PainResistance( this._calculateStatValue( "painResistance" ));
                var newValue:Int = value * 2;
                this._parent.healthPoints.changeHPModifierForAllBodyParts( newValue ); // увеличиваем или уменьшаем модифер для ХП системы.
            };
        }
    }

    private function _calculateStatValue( stat:String ):Int{
        var baseValue:Int = this.getStatValueInt( stat, "base" );
        var modifierValue:Int = this.getStatValueInt( stat, "modifier" );
        var value:Int = baseValue + modifierValue;
        switch( stat ){
            case "strength", "dexterity", "intellect", "endurance":{
                if( value > this._statsMaxValue )
                    value = this._statsMaxValue;
                if( value <= 0 )
                    value = 1;
            };
            case "meleeDamage":{
                var strValue:Int = this.getStatValueInt( "strength", "current" );
                value += strValue + Math.ceil( strValue / 4 );
                if( value <= 0 )
                    value = 1;
            };
            case "rangedDamage":{
                var dexValue:Int = this.getStatValueInt( "dexterity", "current" );
                var intValue:Int = this.getStatValueInt( "intellect", "current" );
                value += Math.ceil( dexValue / 2 + intValue / 2 );
                if( value <= 0 )
                    value = 1;
            };
            case "movementSpeed":{
                var dexValue:Int = this.getStatValueInt( "dexterity", "current" );
                value += dexValue * 15;
                if( value <= 0 )
                    value = 1;
            };
            case "poisonResistance":{
                var endValue:Int = this.getStatValueInt( "endurance", "current" );
                value += endValue * 2;
                if( value < -this._resistanceMaxValue )
                    value = -this._resistanceMaxValue;
                else if( value > this._resistanceMaxValue )
                    value = this._resistanceMaxValue;
            };
            case "diseaseResistance":{
                var endValue:Int = this.getStatValueInt( "endurance", "current" );
                value += endValue * 2;
                if( value < -this._resistanceMaxValue )
                    value = -this._resistanceMaxValue;
                else if( value > this._resistanceMaxValue )
                    value = this._resistanceMaxValue;
            };
            case "bleedingResistance":{
                var endValue:Int = this.getStatValueInt( "endurance", "current" );
                value += endValue * 2;
                if( value < -this._resistanceMaxValue )
                    value = -this._resistanceMaxValue;
                else if( value > this._resistanceMaxValue )
                    value = this._resistanceMaxValue;
            };
            case "painResistance":{
                var endValue:Int = this.getStatValueInt( "endurance", "current" );
                var strValue:Int = this.getStatValueInt( "strength", "current" );
                value += strValue * 2 + endValue;
                if( value < -this._resistanceMaxValue )
                    value = -this._resistanceMaxValue;
                else if( value > this._resistanceMaxValue )
                    value = this._resistanceMaxValue;
            };
            case "knockdownResistance":{
                var strValue:Int = this.getStatValueInt( "strength", "current" );
                value += strValue * 2 + Math.ceil( strValue / 5 );
                if( value < -this._resistanceMaxValue )
                    value = -this._resistanceMaxValue;
                else if( value > this._resistanceMaxValue )
                    value = this._resistanceMaxValue;
            };
            case "kineticResistance", "electricResistance", "fireResistance", "plasmaResistance", "laserResistance":{
                if( value < -this._resistanceMaxValue )
                    value = -this._resistanceMaxValue;
                else if( value > this._resistanceMaxValue )
                    value = this._resistanceMaxValue;
            }
        }
        return value;
    }

    private function _setValueToStat( stat:String, place:String, value:Int ):Void{
        var msg:String = this._errMsg();
        msg += '_setValueToStat. Can not find "$stat" "$place"';

        switch( stat ){
            case "strength": {
                switch( place ){
                    case "current": this.strength.Current = Strength( value );
                    case "modifier": this.strength.Modifier = Strength( value );
                    case "base": this.strength.Base = Strength( value );
                }
            };
            case "dexterity": {
                switch( place ){
                    case "current": this.dexterity.Current = Dexterity( value );
                    case "modifier": this.dexterity.Modifier = Dexterity( value );
                    case "base": this.dexterity.Base = Dexterity( value );
                }
            };
            case "intellect":{
                switch( place ){
                    case "current": this.intellect.Current = Intellect( value );
                    case "modifier": this.intellect.Modifier = Intellect( value );
                    case "base": this.intellect.Base = Intellect( value );
                }
            };
            case "endurance":{
                switch( place ){
                    case "current": this.endurance.Current = Endurance( value );
                    case "modifier": this.endurance.Modifier = Endurance( value );
                    case "base": this.endurance.Base = Endurance( value );
                }
            };
            case "movementSpeed":{
                switch( place ){
                    case "current": this.movementSpeed.Current = MovementSpeed( value );
                    case "modifier": this.movementSpeed.Modifier = MovementSpeed( value );
                    case "base": this.movementSpeed.Base = MovementSpeed( value );
                }
            };
            case "meleeDamage":{
                switch( place ){
                    case "current": this.meleeDamage.Current = MeleeDamage( value );
                    case "modifier": this.meleeDamage.Modifier = MeleeDamage( value );
                    case "base": this.meleeDamage.Base = MeleeDamage( value );
                }
            };
            case "rangedDamage":{
                switch( place ){
                    case "current": this.rangedDamage.Current = RangedDamage( value );
                    case "modifier": this.rangedDamage.Modifier = RangedDamage( value );
                    case "base": this.rangedDamage.Base = RangedDamage( value );
                }
            };
            case "kineticResistance":{
                switch( place ){
                    case "current": this.kineticResistance.Current = KineticResistance( value );
                    case "modifier": this.kineticResistance.Modifier = KineticResistance( value );
                    case "base": this.kineticResistance.Base = KineticResistance( value );
                }
            };
            case "electricresistance":{
                switch( place ){
                    case "current": this.electricResistance.Current = ElectricResistance( value );
                    case "modifier": this.electricResistance.Modifier = ElectricResistance( value );
                    case "base": this.electricResistance.Base = ElectricResistance( value );
                }
            };
            case "fireResistance":{
                switch( place ){
                    case "current": this.fireResistance.Current = FireResistance( value );
                    case "modifier": this.fireResistance.Modifier = FireResistance( value );
                    case "base": this.fireResistance.Base = FireResistance( value );
                }
            };
            case "plasmaResistance":{
                switch( place ){
                    case "current": this.plasmaResistance.Current = PlasmaResistance( value );
                    case "modifier": this.plasmaResistance.Modifier = PlasmaResistance( value );
                    case "base": this.plasmaResistance.Base = PlasmaResistance( value );
                }
            };
            case "laserResistance": {
                switch( place ){
                    case "current": this.laserResistance.Current = LaserResistance( value );
                    case "modifier": this.laserResistance.Modifier = LaserResistance( value );
                    case "base": this.laserResistance.Base = LaserResistance( value );
                }
            };
            case "poisonResistance":{
                switch( place ){
                    case "current": this.poisonResistance.Current = PoisonResistance( value );
                    case "modifier": this.poisonResistance.Modifier = PoisonResistance( value );
                    case "base": this.poisonResistance.Base = PoisonResistance( value );
                }
            };
            case "diseaseResistance":{
                switch( place ){
                    case "current": this.diseaseResistance.Current = DiseaseResistance( value );
                    case "modifier": this.diseaseResistance.Modifier = DiseaseResistance( value );
                    case "base": this.diseaseResistance.Base = DiseaseResistance( value );
                }
            };
            case "bleedingResistance": {
                switch( place ){
                    case "current": this.bleedingResistance.Current = BleedingResistance( value );
                    case "modifier": this.bleedingResistance.Modifier = BleedingResistance( value );
                    case "base": this.bleedingResistance.Base = BleedingResistance( value );
                }
            };
            case "painResistance": {
                switch( place ){
                    case "current": this.painResistance.Current = PainResistance( value );
                    case "modifier": this.painResistance.Modifier = PainResistance( value );
                    case "base": this.painResistance.Base = PainResistance( value );
                }
            };
            case "knockdownResistance":{
                switch( place ){
                    case "current": this.knockdownResistance.Current = KnockdownResistance( value );
                    case "modifier": this.knockdownResistance.Modifier = KnockdownResistance( value );
                    case "base": this.knockdownResistance.Base = KnockdownResistance( value );
                }
            };
            default: throw '$msg';
        }
    }

    private function _getStatContainer( stat:String ):Stat{
        var msg:String = this._errMsg();
        msg += '_getStatContainer. "$stat" is not valid!';

        switch( stat ){
            case "strength": return this.strength;
            case "endurance": return this.endurance;
            case "dexterity": return this.dexterity;
            case "intellect": return this.intellect;
            case "meleeDamage": return this.meleeDamage;
            case "rangedDamage": return this.rangedDamage;
            case "movementSpeed": return this.movementSpeed;
            case "kineticResistance": return this.kineticResistance;
            case "electricresistance": return this.electricResistance;
            case "laserResistance": return this.laserResistance;
            case "plasmaResistance": return this.plasmaResistance;
            case "fireResistance": return this.fireResistance;
            case "poisonResistance": return this.poisonResistance;
            case "diseaseResistance": return this.poisonResistance;
            case "knockdownResistance": return this.knockdownResistance;
            case "bleedingResistance": return this.bleedingResistance;
            case "painResistance": return this.painResistance;
            default: throw '$msg';
        }
    }

    private function _getIntFromStats( container:Stats ):Int{
        switch( container ){
            case Strength( v ):{ return v;}; 
            case Dexterity( v ):{ return v;};
            case Endurance( v ):{ return v;};
            case Intellect( v ):{ return v;};
            case MovementSpeed( v ):{ return v;};
            case MeleeDamage( v ):{ return v;};
            case RangedDamage( v ):{ return v;};
            case KineticResistance( v ):{ return v;};
            case FireResistance( v ):{ return v;};
            case ElectricResistance( v ):{ return v;};
            case PlasmaResistance( v ):{ return v;};
            case LaserResistance( v ):{ return v;};
            case PoisonResistance( v ):{ return v;};
            case KnockdownResistance( v ):{ return v;};
            case DiseaseResistance( v ):{ return v;};
            case BleedingResistance( v ):{ return v;};
            case PainResistance( v ):{ return v;};
        }
    }

    private function _errMsg():String{
        var msg:String = this._parent.errMsg();
        msg += "EntityStatSystem.";
        return msg;
    }
}