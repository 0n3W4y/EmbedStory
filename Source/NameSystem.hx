package;

import js.html.svg.StringList;

typedef NameSystemConfig = {
    var Name:String;
    var Surname:String;
}

class NameSystem{

    public var name:String;
    public var surname:String;

    private var _parent:Entity;

    public function new( parent:Entity, params:NameSystemConfig ):Void{
        this._parent = parent;
        this.name = params.Name;
        this.surname = params.Surname;
    }

    public function init():Void{
        var msg:String = 'Error in NameSystem.init. ';

        if( this._parent == null )
            throw '$msg Parent is null';

        if( this.name == null )
            throw '$msg Name is null';

        if( this.surname == null )
            throw '$msg Surname is null';
    }

    public function getFullName():String{
        return this.name + ' ' + this.surname;
    }
}