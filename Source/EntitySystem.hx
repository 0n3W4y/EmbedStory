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
    }

    public function createEntity( type:String, subType:String ):Entity {
        var config:Dynamic = null;  
        for( key in this._deploy.entityConfig ){
            var value:Dynamic = this._deploy.entityConfig[ key ];
            var valueType = Reflect.getProperty( value, "type" );
            var valueSubType = Reflect.getProperty( value, "subType" );
            if( valueType == type && valueSubType == subType )
                config = Reflect.getProperty( value, "systems" );

        }

        if( config == null )
            throw 'Error in EntitySystem._createRockEntity. No Config found for entity with type "$type" and sub type "$subType".';

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
        

        for( key in Reflect.fields( params )){
            var value:Dynamic = Reflect.getProperty( params, key );
            switch( key ){
                case "hp": {};
                case "age": {};
                case "name": nameSystemConfig = this._createNameSystemConfig( value );
                default: throw 'Error in EntitySystem._createRockEntity. No system found with key "$key".';
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
            var value = Reflect.getProperty( config, key );
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
        var ageSystemConfig:EntityAgeSystemConfig = { Phases: null, Year: null, Month: null, Day: null, Hour: null, Minute: null };
        return null;
    }

    private function _createHPSystemConfig( config:Dynamic ):EntityHealthPointsSystemConfig{
        var hpSystemConfig:EntityHealthPointsSystemConfig = { Torso: null, LeftHand: null, LeftLeg: null, RightHand: null, RightLeg: null, Head: null };
        return null;
    }

    private function _createEntityID():Int{
        var value:Int = this._entityID;
        this._entityID++;
        return value;
    }

}