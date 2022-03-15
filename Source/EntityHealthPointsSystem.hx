package;

enum HealthPoint{
    HealthPoint( _:Int );
}

typedef Head = {
    var LeftEye:BodyPart;
    var RightEye:BodyPart;
    var HeadNose:BodyPart;
    var HeadMouth:BodyPart;
    var Brain:BodyPart;
}

typedef LeftHand = {
    var LeftArm:BodyPart;
    var LeftWrist:BodyPart;
}

typedef RightHand = {
    var RightArm:BodyPart;
    var RightWrist:BodyPart;
}

typedef LeftLeg = {
    var LeftFoot:BodyPart;
    var leftSole:BodyPart;
}

typedef RightLeg = {
    var RightFoot:BodyPart;
    var RightSole:BodyPart;
}

typedef Body = {
    var LeftLung:BodyPart;
    var RightLung:BodyPart;
    var Heart:BodyPart;
}

typedef BodyPart = {
    var HP:HealthPoint;
    var currentHP:HealthPoint;
    var Type:String;
    var Status:String;
}

class EntityHealthPointsSystem{

    public var totalHp:HealthPoint;
    public var currentTotalHP:HealthPoint;

    public var head:Head;
    public var leftHand:LeftHand;
    public var rightHand:RightHand;
    public var body:Body;
    public var leftLeg:LeftLeg;
    public var rightLeg:RightLeg;

    public function new():Void{

    }

    public function init():Void{
        
    }

    public function postInit():Void{

    }

    public function updateTotalHP():Void{
        var headLeftEye:Int = switch (this.head.LeftEye.HP ){case HealthPoint(v): v;};
    }

    public function updateCurrentTotalHP():Void{

    }
}