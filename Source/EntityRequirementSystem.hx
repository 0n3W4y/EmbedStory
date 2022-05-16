package;

enum Hunger {
    Hunger( _:Int );
}
typedef EntityRequirementSystemConfig = {
    var Hunger: Int;
    var Ratio: Int;
}

class EntityRequirementSystem{

    
    public var currentHunger: Hunger;
    public var hungerRatio: Int;

    public var empty:Bool;
    public var isHungry:Bool;
    public var canEat:Bool;

    public var hasMouth:Bool;


    private var _curentTick:Int;
    private var _inited:Bool;
    private var _postInited:Bool;
    private var _parent:Entity;
    private var _fullHunger: Int;
    private var _hungryTriggerPercent:Int;

    public function new( parent:Entity, config:EntityRequirementSystemConfig ):Void{
        this._parent = parent;
        this._fullHunger =  config.Hunger;
        this.currentHunger = Hunger( config.Hunger );
        this.hungerRatio = config.Ratio;
        this._hungryTriggerPercent = 15;

        this._curentTick = 0;
        this.empty = false;
        this.isHungry = false;
        this.canEat = false;
        this.hasMouth = true;
    }

    public function init():Void{
        var msg:String = this._parent.errMsg();
        msg += "EntityRequirementSystem.init.";
        if( this._inited )
            throw '$msg already inited!';

        if( this._parent == null )
            throw '$msg parent is null!';

        if( this._fullHunger < 0 || Math.isNaN( this._fullHunger ))
            throw '$msg Full hunger is null!';


        if( Math.isNaN( this.hungerRatio ) || this.hungerRatio <= 0 )
            throw '$msg Hunger ratio is not correct!';

        this._inited = true;
    }

    public function postInit():Void{
        var msg:String = this._parent.errMsg();
        msg += 'EntityRequirementSystem.postInit.';
        if( this._postInited )
            throw '$msg already post inited!';

        this._postInited = true;
    }

    public function update( time:Int ):Void {
        if( this.empty )
            return;

        this._curentTick += time;
        if( this._curentTick >= 1000 ){ // тикаем по секунде
            this._curentTick -= 1000;
            var currentHungerInt:Int = switch( this.currentHunger ){ case Hunger( v ): v; };
            currentHungerInt -= hungerRatio;
            this.currentHunger = Hunger( currentHungerInt );
            if( this.checkEmpty() ){
                this.empty = true;
                this.currentHunger = Hunger( 0 );
                //degrade some skills;
                var stats:EntityStatsSystem = this._parent.stats;
                if( stats != null ){
                    //убираем силу из-за голода.
                   this._decreaseStatsIfHungry();
                    //можно использовать нокдаун, как обессилен - отправить в ближайший госпиталь и снять круглую сумму. 
                }
            }
            
            this._canEat();
            this._isHungry();
        }
    }

    public function eat( value:Int ):Void{
        if( !this.canEat )
            return;

        var fullHungerInt:Int = this._fullHunger;
        var currentHungerInt:Int = switch( this.currentHunger ){ case Hunger( v ): v; };
        currentHungerInt += value;
        if( currentHungerInt >= fullHungerInt ){
            currentHungerInt = fullHungerInt;
            this.canEat = false;
        }

        this.currentHunger = Hunger( currentHungerInt );
        this.empty = false;
        this._curentTick = 0;
        this._increaseStatsIfNotHungry();
        
        var msg:String = this._parent.errMsg();
        trace( '$msg is eating');
        this._isHungry();
    }

    

    public function checkEmpty():Bool{
        var currentHungerInt:Int = switch( this.currentHunger ){ case Hunger( v ): v; };
        if( currentHungerInt <= 0 )
            return true;

        return false;
    }

    public function getFullHunger():Int{
        return this._fullHunger;
    }






    private function _canEat():Void{
        if( !this.hasMouth )
            return;

        if( this.canEat )
            return;

        var currentHungerInt:Int = switch( this.currentHunger ){ case Hunger( v ): v; };
        var fullHungerInt:Int = this._fullHunger;
        if( fullHungerInt > currentHungerInt )
            this.canEat = true;
    }

    private function _isHungry():Void{
        var currentHunger:Int = switch( this.currentHunger ){ case Hunger( v ): v; };
        var fullHunger:Int = this._fullHunger;
        var value:Int = Math.round( fullHunger * this._hungryTriggerPercent / 100 );
        if( value <= currentHunger ){
            this.isHungry = true;
            var msg:String = this._parent.errMsg();
            trace( '$msg is HUNGRY!');
        }
        else
            this.isHungry = false;
    }

    private function _decreaseStatsIfHungry():Void{
        var stats:EntityStatsSystem = this._parent.stats;
        stats.changeStatModifierValue( "str", -3 );
        stats.changeStatModifierValue( "int", -1 );
        stats.changeStatModifierValue( "dex", -2 );
        stats.changeStatModifierValue( "end", -1 );
    }

    private function _increaseStatsIfNotHungry():Void{
        var stats:EntityStatsSystem = this._parent.stats;
        stats.changeStatModifierValue( "str", 3 );
        stats.changeStatModifierValue( "int", 1 );
        stats.changeStatModifierValue( "dex", 2 );
        stats.changeStatModifierValue( "end", 1 );
    }
}