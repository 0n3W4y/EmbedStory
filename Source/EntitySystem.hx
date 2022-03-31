package;

enum EntityDeployID{
    EntityDeployID( _:Int );
}

class EntitySystem{

    private var _parent:Game;
    private var _deploy:Deploy;

    public function new( parent:Game ):Void{
        this._parent = parent;
        this._deploy = parent.deploy;
    }

    public function createEntity( type:String, subType:String ):Entity{
        switch( type ){
            case "rock": return this._createRockEntity( subType );
            default: throw 'Error in EntitySystem.createEntity. Type "$type" is now available.';
        }
        return null;
    }

    public function createEntityByID( id:EntityDeployID ):Entity{
        var config:Dynamic = this._deploy.entityConfig[ id ];
        return null;
    }



    private function _createRockEntity( subType:String ):Entity{
        var config:Dynamic = null;
        for( key in this._deploy.entityConfig ){
            var value:Dynamic = this._deploy.entityConfig[ key ];
            var valueType = Reflect.getProperty( value, "type" );
            var valueSubType = Reflect.getProperty( value, "subType" );
            if( valueType == "rock" && valueSubType == subType )
                config = value;
        }

        if( config == null )
            throw 'Error in EntitySystem._createRockEntity. No Config found for entity with type "rock" and sub type "$subType".';

        var entity:Entity = new Entity();
    }

}