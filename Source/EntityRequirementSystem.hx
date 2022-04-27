package;

enum Hunger {
    Hunger( _:Int );
}
typedef EntityRequirementSystemConfig = {
    var Hunger: Int;
    var Ratio:Int;
}

class EntityRequirementSystem{

    public var fullHunger: Hunger;
    public var currentHunger: Hunger;
    public var hungerRatio: Int;

    public var empty:Bool;


    private var _curentTick:Int;
    private var _inited:Bool;
    private var _postInited:Bool;
    private var _parent:Entity;

    public function new( parent:Entity, config:EntityRequirementSystemConfig ):Void{
        this._parent = parent;
        this.fullHunger = Hunger( config.Hunger );
        this.currentHunger = Hunger( config.Hunger );
        this.hungerRatio = config.Ratio;

        this._curentTick = 0;
        this.empty = false;
    }

    public function init():Void{
        var msg:String = this._parent.errMsg();
        msg += "EntityRequirementSystem.init.";
        if( this._inited )
            throw '$msg already inited!';

        if( this._parent == null )
            throw '$msg parent is null!';

        if( this.fullHunger == null )
            throw '$msg Full hunger is null!';

        if( this.currentHunger == null )
            throw '$msg current hunger is null!';

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
                //degrade some skills;
            }
        }
    }

    public function eat( value:Int ):Void{
        var fullHungerInt:Int = switch( this.fullHunger ){ case Hunger( v ): v; };
        var currentHungerInt:Int = switch( this.currentHunger ){ case Hunger( v ): v; };
        currentHungerInt += value;
        if( currentHungerInt >= fullHungerInt )
            currentHungerInt = fullHungerInt;

        this.currentHunger = Hunger( currentHungerInt );
        this.empty = false;
        this._curentTick = 0;
    }

    public function canEat():Bool{
        var currentHungerInt:Int = switch( this.currentHunger ){ case Hunger( v ): v; };
        var fullHungerInt:Int = switch( this.fullHunger ){ case Hunger( v ): v; };
        if( fullHungerInt > currentHungerInt )
            return true;

        return false;
    }

    public function checkEmpty():Bool{
        var currentHungerInt:Int = switch( this.currentHunger ){ case Hunger( v ): v; };
        if( currentHungerInt <= 0 )
            return true;

        return false;
    }
}