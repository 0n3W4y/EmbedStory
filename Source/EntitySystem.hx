package;

import EntityRequirementSystem.EntityRequirementSystemConfig;
import EntitySkillSystem.EntitySkillSystemConfig;
import EntityStatsSystem.EntityStatsSystemConfig;
import EntityAISystem.EntityAISystemConfig;
import EntityNameSystem.EntityNameSystemConfig;
import EntityHealthPointsSystem.EntityHealthPointsSystemConfig;
import EntityAgeSystem.EntityAgeSystemConfig;
import Entity.EntityConfig;
import Entity.EntityID;


enum EntityDeployID{
    EntityDeployID( _:Int );
}

class EntitySystem{

    private var _parent:Game;
    private var _deploy:Deploy;
    private var _entityID:Int;

    public function new( parent:Game ):Void{
        this._parent = parent;
        this._deploy = parent.deploy;
        this._entityID = 0;
    }

    public function createEntity( type:String, subType:String ):Entity {
        var config:Dynamic = null;  
        for( value in this._deploy.entityConfig ){
            var valueType = Reflect.getProperty( value, "type" );
            var valueSubType = Reflect.getProperty( value, "subType" );
            if( valueType == type && valueSubType == subType )
                config = value;

        }

        if( config == null )
            throw 'Error in EntitySystem._createEntity. No Config found for entity with type "$type" and sub type "$subType".';

        return this._createEntity( config );
    }

    public function createEntityByDeployID( id:EntityDeployID ):Entity{
        var config:Dynamic = this._deploy.entityConfig[ id ];
        if( config == null )
            throw 'Error in EntitySystem.createEntityByID. No config for entity "$id".';

        return this._createEntity( config );
    }

    public function generateEntityByType( type:String ):Entity {
        return null;
    }



    private function _createEntity( params:Dynamic ):Entity{
        var entityID:EntityID = EntityID( this._createEntityID() );
        var ageSystemConfig:EntityAgeSystemConfig = null;
        var hpSystemConfig:EntityHealthPointsSystemConfig = null;
        var nameSystemConfig:EntityNameSystemConfig = null;
        var aISystemConfig:EntityAISystemConfig = null;
        var statsSystemConfig:EntityStatsSystemConfig = null;
        var skillSystemConfig:EntitySkillSystemConfig = null;
        var requirementSystemConfig:EntityRequirementSystemConfig = null;
        
        var configSystems:Dynamic = Reflect.getProperty( params, "systems" );

        for( key in Reflect.fields( configSystems )){
            var value:Dynamic = Reflect.getProperty( configSystems, key );
            switch( key ){
                case "hp": hpSystemConfig = this._createHPSystemConfig( value );
                case "age": ageSystemConfig = this._createAgeSystemConfig( value );
                case "name": nameSystemConfig = this._createNameSystemConfig( value );
                case "aI": aISystemConfig = this._createAISystemConfig( value );
                case "stats": statsSystemConfig = this._createStatsSystemConfig( value );
                case "skills": skillSystemConfig = this._createSkillSystemConfig( value );
                case "requirement": requirementSystemConfig = this._createRequirementSystemConfig( value );
                default: throw 'Error in EntitySystem._createEntity. No system found with key "$key".';
            }
        }

        var entityConfig:EntityConfig = { 
            EntityType: Reflect.getProperty( params, "type" ),  
            EntitySubType: Reflect.getProperty( params, "subType" ), 
            EntityID: entityID, 
            DeployID: EntityDeployID( Reflect.getProperty( params, "id" )), 
            AgeSystemConfig: ageSystemConfig, 
            HPSystemConfig: hpSystemConfig, 
            NameSystemConfig: nameSystemConfig,
            AISystemConfig: aISystemConfig,
            StatsSystemConfig: statsSystemConfig,
            SkillSystemConfig: skillSystemConfig,
            RequirementSystemConfig: requirementSystemConfig
        };
        var entity:Entity = new Entity( entityConfig );
        return entity;
    }

    private function _createAISystemConfig( config: Dynamic ):EntityAISystemConfig{
        return null;
    }

    private function _createStatsSystemConfig( config: Dynamic ):EntityStatsSystemConfig{
        var str:Int = Reflect.getProperty( config, "str" );
        var end:Int = Reflect.getProperty( config, "end" );
        var dex:Int = Reflect.getProperty( config, "dex" );
        var int:Int = Reflect.getProperty( config, "int" );
        var mAtk:Int = Reflect.getProperty( config, "mAtk" );
        var rAtk:Int = Reflect.getProperty( config, "rAtk" );
        var moveSpd:Int = Reflect.getProperty( config, "moveSpd" );
        var eatSpd:Int = Reflect.getProperty( config, "eatSpd" );
        var fASpd:Int = Reflect.getProperty( config, "firstAidSpd" );
        var bandagSpd:Int = Reflect.getProperty( config, "bandagSpd" );
        var docSpd:Int = Reflect.getProperty( config, "docSpd" );
        var equipISpd:Int = Reflect.getProperty( config, "equipSpd" );
        var chnageWSpd:Int = Reflect.getProperty( config, "changeWeaponSpd" );
        var blockMD:Int = Reflect.getProperty( config, "blockRD" );
        var evadeMD:Int = Reflect.getProperty( config, "evadeMD" );
        var blockRD:Int = Reflect.getProperty( config, "blockRD" );
        var evadeRD:Int = Reflect.getProperty( config, "evadeMD" );
        var kiRes:Int = Reflect.getProperty( config, "kiRes" );
        var fiRes:Int = Reflect.getProperty( config, "fiRes" );
        var elRes:Int = Reflect.getProperty( config, "elRes" );
        var plRes:Int = Reflect.getProperty( config, "plRes" );
        var laRes:Int = Reflect.getProperty( config, "laRes" );
        var poRes:Int = Reflect.getProperty( config, "poRes" );
        var knRes:Int = Reflect.getProperty( config, "knRes" );
        var diRes:Int = Reflect.getProperty( config, "diRes" );
        var blRes:Int = Reflect.getProperty( config, "blRes" );
        var paRes:Int = Reflect.getProperty( config, "paRes" );

        if( Reflect.getProperty( config, "generate" ) == 1 ){
            str = Math.floor( 1 + Math.random() * str );
            end = Math.floor( 1 + Math.random() * end );
            int = Math.floor( 1 + Math.random() * int );
            dex = Math.floor( 1 + Math.random() * dex );
            moveSpd = Math.floor( 1000 + Math.random() * moveSpd );
            eatSpd = Math.floor( 1000 + Math.random() * eatSpd );
            fASpd = Math.floor( 1000 + Math.random() * fASpd );
            bandagSpd = Math.floor( 1000 + Math.random() * bandagSpd );
            docSpd = Math.floor( 1000 + Math.random() * docSpd );
            equipISpd = Math.floor( 1000 + Math.random() * equipISpd );
            chnageWSpd = Math.floor( 1000 + Math.random() * chnageWSpd );
        }
        
        return { 
            STR: str, 
            DEX: dex,
            END: end,
            INT: int,
            MATK: mAtk,
            RATK: rAtk,
            MoveSPD: moveSpd,
            EatingSPD: eatSpd,
            FirstAidSPD: fASpd,
            BandagingSPD: bandagSpd,
            DoctorSDP: docSpd,
            EquipItemSPD: equipISpd,
            ChangeWeaponSPD: chnageWSpd,
            BlockRD: blockRD,
            BlockMD: blockMD,
            EvadeRD: evadeRD,
            EvadeMD: evadeMD,
            KiRes: kiRes,
            FiRes: fiRes, 
            ElRes: elRes, 
            PlRes: plRes, 
            LaRes: laRes,
            PoRes: poRes, 
            KnRes: knRes, 
            DiRes: diRes, 
            BlRes: blRes,
            PaRes: paRes
        };
    }

    private function _createSkillSystemConfig( config: Dynamic ):EntitySkillSystemConfig{
        var skillSystemConfig:EntitySkillSystemConfig = {
            
        };

        return skillSystemConfig;
    }

    private function _createRequirementSystemConfig( config: Dynamic ):EntityRequirementSystemConfig{
        return {
            Hunger: Reflect.getProperty( config, "hunger" ),
            Ratio: Reflect.getProperty( config, "ratio" )
        };
    }

    private function _createNameSystemConfig( config:Dynamic ):EntityNameSystemConfig{
        return {
            Name: Reflect.getProperty( config, "name" ),
            Nickname: Reflect.getProperty( config, "nickname" ),
            Surname: Reflect.getProperty( config, "surname" )
        };
    }

    private function _createAgeSystemConfig( config:Dynamic ):EntityAgeSystemConfig{
        
        if( Reflect.getProperty( config, "generate" ) == 1 ){
            return {
                Phases: Reflect.getProperty( config, "phases" ),
                Year: Math.floor( Math.random() * ( Reflect.getProperty( config, "year" ) + 1 )),
                Month: Math.floor( Math.random() * ( Reflect.getProperty( config, "month" ) + 1 )),
                Day: Math.floor( Math.random() * ( Reflect.getProperty( config, "day" ) + 1 )),
                Hour: Math.floor( Math.random() * ( Reflect.getProperty( config, "hour" ) + 1 )),
                Minute: Math.floor( Math.random() * ( Reflect.getProperty( config, "minute" ) + 1 ))
            };
        }else{
            return {
                Phases: Reflect.getProperty( config, "phases" ),
                Year: Reflect.getProperty( config, "year" ),
                Month: Reflect.getProperty( config, "month" ),
                Day: Reflect.getProperty( config, "day" ),
                Hour: Reflect.getProperty( config, "hour" ),
                Minute: Reflect.getProperty( config, "minute" ) 
            };
        }
    }

    private function _createHPSystemConfig( config:Dynamic ):EntityHealthPointsSystemConfig{
        return {
            Torso: Reflect.getProperty( config, "torso" ),
            LeftHand: Reflect.getProperty( config, "leftHand" ),
            LeftLeg: Reflect.getProperty( config, "leftLeg" ),
            RightHand: Reflect.getProperty( config, "rightHand" ),
            RightLeg: Reflect.getProperty( config, "rightLeg" ),
            Head: Reflect.getProperty( config, "head" )
        };
    }

    private function _createEntityID():Int{
        var value:Int = this._entityID;
        this._entityID++;
        return value;
    }

}