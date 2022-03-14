package;

enum HealthPoint{
    HealthPoint( _:Int );
}

typedef Head = {
    var LeftEye:Eye;
    var RightEye:Eye;
    var HeadNose:Nose;
    var HeadMouth:Mouth;
}

typedef LeftArm = {

}

typedef RightArm = {

}

typedef Eye = {
    var HP:HealthPoint;
    var Type:String;
}

typedef Mouth = {
    var HP:HealthPoint;
    var Type:String;
}

typedef Nose = {
    var HP:HealthPoint;
    var Type:String;
}

class EntityHealthPointsSystem{

    public var totalHp:Int;

    public var head:Int;

    public function new():Void{

    }
}