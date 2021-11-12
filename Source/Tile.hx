package;

import openfl.display.Sprite;

enum TileID
{
	TileID( _:Int );
}

enum FloorTypeDeployID{
    FloorTypeDeployID( _:Int );
}

enum GroundTypeDeployID{
    GroundTypeDeployID( _:Int );
}

typedef TileConfig = {
    var ID:TileID;
    var GridX:Int;
    var GridY:Int;
    var TileSize:Int;
    var GroundType:String;
    var FloorType:String;
    var IsWalkable:Int;
    var MovementRatio:Int;
    var CanPlaceObjects:Int;
    var CanPlaceStaff:Int;
    var CanCharacterStand:Int;
    var Index:Int;
}

class Tile {
    public var tileSize:Int;
    public var groundType:String; // earth, water, rock, sandstone, shallow, dirt, dryEarth;
    public var groundTypeGraphicsIndex:Int;
    public var floorType:String; // grass, rockroad, woodenfloor, sand;
    public var floorTypeGraphicIndex:Int;
    public var gridX:Int;
    public var gridY:Int;
    public var graphicsX:Int;
    public var graphicsY:Int;

    public var movementRatio:Int;
    public var isWalkable:Int;
    public var canPlaceObjects:Int;
    public var canPlaceStaff:Int;
    public var canCharacterStand:Int;

    public var tileGroundSprite:Sprite;
    public var tileFloorSprite:Sprite;

    private var _id:TileID;
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
        this._id = params.ID;
        this._index = params.Index;
        this.canPlaceObjects = params.CanPlaceObjects;
        this.canPlaceStaff = params.CanPlaceStaff;
        this.canCharacterStand = params.CanCharacterStand;

        this._init = false;
        this._postInit = false;
        

        this.calculateGraphicsPosition();
    }

    public function init():Void {
        var errMsg:String = 'Error in Tile.init. ';

        if( this._init )
            trace( 'Tile already inited' );

        if( this.gridX == null )
            throw '$errMsg GridX = null';

        if( this.gridY == null )
            throw '$errMsg GridY = null';

        if( this.tileSize == null )
            throw '$errMsg Tile Size = null';

        if( this.groundType == null )
            throw '$errMsg Ground type = null';

        if( this.isWalkable == null )
            throw '$errMsg Is walkable = null';

        if( this.floorType == null )
            throw '$errMsg Floor type = null';

        if( this.graphicsX == null )
            throw '$errMsg Graphics X = null';

        if( this.graphicsY == null )
            throw '$errMsg Graphics Y = null';

        if( this.movementRatio == null )
            throw '$errMsg Movement ratio = null';

        if( this.canPlaceObjects == null )
            throw '$errMsg Can Place objects = null';

        if( this.canCharacterStand == null )
            throw '$errMsg Can player stand = null';

        if( this.canPlaceStaff == null )
            throw '$errMsg Can place staff is null';

        this._init = true;
    }

    public function postInit():Void {
        var errMsg:String = 'Error in Tile.postInit. ';
        if( this._postInit )
            trace( 'Tile already post inited' );
        //check sprites;
    }

    public function calculateGraphicsPosition():Void {
        this.graphicsX = tileSize * this.gridX;
        this.graphicsY = tileSize * this.gridY;
    }

    public function getId():TileID {
        return this._id;
    }

    public function getIndex():Int{
        return this._index;
    }

    public function changeFloorType( params:Dynamic ):Void{
        var deployID:Int = Reflect.getProperty( params, "id" );
        this._floorTypeDeployID = FloorTypeDeployID( deployID );
        this.floorType = Reflect.getProperty( params, "name" );

        if( this.floorType == "nothing" ){
            throw 'Error in Tile.changeFloorType. Floor type is "nothing", use "changeFloorTypeToNothing()"';
            return;
        }        
        this._updateFields( params );
    }

    public function changeFloorTypeToNothing( params:Dynamic ):Void{
        this._floorTypeDeployID = FloorTypeDeployID( 300 );
        this.floorType = "nothing";
        this._updateFields( params ); // params is config groundType;
    }

    public function updateGroundType( params:Dynamic ):Void{
        this.groundType = Reflect.getProperty( params, "name" );
        var deployID:Int = Reflect.getProperty( params, "id" );
        this._groundTypeDeployID = GroundTypeDeployID( deployID );
        this._updateFields( params );
    }

    private function _updateFields( params:Dynamic ):Void{
        for( key in Reflect.fields( params )){
            switch( key ){
                case "movementRatio": this.movementRatio = Reflect.getProperty( params, key );
                case "isWalkable": this.isWalkable = Reflect.getProperty( params, key );
                case "canPlaceObjects": this.canPlaceObjects = Reflect.getProperty( params, key );
                case "canPlayerStand": this.canCharacterStand = Reflect.getProperty( params, key );
                default: {};
            }
        }
    }



}