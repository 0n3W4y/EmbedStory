package;


typedef DeployConfig = {
    var FloorTypeConfig:Dynamic;
    var BiomeConfig:Dynamic;
    var GroundTypeConfig:Dynamic;
}

class Deploy{

    public var floorTypeConfig:Map<String, Map<String, Dynamic>>;
    public var groundTypeConfig:Map<String, Map<String, Dynamic>>;
    public var biomeConfig:Map<String, Map<String, Dynamic>>;

    private var _parent:Game;

    public function new( parent:Game, params:DeployConfig ):Void{
        this._parent = parent;
        //this.floorTypeConfig = params.FloorTypeConfig;
        //this.groundTypeConfig = params.GroundTypeConfig;
        //this.biomeConfig = params.BiomeConfig;

        this.floorTypeConfig = new Map<String, Map<String, Dynamic>>();
		for( key in Reflect.fields( params.FloorTypeConfig )){
			//var key:String = Std.parseInt( key );
			this.floorTypeConfig[ key ] = Reflect.getProperty( params.FloorTypeConfig, key );
		}

        this.groundTypeConfig = new Map<String, Map<String, Dynamic>>();
        for( key in Reflect.fields( params.GroundTypeConfig )){
            this.groundTypeConfig[ key ] = Reflect.getProperty( params.GroundTypeConfig, key );
        }

        this.biomeConfig = new Map<String, Map<String, Dynamic>>();
        for( key in Reflect.fields( params.BiomeConfig )){
            this.biomeConfig[ key ] = Reflect.getProperty( params.BiomeConfig, key );
        }
    }

    public function getParent():Game{
        return this._parent;
    }
}