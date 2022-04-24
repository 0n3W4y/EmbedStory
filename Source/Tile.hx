package;

import Entity.EntityID;
import openfl.display.Sprite;


enum FloorTypeDeployID{
    FloorTypeDeployID( _:Int );
}

enum GroundTypeDeployID{
    GroundTypeDeployID( _:Int );
}

typedef TileConfig = {
    var GridX:Int;
    var GridY:Int;
    var TileSize:Int;
    var GroundType:String;
    var FloorType:String;
    var IsWalkable:Bool;
    var MovementRatio:Int;
    var CanPlaceFloor:Bool;
    var CanRemoveFloor:Bool;
    var CanPlaceObjects:Bool;
    var CanPlaceStaff:Bool;
    var CanCharacterStand:Bool;
    var Index:Int;
    var FloorDeployID: FloorTypeDeployID;
    var GroundDeployID: GroundTypeDeployID;
}

class Tile {
    public var tileSize:Int;
    public var groundType:String; // earth, water, rock, sandstone, shallow, dirt, dryEarth;
    public var groundTypeGraphicIndex:Int;
    public var floorType:String; // grass, rockroad, woodenfloor, sand;
    public var floorTypeGraphicIndex:Int;
    public var gridX:Int;
    public var gridY:Int;
    public var graphX:Int;
    public var graphY:Int;

    public var movementRatio:Int;
    public var isWalkable:Bool;
    public var canPlaceFloor:Bool;
    public var canRemoveFloor:Bool;
    public var canPlaceObjects:Bool;
    public var canPlaceStaff:Bool;
    public var canCharacterStand:Bool;

    public var currentObject:EntityID;
    public var currentStuff:EntityID;
    public var currentCharacter:EntityID;
    public var currentEffect:Dynamic;

    public var hasRockFog:Bool;

    public var floorGraphicIndex:Int;

    public var tileGroundSprite:Sprite;
    public var tileFloorSprite:Sprite;

    private var _init:Bool;
    private var _postInit:Bool;
    private var _index:Int;
    private var _groundTypeDeployID:GroundTypeDeployID;
    private var _floorTypeDeployID:FloorTypeDeployID;

    public function new( params:TileConfig ):Void {
        this.gridX = params.GridX;
        this.gridY = params.GridY;
        this.tileSize = params.TileSize;
        this.groundType = params.GroundType;
        this.isWalkable = params.IsWalkable;
        this.floorType = params.FloorType;
        this.movementRatio = params.MovementRatio;
        this._index = params.Index;
        this.canPlaceFloor = params.CanPlaceFloor;
        this.canRemoveFloor = params.CanRemoveFloor;
        this.canPlaceObjects = params.CanPlaceObjects;
        this.canPlaceStaff = params.CanPlaceStaff;
        this.canCharacterStand = params.CanCharacterStand;
        this._floorTypeDeployID = params.FloorDeployID;
        this._groundTypeDeployID = params.GroundDeployID;

        this.currentCharacter = null;
        this.currentObject = null;
        this.currentStuff = null;
        this.currentEffect = null;
        
        this.hasRockFog = false;

        this._init = false;
        this._postInit = false;        

        this.calculateGraphicsPosition();
    }

    public function init():Void {
        var errMsg:String = 'Error in Tile.init. ';

        if( this._init )
            trace( 'Tile already inited' );

        if( this.gridX == -1 )
            throw '$errMsg GridX is not valid';

        if( this.gridY == -1 )
            throw '$errMsg GridY is not valid';

        if( this.tileSize == -1 )
            throw '$errMsg Tile Size is not valid';

        if( this.groundType == null )
            throw '$errMsg Ground type is null';

        if( this.floorType == null )
            throw '$errMsg Floor type is null';

        if( this.graphX == -1 )
            throw '$errMsg Graphics X is not valid';

        if( this.graphY == -1 )
            throw '$errMsg Graphics Y is not valid';

        if( this.movementRatio == -1 )
            throw '$errMsg Movement ratio is not valid';

        if( this._floorTypeDeployID == null )
            throw '$errMsg Floor type deploy ID is null';

        if( this._groundTypeDeployID == null )
            throw '$errMsg Ground type deploy ID is null';

        if( !Std.isOfType( this._index, Int ))
            throw '$errMsg Index is not valid';

        this._init = true;
    }

    public function postInit():Void {
        var errMsg:String = 'Error in Tile.postInit. ';
        
        if( this._postInit )
            trace( 'Tile already post inited' );
        //check sprites;
    }

    public function calculateGraphicsPosition():Void {
        this.graphX = tileSize * this.gridX;
        this.graphY = tileSize * this.gridY;
    }

    public function getIndex():Int{
        return this._index;
    }

    public function changeFloorType( params:Dynamic ):Void{
        this.floorType = Reflect.getProperty( params, "floorType" );
        var deployID:Int = Reflect.getProperty( params, "id" );
        this._floorTypeDeployID = FloorTypeDeployID( deployID );
        this._updateFields( params );
    }

    public function changeGroundType( params:Dynamic ):Void{
        this.groundType = Reflect.getProperty( params, "groundType" );
        var deployID:Int = Reflect.getProperty( params, "id" );
        this._groundTypeDeployID = GroundTypeDeployID( deployID );
        this._updateFields( params );
    }

    private function _updateFields( params:Dynamic ):Void{
        for( key in Reflect.fields( params )){
            switch( key ){
                case "movementRatio": this.movementRatio = Reflect.getProperty( params, key );
                case "isWalkable": this.isWalkable = Reflect.getProperty( params, key );
                case "canPlaceFloor": this.canPlaceFloor = Reflect.getProperty( params, key );
                case "canRemoveFloor": this.canRemoveFloor = Reflect.getProperty( params, key );
                case "canPlaceObjects": this.canPlaceObjects = Reflect.getProperty( params, key );
                case "canPlayerStand": this.canCharacterStand = Reflect.getProperty( params, key );
                case "canPlaceStaff": this.canPlaceStaff = Reflect.getProperty( params, key );
                case "canCharacterStand": this.canCharacterStand = Reflect.getProperty( params, key );
                case "groundType", "id", "graphics", "floorType":{};
                default: throw 'Error in Tile._updateFields. "$key" not found.';
            }
        }
    }



}