package;


typedef EntityAgeSystemConfig = {
    var Year:Int;
    var Month:Int;
    var Day:Int;
    var Hour:Int;
    var Minute:Int;
    var Phases:Array<Int>;
}

typedef Age = {
    var Minute:Int;
    var Hour:Int;
    var Day:Int;
    var Month:Int;
    var Year:Int;
}

class EntityAgeSystem{

    public var currentPhase:Int;
    public var currentTime:Int;

    public var year:Int;
    public var month:Int;
    public var day:Int;
    public var hour:Int;
    public var minute:Int;

    private var _parent:Entity;

    private var _phases:Array<Int>; // Индекс обозначает фазу, значение обозначает количество времени для этой фазы ( время будет исчислять в часах );
    private var _isPhaseLast:Bool;

    public function new( parent:Entity, params:EntityAgeSystemConfig ):Void{
        this._parent = parent;
        this.currentTime = 0;
        this._phases = params.Phases;

        this._calculatePhase();
        this._isPhaseLast = false;
    }

    public function init():Void{
        var msg:String = 'Error in AgeSystem.init. ';

        if( this._parent == null )
            throw '$msg Parent is null';

        if( this.currentTime == null )
            throw '$msg Total Time is null';

        if( this.currentPhase == null )
            throw '$msg Phase is null';

        if( this.year == null )
            throw '$msg Year is null';

        if( this.day == null )
            throw '$msg Day is null';

        if( this.hour == null )
            throw '$msg Hour is null';

        if( this.month == null )
            throw '$msg Month is null';
        
        if( this._phases == null )
            throw '$msg Array with phases is null';
    }

    public function update( time:Int ):Void{
        this.currentTime += time;
        if( this.currentTime >= 1000 ){
            this.currentTime -= 1000;
            this.timeUp();
        }
    
    }

    public function timeUp():Void{
        this.minute++;
        if( this.minute >= 60 ){
            this.minute = 0;
            this.hour++;
            if( this.hour >= 24 ){
                this.hour = 0;
                this.day++;
                if( this.day >= 30 ){
                    this.day = 0;
                    this.month++;
                    if( this.month >= 12 ){
                        this.month = 0;
                        this.year++;
                    }
                }
            }
        }
        if( !this._isPhaseLast )
            this._checkPhase();
    }

    public function getAge():Age{
        return { Year: this.year, Month: this.month, Day: this.day, Hour: this.hour, Minute: this.minute };
    }





    private function _phaseUp():Void{
        this.currentPhase++;
        if( this.currentPhase >= this._phases.length )
            this._isPhaseLast = true;

        //change graphics;
    }

    private function _calculatePhase():Void{
        var lastIndex:Int = 0;
        var time:Int = this.year * 12 * 30 * 24 + this.month * 30 * 24 + this.day * 24 + this.hour;
        for( i in 0...this._phases.length ){            
            var nextPhaseTime:Int = this._phases[ i ];
            if( time < nextPhaseTime ){
                this.currentPhase = i - 1;
                break;
            } 
            lastIndex = i;     
        }

        if( lastIndex == this._phases.length - 1 ){
            this._isPhaseLast = true;
            this.currentPhase = lastIndex;
        }

        //changeGraphics;
    }

    private function _checkPhase():Void{
        var phase:Int = this.currentPhase;
        if( phase < this._phases.length ){
            var nextPhaseTime:Int = this._phases[ phase + 1 ];
        }
    }


    
}