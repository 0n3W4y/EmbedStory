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
    var EatingSPD:Int;
    var FirstAidSPD:Int;
    var BandagingSPD:Int;
    var DoctorSDP:Int;
    var BlockMD:Int;
    var BlockRD:Int;
    var EvadeMD:Int;
    var EvadeRD:Int;
    var EquipItemSPD:Int;
    var ChangeWeaponSPD:Int;
}

typedef Stat = {
    var Current:Stats;
    var Modifier:Stats;
    var Base:Stats;
}

enum Stats {
    Strength( _:Int ); // сила рукопашной атаки и\или ближний бой урон. + переносимый вес + шанс нокаута в ближнем бою выше, сопротивление нокауту
    Dexterity( _:Int ); // общая скорость увеличена + уворот от ближнего боя + обращение с оружием дальнего боя
    Endurance( _:Int ); // HP + сопротивление болезням/ядам + сопротивление боль и уменьшение времени нахождения в нокауте.
    Intellect( _:Int ); // множитель обучения скилам
    MovementSpeed( _:Int ); // by default 1000 // dex*15;
    EatingSpeed( _:Int ); // by default 1000 / currentSkillInt * item using speed;
    FirstAidSpeed( _:Int );// by default 1000
    BandagingSpeed( _:Int );// by default 1000
    DoctorSpeed( _:Int );// by default 1000
    EquipItemSpeed( _:Int );// by default 1000
    ChangeWeaponSpeed( _:Int );// by default 1000
    MeleeDamage( _:Int ); // str + str/4;
    RangedDamage( _:Int ); // dex/2 + int/2;
    BlockMeleeDamage( _:Int );
    EvadeMeleeDamage( _:Int );
    BlockRangedDamage( _:Int );
    EvadeRangedDamage( _:Int );
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
    public var firstAidSpeed:Stat; // first aid - damaged parts restore;
    public var doctorSpeed:Stat; // do doctor things;
    public var bandagingSpeed:Stat; // do bandages for stop bleeding;
    public var eatingSpeed:Stat; // eat some food;
    public var equipItemSpeed:Stat;
    public var changeWeaponSpeed:Stat;

    public var meleeDamage:Stat;
    public var rangedDamage:Stat;
    public var blockMeleeDamage:Stat;
    public var evadeMeleeDamage:Stat;
    public var blockRangedDamage:Stat;
    public var evadeRangedDamage:Stat;

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

        this.strength = this._createStat( "strength" );
        this.dexterity = this._createStat( "dexterity" );
        this.endurance = this._createStat( "endurance" );
        this.intellect = this._createStat( "intellect" );

        this.movementSpeed = this._createStat( "movementSpeed" );
        this.bandagingSpeed = this._createStat( "bandagingSpeed" );
        this.firstAidSpeed = this._createStat( "firstAidSpeed" );
        this.doctorSpeed = this._createStat( "doctorSpeed" );
        this.eatingSpeed = this._createStat( "eatingSpeed" );
        this.equipItemSpeed = this._createStat( "equipItemSpeed" );
        this.changeWeaponSpeed = this._createStat( "changeWeaponSpeed" );

        this.meleeDamage = this._createStat( "meleeDamage" );
        this.rangedDamage = this._createStat( "rangedDamage" );
        this.blockMeleeDamage = this._createStat( "blockMeleeDamage" );
        this.blockRangedDamage = this._createStat( "blockRangedDamage" );
        this.evadeMeleeDamage = this._createStat( "evadeMeleeDamage" );
        this.evadeRangedDamage = this._createStat( "evadeRangedDamage" );

        this.kineticResistance = this._createStat( "kineticResistance" );
        this.fireResistance = this._createStat( "fireResistance" );
        this.electricResistance = this._createStat( "electricResistance" );
        this.plasmaResistance = this._createStat( "plasmaResistance" );
        this.laserResistance = this._createStat( "laserResistance" );
        this.poisonResistance  = this._createStat( "poisonResistance" );
        this.knockdownResistance = this._createStat( "knockdownResistance" );
        this.diseaseResistance = this._createStat( "diseaseResistance" ); 
        this.bleedingResistance = this._createStat( "bleedingResistance" );
        this.painResistance = this._createStat( "painResistance" ); 
        
        this._setValueToStat( "strength", "base", config.STR );
        this._setValueToStat( "dexterity", "base", config.DEX ); 
        this._setValueToStat( "endurance", "base", config.END ); 
        this._setValueToStat( "intellect", "base", config.INT );
        this._setValueToStat( "movementSpeed", "base", config.MoveSPD );        
        this._setValueToStat( "bandagingSpeed", "base", config.BandagingSPD ); 
        this._setValueToStat( "firstAidSpeed", "base", config.FirstAidSPD );
        this._setValueToStat( "doctorSpeed", "base", config.DoctorSDP );
        this._setValueToStat( "eatingSpeed", "base", config.EatingSPD );
        this._setValueToStat( "equipItemSpeed", "base", config.EquipItemSPD );
        this._setValueToStat( "changeWeaponSpeed", "base", config.ChangeWeaponSPD );
        this._setValueToStat( "meleeDamage", "base", config.MATK );
        this._setValueToStat( "rangedDamage", "base", config.RATK );
        this._setValueToStat( "blockMeleeDamage", "base", config.BlockMD );
        this._setValueToStat( "blockRangedDamage", "base", config.BlockRD );
        this._setValueToStat( "evadeMeleeDamage", "base", config.EvadeMD );
        this._setValueToStat( "evadeRangedDamage", "base", config.EvadeRD );
        this._setValueToStat( "kineticResistance", "base", config.KiRes );
        this._setValueToStat( "fireResistance", "base", config.FiRes );
        this._setValueToStat( "electricResistance", "base", config.ElRes );
        this._setValueToStat( "plasmaResistance", "base", config.PlRes );
        this._setValueToStat( "laserResistance", "base", config.LaRes );
        this._setValueToStat( "poisonResistance", "base", config.PoRes ); 
        this._setValueToStat( "knockdownResistance", "base", config.KnRes );
        this._setValueToStat( "diseaseResistance", "base", config.DiRes );
        this._setValueToStat( "bleedingResistance", "base", config.BlRes );
        this._setValueToStat( "painResistance", "base", config.PaRes );

        this._setValueToStat( "strength", "current", config.STR );
        this._setValueToStat( "dexterity", "current", config.DEX );
        this._setValueToStat( "endurance", "current", config.END );
        this._setValueToStat( "intellect", "current", config.INT );
        this._setValueToStat( "movementSpeed", "current", this._calculateCurrentStatValue( "movementSpeed" ));
        this._setValueToStat( "bandagingSpeed", "current", this._calculateCurrentStatValue( "bandagingSpeed" ));
        this._setValueToStat( "firstAidSpeed", "current", this._calculateCurrentStatValue( "firstAidSpeed" ));
        this._setValueToStat( "doctorSpeed", "current", this._calculateCurrentStatValue( "doctorSpeed" ));
        this._setValueToStat( "eatingSpeed", "current", this._calculateCurrentStatValue( "eatingSpeed" ));
        this._setValueToStat( "equipItemSpeed", "current", this._calculateCurrentStatValue( "equipItemSpeed" ));
        this._setValueToStat( "changeWeaponSpeed", "current", this._calculateCurrentStatValue( "changeWeaponSpeed" ));
        this._setValueToStat( "meleeDamage", "current", this._calculateCurrentStatValue( "meleeDamage" ));
        this._setValueToStat( "rangedDamage", "current", this._calculateCurrentStatValue( "rangedDamage" ));
        this._setValueToStat( "blockMeleeDamage", "current", this._calculateCurrentStatValue( "blockMeleeDamage" ));
        this._setValueToStat( "blockRangedDamage", "current", this._calculateCurrentStatValue( "blockRangedDamage" ));
        this._setValueToStat( "evadeMeleeDamage", "current", this._calculateCurrentStatValue( "evadeMeleeDamage" ));
        this._setValueToStat( "evadeRangedDamage", "current", this._calculateCurrentStatValue( "evadeRangedDamage" ));
        this._setValueToStat( "kineticResistance", "current", this._calculateCurrentStatValue( "kineticResistance" ));
        this._setValueToStat( "fireResistance", "current", this._calculateCurrentStatValue( "fireResistance" ));
        this._setValueToStat( "electricResistance", "current", this._calculateCurrentStatValue( "electricResistance" ));
        this._setValueToStat( "plasmaResistance", "current", this._calculateCurrentStatValue( "plasmaResistance" ));
        this._setValueToStat( "laserResistance", "current", this._calculateCurrentStatValue( "laserResistance" ));
        this._setValueToStat( "poisonResistance", "current", this._calculateCurrentStatValue( "poisonResistance" ));
        this._setValueToStat( "knockdownResistance", "current", this._calculateCurrentStatValue( "knockdownResistance" ));
        this._setValueToStat( "diseaseResistance", "current", this._calculateCurrentStatValue( "diseaseResistance" ));
        this._setValueToStat( "bleedingResistance", "current", this._calculateCurrentStatValue( "bleedingResistance" ));
        this._setValueToStat( "painResistance", "current", this._calculateCurrentStatValue( "painResistance" ));
        
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

        if( this.getStatValueInt( "firstAidSpeed", "base" ) <= 0 || Math.isNaN( this.getStatValueInt( "firstAidSpeed", "base" )))
            throw '$msg First aid speed not valid';

        if( this.getStatValueInt( "doctorSpeed", "base" ) <= 0 || Math.isNaN( this.getStatValueInt( "doctorSpeed", "base" )))
            throw '$msg Doctor speed not valid';

        if( this.getStatValueInt( "bandagingSpeed", "base" ) <= 0 || Math.isNaN( this.getStatValueInt( "bandagingSpeed", "base" )))
            throw '$msg Bandaging speed not valid';

        if( this.getStatValueInt( "eatingSpeed", "base" ) <= 0 || Math.isNaN( this.getStatValueInt( "eatingSpeed", "base" )))
            throw '$msg Eating speed not valid';

        if( this.getStatValueInt( "equipItemSpeed", "base" ) <= 0 || Math.isNaN( this.getStatValueInt( "equipItemSpeed", "base" )))
            throw '$msg equip item speed not valid';

        if( this.getStatValueInt( "changeWeaponSpeed", "base" ) <= 0 || Math.isNaN( this.getStatValueInt( "changeWeaponSpeed", "base" )))
            throw '$msg Change Weapon speed not valid';

        if( this.getStatValueInt( "meleeDamage", "base" ) < 0 || Math.isNaN( this.getStatValueInt( "meleeDamage", "base" )))
            throw '$msg Melee Damage not valid';

        if( this.getStatValueInt( "rangedDamage", "base" ) < 0 || Math.isNaN( this.getStatValueInt( "rangedDamage", "base" )))
            throw '$msg Ranged Damage not valid';

        if( this.getStatValueInt( "blockMeleeDamage", "base" ) < 0 || Math.isNaN( this.getStatValueInt( "blockMeleeDamage", "base" )))
            throw '$msg Block Melee damage not valid';

        if( this.getStatValueInt( "blockRangedDamage", "base" ) < 0 || Math.isNaN( this.getStatValueInt( "blockRangedDamage", "base" )))
            throw '$msg Block Ranged damage not valid';

        var evadeMD:Int = this.getStatValueInt( "evadeMeleeDamage", "base" );
        if( evadeMD < -this._resistanceMaxValue || Math.isNaN( evadeMD ) || evadeMD > this._resistanceMaxValue )
            throw '$msg Evade Melee Damage "$evadeMD" not valid';

        var evadeRD:Int = this.getStatValueInt( "evadeRangedDamage", "base" );
        if( evadeRD < -this._resistanceMaxValue || Math.isNaN( evadeRD ) || evadeRD > this._resistanceMaxValue )
            throw '$msg Evade Ranged Damage "$evadeRD" not valid';

        var kiRes:Int = this.getStatValueInt( "kineticResistance", "base" );
        if( kiRes < -this._resistanceMaxValue || Math.isNaN( kiRes ) || kiRes > this._resistanceMaxValue )
            throw '$msg Kinetic Res "$kiRes" not valid';

        var fiRes:Int = this.getStatValueInt( "fireResistance", "base" );
        if( fiRes < -this._resistanceMaxValue || Math.isNaN( fiRes ) || fiRes > this._resistanceMaxValue )
            throw '$msg Fire Res "$fiRes" not valid';

        var elRes:Int = this.getStatValueInt( "electricResistance", "base" );
        if( elRes < -this._resistanceMaxValue || Math.isNaN( elRes ) || elRes > this._resistanceMaxValue )
            throw '$msg Electric Res "$elRes" not valid';

        var plRes:Int = this.getStatValueInt( "plasmaResistance", "base" );
        if( plRes < -this._resistanceMaxValue || Math.isNaN( plRes ) || plRes > this._resistanceMaxValue )
            throw '$msg Plasma Res "$plRes" not valid';

        var laRes:Int = this.getStatValueInt( "laserResistance", "base" );
        if( laRes < -this._resistanceMaxValue || Math.isNaN( laRes ) || laRes > this._resistanceMaxValue )
            throw '$msg Laser Res "$laRes" not valid';

        var poRes:Int = this.getStatValueInt( "poisonResistance", "base" );
        if( poRes < -this._resistanceMaxValue || Math.isNaN( poRes ) || poRes > this._resistanceMaxValue )
            throw '$msg Poison Res "$poRes"not valid';

        var knRes:Int = this.getStatValueInt( "knockdownResistance", "base" );
        if( knRes < -this._resistanceMaxValue || Math.isNaN( knRes ) || knRes > this._resistanceMaxValue )
            throw '$msg Knockdown Res "$knRes" not valid';

        var diRes:Int = this.getStatValueInt( "diseaseResistance", "base" );
        if( diRes < -this._resistanceMaxValue || Math.isNaN( diRes ) || diRes > this._resistanceMaxValue )
            throw '$msg Disease Res "$diRes" not valid';

        var blRes:Int = this.getStatValueInt( "bleedingResistance", "base" );
        if( blRes < -this._resistanceMaxValue || Math.isNaN( blRes ) || blRes > this._resistanceMaxValue )
            throw '$msg Bleeding Res "$blRes" not valid';

        var paRes:Int = this.getStatValueInt( "painResistance", "base" );
        if( paRes < -this._resistanceMaxValue || Math.isNaN( paRes ) || paRes > this._resistanceMaxValue )
            throw '$msg Pain Res "$paRes" not valid';

        this._parent.healthPoints.changeHPModifierForAllBodyParts( this.getModifierForBodyPart());
        this._inited = true;
    }

    public function postInit():Void{
        var msg:String = this._parent.errMsg();
        msg += 'EntityStatSystem.postInit. ';

        if( this._postInited )
            throw '$msg already inited!';

        this._postInited = true;
    }

    public function traceStats():Void{
        var str = this._getStatValue( "strength", "current" );
        var end = this._getStatValue( "endurance", "current" );
        var int = this._getStatValue( "intellect", "current" );
        var dex = this._getStatValue( "dexterity", "current" );
        var mAtk:Int = this._getStatValue( "meleeDamage", "current" );
        var rAtk:Int = this._getStatValue( "rangedDamage", "current" );
        var evadeMD:Int = this._getStatValue( "evadeMeleeDamage", "current" );
        var evadeRD:Int = this._getStatValue( "evadeRangedDamage", "current" );
        var kiRes:Int = this._getStatValue( "kineticResistance", "current" );
        var poRes:Int = this._getStatValue( "poisonResistance", "current" );
        var knRes:Int = this._getStatValue( "knockdownResistance", "current" );
        var diRes:Int = this._getStatValue( "diseaseResistance", "current" );
        var paRes:Int = this._getStatValue( "painResistance", "current" );
        trace( 'STR: $str; DEX: $dex; END: $end; INT: $int; MDMG: $mAtk; RDMG: $rAtk; Evade Melee: $evadeMD; Evade Ranged: $evadeRD; Kinetic: $kiRes; Poison: $poRes; Knockdown: $knRes; Disease: $diRes; Pain: $paRes;');
        var currentHP:Int = switch( this._parent.healthPoints.currentHP ){ case HealthPoint( v ): v; };
        var totalHP:Int = switch( this._parent.healthPoints.totalHP ){ case HealthPoint( v ): v; };
        trace( 'Current HP: $currentHP; Total HP: $totalHP' );
    }


    public inline function getStatValueInt( stat:String, place:String ):Int{
        return this._getStatValue( stat, place );
    }


    public inline function getModifierForBodyPart():Int{
        return this._getStatValue( "endurance", "current" ) * 2;
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
            case "movementSpeed", "meleeDamage", "rangedDamage", "eatingSpeed", "firstAidSpeed", "doctorSpeed", "bandagingSpeed", "equipItemSpeed", "changeWeaponSpeed" :{
                if( statValue <= 0 )
                    return false;
                else
                    return true;
            }
            case "kineticResistance", "electricResistance", "fireResistance", "plasmaResistance", "laserResistance", "poisonResistance", "knockdownResistance", "diseaseResistance",
                    "painResistance", "bleedingResistance", "blockMeleeDamage", "blockRangedDamage", "evadeMeleeDamage", "evadeRangedDamage" :{
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

        var calculatedValue:Int = this._calculateCurrentStatValue( stat );
        var oldValue:Int = this._getStatValue( stat, "current");
        if( oldValue == calculatedValue )
            return;

        this._setValueToStat( stat, "current", calculatedValue );
        this._autoCalculateDependencies( stat, value );
    }

    public function changeStatBaseValue( stat:String, value:Int ):Void{
        //change "base" in stat and calculating "current";
        var statBaseValue:Int = this.getStatValueInt( stat, "base" );
        statBaseValue += value;
        this._setValueToStat( stat, "base", statBaseValue );

        var calculatedValue:Int = this._calculateCurrentStatValue( stat );
        this._setValueToStat( stat, "current", calculatedValue);
        this._autoCalculateDependencies( stat, value );
    }

    public function changePain( value:Int ):Void {
        if( value == 0 )
            return;

        var currentValue:Int = switch( this.pain ){case Pain( v ): v; };
        if( currentValue == this._painMaxValue && value > 0 )
            return;

        if( currentValue == 0 && value < 0 )
            return;

        if( value > 0 )
            currentValue += value - Math.round( value / 100 * this.getStatValueInt( "painResistance", "current" ));
        else
            currentValue += value;

        if( currentValue > this._painMaxValue ){
            this.pain = Pain( this._painMaxValue );
            //knockdown effect add;
        }else if( currentValue < 0 )
            this.pain = Pain( 0 );
        else
            this.pain = Pain( currentValue );

        // Каждые 200 пунктов боли уменьшаем основные статы.
        var statModifier = -1;
        if( value < 0 )
            statModifier = 1;

        if( currentValue%200 == 0 ){
            this.changeStatModifierValue( "strength", statModifier );
            this.changeStatModifierValue( "dexterity", statModifier );
            this.changeStatModifierValue( "intellect", statModifier );
            this.changeStatModifierValue( "endurance", statModifier );
        }        
    }
    








    private function _autoCalculateDependencies( stat:String, value:Int ):Void{
        //TODO;
        var skill:EntitySkillSystem = this._parent.skills;
        var hp:EntityHealthPointsSystem = this._parent.healthPoints;
        var list:Array<String> = [];
        switch( stat ){
            case "strength": {
                list = [ "knockdownResistance", "painResistance", "meleeDamage" ];
                // от силы зависит: ближний бой. переносимый вес. шанс нокаута в ближнем бою, шанс получить нокаут;
                //переносимый вес в инвентаре
                //шанс нокаута в скилах                
            };
            case "intellect": {
                list = [ "rangedDamage" ];
                var statValue:Int = this.getStatValueInt( stat, "current" );
                if( skill != null )
                    this._parent.skills.skillGrowupMultiplier = Math.round( statValue / 5 );
            };
            case "dexterity": {
                list = [ "movementSpeed", "firstAidSpeed", "doctorSpeed", "eatingSpeed", "equipItemSpeed", "bandagingSpeed", "changeWeaponSpeed", "rangedDamege", "evadeMeleeDamage", "evadeRangedDamage" ];
            };
            case "endurance": {
                list = [ "poisonResistance", "diseaseResistance", "bleedingResistance", "painResistance" ];
                var modifier:Int = ( this.getStatValueInt( "endurance", "current" ) - value ) * 2 - this.getModifierForBodyPart() ;// old stat value - current stat value;
                hp.changeHPModifierForAllBodyParts( -modifier ); // увеличиваем или уменьшаем модифер для ХП системы.
            };
            for( i in 0...list.length ){
                this._setValueToStat( list[ i ], "current", this._calculateCurrentStatValue( list[ i ] ));
            }
        }
    }

    private function _calculateCurrentStatValue( stat:String ):Int{
        var baseValue:Int = this.getStatValueInt( stat, "base" );
        var modifierValue:Int = this.getStatValueInt( stat, "modifier" );
        var value:Int = baseValue + modifierValue;
        var strValue:Int = this.getStatValueInt( "strength", "current" );
        var dexValue:Int = this.getStatValueInt( "dexterity", "current" );
        var intValue:Int = this.getStatValueInt( "intellect", "current" );
        var endValue:Int = this.getStatValueInt( "endurance", "current" );
        switch( stat ){
            case "strength", "dexterity", "intellect", "endurance":{
                if( value > this._statsMaxValue )
                    value = this._statsMaxValue;
                if( value <= 0 )
                    value = 1;
            };
            case "meleeDamage":{
                value += strValue + Math.ceil( strValue / 4 );
                if( value <= 0 )
                    value = 1;

                trace( 'Melee Damage : $value' );
            };
            case "rangedDamage":{
                value += Math.ceil( dexValue / 2 + intValue / 2 );
                if( value <= 0 )
                    value = 1;
            };
            case "movementSpeed", "firstAidSpeed", "doctorSpeed", "eatingSpeed", "equipItemSpeed", "bandagingSpeed", "changeWeaponSpeed":{
                value += dexValue * 15;
                if( value <= 0 )
                    value = 1;
            };
            case "poisonResistance", "diseaseResistance", "bleedingResistance":{
                value += endValue * 2;
                if( value < -this._resistanceMaxValue )
                    value = -this._resistanceMaxValue;
                else if( value > this._resistanceMaxValue )
                    value = this._resistanceMaxValue;
            };
            case "painResistance":{
                value += strValue * 2 + endValue;
                if( value < -this._resistanceMaxValue )
                    value = -this._resistanceMaxValue;
                else if( value > this._resistanceMaxValue )
                    value = this._resistanceMaxValue;
            };
            case "knockdownResistance":{
                value += strValue * 2 + Math.ceil( strValue / 5 );
                if( value < -this._resistanceMaxValue )
                    value = -this._resistanceMaxValue;
                else if( value > this._resistanceMaxValue )
                    value = this._resistanceMaxValue;
            };
            case "evadeMeleeDamage":{
                value += Math.ceil( dexValue + dexValue / 2 );
                if( value < -this._resistanceMaxValue )
                    value = -this._resistanceMaxValue;
                else if( value > this._resistanceMaxValue )
                    value = this._resistanceMaxValue;
            };
            case "evadeRangedDamage":{
                value += Math.ceil( dexValue / 2 );
                if( value < -this._resistanceMaxValue )
                    value = -this._resistanceMaxValue;
                else if( value > this._resistanceMaxValue )
                    value = this._resistanceMaxValue;
            }
            case "kineticResistance", "electricResistance", "fireResistance", "plasmaResistance", "laserResistance":{
                if( value < -this._resistanceMaxValue )
                    value = -this._resistanceMaxValue;
                else if( value > this._resistanceMaxValue )
                    value = this._resistanceMaxValue;
            }
            case "blockMeleeDamage", "blockRangedDamage":{
                if( value < 0 )
                    value = 0;
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
            case "eatingSpeed":{
                switch( place ){
                    case "current": this.eatingSpeed.Current = EatingSpeed( value );
                    case "modifier": this.eatingSpeed.Modifier = EatingSpeed( value );
                    case "base": this.eatingSpeed.Base = EatingSpeed( value );
                }
            };
            case "equipItemSpeed":{
                switch( place ){
                    case "current": this.equipItemSpeed.Current = EquipItemSpeed( value );
                    case "modifier": this.equipItemSpeed.Modifier = EquipItemSpeed( value );
                    case "base": this.equipItemSpeed.Base = EquipItemSpeed( value );
                }
            };
            case "changeWeaponSpeed":{
                switch( place ){
                    case "current": this.changeWeaponSpeed.Current = ChangeWeaponSpeed( value );
                    case "modifier": this.changeWeaponSpeed.Modifier = ChangeWeaponSpeed( value );
                    case "base": this.changeWeaponSpeed.Base = ChangeWeaponSpeed( value );
                }
            };
            case "firstAidSpeed":{
                switch( place ){
                    case "current": this.firstAidSpeed.Current = FirstAidSpeed( value );
                    case "modifier": this.firstAidSpeed.Modifier = FirstAidSpeed( value );
                    case "base": this.firstAidSpeed.Base = FirstAidSpeed( value );
                }
            };
            case "bandagingSpeed":{
                switch( place ){
                    case "current": this.bandagingSpeed.Current = BandagingSpeed( value );
                    case "modifier": this.bandagingSpeed.Modifier = BandagingSpeed( value );
                    case "base": this.bandagingSpeed.Base = BandagingSpeed( value );
                }
            };
            case "doctorSpeed":{
                switch( place ){
                    case "current": this.doctorSpeed.Current = DoctorSpeed( value );
                    case "modifier": this.doctorSpeed.Modifier = DoctorSpeed( value );
                    case "base": this.doctorSpeed.Base = DoctorSpeed( value );
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
            case "blockMeleeDamage":{
                switch( place ){
                    case "current": this.blockMeleeDamage.Current = BlockMeleeDamage( value );
                    case "modifier": this.blockMeleeDamage.Modifier = BlockMeleeDamage( value );
                    case "base": this.blockMeleeDamage.Base = BlockMeleeDamage( value );
                }
            };
            case "blockRangedDamage":{
                switch( place ){
                    case "current": this.blockRangedDamage.Current = BlockRangedDamage( value );
                    case "modifier": this.blockRangedDamage.Modifier = BlockRangedDamage( value );
                    case "base": this.blockRangedDamage.Base = BlockRangedDamage( value );
                }
            };
            case "evadeRangedDamage":{
                switch( place ){
                    case "current": this.evadeRangedDamage.Current = EvadeRangedDamage( value );
                    case "modifier": this.evadeRangedDamage.Modifier = EvadeRangedDamage( value );
                    case "base": this.evadeRangedDamage.Base = EvadeRangedDamage( value );
                }
            };
            case "evadeMeleeDamage":{
                switch( place ){
                    case "current": this.evadeMeleeDamage.Current = EvadeMeleeDamage( value );
                    case "modifier": this.evadeMeleeDamage.Modifier = EvadeMeleeDamage( value );
                    case "base": this.evadeMeleeDamage.Base = EvadeMeleeDamage( value );
                }
            };
            case "kineticResistance":{
                switch( place ){
                    case "current": this.kineticResistance.Current = KineticResistance( value );
                    case "modifier": this.kineticResistance.Modifier = KineticResistance( value );
                    case "base": this.kineticResistance.Base = KineticResistance( value );
                }
            };
            case "electricResistance":{
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

        var container:Stat;
        switch( stat ){
            case "strength": container = this.strength;
            case "endurance": container = this.endurance;
            case "dexterity": container = this.dexterity;
            case "intellect": container = this.intellect;
            case "meleeDamage": container = this.meleeDamage;
            case "rangedDamage": container = this.rangedDamage;
            case "blockMeleeDamage": container = this.blockMeleeDamage;
            case "blockRangedDamage": container = this.blockRangedDamage;
            case "evadeMeleeDamage": container = this.evadeMeleeDamage;
            case "evadeRangedDamage": container = this.evadeRangedDamage;
            case "movementSpeed": container = this.movementSpeed;
            case "bandagingSpeed": container = this.bandagingSpeed;
            case "firstAidSpeed": container = this.firstAidSpeed;
            case "doctorSpeed": container = this.doctorSpeed;
            case "eatingSpeed": container = this.eatingSpeed;
            case "equipItemSpeed": container = this.equipItemSpeed;
            case "changeWeaponSpeed": container = this.changeWeaponSpeed;
            case "kineticResistance": container = this.kineticResistance;
            case "electricResistance": container = this.electricResistance;
            case "laserResistance": container = this.laserResistance;
            case "plasmaResistance": container = this.plasmaResistance;
            case "fireResistance": container = this.fireResistance;
            case "poisonResistance": container = this.poisonResistance;
            case "diseaseResistance": container = this.poisonResistance;
            case "knockdownResistance": container = this.knockdownResistance;
            case "bleedingResistance": container = this.bleedingResistance;
            case "painResistance": container = this.painResistance;
            default: throw '$msg';
        }
        return container;
    }

    private function _getStatValue( stat:String, place:String ):Int{
        var msg:String = this._errMsg() + "_getStatValue";
        var container:Stat = this._getStatContainer( stat );
        var newContainer:Stats;
        switch( place ){
            case "current": newContainer = container.Current;
            case "modifier":newContainer = container.Modifier;
            case "base": newContainer = container.Base;
            default: throw '$msg "$place" is not valid';
        }
        switch( newContainer ){
            case Strength( v ):return v;
            case Dexterity( v ): return v;
            case Endurance( v ): return v;
            case Intellect( v ): return v;
            case MovementSpeed( v ): return v;
            case EatingSpeed( v ): return v;
            case FirstAidSpeed( v ): return v;
            case DoctorSpeed( v ): return v;
            case BandagingSpeed( v ):return v;
            case EquipItemSpeed( v ): return v;
            case ChangeWeaponSpeed( v ): return v;
            case MeleeDamage( v ): return v;
            case RangedDamage( v ): return v;
            case BlockMeleeDamage( v ): return v;
            case BlockRangedDamage( v ): return v;
            case EvadeRangedDamage( v ): return v;
            case EvadeMeleeDamage( v ): return v;
            case KineticResistance( v ): return v;
            case FireResistance( v ): return v;
            case ElectricResistance( v ): return v;
            case PlasmaResistance( v ): return v;
            case LaserResistance( v ): return v;
            case PoisonResistance( v ): return v;
            case KnockdownResistance( v ): return v;
            case DiseaseResistance( v ):return v;
            case BleedingResistance( v ): return v;
            case PainResistance( v ): return v;
        }
    }
    private function _createStat( stat:String ):Stat{
        var msg:String = this._errMsg() + "_createStat.";
        switch( stat ){
            case "strength": return { Current: Strength( 0 ), Modifier: Strength( 0 ), Base: Strength( 0 )};
            case "endurance": return { Current: Endurance( 0 ), Modifier: Endurance( 0 ), Base: Endurance( 0 )};
            case "dexterity": return { Current: Dexterity( 0 ), Modifier: Dexterity( 0 ), Base: Dexterity( 0 )};
            case "intellect": return { Current: Intellect( 0 ), Modifier: Intellect( 0 ), Base: Intellect( 0 )};
            case "meleeDamage": return { Current: MeleeDamage( 0 ), Modifier: MeleeDamage( 0 ), Base: MeleeDamage( 0 )};
            case "rangedDamage": return { Current: RangedDamage( 0 ), Modifier: RangedDamage( 0 ), Base: RangedDamage( 0 )};
            case "blockMeleeDamage": return { Current: BlockMeleeDamage( 0 ), Modifier: BlockMeleeDamage( 0 ), Base: BlockMeleeDamage( 0 )};
            case "blockRangedDamage": return { Current: BlockRangedDamage( 0 ), Modifier: BlockRangedDamage( 0 ), Base: BlockRangedDamage( 0 )};
            case "evadeMeleeDamage": return { Current: EvadeMeleeDamage( 0 ), Modifier: EvadeMeleeDamage( 0 ), Base: EvadeMeleeDamage( 0 )};
            case "evadeRangedDamage": return { Current: EvadeRangedDamage( 0 ), Modifier: EvadeRangedDamage( 0 ), Base: EvadeRangedDamage( 0 )};
            case "movementSpeed": return { Current: MovementSpeed( 0 ), Modifier: MovementSpeed( 0 ), Base: MovementSpeed( 0 )};
            case "bandagingSpeed": return { Current: BandagingSpeed( 0 ), Modifier: BandagingSpeed( 0 ), Base: BandagingSpeed( 0 )};
            case "firstAidSpeed": return { Current: FirstAidSpeed( 0 ), Modifier: FirstAidSpeed( 0 ), Base: FirstAidSpeed( 0 )};
            case "doctorSpeed": return { Current: DoctorSpeed( 0 ), Modifier: DoctorSpeed( 0 ), Base: DoctorSpeed( 0 )};
            case "eatingSpeed": return { Current: EatingSpeed( 0 ), Modifier: EatingSpeed( 0 ), Base: EatingSpeed( 0 )};
            case "equipItemSpeed": return { Current: EquipItemSpeed( 0 ), Modifier: EquipItemSpeed( 0 ), Base: EquipItemSpeed( 0 )};
            case "changeWeaponSpeed": return { Current: ChangeWeaponSpeed( 0 ), Modifier: ChangeWeaponSpeed( 0 ), Base: ChangeWeaponSpeed( 0 )};
            case "kineticResistance": return { Current: KineticResistance( 0 ), Modifier: KineticResistance( 0 ), Base: KineticResistance( 0 )};
            case "electricResistance": return { Current: ElectricResistance( 0 ), Modifier: ElectricResistance( 0 ), Base: ElectricResistance( 0 )};
            case "laserResistance": return { Current: LaserResistance( 0 ), Modifier: LaserResistance( 0 ), Base: LaserResistance( 0 )};
            case "plasmaResistance": return { Current: PlasmaResistance( 0 ), Modifier: PlasmaResistance( 0 ), Base: PlasmaResistance( 0 )};
            case "fireResistance": return { Current: FireResistance( 0 ), Modifier: FireResistance( 0 ), Base: FireResistance( 0 )};
            case "poisonResistance": return { Current: PoisonResistance( 0 ), Modifier: PoisonResistance( 0 ), Base: PoisonResistance( 0 )};
            case "diseaseResistance": return { Current: DiseaseResistance( 0 ), Modifier: DiseaseResistance( 0 ), Base: DiseaseResistance( 0 )};
            case "knockdownResistance": return { Current: KnockdownResistance( 0 ), Modifier: KnockdownResistance( 0 ), Base: KnockdownResistance( 0 )};
            case "bleedingResistance": return { Current: BleedingResistance( 0 ), Modifier: BleedingResistance( 0 ), Base: BleedingResistance( 0 )};
            case "painResistance": return { Current: PainResistance( 0 ), Modifier: PainResistance( 0 ), Base: PainResistance( 0 )};
            default: throw '$msg "$stat" is not valid';
        }
    }

    private inline function _errMsg():String{
        return this._parent.errMsg() + "EntityHealthPointsSystem.";
    }
}