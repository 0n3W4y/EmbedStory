package;

import openfl.display.Sprite;

enum TileID
{
	TileID( _:Int );
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
    var CanPlayerStand:Int;
    var Index:Int;
}

class Tile {
    public var tileSize:Int;
    public var groundType:String; // earth, water, rock, sandstone, shallow, dryGround;
    public var floorType:String; // grass, rockroad, woodenfloor, sand;
    public var gridX:Int;
    public var gridY:Int;
    public var graphicsX:Int;
    public var graphicsY:Int;

    public var movementRatio:Int;
    public var isWalkable:Int;
    public var canPlaceObjects:Int;
    public var canPlayerStand:Int;

    public var tileGroundSprite:Sprite;
    public var tileFloorSprite:Sprite;

    private var _id:TileID;
    private var _init:Bool;
    private var _postInit:Bool;
    private var _index:Int;

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
        this.canPlaceObjects = 1;

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

}