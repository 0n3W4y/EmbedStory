package;

import Entity.EntityID;

typedef EntityHealthPointsSystemConfig = {
    var Parent:Entity;
    var Torso:Dynamic;
    var Head:Dynamic;
    var LeftLeg:Dynamic;
    var RightLeg:Dynamic;
    var LeftHand:Dynamic;
    var RightHand:Dynamic;
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
        if( params.Head != null )
            this._configure( "head", params.Head );

        if( params.Torso != null )
            this._configure( "torso", params.Torso );

        if( params.LeftHand != null )
            this._configure( "leftHand", params.LeftHand );

        if( params.RightHand != null )
            this._configure( "rightHand", params.RightHand );

        if( params.LeftLeg != null )
            this._configure( "leftLeg", params.LeftLeg );

        if( params.RightLeg != null )
            this._configure( "rightLeg", params.RightLeg );

    }

    public function init():Void{
       var msg:String = this._errMsg();
       msg = '$msg + in init. ';
        if( torso == null )
            throw '$msg Torso is null!';
    }

    public function postInit():Void{
        var msg:String = this._errMsg();
        msg = '$msg in postInit. ';
        if( torso == null )
            throw '$msg Torso is null!';
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
        if( this.leftHand != null ){
            var leftHandArmHP:Int = switch( this.leftHand.Arm.currentHP ){ case HealthPoint( v ): v; };
            var leftHandWristHP:Int = switch( this.leftHand.Wrist.currentHP ){ case HealthPoint( v ): v; };
            leftHandHP = leftHandArmHP + leftHandWristHP;
        }

        var rightHandHP:Int = 0;
        if( this.rightHand != null ){
            var rightHandArmHP:Int = switch( this.rightHand.Arm.currentHP ){ case HealthPoint( v ): v; };
            var rightHandWristHP:Int = switch( this.rightHand.Wrist.currentHP ){ case HealthPoint( v ): v; };
            rightHandHP = rightHandArmHP + rightHandWristHP;
        }

        var leftLegHP:Int = 0;
        if( this.leftLeg != null ){
            var leftLegFootHP:Int = switch( this.leftLeg.Foot.currentHP ){ case HealthPoint( v ): v; };
            var leftLegSoleHP:Int = switch( this.leftLeg.Sole.currentHP ){ case HealthPoint( v ): v; };
            leftLegHP = leftLegFootHP + leftLegSoleHP;
        }

        var rightLegHP:Int = 0;
        if( this.rightLeg != null ){
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
        var container:BodyPart = null;
        var msg:String = this._errMsg();
        msg = '$msg in takeDamageTo. ';
        switch( place ){
            case "head": {
                if( this.head == null ) 
                    throw '$msg head does not exist'; 
        
                if( this.head.Head.Status == "disrupted" )
                    throw '$msg head already disrupted';

                container = this.head.Head;
                this._takeDamageTo( container, value );
            }
            case "leftEye": {
                if( this.head == null ) 
                    throw '$msg head does not exist'; 
        
                if( this.head.LeftEye.Status == "disrupted" )
                    throw '$msg Left eye already disrupted';

                container = this.head.LeftEye;
                this._takeDamageTo( container, value );
            };
            case "rightEye": {
                if( this.head == null ) 
                    throw '$msg head does not exist'; 
        
                if( this.head.RightEye.Status == "disrupted" )
                    throw '$msg Right eye already disrupted';

                container = this.head.RightEye;
                this._takeDamageTo( container, value );
            };
            case "nose": {
                if( this.head == null ) 
                    throw '$msg head does not exist'; 
        
                if( this.head.Nose.Status == "disrupted" )
                    throw '$msg Nose already disrupted';

                container = this.head.Nose;
                this._takeDamageTo( container, value );
            };
            case "mouth": {
                if( this.head == null ) 
                    throw '$msg head does not exist'; 
        
                if( this.head.Mouth.Status == "disrupted" )
                    throw '$msg Mouth already disrupted';

                container = this.head.Mouth;
                this._takeDamageTo( container, value );
            };
            case "brain": {
                if( this.head == null ) 
                    throw '$msg head does not exist'; 
        
                if( this.head.Brain.Status == "disrupted" )
                    throw '$msg Brain already disrupted';

                container = this.head.Brain;
                this._takeDamageTo( container, value );
            };
            case "leftArm": {
                if( this.leftHand == null ) 
                    throw '$msg Left hand does not exist'; 
        
                if( this.leftHand.Arm.Status == "disrupted" )
                    throw '$msg Left Arm already disrupted';

                container = this.leftHand.Arm;
                this._takeDamageTo( container, value );
            };
            case "leftWrist": {
                if( this.leftHand == null ) 
                    throw '$msg Left Hand does not exist'; 
        
                if( this.leftHand.Wrist.Status == "disrupted" )
                    throw '$msg Left Wrist already disrupted';

                container = this.leftHand.Wrist;
                this._takeDamageTo( container, value );
            };
            case "rightArm": {
                if( this.rightHand == null ) 
                    throw '$msg Right Hand does not exist'; 
        
                if( this.rightHand.Arm.Status == "disrupted" )
                    throw '$msg Right Arm already disrupted';

                container = this.rightHand.Arm;
                this._takeDamageTo( container, value );
            };
            case "rightWrist": {
                if( this.rightHand == null ) 
                    throw '$msg Right Hand does not exist'; 
        
                if( this.rightHand.Wrist.Status == "disrupted" )
                    throw '$msg Right Wrist already disrupted';

                container = this.rightHand.Wrist;
                this._takeDamageTo( container, value );
            };
            case "leftFoot": {
                if( this.leftLeg == null ) 
                    throw '$msg Left Leg does not exist'; 
        
                if( this.leftLeg.Foot.Status == "disrupted" )
                    throw '$msg Left Foot already disrupted';

                container = this.leftLeg.Foot;
                this._takeDamageTo( container, value );
            };
            case "leftSole": {
                if( this.leftLeg == null ) 
                    throw '$msg Left Sole does not exist'; 
        
                if( this.leftLeg.Sole.Status == "disrupted" )
                    throw '$msg Left Sole already disrupted';

                container = this.leftLeg.Sole;
                this._takeDamageTo( container, value );
            };
            case "rightFoot": {
                if( this.rightLeg == null ) 
                    throw '$msg Right Leg does not exist'; 
        
                if( this.rightLeg.Foot.Status == "disrupted" )
                    throw '$msg Right Foot already disrupted';

                container = this.rightLeg.Foot;
                this._takeDamageTo( container, value );
            };
            case "rightSole": {
                if( this.rightLeg == null ) 
                    throw '$msg Right Leg does not exist'; 
        
                if( this.rightLeg.Sole.Status == "disrupted" )
                    throw '$msg Right Sole already disrupted';

                container = this.rightLeg.Sole;
                this._takeDamageTo( container, value );
            };
            case "torso": {
                if( this.torso == null ) 
                    throw '$msg torso does not exist'; 
        
                if( this.torso.Torso.Status == "disrupted" )
                    throw '$msg torso already disrupted';

                container = this.torso.Torso;
                this._takeDamageTo( container, value );
            };
            case "leftLung": {
                if( this.torso == null ) 
                    throw '$msg torso does not exist'; 
        
                if( this.torso.LeftLung.Status == "disrupted" )
                    throw '$msg Left Lung already disrupted';

                container = this.torso.LeftLung;
                this._takeDamageTo( container, value );
            };
            case "rightLung": {
                if( this.torso == null ) 
                    throw '$msg torso does not exist'; 
        
                if( this.torso.RightLung.Status == "disrupted" )
                    throw '$msg Right Lung already disrupted';

                container = this.torso.RightLung;
                this._takeDamageTo( container, value );
            };
            case "heart": {
                if( this.torso == null ) 
                    throw '$msg torso does not exist'; 
        
                if( this.torso.Heart.Status == "disrupted" )
                    throw '$msg Heart already disrupted';

                container = this.torso.Heart;
                this._takeDamageTo( container, value );
            };
            default: throw '$msg. There is no "$place" in.';
        }

        //updatePassiveSkills();
    }

    

    private function _takeDamageTo( place:BodyPart, value:Int ):Void{
        var currentHP:Int = switch( place.currentHP ){ case HealthPoint(v): v; };
        var hp:Int = switch( place.HP ){ case HealthPoint(v): v; };
        var delta:Int = currentHP - value;
        var halfHP:Int = Math.round( hp / 2 );
        var fifteenPercentHP:Int = Math.round( hp * 0.15 );// 15% - status broken;        

        if( delta < halfHP && delta > fifteenPercentHP ){
            place.currentHP = HealthPoint( delta );
            place.Status = "damaged";
        }else if( delta < fifteenPercentHP && delta > 0 ){
            place.currentHP = HealthPoint( delta );
            place.Status = "broken";
        }else if( delta <= 0 ){
            place.currentHP = HealthPoint( 0 );
            place.Status = "disrupted";
            if( this._checkForDeath() )
                //Запустить процесс смерти.

            this._checkBodyPartsDependense();
        }else{
            place.currentHP = HealthPoint( delta );
        }
    }

    private function _checkBodyPartsDependense():Void{
        if( this.leftHand != null ){
            if( this.leftHand.Arm.Status == "disrupted" && this.leftHand.Wrist.Status != "disrupted" )
                this.leftHand.Wrist.Status = "disrupted";
        }

        if( this.rightHand != null ){
            if( this.rightHand.Arm.Status == "disrupted" && this.rightHand.Wrist.Status != "disrupted" )
                this.rightHand.Wrist.Status = "disrupted";
        }

        if( this.leftLeg != null ){
            if( this.leftLeg.Foot.Status == "disrupted" && this.leftLeg.Sole.Status != "disrupted" )
                this.leftLeg.Sole.Status = "disrupted";
        }

        if( this.rightLeg != null ){
            if( this.rightLeg.Foot.Status == "disrupted" && this.rightLeg.Sole.Status != "disrupted" )
                this.rightLeg.Sole.Status = "disrupted";
        }
    }

    private function _checkForDeath():Bool{
        if( this.torso.Heart.Status == "disrupted")
            return true;

        if( this.torso.Torso.Status == "disrupted" )
            return true;

        if( this.torso.LeftLung.Status == "disrupted" && this.torso.RightLung.Status == "disrupted" )
            return true;

        if( this.head.Head.Status == "disrupted" )
            return true;

        if( this.head.Brain.Status == "disrupted" )
            return true;

        return false;
    }

    private function _configure( place:String, params:Dynamic ):Void{
        var msg:String = this._errMsg();
        switch( place ){
            case "head":{
                this.head = { Head: null, LeftEye: null, RightEye: null, Mouth: null, Brain: null, Nose: null }
                for( key in Reflect.fields( params )){

                }
            };
            case "torso":{};
            case "leftLeg":{};
            case "rightLeg":{};
            case "leftHand":{};
            case "rightHand":{};
        }
    }

    private function _errMsg():String{
        var entityName:String = this._parent.entityName;
        var entityType:String = this._parent.entityType;
        var entitySubType:String = this._parent.entitySubType;
        var entityID:EntityID = this._parent.getId();
        return 'Error in EntityHealthPointSystem. "$entityName" "$entityType" "$entitySubType" "$entityID".';
    }
}