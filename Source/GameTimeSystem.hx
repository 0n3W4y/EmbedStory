package;

class GameTimeSystem{

    public var currentYear:Int;
    public var currentMonth:Int;
    public var currentDay:Int;
    public var currentHour:Int;
    public var currentMinute:Int;
    //public var currentSeason:String;

    private var _tickTimeLine:Int; // отсечка по подсчету времени по тикам
    private var _minuteTimeLine:Int;
    private var _hourTimeLine:Int;
    private var _dayTimeLine:Int;
    private var _monthTimeLine:Int;
    //public static var Seasons:Array<String> = [ "summer", "autumn", "winter", "spring" ];
    //public var timeMultiplier = 1; // Множитель времени.

    private var _parent:Game;
    private var _currenTickTime:Int;

    public function new( parent:Game ):Void{
        this._parent = parent;
        this._tickTimeLine = 1000;
        this._minuteTimeLine = 60;
        this._hourTimeLine = 60;
        this._dayTimeLine = 24;
        this._monthTimeLine = 12;

        this._currenTickTime = 0;
    }

    public function update( time:Int ):Void{
        this._currenTickTime += time;
        if( this._currenTickTime >= this._tickTimeLine )
            this.timeUp();
    }

    public function timeUp():Void{
        this._currenTickTime -= this._tickTimeLine;
        this.currentMinute++;
        if( this.currentMinute >= this._minuteTimeLine ){
            this.currentHour++;
            this.currentMinute = 0;
            if( this.currentHour >= this._hourTimeLine ){
                this.currentDay++;
                this.currentHour = 0;
                if( this.currentDay >= this._dayTimeLine ){
                    this.currentMonth++;
                    //this.checkSeason();
                    this.currentDay = 0;
                    if( this.currentMonth >= this._monthTimeLine ){
                        this.currentYear++;
                        this.currentMonth = 0;
                    }
                }                 
            }
        }
    }

    public function getStringFullDateTime():String{
        var value:String = "";
        var currentMinute:String = Std.string( this.currentMinute );
        if( this.currentMinute < 10 )
            currentMinute = '0' + this.currentMinute;

        value = this.currentYear + '.' + this.currentMonth + '.' + this.currentDay + ' ' + this.currentHour + ":" + currentMinute;
        return value;
    }

    public function getStringTime():String{
        var value:String = '';
        var currentMinute:String = Std.string( this.currentMinute );
        if( this.currentMinute < 10 )
            currentMinute = '0' + this.currentMinute;

        value = this.currentHour + currentMinute;
        return value;
    }

    public function getStringDate():String{
        var value:String = '';
        value = this.currentYear + '.' + this.currentMonth + '.' + this.currentDay;
        return value;
    }

}