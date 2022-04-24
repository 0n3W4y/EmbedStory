package;

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

    public function generateEntity( type:String ):Entity{
        return null;
    }



    private function _createEntity( params:Dynamic ):Entity{
        var entityID:EntityID = EntityID( this._createEntityID() );
        var ageSystemConfig:EntityAgeSystemConfig = null;
        var hpSystemConfig:EntityHealthPointsSystemConfig = null;
        var nameSystemConfig:EntityNameSystemConfig = null;
        
        var configSystems:Dynamic = Reflect.getProperty( params, "systems" );

        for( key in Reflect.fields( configSystems )){
            var value:Dynamic = Reflect.getProperty( configSystems, key );
            switch( key ){
                case "hp": hpSystemConfig = this._createHPSystemConfig( value );
                case "age": ageSystemConfig = this._createAgeSystemConfig( value );
                case "name": nameSystemConfig = this._createNameSystemConfig( value );
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
            NameSystemConfig: nameSystemConfig 
        };
        var entity:Entity = new Entity( entityConfig );


        return entity;
    }

    private function _createNameSystemConfig( config:Dynamic ):EntityNameSystemConfig{
        var nameSystemConfig:EntityNameSystemConfig = { Name: null, Nickname: null, Surname: null };
        for( key in Reflect.fields( config )){
            var value:String = Reflect.getProperty( config, key );
            switch( key ){
                case "name": nameSystemConfig.Name = value;
                case "surname": nameSystemConfig.Surname = value;
                case "nickname": nameSystemConfig.Nickname = value;
                default: throw 'Error in EntitySystem._createNameSystemConfig. No "$key" found in AgeNameSystemConfig.';
            }
        }

        return nameSystemConfig;
    }

    private function _createAgeSystemConfig( config:Dynamic ):EntityAgeSystemConfig{
        var ageSystemConfig:EntityAgeSystemConfig = { Phases: [], Year: -1, Month: -1, Day: -1, Hour: -1, Minute: -1 };
        var generate:Int = 0;
        for( key in Reflect.fields( config )){
            switch( key ){
                case "phases":ageSystemConfig.Phases = Reflect.getProperty( config, key );
                case "year": ageSystemConfig.Year = Reflect.getProperty( config, key );
                case "month": ageSystemConfig.Month = Reflect.getProperty( config, key );
                case "day": ageSystemConfig.Day = Reflect.getProperty( config, key );
                case "hour": ageSystemConfig.Hour = Reflect.getProperty( config, key );
                case "minute": ageSystemConfig.Minute = Reflect.getProperty( config, key );
                case "generate": generate = Reflect.getProperty( config, key );
                default: throw 'Error in EntitySystem._createAgeSystemConfig. There is no field with key "$key".';
            }
        }

        if( generate == 1 ){ 
            ageSystemConfig.Minute = Math.floor( Math.random() * ( ageSystemConfig.Minute + 1 ));
            ageSystemConfig.Hour = Math.floor( Math.random() * ( ageSystemConfig.Hour + 1 ));
            ageSystemConfig.Day = Math.floor( Math.random() * ( ageSystemConfig.Day + 1 ));
            ageSystemConfig.Month = Math.floor( Math.random() * ( ageSystemConfig.Month + 1 ));
            ageSystemConfig.Year = Math.floor( Math.random() * ( ageSystemConfig.Year + 1 ));
        }

        return ageSystemConfig;
    }

    private function _createHPSystemConfig( config:Dynamic ):EntityHealthPointsSystemConfig{
        var hpSystemConfig:EntityHealthPointsSystemConfig = { Torso: null, LeftHand: null, LeftLeg: null, RightHand: null, RightLeg: null, Head: null };
        for( key in Reflect.fields( config )){
            var value:Dynamic = Reflect.getProperty( config, key );
            switch( key ){
                case "torso": hpSystemConfig.Torso = value;
                case "leftHand": hpSystemConfig.LeftHand = value;
                case "rightHand": hpSystemConfig.RightHand = value;
                case "lefLeg": hpSystemConfig.LeftLeg = value;
                case "rightLeg": hpSystemConfig.RightLeg = value;
                case "head": hpSystemConfig.Head = value;
                default: 'Error in EntitySystem._createHPSystemConfig. There is no field with key "$key".';
            }
        }
        return hpSystemConfig;
    }

    private function _createEntityID():Int{
        var value:Int = this._entityID;
        this._entityID++;
        return value;
    }

}