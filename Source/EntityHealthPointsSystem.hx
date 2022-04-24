package;

typedef EntityHealthPointsSystemConfig = {
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
    var CurrentHP:HealthPoint;
    var PartType:String; // natural ( 100% ), wood( 75% ), steel( 90% ), carbon( 110% ), cybernetic( 150% );
    var Status:String; // healthy ( 100% HP ), damaged( 50% HP), broken( 15% HP ), disrupted ( 0% HP );
}

class EntityHealthPointsSystem{

    public var totalHp:HealthPoint;
    public var currentTotalHP:HealthPoint;
    public var isDead:Bool;

    public var head:Head;
    public var leftHand:LeftHand;
    public var rightHand:RightHand;
    public var torso:Torso;
    public var leftLeg:LeftLeg;
    public var rightLeg:RightLeg;

    private var _parent:Entity;
    private var _percentToBrokenPart:Float;
    private var _percentToDamagePart:Float;

    public function new( parent:Entity, params:EntityHealthPointsSystemConfig ):Void{
        this._parent = parent;
        this.isDead = false;
        this._percentToBrokenPart = 15/100;
        this._percentToDamagePart = 40/100;

        if( params.Head != null )
            this._configureHead( params.Head );

        if( params.Torso != null )
            this._configureTorso( params.Torso );

        if( params.LeftHand != null )
            this._configureLeftHand( params.LeftHand );

        if( params.RightHand != null )
            this._configureRightHand( params.RightHand );

        if( params.LeftLeg != null )
            this._configureLeftLeg( params.LeftLeg );

        if( params.RightLeg != null )
            this._configureRightLeg( params.RightLeg );

    }

    public function init():Void{
       var msg:String = this._parent.errMsg();
       msg = '$msg + in init. ';
        if( torso == null )
            throw '$msg Torso is null!';
    }

    public function postInit():Void{
        var msg:String = this._parent.errMsg();
        msg = '$msg in postInit. ';
        if( torso == null )
            throw '$msg Torso is null!';
    }

    public function updateTotalHP():Void{
        var msg:String = this._parent.errMsg();
        var headHP:Int = 0;
        if( this.head != null ){
            var headLeftEye:Int = 0;
            var headRightEye:Int = 0;
            var headNose:Int = 0;
            var headMouth:Int = 0;
            var headBrain:Int = 0;

            if( this.head.LeftEye != null )
                headLeftEye = switch( this.head.LeftEye.HP ){case HealthPoint(v): v;};

            if( this.head.RightEye != null )
                headRightEye = switch( this.head.RightEye.HP ){case HealthPoint(v): v;};

            if( this.head.Nose != null )
                headNose = switch( this.head.Nose.HP ){case HealthPoint(v): v;};

            if( this.head.Mouth != null )
                headMouth = switch( this.head.Mouth.HP ){case HealthPoint(v): v;};

            if( this.head.Brain != null )
                headBrain = switch( this.head.Brain.HP ){case HealthPoint(v): v;};

            if( this.head.Head == null )
                throw '$msg updateTotalHP. head.Head is NULL!!!';

            var headHead:Int = switch( this.head.Head.HP ){ case HealthPoint(v): v; };
            headHP = headLeftEye + headRightEye + headNose + headMouth + headBrain + headHead;
        }

        var leftHandHP:Int = 0;
        if( this.leftHand != null ){
            var leftHandArmHP:Int = 0;
            var leftHandWristHP:Int = 0;

            if( this.leftHand.Arm != null )
                leftHandArmHP = switch( this.leftHand.Arm.HP ){ case HealthPoint( v ): v; };

            if( this.leftHand.Wrist != null )
                leftHandWristHP = switch( this.leftHand.Wrist.HP ){ case HealthPoint( v ): v; };

            leftHandHP = leftHandArmHP + leftHandWristHP;
        }

        var rightHandHP:Int = 0;
        if( this.rightHand != null ){
            var rightHandArmHP:Int = 0;
            var rightHandWristHP:Int = 0;

            if( this.rightHand.Arm != null )
                rightHandArmHP = switch( this.rightHand.Arm.HP ){ case HealthPoint( v ): v; };

            if( this.rightHand.Arm != null )
                rightHandWristHP = switch( this.rightHand.Wrist.HP ){ case HealthPoint( v ): v; };

            rightHandHP = rightHandArmHP + rightHandWristHP;
        }

        var leftLegHP:Int = 0;
        if( this.leftLeg != null ){
            var leftLegFootHP:Int = 0;
            var leftLegSoleHP:Int = 0;

            if( this.leftLeg.Foot != null )
                leftLegFootHP = switch( this.leftLeg.Foot.HP ){ case HealthPoint( v ): v; };

            if( this.leftLeg.Sole != null )
                leftLegSoleHP = switch( this.leftLeg.Sole.HP ){ case HealthPoint( v ): v; };

            leftLegHP = leftLegFootHP + leftLegSoleHP;
        }

        var rightLegHP:Int = 0;
        if( this.rightLeg != null ){
            var rightLegFootHP:Int = 0;
            var rightLegSoleHP:Int = 0;

            if( this.rightLeg.Foot != null )
                rightLegFootHP = switch( this.rightLeg.Foot.HP ){ case HealthPoint( v ): v; };

            if( this.rightLeg.Sole != null )
                rightLegSoleHP = switch( this.rightLeg.Sole.HP ){ case HealthPoint( v ): v; };

            rightLegHP = rightLegFootHP + rightLegSoleHP;
        }

        var torsoLeftLung:Int = 0;
        var torsoRightLung:Int = 0;
        var torsoHeart:Int = 0;
        var torsoTorso:Int = switch( this.torso.Torso.HP ){ case HealthPoint(v): v; };

        if( this.torso.LeftLung != null )
            torsoLeftLung = switch( this.torso.LeftLung.HP ){ case HealthPoint(v): v; };

        if( this.torso.RightLung != null )
            torsoRightLung = switch( this.torso.RightLung.HP ){ case HealthPoint(v): v; };

        if( this.torso.Heart != null )
            torsoHeart = switch( this.torso.Heart.HP ){ case HealthPoint(v): v; };
       
        var torsoHP:Int = torsoLeftLung + torsoRightLung + torsoHeart + torsoTorso ;

        this.totalHp = HealthPoint( headHP + leftHandHP + rightHandHP + leftLegHP + rightLegHP + torsoHP );
    }

    public function updateCurrentTotalHP():Void{
        var msg:String = this._parent.errMsg();
        var headHP:Int = 0;
        if( this.head != null ){
            var headLeftEye:Int = 0;
            var headRightEye:Int = 0;
            var headNose:Int = 0;
            var headMouth:Int = 0;
            var headBrain:Int = 0;

            if( this.head.LeftEye != null )
                headLeftEye = switch( this.head.LeftEye.CurrentHP ){case HealthPoint(v): v;};

            if( this.head.RightEye != null )
                headRightEye = switch( this.head.RightEye.CurrentHP ){case HealthPoint(v): v;};

            if( this.head.Nose != null )
                headNose = switch( this.head.Nose.CurrentHP ){case HealthPoint(v): v;};

            if( this.head.Mouth != null )
                headMouth = switch( this.head.Mouth.CurrentHP ){case HealthPoint(v): v;};

            if( this.head.Brain != null )
                headBrain = switch( this.head.Brain.CurrentHP ){case HealthPoint(v): v;};

            if( this.head.Head == null )
                throw '$msg updateTotalHP. head.Head is NULL!!!';

            var headHead:Int = switch( this.head.Head.CurrentHP ){ case HealthPoint(v): v; };
            headHP = headLeftEye + headRightEye + headNose + headMouth + headBrain + headHead;
        }

        var leftHandHP:Int = 0;
        if( this.leftHand != null ){
            var leftHandArmHP:Int = 0;
            var leftHandWristHP:Int = 0;

            if( this.leftHand.Arm != null )
                leftHandArmHP = switch( this.leftHand.Arm.CurrentHP ){ case HealthPoint( v ): v; };

            if( this.leftHand.Wrist != null )
                leftHandWristHP = switch( this.leftHand.Wrist.CurrentHP ){ case HealthPoint( v ): v; };

            leftHandHP = leftHandArmHP + leftHandWristHP;
        }

        var rightHandHP:Int = 0;
        if( this.rightHand != null ){
            var rightHandArmHP:Int = 0;
            var rightHandWristHP:Int = 0;

            if( this.rightHand.Arm != null )
                rightHandArmHP = switch( this.rightHand.Arm.CurrentHP ){ case HealthPoint( v ): v; };

            if( this.rightHand.Arm != null )
                rightHandWristHP = switch( this.rightHand.Wrist.CurrentHP ){ case HealthPoint( v ): v; };

            rightHandHP = rightHandArmHP + rightHandWristHP;
        }

        var leftLegHP:Int = 0;
        if( this.leftLeg != null ){
            var leftLegFootHP:Int = 0;
            var leftLegSoleHP:Int = 0;

            if( this.leftLeg.Foot != null )
                leftLegFootHP = switch( this.leftLeg.Foot.CurrentHP ){ case HealthPoint( v ): v; };

            if( this.leftLeg.Sole != null )
                leftLegSoleHP = switch( this.leftLeg.Sole.CurrentHP ){ case HealthPoint( v ): v; };

            leftLegHP = leftLegFootHP + leftLegSoleHP;
        }

        var rightLegHP:Int = 0;
        if( this.rightLeg != null ){
            var rightLegFootHP:Int = 0;
            var rightLegSoleHP:Int = 0;

            if( this.rightLeg.Foot != null )
                rightLegFootHP = switch( this.rightLeg.Foot.CurrentHP ){ case HealthPoint( v ): v; };

            if( this.rightLeg.Sole != null )
                rightLegSoleHP = switch( this.rightLeg.Sole.CurrentHP ){ case HealthPoint( v ): v; };
            
            rightLegHP = rightLegFootHP + rightLegSoleHP;
        }

        var torsoLeftLung:Int = 0;
        var torsoRightLung:Int = 0;
        var torsoHeart:Int = 0;
        var torsoTorso:Int = switch( this.torso.Torso.CurrentHP ){ case HealthPoint(v): v; };

        if( this.torso.LeftLung != null )
            torsoLeftLung = switch( this.torso.LeftLung.CurrentHP ){ case HealthPoint(v): v; };

        if( this.torso.RightLung != null )
            torsoRightLung = switch( this.torso.RightLung.CurrentHP ){ case HealthPoint(v): v; };

        if( this.torso.Heart != null )
            torsoHeart = switch( this.torso.Heart.CurrentHP ){ case HealthPoint(v): v; };
       
        var torsoHP:Int = torsoLeftLung + torsoRightLung + torsoHeart + torsoTorso ;

        this.currentTotalHP = HealthPoint( headHP + leftHandHP + rightHandHP + leftLegHP + rightLegHP + torsoHP );
    }

    public function takeDamageTo( place:String, value:Int ):Void{
        var container:BodyPart = null;
        var msg:String = this._parent.errMsg();
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
        var CurrentHP:Int = switch( place.CurrentHP ){ case HealthPoint(v): v; };
        var hp:Int = switch( place.HP ){ case HealthPoint(v): v; };
        var delta:Int = CurrentHP - value;
        var damagedStatus:Int = Math.round( hp * ( this._percentToDamagePart ));
        var brokenStatus:Int = Math.round( hp * ( this._percentToBrokenPart ));// 15% - status broken;        

        if( delta < damagedStatus && delta > brokenStatus ){
            place.CurrentHP = HealthPoint( delta );
            place.Status = "damaged";
        }else if( delta < brokenStatus && delta > 0 ){
            place.CurrentHP = HealthPoint( delta );
            place.Status = "broken";
        }else if( delta <= 0 ){
            place.CurrentHP = HealthPoint( 0 );
            place.Status = "disrupted";
            this._checkBodyPartsDependense();
            if( this._checkForDeath() )
                this._death();
            
        }else{
            place.CurrentHP = HealthPoint( delta );
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

    private function _configureHead( params:Dynamic ):Void{
        var msg:String = this._parent.errMsg();
        this.head = { Head: null, LeftEye: null, RightEye: null, Mouth: null, Brain: null, Nose: null }
        for( key in Reflect.fields( params )){
            var partParams:Dynamic = Reflect.getProperty( params, key );
            switch( key ){
                case "head": this.head.Head = this._addParamsToBodyPart( partParams );
                case "leftEye": this.head.LeftEye = this._addParamsToBodyPart( partParams );
                case "rightEye": this.head.RightEye = this._addParamsToBodyPart( partParams );
                case "mouth": this.head.Mouth = this._addParamsToBodyPart( partParams );
                case "brain": this.head.Brain = this._addParamsToBodyPart( partParams );
                case "nose": this.head.Nose = this._addParamsToBodyPart( partParams );
                default: throw '$msg. _configureHead. There is no "$key" in config';
            }

        }
    }

    private function _configureTorso( params:Dynamic ):Void{
        var msg:String = this._parent.errMsg();
        this.torso = { Torso: null, LeftLung: null, RightLung: null, Heart: null };
        for( key in Reflect.fields( params )){
            var partParams:Dynamic = Reflect.getProperty( params, key );
            switch( key ){
                case "torso": this.torso.Torso = this._addParamsToBodyPart( partParams );
                case "leftLung": this.torso.LeftLung = this._addParamsToBodyPart( partParams );
                case "rightLung": this.torso.RightLung = this._addParamsToBodyPart( partParams );
                case "heart": this.torso.Heart = this._addParamsToBodyPart( partParams );
                default: throw '$msg _configureTorso. There is no "$key" in config.';
            }
        }
    }

    private function _configureLeftLeg( params:Dynamic ):Void{
        var msg:String = this._parent.errMsg();
        this.leftLeg = { Foot: null, Sole: null };
        for( key in Reflect.fields( params )){
            var partParams:Dynamic = Reflect.getProperty( params, key );
            switch( key ){
                case "foot": this.leftLeg.Foot = this._addParamsToBodyPart( partParams );
                case "sole": this.leftLeg.Sole = this._addParamsToBodyPart( partParams );
                default: throw '$msg _configureLeftLeg. There is no "$key" in config.';
            }
        }
    }

    private function _configureRightLeg( params:Dynamic ):Void{
        var msg:String = this._parent.errMsg();
        this.rightLeg = { Foot: null, Sole: null };
        for( key in Reflect.fields( params )){
            var partParams:Dynamic = Reflect.getProperty( params, key );
            switch( key ){
                case "foot": this.rightLeg.Foot = this._addParamsToBodyPart( partParams );
                case "sole": this.rightLeg.Sole = this._addParamsToBodyPart( partParams );
                default: throw '$msg _configureRightLeg. There is no "$key" in config.';
            }
        }
    }

    private function _configureLeftHand( params:Dynamic ):Void{
        var msg:String = this._parent.errMsg();
        this.leftHand = { Arm: null, Wrist: null };
        for( key in Reflect.fields( params )){
            var partParams:Dynamic = Reflect.getProperty( params, key );
            switch( key ){
                case "arm": this.leftHand.Arm = this._addParamsToBodyPart( partParams );
                case "wrist": this.leftHand.Wrist = this._addParamsToBodyPart( partParams );
                default: throw '$msg _configureLeftHand. There is no "$key" in config.';
            }
        }
    }

    private function _configureRightHand( params:Dynamic ):Void{
        var msg:String = this._parent.errMsg();
        this.rightHand = { Arm: null, Wrist: null };
        for( key in Reflect.fields( params )){
            var partParams:Dynamic = Reflect.getProperty( params, key );
            switch( key ){
                case "arm": this.rightHand.Arm = this._addParamsToBodyPart( partParams );
                case "wrist": this.rightHand.Wrist = this._addParamsToBodyPart( partParams );
                default: throw '$msg _configureRightHand. There is no "$key" in config.';
            }
        }
    }

    private function _addParamsToBodyPart( config:Dynamic ):BodyPart{
        var bodyPart:BodyPart = { HP: null, CurrentHP: null, Status: null, PartType: null };
        var msg:String = this._parent.errMsg();
        var hp:Int = Reflect.getProperty( config, "hp" );
        var cHP:Int = Reflect.getProperty( config, "currentHP" );
        var partType:String = Reflect.getProperty( config, "partType" );
        var partStatus:String = Reflect.getProperty( config, "status" );

        if( !Std.isOfType( hp, Int )) 
            throw '$msg _addParamsToBodyPart. HP is not valid';

        bodyPart.HP = HealthPoint( hp );

        if( !Math.isNaN( cHP) )
            bodyPart.CurrentHP = HealthPoint( hp );
        else
            bodyPart.CurrentHP = HealthPoint( cHP );

        if( partType == null )
            bodyPart.PartType = "natural";
        else
            bodyPart.PartType = partType;

        if( partStatus == null )
            bodyPart.Status = "healthy";
        else
            bodyPart.Status = partStatus;

        return bodyPart;
    }

    private function _death():Void{
        this.isDead = true;
    }
}