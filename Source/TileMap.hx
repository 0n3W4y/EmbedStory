package;

import Tile;

/*
typedef BiomeConfig = {
    var GroundType:Map<String, Dynamic>;
    var FloorType:Map<String, Dynamic>;
    var Liquids:Map<String, Dynamic>;
    var Rocks:Map<String, Dynamic>;
    var Resources:Map<String, Dynamic>;
}
*/
typedef TileMapConfig = {
    var Height:Int;
    var Width:Int;
    var Biome:String;
    var TileSize:Int;
    var Parent:Scene;
}

typedef TileMapGeneratedConfig = {
    var RiverConfig:RiverConfig;
    var LakeConfig:LakeConfig;
    var RockConf:RockConfig;
    var ResourseConf:ResourcesConfig;
}

typedef RiverConfig = {
    var River:Bool;
    var RiverWidthMax:Int;
    var RiverWidthMin:Int;
    var RiverOffset:Int;
    var RiverWidthOffset:Int;
    var RiverType:String;
    var RiverGroundType:String;
}

typedef LakeConfig = {
    var Lake:Bool;
    var LakeAmount:Int;
    var LakeWidthMax:Int;
    var LakeWidthMin:Int;
    var LakeHeightMax:Int;
    var LakeHeightMin:Int;
    var LakeOffset:Int;
    var LakeWidthOffset:Int;
    var LakeGroundType:String;
}

typedef RockConfig = {
    var Rock:Bool;
    var RockAmount:Int;
    var RockWidthMax:Int;
    var RockWidthMin:Int;
    var RockHeightMax:Int;
    var RockHeightMin:Int;
    var RockOffset:Int;
    var RockWidthOffset:Int;
    var RockType:String;
}

typedef ResourcesConfig = {

}

class TileMap{
    public var tileSize:Int;
    public var height:Int;
    public var width:Int;
    public var tileStorage:Array<Tile>;
    public var biome:String;
    public var biomeConfig:TileMapGeneratedConfig;

    public var floorTypeConfig:Map<String, Map<String, Dynamic>>;

    private var _tileID:Int;
    private var _init:Bool;
    private var _postInit:Bool;
    private var _parent:Scene;
    private var _deploy:Deploy;

    public function new( params:TileMapConfig ):Void {
        this.height = params.Height;
        this.width = params.Width;
        this.biome = params.Biome;
        this.tileSize = params.TileSize;
        
        this._tileID = 0;
        this._parent = params.Parent;

        this._init = false;
        this._postInit = false;
    }

    public function init():Void{
        var errMsg:String = 'Error in TileMap.';

        if( this._init )
            trace( 'TileMap already inited' );

        if( this.height == null )
            throw '$errMsg Height is null';

        if( this.width == null )
            throw '$errMsg Width is null';

        if( this.biome == null )
            throw '#errMsg Biome config is null';

        if( this._parent == null )
            throw '$errMsg Parent is null';

    }

    public function generateMap():Void {
        var riverConfig:RiverConfig = this._generateRiverConfig();
        var lakeConfig:LakeConfig = this._generateLakeConfig();
        var rockConfig:RockConfig = this._generateRockConfig();
        var resourceConfig:ResourcesConfig = this._generateResourceConfig();

        this._fillTileMap();
        this._generateRock( rockConfig );
        this._generateRiver( riverConfig );
        this._generateLake( lakeConfig );
        this._generateResource( resourceConfig );

    }

    private function _generateRiverConfig():RiverConfig{
        var biomeParams:Map<String, Dynamic> = this._deploy.biomeConfig[ this.biome ];
        var params:Dynamic = biomeParams[ "river" ];
        var riverConfig:RiverConfig = {
            River: null,
            RiverWidthMax: params.riverWidthMax,
            RiverWidthMin: params.riverWidthMin,
            RiverOffset:  params.riverOffset,
            RiverWidthOffset:  params.riverWidthOffset,
            RiverType:  null,
            RiverGroundType: params.riverGroundType
        }
        var riverPercentage:Int = params.river;
        
        var randomNumForRiver:Int = Math.floor( Math.random()*( 100 )); // 0- 99 ;
        var randomNumForRiverType:Int = Math.floor( Math.random()*( 2 )); // 0 - 1;
        

        if( randomNumForRiver <= riverPercentage ) // use 0 -> riverPercentage;
            riverConfig.River = true;
        
        if( randomNumForRiverType == 0 )
            riverConfig.RiverType = "h"; // horizontal;

        return riverConfig;
    }

    private function _generateLakeConfig():LakeConfig{
        var biomeParams:Map<String, Dynamic> = this._deploy.biomeConfig[ this.biome ];
        var params:Dynamic = biomeParams[ "lake" ];
        var lakeConfig:LakeConfig = {    
            Lake: null,
            LakeAmount: null,
            LakeWidthMax: params.lakeWidthMax,
            LakeWidthMin: params.lakeWidthMin,
            LakeHeightMax: params.lakeHeightMax,
            LakeHeightMin: params.lakeHeightMin,
            LakeOffset: params.lakeOffset,
            LakeWidthOffset: params.lakeWidthOffset,
            LakeGroundType: params.lakeGroundType
        };

        var lakePercentage:Int = params.lake;

        var randomNumForLake:Int = Math.floor( Math.random()*( 100 )); // 0 - 99;
        var randomNumForLakeAmount:Int = Math.floor( 1 + Math.random()*( params.lakeAmount ));

        if( randomNumForLake <= lakePercentage )
            lakeConfig.Lake = true;

        lakeConfig.LakeAmount = randomNumForLakeAmount;
        return lakeConfig;
    }

    private function _generateRockConfig():RockConfig{
        var rockConfig:RockConfig = {
            Rock: null,
            RockAmount: null,
            RockWidthMax: null,
            RockWidthMin: null,
            RockHeightMax: null,
            RockHeightMin: null,
            RockOffset: null,
            RockWidthOffset: null,
            RockType: null
        };
        return null;
    }

    private function _generateResourceConfig():ResourcesConfig{
        var resoureceConfig:ResourcesConfig = {

        };
        return null;
    }

    private function _fillTileMap():Void {
        var biomeConfig:Map<String, Dynamic> = this._deploy.biomeConfig[ this.biome ];
        var biomGroundTypeConfig:Dynamic = biomeConfig[ "groundType" ];

        var tileConfig:TileConfig = {
            ID: null,
            GridX: null,
            GridY: null,
            TileSize: this.tileSize,
            GroundType: null,
            FloorType: null,
            IsWalkable: null,
            MovementRatio: null,
            CanPlaceObjects: null,
            CanPlayerStand: null,
            Index: null
        }
       
        for( i in 0...this.height ){                
            for( j in 0...this.width ){
                var newId:TileID= this._generateTileID();
                tileConfig.ID = newId;
                tileConfig.GridX = j;
                tileConfig.GridY = i;
                tileConfig.Index = i * this.height + j;
                var tileGroundType:String = _generateGroundType( biomGroundTypeConfig )  ; 
                var newTile:Tile = new Tile( tileConfig );
                this.tileStorage.push( newTile );
            }
        }
    }

    private function _generateRiver( params:RiverConfig ):Void{
        //generate river;
        if( params.River ){
            var riverWidthMax:Int = params.RiverWidthMax;
            var riverWidthMin:Int = params.RiverWidthMin;
            var riverOffset:Int = params.RiverOffset;
            var riverType:String = params.RiverType;
            var riverGroundType:String = params.RiverGroundType;
            var riverWidthOffsetMax = params.RiverWidthOffset; // -1, 0, +1;

            var currentRiverWidth:Int = Math.floor( riverWidthMin + Math.random() * ( riverWidthMax - riverWidthMin + 1 ));
            var safeZoneForRiver:Int = 10;

            //horizontal river
            var tileMapHeight = this.height;
            var tileMapWidth = this.width;
            if( riverType == "h" ){
                tileMapHeight = this.width;
                tileMapWidth = this.height;
            }

            var storeIndex:Bool = false;
            var indexesOfMinHeightOfRiver:Array<Int> = [];
            var riverPoint:Int = Math.floor( currentRiverWidth + safeZoneForRiver + Math.random()* ( tileMapWidth - currentRiverWidth - safeZoneForRiver  + 1 ));

            for( i in 0...tileMapHeight ){
                currentRiverWidth += Math.floor( -riverWidthOffsetMax + Math.random()*( riverWidthOffsetMax*2 + 1 ));
                if( currentRiverWidth > riverWidthMax )
                    currentRiverWidth = riverWidthMax;
                else if( currentRiverWidth <= riverWidthMin ){
                    currentRiverWidth = riverWidthMin;
                    storeIndex = true;
                }                        

                riverPoint += Math.floor( -riverOffset + Math.random()* ( riverOffset*2 + 1 )); // offset on coord Y -1, 0, +1;
                for( j in 0...currentRiverWidth ){
                    var index:Int = ( riverPoint + j ) * this.height + i;
                    var tile:Tile = this.tileStorage[ index ];
                    tile.groundType = riverGroundType;
                    tile.isWalkable = 0;
                    if( storeIndex ){
                        indexesOfMinHeightOfRiver.push( index );
                        storeIndex = false;
                    }                        
                }                
            }
        }
    }

    private function _generateLake( params:LakeConfig ):Void{
        if( params.Lake ){
            var lakeAmount:Int = params.LakeAmount;
            var lakeWidthMax:Int = params.LakeWidthMax;
            var lakeWidthMin:Int = params.LakeWidthMin;
            var lakeHeightMax:Int = params.LakeHeightMax;
            var lakeHeightMin:Int = params.LakeHeightMin;
            var lakeGroundType:String = params.LakeGroundType;
            var lakeOffset:Int = params.LakeOffset;
            var lakeWidthOffset:Int = params.LakeWidthOffset; // -1, 0, +1;

            for( i in 0...lakeAmount ){
                var lakeWidthAverage = Math.floor( lakeWidthMin + Math.random()*( lakeWidthMax - lakeWidthMin + 1 ));
                var lakeHeightAverage = Math.floor( lakeHeightMin + Math.random()*( lakeHeightMax - lakeHeightMin + 1 ));
                var lakePointTop = Math.floor( lakeHeightAverage/2 + Math.random()*( this.height - lakeHeightAverage/2 + 1)); // if lake going out of range, we must place about half of lake;
                var lakePointLeft = Math.floor( lakeWidthAverage/2 + Math.random()*( this.width - lakeWidthAverage/2 + 1 ));
                
                for( j in 0...lakeHeightAverage ){
                    lakePointLeft += Math.floor( -lakeOffset + Math.random()*( lakeOffset*2 + 1 ));
                    lakeWidthAverage += Math.floor( -lakeWidthOffset + Math.random()*( lakeWidthOffset*2 +1 ));
                    for( k in 0...lakeWidthAverage ){
                        var index:Int = ( lakePointTop + j ) * this.height + lakePointLeft + k;
                        var lakeTile:Tile = this.tileStorage[ index ];
                        lakeTile.groundType = lakeGroundType;
                        lakeTile.isWalkable = 0;
                    }
                }
            }
        }        
    }

    private function _generateRock( params:RockConfig ):Void{
        if( !params.Rock )
            return;

        var rockAmount:Int = params.RockAmount;
        var rockWidthMax:Int = params.RockWidthMax;
        var rockWidthMin:Int = params.RockWidthMin;
        var rockHeightMax:Int = params.RockHeightMax;
        var rockHeightMin:Int = params.RockHeightMin;
        var rockOffset:Int = params.RockOffset;
        var rockWidthOffset:Int = params.RockWidthOffset;
        var rockType:String = params.RockType;

        for( i in 0...rockAmount ){
            var rockWidthAverage:Int = Math.floor( rockWidthMin + Math.random()*( rockWidthMax - rockWidthMin + 1 ));
            var rockHeightAverage:Int = Math.floor( rockHeightMin + Math.random()*( rockHeightMax - rockHeightMin + 1 ));
            var rockPointTop:Int = Math.floor( rockHeightAverage/2 + Math.random()*( this.height - rockHeightAverage/2 + 1));
            var rockPointLeft:Int = Math.floor( rockWidthAverage/2 + Math.random()*( this.width - rockWidthAverage/2 + 1));

            for( j in 0...rockHeightAverage ){
                rockPointLeft += Math.floor( -rockOffset + Math.random()*( rockOffset*2 + 1 ));
                rockWidthAverage += Math.floor( -rockWidthOffset + Math.random()*( rockWidthOffset*2 + 1 ));
                for( k in 0...rockWidthAverage ){
                    var index:Int  = ( rockPointTop + j ) * this.height + rockPointLeft + k;
                    var rockTile:Tile = this.tileStorage[ index ];
                    rockTile.groundType = rockType;
                    rockTile.isWalkable = 1;
                }
            }
        }
    }

    private function _generateResource( params:ResourcesConfig ):Void{

    }
    private function _generateGroundType( params:Map<String, Dynamic> ):String{
        return null;
    }

    private function _generateFloorTypeForEarthTiles():Void{
        var biomeFloorTypes:Map<String, Dynamic> = this._deploy.biomeConfig[ this.biome ];

            for( i in 0...this.tileStorage.length ){
            var floorType:String = null;
            var tile:Tile = this.tileStorage[ i ];
            if( tile.groundType == "earth" ){
                var summ:Int = 0;
                var lastSumm:Int = 0;
                var randmonNum:Int = Math.floor( Math.random()* 100 ); // 0 - 99;
                for( key in biomeFloorTypes.keys() ){
                    var keyValue:Int = biomeFloorTypes[ key ];
                    summ += keyValue;
                    if( lastSumm >= randmonNum && summ < randmonNum ){
                        floorType = key;
                        break;
                    }else{
                        lastSumm = summ;
                    }
                }
                if( floorType == null )
                    continue;

                tile.floorType = floorType;
            }else{
                continue;
            }
        }
    }

    private function _generateTileID():TileID {
        this._tileID++;
        return TileID( this._tileID );
    }
}