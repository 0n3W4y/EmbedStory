package;

typedef EntityHealthPointsSystemConfig = {
    var Parent:Entity;
}

enum HealthPoint{
    HealthPoint( _:Int );
}

typedef Head = {
    var Head:BodyPart;
    var LeftEye:BodyPart;
    var RightEye:BodyPart;
    var Nose:BodyPart;
    var Mouth:BodyPart;
    var Brain:BodyPart;
}

typedef LeftHand = {
    var Arm:BodyPart;
    var Wrist:BodyPart;
}

typedef RightHand = {
    var Arm:BodyPart;
    var Wrist:BodyPart;
}

typedef LeftLeg = {
    var Foot:BodyPart;
    var Sole:BodyPart;
}

typedef RightLeg = {
    var Foot:BodyPart;
    var Sole:BodyPart;
}

typedef Torso = {
    var LeftLung:BodyPart;
    var RightLung:BodyPart;
    var Heart:BodyPart;
    var Torso:BodyPart;
}

typedef BodyPart = {
    var HP:HealthPoint;
    var currentHP:HealthPoint;
    var Type:String; // natural ( 100% ), wood( 75% ), steel( 90% ), carbon( 110% ), cybernetic( 150% );
    var Status:String; // healthy ( 100% HP ), damaged( 50% HP), broken( 15% HP ), disrupted ( 0% HP );
}

class EntityHealthPointsSystem{

    public var totalHp:HealthPoint;
    public var currentTotalHP:HealthPoint;

    public var head:Head;
    public var leftHand:LeftHand;
    public var rightHand:RightHand;
    public var torso:Torso;
    public var leftLeg:LeftLeg;
    public var rightLeg:RightLeg;

    private var _parent:Entity;

    public function new( params:EntityHealthPointsSystemConfig ):Void{
        this._parent = params.Parent;
    }

    public function init():Void{
        var errMsg:String = 'Error in EntityHealthPointsSystem.init. ';
        if( torso == null )
            throw '$errMsg Torso is null!';
    }

    public function postInit():Void{
        var errMsg:String = 'Error in EntityHealthPointsSystem.postInit. ';
        if( torso == null )
            throw '$errMsg Torso is null!';
    }

    public function updateTotalHP():Void{
        var headHP:Int = 0;
        if( this.head != null ){
            var headLeftEye:Int = switch( this.head.LeftEye.HP ){case HealthPoint(v): v;};
            var headRightEye:Int = switch( this.head.RightEye.HP ){case HealthPoint(v): v;};
            var headNose:Int = switch( this.head.Nose.HP ){case HealthPoint(v): v;};
            var headMouth:Int = switch( this.head.Mouth.HP ){case HealthPoint(v): v;};
            var headBrain:Int = switch( this.head.Brain.HP ){case HealthPoint(v): v;};
            var headHead:Int = switch( this.head.Head.HP ){ case HealthPoint(v): v; };
            headHP = headLeftEye + headRightEye + headNose + headMouth + headBrain + headHead;
        }

        var leftHandHP:Int = 0;
        if( this.leftHand == null ){
            var leftHandArmHP:Int = switch( this.leftHand.Arm.HP ){ case HealthPoint( v ): v; };
            var leftHandWristHP:Int = switch( this.leftHand.Wrist.HP ){ case HealthPoint( v ): v; };
            leftHandHP = leftHandArmHP + leftHandWristHP;
        }

        var rightHandHP:Int = 0;
        if( this.rightHand == null ){
            var rightHandArmHP:Int = switch( this.rightHand.Arm.HP ){ case HealthPoint( v ): v; };
            var rightHandWristHP:Int = switch( this.rightHand.Wrist.HP ){ case HealthPoint( v ): v; };
            rightHandHP = rightHandArmHP + rightHandWristHP;
        }

        var leftLegHP:Int = 0;
        if( this.leftLeg == null ){
            var leftLegFootHP:Int = switch( this.leftLeg.Foot.HP ){ case HealthPoint( v ): v; };
            var leftLegSoleHP:Int = switch( this.leftLeg.Sole.HP ){ case HealthPoint( v ): v; };
            leftLegHP = leftLegFootHP + leftLegSoleHP;
        }

        var rightLegHP:Int = 0;
        if( this.rightLeg == null ){
            var rightLegFootHP:Int = switch( this.rightLeg.Foot.HP ){ case HealthPoint( v ): v; };
            var rightLegSoleHP:Int = switch( this.rightLeg.Sole.HP ){ case HealthPoint( v ): v; };
            rightLegHP = rightLegFootHP + rightLegSoleHP;
        }

        var torsoLeftLung:Int = switch( this.torso.LeftLung.HP ){ case HealthPoint(v): v; };
        var torsoRightLung:Int = switch( this.torso.RightLung.HP ){ case HealthPoint(v): v; };
        var torsoHeart:Int = switch( this.torso.Heart.HP ){ case HealthPoint(v): v; };
        var torsoTorso:Int = switch( this.torso.Torso.HP ){ case HealthPoint(v): v; };
        var torsoHP:Int = torsoLeftLung + torsoRightLung + torsoHeart + torsoTorso ;

        this.totalHp = HealthPoint( headHP + leftHandHP + rightHandHP + leftLegHP + rightLegHP + torsoHP );
    }

    public function updateCurrentTotalHP():Void{
        var headHP:Int = 0;
        if( this.head != null ){
            var headLeftEye:Int = switch( this.head.LeftEye.currentHP ){case HealthPoint(v): v;};
            var headRightEye:Int = switch( this.head.RightEye.currentHP ){case HealthPoint(v): v;};
            var headNose:Int = switch( this.head.Nose.currentHP ){case HealthPoint(v): v;};
            var headMouth:Int = switch( this.head.Mouth.currentHP ){case HealthPoint(v): v;};
            var headBrain:Int = switch( this.head.Brain.currentHP ){case HealthPoint(v): v;};
            var headHead:Int = switch( this.head.Head.currentHP ){ case HealthPoint(v): v; };
            headHP = headLeftEye + headRightEye + headNose + headMouth + headBrain + headHead;
        }

        var leftHandHP:Int = 0;
        if( this.leftHand == null ){
            var leftHandArmHP:Int = switch( this.leftHand.Arm.currentHP ){ case HealthPoint( v ): v; };
            var leftHandWristHP:Int = switch( this.leftHand.Wrist.currentHP ){ case HealthPoint( v ): v; };
            leftHandHP = leftHandArmHP + leftHandWristHP;
        }

        var rightHandHP:Int = 0;
        if( this.rightHand == null ){
            var rightHandArmHP:Int = switch( this.rightHand.Arm.currentHP ){ case HealthPoint( v ): v; };
            var rightHandWristHP:Int = switch( this.rightHand.Wrist.currentHP ){ case HealthPoint( v ): v; };
            rightHandHP = rightHandArmHP + rightHandWristHP;
        }

        var leftLegHP:Int = 0;
        if( this.leftLeg == null ){
            var leftLegFootHP:Int = switch( this.leftLeg.Foot.currentHP ){ case HealthPoint( v ): v; };
            var leftLegSoleHP:Int = switch( this.leftLeg.Sole.currentHP ){ case HealthPoint( v ): v; };
            leftLegHP = leftLegFootHP + leftLegSoleHP;
        }

        var rightLegHP:Int = 0;
        if( this.rightLeg == null ){
            var rightLegFootHP:Int = switch( this.rightLeg.Foot.currentHP ){ case HealthPoint( v ): v; };
            var rightLegSoleHP:Int = switch( this.rightLeg.Sole.currentHP ){ case HealthPoint( v ): v; };
            rightLegHP = rightLegFootHP + rightLegSoleHP;
        }

        var torsoLeftLung:Int = switch( this.torso.LeftLung.currentHP ){ case HealthPoint(v): v; };
        var torsoRightLung:Int = switch( this.torso.RightLung.currentHP ){ case HealthPoint(v): v; };
        var torsoHeart:Int = switch( this.torso.Heart.currentHP ){ case HealthPoint(v): v; };
        var torsoTorso:Int = switch( this.torso.Torso.currentHP ){ case HealthPoint(v): v; };
        var torsoHP:Int = torsoLeftLung + torsoRightLung + torsoHeart + torsoTorso ;

        this.currentTotalHP = HealthPoint( headHP + leftHandHP + rightHandHP + leftLegHP + rightLegHP + torsoHP );
    }

    public function takeDamageTo( place:String, value:Int ):Void{
        switch( place ){
            case "head": this._takeDamageToHead( value );
            case "leftEye": {};
            case "torso": this._takeDamageToTorso( value );
            default: throw 'Error in EntityHealthPointsSystem.takeDamageTo. There is no "$place" in.';
        }
    }

    


    private function _takeDamageToHead ( value:Int ):Void{
        var msg:String = 'Error in EntityHealthPointSystem.takeDamageTo. ';
        if( this.head == null ) 
            throw '$msg head does not exist'; 
        
        if( this.head.Head == null ) 
            throw '$msg head.Head does not exist';

        if( this.head.Head.Status == "disrupted" )
            throw '$msg head already disrupted';


        var currentHP:Int = switch( this.head.Head.currentHP ){ case HealthPoint(v): v; };
        var hp:Int = switch( this.head.Head.HP ){ case HealthPoint(v): v; };
        var delta:Int = currentHP - value;

        var halfHP:Int = Math.round( hp/2 );

    }

    private function _takeDamageToTorso( value:Int ):Void{

    }
}