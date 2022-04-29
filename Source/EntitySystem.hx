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
        return { 
            STR: Reflect.getProperty( config, "str" ), 
            DEX: Reflect.getProperty( config, "dex" ),
            END: Reflect.getProperty( config, "end" ),
            INT: Reflect.getProperty( config, "int" ),
            MATK: Reflect.getProperty( config, "matk" ),
            RATK: Reflect.getProperty( config, "ratk" ),
            Pain: Reflect.getProperty( config, "pain" ),
            KiRes: Reflect.getProperty( config, "kires" ),
            FiRes: Reflect.getProperty( config, "fires" ), 
            ElRes: Reflect.getProperty( config, "elres" ), 
            PlRes: Reflect.getProperty( config, "plres" ), 
            LaRes: Reflect.getProperty( config, "lares" ),
            PoRes: Reflect.getProperty( config, "pores" ), 
            KnRes: Reflect.getProperty( config, "knres" ), 
            DiRes: Reflect.getProperty( config, "dires" ), 
            BlRes: Reflect.getProperty( config, "blres" ),
            PaRes: Reflect.getProperty( config, "pares" ) 
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
            LeftLeg: Reflect.getProperty( config, "lefLeg" ),
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