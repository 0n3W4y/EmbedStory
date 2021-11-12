package;

class GameTimeSystem{

    public var currentYear:Int;
    public var currentMonth:Int;
    public var currentDay:Int;
    public var currentHour:Int;
    public var currentMinute:Int;
    //public var currentSeason:String;

    public static var TickTimeline:Int = 1000; // отсечка по подсчету времени по тикам
    public static var MinuteTimeline:Int = 60;
    public static var HoureTimeline:Int = 24;
    public static var DayTimeline:Int = 30;
    public static var MonthTimeline:Int = 12;
    //public static var Seasons:Array<String> = [ "summer", "autumn", "winter", "spring" ];

    private var _parent:Game;
    private var _currenTickTime:Int;

    public function new( parent:Game ):Void{
        this._parent = parent;

        this._currenTickTime = 0;
    }

    public function update( time:Int ):Void{
        this._currenTickTime += time;
        if( this._currenTickTime >= TickTimeline )
            this.timeUp();
    }

    public function timeUp():Void{
        this._currenTickTime -= TickTimeline;
        this.currentMinute++;
        if( this.currentMinute >= MinuteTimeline ){
            this.currentHour++;
            this._parent.stage.hourUp();
            this.currentMinute = 0;
            if( this.currentHour >= HoureTimeline ){
                this.currentDay++;
                this.currentHour = 0;
                if( this.currentDay > DayTimeline ){
                    this.currentMonth++;
                    //this.checkSeason();
                    this.currentDay = 1;
                    if( this.currentMonth > MonthTimeline ){
                        this.currentYear++;
                        this.currentMonth = 1;
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