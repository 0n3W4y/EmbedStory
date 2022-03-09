package;

import Tile;
import Deploy;
import haxe.EnumTools;


enum TileMapID{
    TileMapID( _:Int );
}

enum BiomeDeployID{
    BiomeDeployID( _:Int );
}

typedef TileMapConfig = {
    var Height:Int;
    var Width:Int;
    var Biome:String;
    var TileSize:Int;
    var DeployID:BiomeDeployID;
    var TileMapID:TileMapID;
    var Name:String;
}

typedef TileMapGeneratedConfig = {
    var RiverConfig:RiverConfig;
    var LakeConfig:LakeRockConfig;
    var RockConf:LakeRockConfig;
    var ResourseConf:ResourcesConfig;
}

typedef RiverConfig = {
    var Emerging:Bool;
    var WidthMax:Int;
    var WidthMin:Int;
    var Offset:Int;
    var WidthOffset:Int;
    var RiverType:String;
    var GroundType:String;
}

typedef LakeRockConfig = {
    var Emerging:Bool;
    var Amount:Int;
    var WidthMax:Int;
    var WidthMin:Int;
    var HeightMax:Int;
    var HeightMin:Int;
    var Offset:Int;
    var WidthOffset:Int;
    var GroundType:String;
}

typedef ResourcesConfig = {

}

class TileMap{
    public var tileSize:Int;
    public var height:Int;
    public var width:Int;
    public var tileStorage:Array<Tile>;
    public var biome:String;
    public var name:String;


    private var _tileID:Int;
    private var _init:Bool;
    private var _postInit:Bool;
    private var _parent:Scene;
    private var _deploy:Deploy;
    private var _biomeDeployID:BiomeDeployID;
    private var _tileMapID:TileMapID;
    private var _totalTiles:Int;

    public function new( parent:Scene, params:TileMapConfig ):Void {
        this.height = params.Height;
        this.width = params.Width;
        this.biome = params.Biome;
        this.tileSize = params.TileSize;
        this.name = params.Name;
        this._tileMapID = params.TileMapID;
        this._biomeDeployID = params.DeployID;
        this._totalTiles = this.height * this.width;
        
        this._tileID = 0;
        this._parent = parent;

        this._init = false;
        this._postInit = false;

        this.tileStorage = new Array<Tile>();
        this._deploy = this._parent.getParent().getParent().deploy;
    }

    public function init():Void{
        var errMsg:String = 'Error in TileMap.init';

        if( this._init )
            return;

        if( this.height == null )
            throw '$errMsg Height is null';

        if( this.width == null )
            throw '$errMsg Width is null';

        if( this.biome == null )
            throw '$errMsg Biome config is null';

        if( this._parent == null )
            throw '$errMsg Parent is null';

        if( this.tileSize == null )
            throw '$errMsg Tile Size is null';

        if( this._tileMapID == null )
            throw '$errMsg Tile Map ID is null';

        if( this.name == null )
            throw '$errMsg Name is null';

        if( this._deploy == null )
            throw '$errMsg Deploy is null';

        this._init = true;

    }

    public function postInit():Void{
        if( this._postInit )
            return;

        var errMsg:String = 'Error in TileMap.postInit';

        this._postInit = true;
    }

    public function generateMap():Void {
        //TODO: 
        //изменить json настройку биома в "liquids": "river1": {... liquidType: "river" ... }
        // убрать создание конфига снизу, влепить его в создании самой реки, найти значение из reflect.fields() и найти liquidType: "river", создать реку или реки.
        // тоже самое сделать и для других.
        //var riverConfig:RiverConfig = this._generateRiverConfig();
        //var lakeConfig:LakeRockConfig = this._generateLakeConfig();
        //var rockConfig:LakeRockConfig = this._generateRockConfig();
        //var resourceConfig:ResourcesConfig = this._generateResourceConfig();

        this._fillTileMap();
        this._generateLiquids();
        this._generateLakeRock( lakeConfig );
        this._generateLakeRock( rockConfig );
        this._generateRiver( riverConfig );
        this._generateResources( resourceConfig );

        //generateGroundLayer();
        //generateFloorLayer();
        //this.generateObjectsLayer(); // rocks, trees, bushes, stones, logs, etc;

    }

    public function changeFloorTypeForTile( tileId:TileID, floorType:String ):Void{
        var tile:Tile = this._findTileByTileId( tileId );
        if( tile.canPlaceFloor == 0 )
            throw 'Error in TileMap.changeFloorTypeForTile. Tile with id "$tileId" not support change floor.';
        /*
        var tileGroundTypeDeployId:GroundTypeDeployID = this._deploy.getGroundTypeDeployID( tile.groundType );
        var groundTileConfig:Dynamic = this._deploy.groundTypeConfig[ tileGroundTypeDeployId ];
        tile.changeGroundType( groundTileConfig );
        */
        var tileFloorTypeDeployId:FloorTypeDeployID = this._deploy.getFloorTypeDeployID( floorType );
        var floorTileConfig:Dynamic = this._deploy.floorTypeConfig[ tileFloorTypeDeployId ];
        tile.changeFloorType( floorTileConfig );

        //TODO: check for object on tile and update tile fields;
    }

    public function getTileByTileId( tileId:TileID ):Tile{
        var tile:Tile = this._findTileByTileId( tileId );
        return tile;
    }

    public function getTileMpaID():TileMapID{
        return this._tileMapID;
    }

    private function _generateLiquids():Void{
        var biomeConfig:Dynamic = this._deploy.biomeConfig[ this._biomeDeployID ];
        var liquidsConfig:Dynamic = Reflect.getProperty( biomeConfig, "liquids" ); //{ river:{}, lake:{} };
    }

    private function _generateRiverConfig():RiverConfig{
        var biomeParams:Dynamic = this._deploy.biomeConfig[ this._biomeDeployID ];
        var params:Dynamic = Reflect.getProperty( biomeParams, "river" );
        var riverConfig:RiverConfig = {
            Emerging: null,
            WidthMax: params.riverWidthMax,
            WidthMin: params.riverWidthMin,
            Offset:  params.riverOffset,
            WidthOffset:  params.riverWidthOffset,
            RiverType:  null,
            GroundType: params.riverGroundType
        }
        var riverPercentage:Int = params.emerging;
        
        var randomNumForRiver:Int = Math.floor( Math.random()*( 100 )); // 0 - 99 ;
        var randomNumForRiverType:Int = Math.floor( Math.random()*( 2 )); // 0 - 1;
        

        if( randomNumForRiver <= riverPercentage ) // use 0 -> riverPercentage;
            riverConfig.Emerging = true;
        
        if( randomNumForRiverType == 0 )
            riverConfig.RiverType = "h"; // horizontal;

        return riverConfig;
    }

    private function _generateLakeConfig():LakeRockConfig{
        var biomeParams:Dynamic = this._deploy.biomeConfig[ this._biomeDeployID ];
        var params:Dynamic = Reflect.getProperty( biomeParams, "lake" );
        var lakeConfig:LakeRockConfig = {    
            Emerging: null, // появление
            Amount: null,
            WidthMax: params.widthMax,
            WidthMin: params.widthMin,
            HeightMax: params.heightMax,
            HeightMin: params.heightMin,
            Offset: params.offset,
            WidthOffset: params.widthOffset,
            GroundType: params.groundType
        };

        var lakeEmerging:Int = params.emegring;

        var randomNumForLakeEmerging:Int = Math.floor( Math.random()*( 100 )); // 0 - 99;
        var randomNumForLakeAmount:Int = Math.floor( 1 + Math.random()*( params.lakeAmount ));

        if( randomNumForLakeEmerging <= lakeEmerging )
            lakeConfig.Emerging = true;

        lakeConfig.Amount = randomNumForLakeAmount;
        return lakeConfig;
    }

    private function _generateRockConfig():LakeRockConfig{
        var biomeParams:Dynamic = this._deploy.biomeConfig[ this._biomeDeployID ];
        var params:Dynamic = Reflect.getProperty( biomeParams, "rock" );
        var rockConfig:LakeRockConfig = {
            Emerging: null,
            Amount: null,
            WidthMax: params.widthMax,
            WidthMin: params.widthMin,
            HeightMax: params.heightMax,
            HeightMin: params.heightMin,
            Offset: params.offset,
            WidthOffset: params.widthOffset,
            GroundType: params.groundType
        };

        var rockPercentage:Int = params.rock;

        var randomNumForRock:Int =  Math.floor( Math.random()*( 100 )); // 0 - 99;
        var randomNumForRockAmount:Int = Math.floor( 1 + Math.random()*( params.rockAmount ));

        if( randomNumForRock <= rockPercentage )
            rockConfig.Emerging = true;

        rockConfig.Amount = randomNumForRockAmount;
        return rockConfig;
    }

    private function _generateResourceConfig():ResourcesConfig{
        var resoureceConfig:ResourcesConfig = {

        };
        return resoureceConfig;
    }

    private function _fillTileMap():Void {

        this._fillTileMapWithMainGroundTypeTiles(); // заполняем тайлмап тайлами из освноного биома
        this._fillTileMapWithAdditionalGroundTypeTiles(); // добавляем пятна;
        this._fillTileMapWithMainFloorType(); // покрываем первый слой.
        this._fillTileMapWithAdditionalFloorType(); // покарываем первый слой дополнительно.
  
    }

    private function _fillTileMapWithMainGroundTypeTiles():Void{
        var biomeConfig:Dynamic = this._deploy.biomeConfig[ this._biomeDeployID ];
        var mainGroundType:String = Reflect.getProperty( biomeConfig, "mainGroundType" );
        for( i in 0...this.height ){                
            for( j in 0...this.width ){
                var newID:TileID= this._generateTileID();                
                var groundTileDeployID:GroundTypeDeployID = this._deploy.getGroundTypeDeployID( mainGroundType );
                var groundTileConfig:Dynamic = this._deploy.groundTypeConfig[ groundTileDeployID ];

                var tileConfig:TileConfig = {
                    ID: newID,
                    GridX: j,
                    GridY: i,
                    TileSize: this.tileSize,
                    GroundType: mainGroundType,
                    FloorType: "nothing",
                    FloorDeployID: FloorTypeDeployID( 300 ), // deployId of floor type 'nothing';
                    GroundDeployID: groundTileDeployID,
                    IsWalkable: Reflect.getProperty( groundTileConfig, "isWalkable" ),
                    CanPlaceFloor: Reflect.getProperty( groundTileConfig, "canPlaceloor" ),
                    MovementRatio: Reflect.getProperty( groundTileConfig, "movementRatio" ),
                    CanPlaceObjects: Reflect.getProperty( groundTileConfig, "canPlaceObjects" ),
                    CanPlaceStaff: Reflect.getProperty( groundTileConfig, "canPlaceStaff" ),
                    CanCharacterStand: Reflect.getProperty( groundTileConfig, "canCharacterStand" ),
                    Index: i * this.height + j
                }

                var tile:Tile = new Tile( tileConfig );
                tile.init();
                this.tileStorage.push( tile );
            }
        }
    }

    private function _fillTileMapWithAdditionalGroundTypeTiles():Void{
        var biomeConfig:Dynamic = this._deploy.biomeConfig[ this._biomeDeployID ];
        var additionalGroundType:Dynamic = Reflect.getProperty( biomeConfig, "additionalGroundType" );
        var maxTiles:Int = this.height * this.width;
        for( key in Reflect.fields( additionalGroundType )){
            var keyPercentage:Int = Reflect.getProperty( additionalGroundType, key );
            var maxTilesForAdditionalGroundType:Int = Math.round(( maxTiles * keyPercentage ) / 100 );
            var remainTiles:Int = maxTilesForAdditionalGroundType;
            var maxWidth:Int = Math.round(( this.width * keyPercentage ) / 100 );
            var maxHeight:Int = Math.round(( this.height * keyPercentage ) / 100 );
            for( i in 0...maxTilesForAdditionalGroundType ){
                var currentWidth:Int = Math.floor( 1 +  Math.random() * ( maxWidth + 2 )); // 1 - maxWidth;
                var currentHeight:Int = Math.floor( 1 + Math.random() * ( maxHeight + 2 )); // 1 - maxHeight;
                var currentWidthMin:Int = Math.round( currentWidth / 2 );
                var currentHeightMin:Int = Math.round( currentHeight / 2 );

                var config:LakeRockConfig = {
                    Emerging:true,
                    Amount: 1,
                    WidthMax: currentWidth,
                    WidthMin: currentWidthMin,
                    HeightMax: currentHeight,
                    HeightMin: currentHeightMin,
                    Offset: 1,
                    WidthOffset: 1,
                    GroundType: key
                }
                this._generateLakeRock( config );

                remainTiles -= Math.round((( currentWidth + currentWidthMin ) / 2 ) * (( currentHeight + currentHeightMin ) / 2 ));
                if( remainTiles <= 100 )
                    break;
            }
            
        }
    }

    private function _fillTileMapWithMainFloorType():Void{
        // функция работает только в условии. что в maniFloorType всего 1 ключ.
        var biomeConfig:Dynamic = this._deploy.biomeConfig[ this._biomeDeployID ];
        var mainFloorTypeConfig:Dynamic = Reflect.getProperty( biomeConfig, "mainFloorType" );
        var floorType:String = Reflect.fields( mainFloorTypeConfig)[ 0 ];
        var floorTypeDeployID:FloorTypeDeployID = this._deploy.getFloorTypeDeployID( floorType );
        var floorTypeConfig:Dynamic = this._deploy.floorTypeConfig[ floorTypeDeployID ];        
        var floorTypePercentage:Int = Reflect.getProperty( mainFloorTypeConfig, floorType );

        var configForNothingFloorType:Dynamic = this._deploy.floorTypeConfig[ FloorTypeDeployID(300) ];

        for( i in 0...this.tileStorage.length ){
            var tile:Tile = this.tileStorage[ i ];            
            var randomNum:Int = Math.floor( Math.random()* 100 ); // 0 - 99;
            if( randomNum <= floorTypePercentage ){
                tile.changeFloorType( floorTypeConfig );
            }else{
                tile.changeFloorType( configForNothingFloorType );
            }
        }
    }

    private function _fillTileMapWithAdditionalFloorType():Void{
        var biomeConfig:Dynamic = this._deploy.biomeConfig[ this._biomeDeployID ];
        var additionalFloorTypeConfig:Dynamic = Reflect.getProperty( biomeConfig, "additionalFloorType" );

        for( i in 0...this.tileStorage.length ){
            var tile:Tile = this.tileStorage[ i ];
            if ( tile.groundType == "rock" || tile.groundType == "water" || tile.groundType == "sandstone" )
                continue;

            var floorType:String = null;
            var summ:Int = 0;
            var lastSumm:Int = 0;
            var randmonNum:Int = Math.floor( Math.random()* 100 ); // 0 - 99;

            for( key in Reflect.fields( additionalFloorTypeConfig )){
                var keyValue:Int = Reflect.getProperty( additionalFloorTypeConfig, key );
                summ += keyValue;
                if( lastSumm <= randmonNum && randmonNum < summ ){
                    floorType = key;
                    break;
                }else{
                    lastSumm = summ;
                }
            }

            if( floorType == null )
                continue;

            var additionalFloorTypeDeployID:FloorTypeDeployID = this._deploy.getFloorTypeDeployID( floorType );
            var additionalFloorTypeConfig:Dynamic = this._deploy.floorTypeConfig[ additionalFloorTypeDeployID ];
            tile.changeFloorType( additionalFloorTypeConfig );
        }
    }

    private function _generateRiver( params:RiverConfig ):Void{
        //generate river;
        var groundTileDeployID:GroundTypeDeployID = this._deploy.getGroundTypeDeployID( params.GroundType );
        var groundTileConfig:Dynamic = this._deploy.groundTypeConfig[ groundTileDeployID ];
        if( params.Emerging ){
            var riverWidthMax:Int = params.WidthMax;
            var riverWidthMin:Int = params.WidthMin;
            var riverOffset:Int = params.Offset;
            var riverType:String = params.RiverType;
            var riverGroundType:String = params.GroundType;
            var riverWidthOffsetMax = params.WidthOffset; // -1, 0, +1;

            var currentRiverWidth:Int = Math.floor( riverWidthMin + Math.random() * ( riverWidthMax - riverWidthMin + 1 ));

            //horizontal river
            var tileMapHeight = this.height;
            var tileMapWidth = this.width;
            if( riverType == "h" ){
                //TODO
            }else{
                var riverPoint:Int = Math.floor( currentRiverWidth + riverOffset + Math.random()* ( tileMapWidth - currentRiverWidth - riverOffset + 1 ));

                for( i in 0...tileMapHeight ){
                    currentRiverWidth += Math.floor( -riverWidthOffsetMax + Math.random()*( riverWidthOffsetMax*2 + 1 ));
                    if( currentRiverWidth > riverWidthMax )
                        currentRiverWidth = riverWidthMax;
                    else if( currentRiverWidth < riverWidthMin )
                        currentRiverWidth = riverWidthMin;

                    riverPoint += Math.floor( -riverOffset + Math.random()* ( riverOffset*2 + 1 )); // offset on coord x -1, 0, +1;
                    for( j in 0...currentRiverWidth ){
                        var index:Int = ( riverPoint + j ) + tileMapHeight * i;
                        if( this._totalTiles < index )
                            break; // защита от выхода за пределы максимального значения тайлов

                        if( tileMapHeight * i < index || tileMapHeight * (i+1) > index )
                            continue; // защита от выхода за пределы карты

                        var tile:Tile = this.tileStorage[ index ];
                        tile.changeGroundType( groundTileConfig );                  
                    }                
                }
            }
        }
    }

    private function _generateLakeRock( params:LakeRockConfig ):Void{
        var groundTileDeployID:GroundTypeDeployID = this._deploy.getGroundTypeDeployID( params.GroundType );
        var groundTileConfig:Dynamic = this._deploy.groundTypeConfig[ groundTileDeployID ];
        if( params.Emerging ){
            var amount:Int = params.Amount;
            var widthMax:Int = params.WidthMax;
            var widthMin:Int = params.WidthMin;
            var heightMax:Int = params.HeightMax;
            var heightMin:Int = params.HeightMin;
            var offset:Int = params.Offset;
            var widthOffset:Int = params.WidthOffset; // -1, 0, +1;

            for( i in 0...amount ){
                var lakeWidthAverage = Math.floor( widthMin + Math.random()*( widthMax - widthMin + 1 ));
                var lakeHeightAverage = Math.floor( heightMin + Math.random()*( heightMax - heightMin + 1 ));
                var lakePointTop = Math.floor( lakeHeightAverage/2 + Math.random()*( this.height - lakeHeightAverage/2 + 1)); // if lake going out of range, we must place about half of lake;
                var lakePointLeft = Math.floor( lakeWidthAverage/2 + Math.random()*( this.width - lakeWidthAverage/2 + 1 ));
                
                for( j in 0...lakeHeightAverage ){
                    lakePointLeft += Math.floor( -offset + Math.random()*( offset*2 + 1 ));
                    lakeWidthAverage += Math.floor( -widthOffset + Math.random()*( widthOffset*2 +1 ));
                    for( k in 0...lakeWidthAverage ){
                        var index:Int = ( lakePointTop + j ) * this.height + lakePointLeft + k;
                        if( this._totalTiles < index || index < 0 )
                            break; // защита от выхода за пределы карты.

                        var tile:Tile = this.tileStorage[ index ];
                        tile.changeGroundType( groundTileConfig );
                        this._createEnvironment( tile );
                    }
                }
            }
        }        
    }

    private function _generateResources( params:ResourcesConfig ):Void{

    }
/*
    private function _generateGroundType( params:Dynamic ):String{
        var randomNum:Int = Math.floor( Math.random()* 100 ); // 0 - 99;
        var summ:Int = 0;
        var lastSumm:Int = 0;
        for( key in Reflect.fields( params )){
            summ += Reflect.getProperty( params, key );
            if( randomNum > lastSumm && randomNum <= summ )
                return key;
            else
                lastSumm = summ;
        }
        throw 'Error in TileMap._generateGroundType. Ground type is null for Params: $params';      
        return null;
    }

    private function _generateFloorType( groundType:String, params:Dynamic ):String{
        if( groundType == "water" || groundType == "rock" )
            return "nothing";

        var summ:Int = 0;
        var lastSumm:Int = 0;
        var randomNum:Int = Math.floor( Math.random()* 100 ); // 0-99;
        for( key in Reflect.fields( params )){
            summ += Reflect.getProperty( params, key );
            if( randomNum > lastSumm && randomNum <= summ )
                return key;
            else
                lastSumm = summ;
        }
        throw 'Error in TileMap._generateFloorType. Floor type is null for Ground Type: $groundType and Params: $params';
        return null;
    }
*/
    private function _createEnvironment( tile:Tile ):Void{
        //var currentBiome:String = this.biome;
        var tileGroundType:String = tile.groundType; // rock, sandrock
        var newTileConfig:Dynamic = null;
        
        switch( tileGroundType ){
            case "water": newTileConfig = this._deploy.groundTypeConfig[ GroundTypeDeployID( 204 )];
            case "rock": newTileConfig = this._deploy.groundTypeConfig[ GroundTypeDeployID( 202 )];
            case "sandstone": newTileConfig = this._deploy.groundTypeConfig[ GroundTypeDeployID( 203 )];
            default: throw 'Error in TileMap._createEnvironment. "$tileGroundType" is not correct';
        }

        var y:Int = tile.gridY;
        var height:Int = this.height;
        var leftTopIndex:Int = ( y - 1 ) * height - 1;
        var topIndex:Int = ( y - 1 ) * height;
        var rightTopIndex:Int = ( y - 1 ) * height + 1;
        var leftIndex:Int = tile.getIndex() - 1;
        var rightIndex:Int = tile.getIndex() + 1;
        var leftBottomIndex:Int = ( y + 1 ) * height - 1;
        var bottomIndex = ( y + 1 ) * height;
        var rightBottomIndex = ( y + 1 ) * height + 1;
        
        var indexArray:Array<Int> = [ leftTopIndex, topIndex, rightTopIndex, leftIndex, rightIndex, leftBottomIndex, bottomIndex, rightBottomIndex ];
        
        for( i in 0...indexArray.length ){
            if( i < 0 || i >= this._totalTiles ) // защита от выхода за пределы карты
                continue;

            var tile:Tile = this.tileStorage[ i ];
            var tileGroundType:String = tile.groundType;
            if( tileGroundType == tileGroundType )
                continue;
            
            tile.changeGroundType( newTileConfig );
        }
    }
/*
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
*/

    private function _findTileByTileId( tileId:TileID ):Tile{
        var tile:Tile = null;
        for( i in 0...this.tileStorage.length ){
            tile = this.tileStorage[ i ];
            if( EnumValueTools.equals( tileId, tile.getId() ))
                return tile;
        }

        throw 'Error in TileMap._findTile. No tile found in storage with TileID: $tileId .';
        return null;
    }

    private function _generateTileID():TileID {
        this._tileID++;
        return TileID( this._tileID );
    }

}