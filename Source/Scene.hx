package;


import Entity.EntityID;
import haxe.EnumTools;
import TileMap;
import openfl.display.Sprite;

enum SceneID{
    SceneID( _:Int );
}

enum SceneDeployID{
    SceneDeployID( _:Int );
}

typedef SceneConfig = {
    var ID:SceneID;
    var SceneName:String;
    var SceneType:String;
    var DeployID:SceneDeployID;
    var SceneSprite:Sprite;
}

typedef ObjectStorage = {
    var Rocks:Array<Entity>;
    var Trees:Array<Entity>;
    var Stones:Array<Entity>;
    var Ores:Array<Entity>;
}

typedef StuffStorage = {

}

typedef EffectStorage = {

}

typedef CharacterStorage = {
    var Player: Entity;
    var Animals: Array<Entity>;
}

class Scene {
    public var tileMap:TileMap;
    public var objectStorage:ObjectStorage;
    public var stuffStorage:StuffStorage;
    public var effectStorage:EffectStorage;
    public var characterStorage:CharacterStorage;

    public var groundTileMapGraphics:Sprite;
    public var floorTileMapGraphics:Sprite;
    public var objectGraphics:Sprite;
    public var stuffGraphics:Sprite;
    public var characterGraphics:Sprite;
    public var effectGraphics:Sprite;
    public var rockFog:Sprite;
    public var lightingLayer1:Sprite;

    public var sceneName:String;
    public var sceneType:String;
    public var sceneGraphics:Sprite;

    public var showed:Bool;
    public var prepared:Bool;
    public var drawed:Bool;

    private var _sceneID:SceneID;
    private var _parent:SceneSystem;
    private var _sceneDeployID:SceneDeployID;

    public function new( parent:SceneSystem, params:SceneConfig ):Void{
        this._parent = parent;
        this._sceneID = params.ID;        
        this.sceneName = params.SceneName;
        this.sceneType = params.SceneType;
        this._sceneDeployID = params.DeployID;

        this.showed = false;
        this.prepared = false;

        this.sceneGraphics = new Sprite();
        this.groundTileMapGraphics = new Sprite();
        this.floorTileMapGraphics = new Sprite();
        this.objectGraphics = new Sprite();
        this.stuffGraphics = new Sprite();
        this.characterGraphics = new Sprite();
        this.effectGraphics = new Sprite();
        this.rockFog = new Sprite();
        this.lightingLayer1 = new Sprite();

        this.sceneGraphics.addChild(  this.groundTileMapGraphics );
        this.sceneGraphics.addChild(  this.floorTileMapGraphics );
        this.sceneGraphics.addChild(  this.objectGraphics );
        this.sceneGraphics.addChild(  this.stuffGraphics );
        this.sceneGraphics.addChild(  this.characterGraphics );
        this.sceneGraphics.addChild(  this.effectGraphics );
        
        this.objectStorage = { Rocks: [], Trees: [], Stones: [], Ores: [] };
        this.stuffStorage = {};
        this.effectStorage = {};
        this.characterStorage = { Player: null, Animals: [] };

        //by default scene not visible and transperent;
        this.sceneGraphics.visible = false;
        this.sceneGraphics.alpha = 0.0;
    }

    public function show():Void{
        if( this.showed )
            throw 'Error in Scene.show. Scene already shown';

        this._parent.activeScene = this;
        this._parent.getParent().ui.show();
        this.showed = true;
    }

    public  function hide():Void{
        if( !this.showed )
            throw 'Error in Scene.hide. Scene Already hided';

        this._parent.activeScene = null;
        this.sceneGraphics.visible = false;
        this.showed = false;
    }

    public function prepare():Void{
        // this function prepare scene like generate map, add grphics etc.
        if( this.prepared )
            throw 'Error in scene $sceneName, $_sceneID, $_sceneDeployID';

        this.prepared = true;

        if( this.sceneType == "groundMap" || this.sceneType == "globalMap" || this.sceneType == "dungeonMap" )
            this._generate();     

    }

    public function delete():Void{
        this._parent.deleteScene( this );
    }

    public function update( time:Int ):Void{
        if( this.objectStorage != null )
            this._updateObject( time );

        if( this.stuffStorage != null )
            this._updateStuff( time );

        if( this.characterStorage != null )
            this._updateCharacter( time );

        if( this.effectStorage != null )
            this._updateEffect( time );
            
    }

    public function getParent():SceneSystem{
        return this._parent;
    }

    public function getSceneDeployID():SceneDeployID{
        return this._sceneDeployID;
    }

    public function getSceneID():SceneID{
        return this._sceneID;
    }

    public function addEntity( entity:Entity ):Void{
        var entityType:String = entity.entityType;
        var container:Array<Entity> = null;
        switch( entityType ){
            case "rock": container = this.objectStorage.Rocks;
            case "tree": container = this.objectStorage.Trees;
            case "stone": container = this.objectStorage.Stones;
            case "ore": container = this.objectStorage.Ores;
            case "animal": container = this.characterStorage.Animals;
            default: throw 'Error in Scene._createObject. can not find container with entity type: "$entityType".';
        }

        container.push( entity );
    }

    public function removeEntity( entity:Entity ):Void{
        var entityType:String = entity.entityType;
        var container:Array<Entity> = null;
        switch( entityType ){
            case "rock": container = this.objectStorage.Rocks;
            case "tree": container = this.objectStorage.Trees;
            case "stone": container = this.objectStorage.Stones;
            case "ore": container = this.objectStorage.Ores;
            default: throw 'Error in Scene._createObject. can not find container with entity type: "$entityType".';
        }
        var index:Int = -1;
        var oldEntityID:EntityID = entity.getID();
        for( i in 0...container.length ){
            var newEntity:Entity = container[ i ];
            var newEntityID:EntityID = newEntity.getID();
            if( EnumValueTools.equals( oldEntityID, newEntityID )){
                index = i;
                break;
            }
        }
        if( index == -1 )
            throw 'Error in Scene.removeEntity. Index is null for "$entityType" and "$oldEntityID".';

        container.splice( index, 1 ); 
    }

    public function getObjectByID( ID:EntityID ):Entity{
        for( i in 0...this.objectStorage.Rocks.length ){
            var entity:Entity = this.objectStorage.Rocks[ i ];
            var eID:EntityID = entity.getID();
            if( EnumValueTools.equals( ID, eID ))
                return entity;
        }

        for( j in 0...this.objectStorage.Trees.length ){
            var entity:Entity = this.objectStorage.Trees[ j ];
            var eID:EntityID = entity.getID();
            if( EnumValueTools.equals( ID, eID ))
                return entity;
        }

        for( k in 0...this.objectStorage.Stones.length ){
            var entity:Entity = this.objectStorage.Stones[ k ];
            var eID:EntityID = entity.getID();
            if( EnumValueTools.equals( ID, eID ))
                return entity;
        }

        return null;
    }

    public function traceScene():Void{
        // this function must trace tile map and objects to console, without graphics;
        //DELETE after add graphics;
        var tileStorage:Array<Tile> = this.tileMap.tileStorage;
        var height:Int = this.tileMap.height;
        var width:Int = this.tileMap.width;
        for( i in 0...height ){
            var string:String = '';
            for( j in 0...width ){
                var index:Int = i*height + j;
                var tile:Tile = tileStorage[ index ];
                var object:Entity = tile.currentObject;
                if( object != null ){
                    var objectType:String = object.entityType;
                    var objectSubType:String = object.entitySubType;
                    switch( objectType ){
                        case "tree":{
                            switch( objectSubType ){
                                case "tree": string += "T";
                                case "fertileTree": string += "P";
                                case "bush": string += "v";
                                case "fertileBush": string += "u";
                                case "log": string += "l";
                            }
                        }
                        case "rock":{
                            switch( objectSubType ){
                                case "rock": string += "O";
                                case "sandrock": string += "Q";
                                case "copper": string += "C";
                            }
                        }
                        case "stone":{
                            switch( objectSubType ){
                                case "stone": string += "r";
                                case "copper": string += "c";
                            }
                        }
                    }
                }else{
                    var tileFloorType:String = tile.floorType;
                    if( tileFloorType != "nothing" ){
                        switch( tileFloorType ){
                            case "grass": string += '^';
                            case "sand": string += '~';
                            case "water": string += '_';
                            case "shallow": string += '-';
                            case "ice": string += '=';
                            case "rockRoad": string += '+';
                            case "woodenFloor": string += '#';
                        }
                    }else{
                        var tileGroundType:String = tile.groundType;
                        switch( tileGroundType ){
                            case "earth": string += 'e';
                            case "dirt": string += 'd';
                            case "dryEarth": string += 's';
                            case "rockEnvironment": string += 'o';
                            case "sandrockEnvironment": string = "q";
                        }
                    }
                }
            }
            trace( string );
        }
    }






    private function _generate():Void{
        this._generateTileMap();
        this._generateObjects();
    }   

    private function _generateTileMap():Void{
        var sceneDeployConfig:Dynamic = this._parent.getParent().deploy.sceneConfig[ this._sceneDeployID ];
        var biome:String = Reflect.getProperty( sceneDeployConfig, "tileMapBiome" );
        var height:Int = Reflect.getProperty( sceneDeployConfig, "height" );
        var width:Int = Reflect.getProperty( sceneDeployConfig, "width" );
        var tileSize:Int = Reflect.getProperty( sceneDeployConfig, "tileSize" );
        var biomeDeployID:BiomeDeployID = this._parent.getParent().deploy.getBiomeDeployID( biome );

        var tileMapConfig:TileMapConfig = {
            Height: height,
            Width: width,
            TileSize: tileSize,
            DeployID: biomeDeployID,
        }
        this.tileMap = new TileMap( this, tileMapConfig );
        this.tileMap.init();
        this.tileMap.generateMap();

    }

    private function _generateObjects():Void{
        this._createRockObjects();
        this._spreadIndexesForRocksObjects();
        this._createResources();
    }

    private function _createResources():Void{
        var sceneDeployConfig:Dynamic = this._parent.getParent().deploy.sceneConfig[ this._sceneDeployID ];
        var biome:String = Reflect.getProperty( sceneDeployConfig, "tileMapBiome" );
        var biomeDeployID:BiomeDeployID = this._parent.getParent().deploy.getBiomeDeployID( biome );
        var biomeConfig:Dynamic = this._parent.getParent().deploy.biomeConfig[ biomeDeployID ];
        var resourcesConfig:Dynamic = Reflect.getProperty( biomeConfig, "resources" );

        if( resourcesConfig == null )
            throw 'Error in Scene._createResources. Config for $biome biome is NULL!!';

        for( key in Reflect.fields( resourcesConfig )){
            var value:Dynamic = Reflect.getProperty( resourcesConfig, key );
            switch( key ){
                case "tree": this._createObject( "tree", "tree", value );
                case "fertileTree": this._createObject( "tree", "fertileTree", value );
                case "bush": this._createObject( "tree", "bush", value );
                case "fertileBush": this._createObject( "tree", "fertileBush", value );
                case "stone": this._createObject( "stone", "stone",  value);
                case "log": this._createObject( "tree", "log", value );
                case "steelStone": this._createObject( "stone", "steel", value );
                case "copperStone": this._createObject( "stone", "copper", value );
                case "copperOre": this._createOres( "rock", "copper", value );
                default: throw 'Error in Scene._createResources. Can not create resources with key: $key';
            }
        }
    }

    private function _createObject( entityType:String, entitySubType:String, value:Int ):Void {
        var tileStorage:Array<Tile> = this.tileMap.tileStorage;
        var entitySystem:EntitySystem = this._parent.getParent().entitySystem;
        for( i in 0...tileStorage.length ){
            var tile:Tile = tileStorage[ i ];
            var tileGround:String = tile.groundType;
            var tileFloor:String = tile.floorType;
            var tileObject:Entity = tile.currentObject;
            if( tileGround != "rock" && tileGround != "sandrock" && tileGround != "rockEnvironment" && tileGround != "sandrockEnvironment" ){
                if( tileFloor == "nothing" || tileFloor == "grass" || tileFloor == "shallow" || tileFloor == "sand" || tileFloor == "snow" ){
                    if( tileObject == null ){
                        var num:Int = Math.floor( Math.random() * 100 ); // 0 - 99;
                        if( num < value ){
                            var entity:Entity = entitySystem.createEntity( entityType, entitySubType );
                            entity.init();
                            entity.tileIndex = tile.getIndex();
                            this.addEntity( entity );
                            tile.currentObject = entity;                         
                        }
                    }
                }
            }
        }
    }

    private function _createOres( entityType:String, entitySubType:String, value:Int ):Void {
        var rockObjects:Array<Entity> = this.objectStorage.Rocks;
        for( i in 0...rockObjects.length ){
            var randomNum:Int = Math.floor( Math.random()* 100 );
            if( randomNum >= value )
                continue;

            var rockEntity:Entity = rockObjects[ i ];
            var x:Int = rockEntity.gridX;
            var y:Int = rockEntity.gridY;
            var graphicsIndex:Int = rockEntity.graphicIndex;
            var tileIndex:Int = rockEntity.tileIndex;
            var newEntity = this._parent.getParent().entitySystem.createEntity( entityType, entitySubType );
            newEntity.gridX = x;
            newEntity.gridY = y;
            newEntity.graphicIndex = graphicsIndex;
            newEntity.tileIndex = tileIndex;
            this.addEntity( newEntity );
            this.tileMap.tileStorage[ tileIndex ].currentObject = newEntity;
            this.removeEntity( rockEntity );
            

        }
    }

    private function _createRockObjects():Void{
        var newTileStorage:Array<Tile> = this.tileMap.tileStorage;
        for( i in 0...newTileStorage.length ){
            var tile:Tile = newTileStorage[ i ];
            var tileGroundType:String = tile.groundType;
            var rockEntity:Entity = null;
            switch( tileGroundType ){
                case "rock": rockEntity = this._parent.getParent().entitySystem.createEntityByDeployID( EntityDeployID( 1020 )); // 1020 - type "rock", subtype "rock";
                case "sandrock": rockEntity = this._parent.getParent().entitySystem.createEntityByDeployID( EntityDeployID( 1021 )); // 1021 - type "rock", subtype "sandrock";
                default: continue;
            }

            if( rockEntity == null )
                throw 'Error in Scene._createRockObject. Created Entity is NULL! $tileGroundType';

            rockEntity.gridX = tile.gridX;
            rockEntity.gridY = tile.gridY;
            rockEntity.tileIndex = tile.getIndex();
            rockEntity.init();
            this.addEntity( rockEntity );
            tile.currentObject = rockEntity;
            
        }
    }

    private function _spreadIndexesForRocksObjects():Void{
        var rocksArray:Array<Entity> = this.objectStorage.Rocks;
        for( i in 0...rocksArray.length ){
            var entity:Entity = rocksArray[ i ];
            var entityType:String = entity.entityType;
            var entitySubType:String = entity.entitySubType;
            if( entityType == "rock" && ( entitySubType == "rock" || entitySubType == "sandrock" )){
                this._spreadIndexForObject( entity );
            }
        }
    }

    private function _spreadIndexForObject( entity:Entity ):Void{
        //for walls;
        var entityType:String = entity.entityType;
        var entitySubType:String = entity.entitySubType;
        var x:Int = entity.gridX;
        var y:Int = entity.gridY;        

        var top:Bool = false;
        var topCorrdX = x;
        var topCoordY = y - 1;

        var left:Bool = false;
        var leftCoordX = x - 1;
        var leftCoordY = y;

        var right:Bool = false;
        var rightCoordX = x + 1;
        var rightCoordY = y;

        var bottom:Bool = false;
        var bottomCoordX = x;
        var bottomCoordY = y + 1;


        for( i in 0...this.objectStorage.Rocks.length ){
            var obj:Entity = this.objectStorage.Rocks[ i ];
            if( obj.entityType == entityType && obj.entitySubType == entitySubType ){

                var objX:Int = obj.gridX;
                var objY:Int = obj.gridY;
                if( objX == topCorrdX && objY == topCoordY )
                    top = true;
                else if( objX == leftCoordX && objY == leftCoordY )
                    left = true;
                else if( objX == rightCoordX && objY == rightCoordY )
                    right = true;
                else if( objX == bottomCoordX && objY == bottomCoordY )
                    bottom = true;
                else
                    continue;
            }
        }

        if( top && left && right && bottom ){
            //index 1; 4
            entity.graphicIndex = 1;
            var tile:Tile = this.tileMap.getTileByIndex( entity.tileIndex );
            tile.hasRockFog = true;
        }else if( top && left && right && !bottom ){
            //index 2; 3 top+left+right
            entity.graphicIndex = 2;
        }else if( top && left && !right && bottom ){
            //index 3; 3 top+left+bottom
            entity.graphicIndex = 3;
        }else if( top && !left && right && bottom ){
            //index 4; 3 top+right+bottom
            entity.graphicIndex = 4;
        }else if( !top && left && right && bottom ){
            //index 5; 3 left+right+bottom
            entity.graphicIndex = 5;
        }else if( top && left && !right && !bottom ){
            //index 6; 2 top+left
            entity.graphicIndex = 6;
        }else if( !top && left && right && !bottom ){
            //index 7; 2 left+right
            entity.graphicIndex = 7;
        }else if( !top && !left && right && bottom ){
            //index 8; 2 right+bottom
            entity.graphicIndex = 8;
        }else if( top && !left && !right && bottom ){
            //index 9; 2 top+bottom
            entity.graphicIndex = 9;
        }else if( top && !left && !right && bottom ){
            //index 10; 2 top+bottom
            entity.graphicIndex = 10;
        }else if( !top && left && !right && bottom ){
            //index 11; 2 bot+left
            entity.graphicIndex = 11;
        }else if( top && !left && right && !bottom ){
            //index 12; 2 top+right
            entity.graphicIndex = 12;
        }else if( top && !left && !right && !bottom ){
            //index 13; 1 top
            entity.graphicIndex = 13;
        }else if( !top && !left && right && !bottom ){
            //index 14; 1 right
            entity.graphicIndex = 14;
        }else if( !top && left && !right && !bottom ){
            //index 15; 1 left
            entity.graphicIndex = 15;
        }else if( !top && !left && !right && bottom ){
            //index 16; 1 bottom
            entity.graphicIndex = 16;
        }else if( !top && !left && !right && !bottom ){
            //index 0; 0
            entity.graphicIndex = 0;
        }else{
            throw 'Error in Scene._spreadIndexForRockObject. Something wrong with function. Top: $top, Bot: $bottom, Left: $left, Right: $right .';
        }
        
    }

    private function _updateObject( time:Int ):Void{
        for( i in 0...this.objectStorage.Trees.length ){
            this.objectStorage.Trees[ i ].update( time );
        }
    }

    private function _updateStuff( time:Int ):Void{
        
    }

    private function _updateCharacter( time:Int ):Void{
        for( i in 0...this.characterStorage.Animals.length )
            this.characterStorage.Animals[ i ].update( time );
    }

    private function _updateEffect( time:Int ):Void{

    }


}