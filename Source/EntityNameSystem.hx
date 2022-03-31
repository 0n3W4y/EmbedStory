package;

typedef EntityNameSystemConfig = {
    var Name:String;
    var Surname:String;
    var Nickname:String;
}

class EntityNameSystem {

    public var name:String;
    public var surname:String;
    public var nickname:String;

    private var _parent:Entity;

    public function new( parent:Entity, config:EntityNameSystemConfig ):Void{
        this._parent = parent;

        this.name = config.Name;
        this.surname = config.Surname;
        this.nickname = config.Nickname;
    }

    public function getFullName():String{
        var entityName:String = this.name;
        var entitySurname:String = this.surname;
        var entityNickname:String = this.nickname;

        var str:String = '';
        if( entityName != null )
            str += '$entityName';

        if( entityNickname != null )
            str += ' $entityNickname';

        if( entitySurname != null )
            str += ' $entitySurname';
        
        return str;
    }
}