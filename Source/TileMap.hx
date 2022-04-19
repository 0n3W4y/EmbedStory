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
    var OffsetY:Int;
    var WidthOffset:Int;
    var HeightOffset:Int;
    var RiverType:String;
    var GroundType:String;
}

typedef LiquidRiverConfig = {
    var Emerging:Int;
    var WidthMax:Int;
    var WidthMin:Int;
    var Offset:Int;
    var WidthOffset:Int;
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
        this._generateLiquids();
        this._generateSolids();
    }






    private function _prepareTileMap():Void{
        this._fillTileMapWithMainGroundTypeTiles(); // заполняем тайлмап тайлами из освноного биома
        this._fillTileMapWithAdditionalGroundTypeTiles(); // добавляем пятна;
        this._fillTileMapWithMainFloorType(); // покрываем основным полом.
        this._fillTileMapWithAdditionalFloorType(); // покарываем дополнительными полами.
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
        var floorTileConfigForNothing:Dynamic = this._deploy.floorTypeConfig[ FloorTypeDeployID( 300 ) ];

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

            var startingPointX:Int = Math.floor( Math.random() * ( this.width - widthMax )); // random starting point on x with safe distance on right;
            var startingPointY:Int = Math.floor( Math.random() * ( this.height - heightMax )); // random starting point on y with safe distance on bottom;
            var currentWidth:Int = Math.floor( widthMin + Math.random() * ( widthMin + widthMax + 1 ));
            var currentHeight:Int = Math.floor( heightMin + Math.random() * ( heightMax + heightMin + 1 ));

            var leftTopPointX:Int = startingPointX;
            var leftTopPointY:Int = startingPointY;
            var averageWidth:Int = Math.round(( widthMax + widthMin) / 2 );
            var averageHeight:Int = Math.round(( heightMax + heightMin ) / 2 );

            for( i in 0...averageHeight ){ // do horizontal lines;
                leftTopPointX += Math.floor( -offsetX + Math.random()*( offsetX*2 + 1 ));
                currentWidth += Math.floor( -widthOffset + Math.random()*( widthOffset*2 + 1 ));
                if( currentWidth > widthMax )
                    currentWidth = widthMax;

                if( currentWidth < widthMin )
                    currentWidth = widthMin;

                var y:Int = startingPointY + i;
                for( j in 0...currentWidth ){
                    var x:Int = leftTopPointX + j;
                    var index:Int = y * this.height + x;
                    if( index < 0 || index >= this._totalTiles )
                        continue;

                    var tile:Tile = this.tileStorage[ index ];
                    tile.changeGroundType( groundTileConfig );
                    tile.changeFloorType( floorTileConfigForNothing );
                    this._createEnvironment( tile );
                }
            }

            for( k in 0...averageWidth ){ // do vertical lines;
                leftTopPointY = Math.floor( -offsetY + Math.random()*( offsetY*2 + 1 ));
                currentHeight = Math.floor( -heightOffset + Math.random()*( heightOffset*2 + 1));
                if( currentHeight > heightMax )
                    currentHeight = heightMax;

                if( currentHeight < heightMin )
                    currentHeight = heightMin;

                var x:Int = startingPointX + k;
                for( l in 0...currentHeight ){
                    var y:Int = leftTopPointY + l;
                    var index:Int = y * this.height + x;
                    if( index < 0 || index >= this._totalTiles )
                        continue;

                    var tile:Tile = this.tileStorage[ index ];
                    tile.changeGroundType( groundTileConfig );
                    tile.changeFloorType( floorTileConfigForNothing );
                    this._createEnvironment( tile );
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
            var generatedConfig:LiquidRiverConfig = this._generateLiquidRiverConfig( config );
            this._generateLiquidRiver( generatedConfig );
        }
    }

    private function _prepareForGenerateSolidRiver( params:Dynamic ):Void{

    }

    private function _prepareForGenerateLiquid( params:Dynamic ):Void{
        for( key in Reflect.fields( params )){
            var config:Dynamic = Reflect.getProperty( params, key );
            var generatedConfig:LiquidConfig = this._generateLiquidConfig( config );
            this._generateLiquid( generatedConfig );
        }
    }    

    private function _generateLiquidRiverConfig( params:Dynamic ):LiquidRiverConfig{
        var riverConfig:LiquidRiverConfig = {
            Emerging: Reflect.getProperty( params, "emerging" ),
            WidthMax: Reflect.getProperty( params, "widthMax" ),
            WidthMin: Reflect.getProperty( params, "widthMin" ),
            Offset: Reflect.getProperty( params, "offsetX" ),
            WidthOffset: Reflect.getProperty( params, "widthOffset" ),
            RiverType: Reflect.getProperty( params, "riverType" ),
            FloorType: Reflect.getProperty( params, "FloorType" )
        }
        return riverConfig;
    }

    private function _generateLiquidConfig( params:Dynamic ):LiquidConfig{
        var config:LiquidConfig = {    
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
            FloorType: Reflect.getProperty( params, "floorType" )
        };
        return config;
    }


    private function _generateLiquidRiver( params:LiquidRiverConfig ):Void{
        var floorTileDeployID:FloorTypeDeployID = this._deploy.getFloorTypeDeployID( params.FloorType );
        var floorTileConfig:Dynamic = this._deploy.floorTypeConfig[ floorTileDeployID ];

        var randomNum:Int = Math.floor( Math.random() * 100 ); // 0 - 99;
        if( randomNum >= params.Emerging )
            return;
        
        var widthMax:Int = params.WidthMax;
        var widthMin:Int = params.WidthMin;
        var offset:Int = params.Offset;
        var riverType:String = params.RiverType;
        var widthOffset = params.WidthOffset;

        var currentRiverWidth:Int = Math.floor( widthMin + Math.random() * ( widthMax - widthMin + 1 ));
        if( riverType == null ){
            var randNum:Int = Math.floor( Math.random()* 2 ); // 0 - 1;
            if( randNum == 0 )
                riverType = "h"; // horizontal
            else
                riverType = "v"; // vertical
        }
    
        if( riverType == "h" ){
            var riverPoint:Int = Math.floor( currentRiverWidth + offset + Math.random()* ( this.height - currentRiverWidth - offset ));
            for( i in 0...this.width ){
                riverPoint += Math.floor( -offset + Math.random()* ( offset*2 + 1 ));
                currentRiverWidth += Math.floor( -widthOffset + Math.random()*( widthOffset*2 + 1 ));

                if( currentRiverWidth > widthMax )
                    currentRiverWidth = widthMax;
                else if( currentRiverWidth < widthMin )
                    currentRiverWidth = widthMin;

                for( j in 0...currentRiverWidth ){
                    var index = ( riverPoint + j ) * this.height + i;
                    if( index < 0 || index >= this._totalTiles )
                        continue;

                    var tile:Tile = this.tileStorage[ index ];
                    tile.changeFloorType( floorTileConfig );
                }
            }
        }else{
            var riverPoint:Int = Math.floor( currentRiverWidth + offset + Math.random()* ( this.width - currentRiverWidth - offset ));
            for( i in 0...this.height ){
                riverPoint += Math.floor( -offset + Math.random()* ( offset*2 + 1 ));
                currentRiverWidth += Math.floor( -widthOffset + Math.random()*( widthOffset*2 + 1 ));
                
                if( currentRiverWidth > widthMax )
                    currentRiverWidth = widthMax;
                else if( currentRiverWidth < widthMin )
                    currentRiverWidth = widthMin;                
                
                for( j in 0...currentRiverWidth ){
                    var index:Int = riverPoint + j + this.height * i;
                    if( this._totalTiles <= index || index < 0)
                        continue;

                    var tile:Tile = this.tileStorage[ index ];
                    tile.changeFloorType( floorTileConfig );
                }                
            }
        }
    }

    private function _generateLiquid( params:LiquidConfig ):Void{
        var floorTileDeployID:FloorTypeDeployID = this._deploy.getFloorTypeDeployID( params.FloorType );
        var floorTileConfig:Dynamic = this._deploy.floorTypeConfig[ floorTileDeployID ];

        for( n in 0...params.Amount ){
            var randomNum:Int = Math.floor( Math.random() * 100 ); // 0 - 99;
            if( params.Emerging <= randomNum )
                continue;

            var widthMax:Int = params.WidthMax;
            var widthMin:Int = params.WidthMin;
            var heightMax:Int = params.HeightMax;
            var heightMin:Int = params.HeightMin;
            var offsetX:Int = params.OffsetX;
            var offsetY:Int = params.OffsetY;
            var widthOffset:Int = params.WidthOffset; // -x 0 +x;
            var heightOffset:Int = params.HeightOffset; // -y 0 +y;

            var startingPointX:Int = Math.floor( Math.random() * ( this.width - widthMax )); // random starting point on x with safe distance on right;
            var startingPointY:Int = Math.floor( Math.random() * ( this.height - heightMax )); // random starting point on y with safe distance on bottom;
            var currentWidth:Int = Math.floor( widthMin + Math.random() * ( widthMin + widthMax + 1 ));
            var currentHeight:Int = Math.floor( heightMin + Math.random() * ( heightMax + heightMin + 1 ));

            var leftTopPointX:Int = startingPointX;
            var leftTopPointY:Int = startingPointY;
            var averageWidth:Int = Math.round(( widthMax + widthMin) / 2 );
            var averageHeight:Int = Math.round(( heightMax + heightMin ) / 2 );

            for( i in 0...averageHeight ){ // do horizontal lines;
                leftTopPointX += Math.floor( -offsetX + Math.random()*( offsetX*2 + 1 ));
                currentWidth += Math.floor( -widthOffset + Math.random()*( widthOffset*2 + 1 ));
                if( currentWidth > widthMax )
                    currentWidth = widthMax;

                if( currentWidth < widthMin )
                    currentWidth = widthMin;

                var y:Int = startingPointY + i;
                for( j in 0...currentWidth ){
                    var x:Int = leftTopPointX + j;
                    var index:Int = y * this.height + x;
                    if( index < 0 || index >= this._totalTiles )
                        continue;

                    var tile:Tile = this.tileStorage[ index ];
                    tile.changeFloorType( floorTileConfig );
                }
            }

            for( k in 0...averageWidth ){ // do vertical lines;
                leftTopPointY = Math.floor( -offsetY + Math.random()*( offsetY*2 + 1 ));
                currentHeight = Math.floor( -heightOffset + Math.random()*( heightOffset*2 + 1));
                if( currentHeight > heightMax )
                    currentHeight = heightMax;

                if( currentHeight < heightMin )
                    currentHeight = heightMin;

                var x:Int = startingPointX + k;
                for( l in 0...currentHeight ){
                    var y:Int = leftTopPointY + l;
                    var index:Int = y * this.height + x;
                    if( index < 0 || index >= this._totalTiles )
                        continue;

                    var tile:Tile = this.tileStorage[ index ];
                    tile.changeFloorType( floorTileConfig );
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