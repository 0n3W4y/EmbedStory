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
    }

    public function init():Void{

    }

    public function postInit():Void{

    }

    public function update( time:Int ):Void {
        this._curentTick += time;
        if( this._curentTick >= 1000 ){ // тикаем по секунде
            this._curentTick -= 1000;
            var currentHungerInt:Int = switch( this.currentHunger ){ case Hunger( v ): v; };
            currentHungerInt -= hungerRatio;
            this.currentHunger = Hunger( currentHungerInt );
        }
    }

    public function canEat():Bool{
        return false;
    }

    public function checkEmpty():Bool{
        return false;
    }
}