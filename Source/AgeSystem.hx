package;

typedef AgeSystemConfig = {
    var Hour:Int;
    var Phases:Array<Int>;
}

class AgeSystem{

    public var currentYear:Int;
    public var currentMonth:Int;
    public var currentDay:Int;
    public var currentHour:Int;
    public var currentPhase:Int;
    public var isPhaseChanged:Bool;

    private var _parent:Entity;

    private var _phases:Array<Int>; // Индекс обозначает фазу, значение обозначает количество часов для этой фазы
    private var _isPhaseLast:Bool;

    public function new( parent:Entity, params:AgeSystemConfig ):Void{
        this._parent = parent;
        this.currentHour = params.Hour;
        this._phases = params.Phases;
        
        this._calculateDate();
        this._calculatePhase();
        this.currentHour = this.currentHour%24;
        this.isPhaseChanged = false;
        this._isPhaseLast = false;
    }

    public function init():Void{
        var msg:String = 'Error in AgeSystem.init. ';

        if( this._parent == null )
            throw '$msg Parent is null';

        if( this.currentYear == null )
            throw '$msg Year is null';

        if( this.currentDay == null )
            throw '$msg Day is null';

        if( this.currentHour == null )
            throw '$msg Hour is null';

        if( this.currentMonth == null )
            throw '$msg Month is null';

        if( this.currentPhase == null )
            throw '$msg Phase is null';

        if( this._phases == null )
            throw '$msg Array with phases is null';
    }

    public function update( time:Int ):Void{

    }

    public function hourUp():Void{
        this.currentHour++;
        if( this.currentHour >= 24 ){
            this._DayUp();
            if( !this._isPhaseLast )
                this._checkIsPhaseNeedsUp();
        }   
    }

    private function _DayUp():Void{
        this.currentHour = 0;
        this.currentDay++;
        if( this.currentDay >= 31 )
            this._monthUp();
    }

    private function _monthUp():Void{
        this.currentDay = 1;
        this.currentMonth++;
        if( this.currentMonth >= 13)
            this._yearUp();
    }

    private function _yearUp():Void{
        this.currentMonth = 1;
        this.currentYear++;
    }

    private function _phaseUp():Void{
        this.currentPhase++;
        if( this.currentPhase >= this._phases.length )
            this._isPhaseLast = true;
    }

    private function _calculateDate():Void{
        this.currentYear = Math.floor( this.currentHour / ( 24*30*12 ));
        this.currentDay = ( Math.floor( this.currentHour / 24 ))%30;
        this.currentMonth = ( Math.floor( this.currentHour / ( 24*30 )))%12;
    }

    private function _calculatePhase():Void{
        for( i in 0...this._phases.length ){
            var nextPhaseTime:Int = this._phases[ i ];
            if( this.currentHour <= nextPhaseTime )
                this.currentPhase = i;
        }
    }

    private function _checkIsPhaseNeedsUp():Void{
        for( i in 0...this._phases.length ){
            var phaseTime:Int = this._phases[ i ];
            this.isPhaseChanged = true;
            if( phaseTime >= this.currentHour )
                this._phaseUp();
        } 
    }
}