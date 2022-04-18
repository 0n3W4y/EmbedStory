package;

import Tile;
import Deploy;
import haxe.EnumTools;



enum BiomeDeployID{
    BiomeDeployID( _:Int );
}

typedef TileMapConfig = {
    var Height:Int;
    var Width:Int;
    var TileSize:Int;
    var DeployID:BiomeDeployID;
}

typedef SolidRiverConfig = {
    var Emerging:Int;
    var WidthMax:Int;
    var WidthMin:Int;
    var OffsetX:Int;
    var OffSetY:Int;
    var WidthOffset:Int;
    var HeightOffset:Int;
    var RiverType:String;
    var GroundType:String;
}

typedef LiquidRiverConfig = {
    var Emerging:Int;
    var WidthMax:Int;
    var WidthMin:Int;
    var OffsetX:Int;
    var OffSetY:Int;
    var WidthOffset:Int;
    var HeightOffset:Int;
    var RiverType:String;
    var FloorType:String;
}

typedef LiquidConfig = {
    var Emerging:Int;
    var Amount:Int;
    var WidthMax:Int;
    var WidthMin:Int;
    var HeightMax:Int;
    var HeightMin:Int;
    var OffsetX:Int;
    var OffsetY:Int;
    var WidthOffset:Int;
    var HeightOffset:Int;
    var FloorType:String;
}

typedef SolidConfig = {
    var Emerging:Int;
    var Amount:Int;
    var WidthMax:Int;
    var WidthMin:Int;
    var HeightMax:Int;
    var HeightMin:Int;
    var OffsetX:Int;
    var OffsetY:Int;
    var WidthOffset:Int;
    var HeightOffset:Int;
    var GroundType:String;
}

class TileMap{
    public var tileSize:Int;
    public var height:Int;
    public var width:Int;
    public var tileStorage:Array<Tile>;

    private var _init:Bool;
    private var _postInit:Bool;
    private var _parent:Scene;
    private var _deploy:Deploy;
    private var _biomeDeployID:BiomeDeployID;
    private var _totalTiles:Int;

    public function new( parent:Scene, params:TileMapConfig ):Void {
        this.height = params.Height;
        this.width = params.Width;
        this.tileSize = params.TileSize;
        this._biomeDeployID = params.DeployID;
        this._totalTiles = this.height * this.width;

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

        if( this._parent == null )
            throw '$errMsg Parent is null';

        if( this.tileSize == null )
            throw '$errMsg Tile Size is null';

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

    public function getTileByIndex( tileID:Int ):Tile{
        var tile:Tile = this.tileStorage[ tileID ];
        return tile;
    }

    public function generateMap():Void {
        this._prepareTileMap();
        this._generateSolids();
        this._generateLiquids();
    }






    private function _prepareTileMap():Void{
        this._fillTileMapWithMainGroundTypeTiles(); // заполняем тайлмап тайлами из освноного биома
        this._fillTileMapWithAdditionalGroundTypeTiles(); // добавляем пятна;
        this._fillTileMapWithMainFloorType(); // покрываем основным полом.
        this._fillTileMapWithAdditionalFloorType(); // покарываем дополнительными полами.
    }

    private function _prepareSolids():Void{

    }

    private function _prepareLiquids():Void{

    }

    private function _fillTileMapWithMainGroundTypeTiles():Void{
        var biomeConfig:Dynamic = this._deploy.biomeConfig[ this._biomeDeployID ];
        var mainGroundType:String = Reflect.getProperty( biomeConfig, "mainGroundType" );
        for( i in 0...this.height ){                
            for( j in 0...this.width ){               
                var groundTileDeployID:GroundTypeDeployID = this._deploy.getGroundTypeDeployID( mainGroundType );
                var groundTileConfig:Dynamic = this._deploy.groundTypeConfig[ groundTileDeployID ];

                var tileConfig:TileConfig = {
                    GridX: j,
                    GridY: i,
                    TileSize: this.tileSize,
                    GroundType: Reflect.getProperty( groundTileConfig, "groundType" ),
                    FloorType: "nothing",
                    FloorDeployID: FloorTypeDeployID( 300 ), // deployId of floor type 'nothing';
                    GroundDeployID: groundTileDeployID,
                    IsWalkable: Reflect.getProperty( groundTileConfig, "isWalkable" ),
                    CanPlaceFloor: Reflect.getProperty( groundTileConfig, "canPlaceFloor" ),
                    CanRemoveFloor: Reflect.getProperty( groundTileConfig, "canRemoveFloor" ),
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
            var maxWidth:Int = Math.round( this.width / 20 ); // 5% from max width;
            var maxHeight:Int = Math.round( this.height / 20 ); // 5% from max height;
            for( i in 0...remainTiles ){
                var currentMaxWidth:Int = Math.floor( 1 + Math.random() * ( maxWidth + 2 ));
                var currentMaxHeight:Int = Math.floor( 1 + Math.random() * ( maxHeight + 2 ));
                var currentWidthMin:Int = Math.round( currentMaxWidth / 4 ); // 25% of maximum value
                var currentHeightMin:Int = Math.round( currentMaxHeight / 4 ); // 25% of maximum value

                var config:SolidConfig = {
                    Emerging: 100,
                    Amount: 1,
                    WidthMax: currentMaxWidth,
                    WidthMin: currentWidthMin,
                    HeightMax: currentMaxHeight,
                    HeightMin: currentHeightMin,
                    OffsetX: 1,
                    OffsetY: 1,
                    WidthOffset: 1,
                    HeightOffset: 1,
                    GroundType: key
                }
                this._generateSolid( config );

                remainTiles -= Math.round((( currentMaxWidth + currentWidthMin ) / 2 ) * (( currentMaxHeight + currentHeightMin ) / 2 ));
                if( remainTiles <= 10 )
                    break;
            }
            
        }
    }

    private function _fillTileMapWithMainFloorType():Void{
        // функция работает только в условии. что в maniFloorType всего 1 ключ.
        var biomeConfig:Dynamic = this._deploy.biomeConfig[ this._biomeDeployID ];
        var mainFloorType:String = Reflect.getProperty( biomeConfig, "mainFloorType" );
        var floorTypeDeployID:FloorTypeDeployID = this._deploy.getFloorTypeDeployID( mainFloorType );
        var floorTypeConfig:Dynamic = this._deploy.floorTypeConfig[ floorTypeDeployID ];
        var floorTypeGraphics:Array<String> = Reflect.getProperty( floorTypeConfig, "graphics" );

        var configForNothingFloorType:Dynamic = this._deploy.floorTypeConfig[ FloorTypeDeployID(300) ];

        for( i in 0...this.tileStorage.length ){
            var tile:Tile = this.tileStorage[ i ];
            var tileGroundType:String = tile.groundType;
            if ( tileGroundType == "rock" || tileGroundType == "sandrock" ){
                tile.changeFloorType( configForNothingFloorType );
                continue;
            }

            var randomIndex:Int = Math.floor( Math.random()* floorTypeGraphics.length ); //random index for floor graphics if exist;
            if(( tileGroundType == "rockEnvironment" || tileGroundType == "sandrockEnvironment" ) && mainFloorType == "grass" )
                tile.changeFloorType( configForNothingFloorType );
            else
                tile.changeFloorType( floorTypeConfig );

            tile.floorTypeGraphicIndex = randomIndex;
           
        }
    }

    private function _fillTileMapWithAdditionalFloorType():Void{
        var biomeConfig:Dynamic = this._deploy.biomeConfig[ this._biomeDeployID ];
        var additionalFloorTypeConfig:Dynamic = Reflect.getProperty( biomeConfig, "additionalFloorType" );

        for( i in 0...this.tileStorage.length ){
            var tile:Tile = this.tileStorage[ i ];
            if ( tile.groundType == "rock" || tile.groundType == "sandrock" )
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

    private function _generateSolids():Void{
        var biomeConfig:Dynamic = this._deploy.biomeConfig[ this._biomeDeployID ];
        var solidConfig:Dynamic = Reflect.getProperty( biomeConfig, "solids" ); //{ rock:{ rock1:{}, rock2:{}...}};
        for( key in Reflect.fields( solidConfig )){
            switch( key ){
                case "rock": this._prepareForGenerateSolid( Reflect.getProperty( solidConfig, key ));
                default: throw 'Error in TileMap.generateSolids. Wrong key "$key".';
            }
        }
    }

    private function _prepareForGenerateSolid( params:Dynamic ):Void{
        for( key in Reflect.fields( params )){
            var config:Dynamic = Reflect.getProperty( params, key );
            var generatedConfig:SolidConfig = this._generateSolidConfig( config );
            this._generateSolid( generatedConfig );
        }
    }

    private function _generateSolidConfig( params:Dynamic ):SolidConfig{
        var config:SolidConfig = {  
            Emerging: Reflect.getProperty( params, "emerging" ),  
            Amount: Reflect.getProperty( params, "amount" ),
            WidthMax: Reflect.getProperty( params, "widthMax" ),
            WidthMin: Reflect.getProperty( params, "widthMin" ),
            HeightMax: Reflect.getProperty( params, "heightMax" ),
            HeightMin: Reflect.getProperty( params, "heightMin" ),
            OffsetX: Reflect.getProperty( params, "offsetX" ),
            OffsetY: Reflect.getProperty( params, "offsetY" ),
            WidthOffset: Reflect.getProperty( params, "widthOffset" ),
            HeightOffset: Reflect.getProperty( params, "heightOffset" ),
            GroundType: Reflect.getProperty( params, "groundType" )
        };
        return config;
    }

    private function _generateSolid( params:SolidConfig ):Void{
        var groundTileDeployID:GroundTypeDeployID = this._deploy.getGroundTypeDeployID( params.GroundType );
        var groundTileConfig:Dynamic = this._deploy.groundTypeConfig[ groundTileDeployID ];

        for( n in 0...params.Amount ){
            var randomNum:Int = Math.floor( Math.random() * 100 ); // 0 - 99;
            if( randomNum >= params.Emerging )
                continue;

            var widthMax:Int = params.WidthMax;
            var widthMin:Int = params.WidthMin;
            var heightMax:Int = params.HeightMax;
            var heightMin:Int = params.HeightMin;
            var offsetX:Int = params.OffsetX;
            var offsetY:Int = params.OffsetY;
            var widthOffset:Int = params.WidthOffset; // -x 0 +x;
            var heightOffset:Int = params.HeightOffset; // -y 0 +y;

            for( i in 0...heightMax ){
                for( j in 0...widthMax ){
                    
                }
            }

        }
        
        
    }

    private function _generateLiquids():Void{
        var biomeConfig:Dynamic = this._deploy.biomeConfig[ this._biomeDeployID ];
        var liquidsConfig:Dynamic = Reflect.getProperty( biomeConfig, "liquids" ); //{ river:{}, lake:{} };
        for( key in Reflect.fields( liquidsConfig )){
            switch( key ){
                case "river": this._prepareForGenerateLiquidRiver( Reflect.getProperty( liquidsConfig, key ));
                case "lake": this._prepareForGenerateLiquid( Reflect.getProperty( liquidsConfig, key ));
                default: throw 'Error in TileMap._generateLiquids. Wrong key "$key".';
            }
        }
    }

    private function _prepareForGenerateLiquidRiver( params:Dynamic ):Void{
        for( key in Reflect.fields( params )){
            var config:Dynamic = Reflect.getProperty( params, key );
            var generatedConfig:RiverConfig = this._generateRiverConfig( config );
            this._generateRiver( generatedConfig );
        }
    }

    private function _prepareForGenerateSolidRiver( params:Dynamic ):Void{

    }

    private function _prepareForGenerateLiquid( params:Dynamic ):Void{
        for( key in Reflect.fields( params )){
            var config:Dynamic = Reflect.getProperty( params, key );
            var generatedConfig:LakeRockConfig = this._generateLakeRockConfig( config );
            this._generateLakeRock( generatedConfig );
        }
    }

    

    private function _generateRiverConfig( params:Dynamic ):RiverConfig{
        var riverConfig:RiverConfig = {
            Emerging: null,
            WidthMax: Reflect.getProperty( params, "widthMax" ),
            WidthMin: Reflect.getProperty( params, "widthMin" ),
            Offset: Reflect.getProperty( params, "offset" ),
            WidthOffset: Reflect.getProperty( params, "widthOffset" ),
            RiverType: null,
            FloorType: Reflect.getProperty( params, "FloorType" )
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

    private function _generateLakeRockConfig( params:Dynamic ):LakeRockConfig{
        var config:LakeRockConfig = {    
            Emerging: null, // появление
            Amount: null,
            WidthMax: Reflect.getProperty( params, "widthMax" ),
            WidthMin: Reflect.getProperty( params, "widthMin" ),
            HeightMax: Reflect.getProperty( params, "heightMax" ),
            HeightMin: Reflect.getProperty( params, "heightMin" ),
            Offset: Reflect.getProperty( params, "offset" ),
            WidthOffset: Reflect.getProperty( params, "widthOffset" ),
            GroundType: Reflect.getProperty( params, "groundType" )
        };

        var emerging:Int = params.emegring;

        var randomNumForEmerging:Int = Math.floor( Math.random()*( 100 )); // 0 - 99;
        var randomNumForAmount:Int = Math.floor( 1 + Math.random()*( params.amount ));

        if( randomNumForEmerging <= emerging )
            config.Emerging = true;

        config.Amount = randomNumForAmount;
        return config;
    }


    private function _generateLiquidRiver( params:LiquidRiverConfig ):Void{
        //generate river;
        var floorTileDeployID:FloorTypeDeployID = this._deploy.getFloorTypeDeployID( params.FloorType );
        var floorTileConfig:Dynamic = this._deploy.floorTypeConfig[ floorTileDeployID ];
        if( params.Emerging ){
            var riverWidthMax:Int = params.WidthMax;
            var riverWidthMin:Int = params.WidthMin;
            var riverOffset:Int = params.Offset;
            var riverType:String = params.RiverType;
            //var riverGroundType:String = params.GroundType;
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
                        tile.changeFloorType( floorTileConfig );
                    }                
                }
            }
        }
    }

    private function _generateLiquid( params:LiquidConfig ):Void{
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
                        if( this._totalTiles <= index || index < 0 )
                            break; // защита от выхода за пределы карты.

                        var tile:Tile = this.tileStorage[ index ];
                        if( tile == null )
                            throw 'Error in TileMpa._generateLakeRock. Tile storage does not have tile with index $index.';

                        tile.changeGroundType( groundTileConfig );
                        this._createEnvironment( tile );
                    }
                }
            }
        }        
    }

    



    private function _createEnvironment( tile:Tile ):Void{
        var tileGroundType:String = tile.groundType; // rock, sandrock
        var newTileConfig:Dynamic = null;

        if( tileGroundType == "dirt" || tileGroundType == "dryEarth" || tileGroundType == "earth" )
            return;
        
        switch( tileGroundType ){
            case "rock": newTileConfig = this._deploy.groundTypeConfig[ GroundTypeDeployID( 207 )]; // rockEnvironment
            case "sandrock": newTileConfig = this._deploy.groundTypeConfig[ GroundTypeDeployID( 208 )]; // sandrockEnvironment
            default: throw 'Error in TileMap._createEnvironment. "$tileGroundType" is not correct';
        }

        //рандомно выбираем "подложку" 0 - 1 - 2 по умолчанию
        var number:Int = 2; // радиус распространения подложки.
        var randomNumber:Int = Math.floor( Math.random()*( number + 1 )); // 0 - 2;
       

        var y:Int = tile.gridY;
        var x:Int = tile.gridX;
        var height:Int = this.height;        
        var gridMultiplier:Int = randomNumber * 2 + 1;

        for( i in 0...gridMultiplier ){
            var index:Int = ( y - randomNumber + i ) * height + ( x - randomNumber );
            for( j in 0...gridMultiplier ){
                if( index < 0 || index >= this._totalTiles ) // защита от значений не принадлежащих текущей карты
                    continue; 

                var indexTileGroundType = tile.groundType;
                if( indexTileGroundType == "water" || indexTileGroundType == "rock" || indexTileGroundType == "sandstone" ){ // защита от перезаписи существующих тайлов
                    index++;
                    continue;
                }

                var tile:Tile = this.tileStorage[ index ];
                tile.changeGroundType( newTileConfig );
                index++;
            }
        }
    }


    /*

    public function changeFloorTypeForTile( tileId:TileID, floorType:String ):Void{
        var tile:Tile = this._findTileByTileId( tileId );
        if( tile.canPlaceFloor == 0 )
            throw 'Error in TileMap.changeFloorTypeForTile. Tile with id "$tileId" not support change floor.';

        var tileFloorTypeDeployId:FloorTypeDeployID = this._deploy.getFloorTypeDeployID( floorType );
        var floorTileConfig:Dynamic = this._deploy.floorTypeConfig[ tileFloorTypeDeployId ];
        tile.changeFloorType( floorTileConfig );

        //TODO: check for object on tile ;
    }

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

}