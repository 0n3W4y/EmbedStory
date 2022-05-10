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

typedef HP = {
    var Current:HealthPoint;
    var Modifier:HealthPoint;
    var Base:HealthPoint;
}

typedef Head = {
    var Head:BodyPart;
    var LeftEye:BodyPart;
    var RightEye:BodyPart;
    var Nose:BodyPart;
    var Mouth:BodyPart;
    var Brain:BodyPart;
}

typedef Hand = {
    var Arm:BodyPart;
    var Wrist:BodyPart;
}

typedef Leg = {
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
    var HP:HP;
    var PartType:String; // natural ( 100% ), wood( 60% ), steel( 85% ), carbon( 115% ), cybernetic( 150% );
    var Status:String; // healthy ( 100% HP ), damaged( <40% HP), broken( <15% HP ), disrupted ( 0% HP );
}

class EntityHealthPointsSystem{

    public var totalHp:HealthPoint;
    public var currentHP:HealthPoint;
    public var isDead:Bool;

    public var head:Head;
    public var leftHand:Hand;
    public var rightHand:Hand;
    public var torso:Torso;
    public var leftLeg:Leg;
    public var rightLeg:Leg;

    private var _parent:Entity;
    private var _percentToBrokenPart:Float = 0.15;
    private var _percentToDamagedPart:Float = 0.70;

    public function new( parent:Entity, params:EntityHealthPointsSystemConfig ):Void{
        this._parent = parent;
        this.isDead = false;

        if( params.Head != null )
            this._configureHead( params.Head );

        if( params.Torso != null )
            this._configureTorso( params.Torso );

        if( params.LeftHand != null )
            this._configureHand( params.LeftHand, "left" );

        if( params.RightHand != null )
            this._configureHand( params.RightHand, "right" );

        if( params.LeftLeg != null )
            this._configureLeg( params.LeftLeg, "left" );

        if( params.RightLeg != null )
            this._configureLeg( params.RightLeg, "right" );

        this.updateTotalHP();
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
        var headHP:Int = this._calculateTotalHealthPointsBodyPartInt( "head" );
        var leftHandHP:Int = this._calculateTotalHealthPointsBodyPartInt( "leftHand" );
        var rightHandHP:Int = this._calculateTotalHealthPointsBodyPartInt( "rightHand" );
        var leftLegHP:Int = this._calculateTotalHealthPointsBodyPartInt( "leftLeg" );
        var rightLegHP:Int = this._calculateTotalHealthPointsBodyPartInt( "rightLeg" );
        var torsoHP:Int = this._calculateTotalHealthPointsBodyPartInt( "torso" );

        this.totalHp = HealthPoint( headHP + leftHandHP + rightHandHP + leftLegHP + rightLegHP + torsoHP );
    }

    public function updateCurrentHP():Void{
        var headHP:Int = this._calculateCurrentHealthPointsBodyPartInt( "head" );
        var leftHandHP:Int = this._calculateCurrentHealthPointsBodyPartInt( "leftHand" );
        var rightHandHP:Int = this._calculateCurrentHealthPointsBodyPartInt( "rightHand" );
        var leftLegHP:Int = this._calculateCurrentHealthPointsBodyPartInt( "leftLeg" );
        var rightLegHP:Int = this._calculateCurrentHealthPointsBodyPartInt( "rightLeg" );
        var torsoHP:Int = this._calculateCurrentHealthPointsBodyPartInt( "torso" );

        this.currentHP = HealthPoint( headHP + leftHandHP + rightHandHP + leftLegHP + rightLegHP + torsoHP );
    }

    public function changeBodyPartHP( place:String, target:String, value:Int ):Void{
        var container:BodyPart = this._getBodyPartContainer( place );
        var msg:String = this._parent.errMsg();
        msg = '$msg in changeBodyPartHP. ';
        switch( place ){
            case "head", "leftEye", "rightEye", "nose", "mouth", "brain": {
                if( this.head == null ) 
                    throw '$msg head does not exist'; 
        
                if( this._getBodyPartStatus( container ) == "disrupted" )
                    throw '$msg "$place" already disrupted';
            };
            case "leftArm", "leftWrist": {
                if( this.leftHand == null ) 
                    throw '$msg Left hand does not exist'; 
        
                if( this._getBodyPartStatus( container ) == "disrupted" )
                    throw '$msg "$place" already disrupted';
            };
            case "rightArm", "rightWrist": {
                if( this.rightHand == null ) 
                    throw '$msg Right Hand does not exist'; 
        
                if( this._getBodyPartStatus( container ) == "disrupted" )
                    throw '$msg "$place" already disrupted';
            };
            case "leftFoot", "leftSole": {
                if( this.leftLeg == null ) 
                    throw '$msg Left Leg does not exist'; 
        
                if( this._getBodyPartStatus( container ) == "disrupted" )
                    throw '$msg "$place" already disrupted';
            };
            case "rightFoot", "rightSole": {
                if( this.rightLeg == null ) 
                    throw '$msg Right Leg does not exist'; 
        
                if( this._getBodyPartStatus( container ) == "disrupted" )
                    throw '$msg "$place" already disrupted';
            };
            case "torso", "leftLung", "rightLung", "heart": {
                if( this.torso == null ) 
                    throw '$msg torso does not exist'; 
        
                if( this._getBodyPartStatus( container ) == "disrupted" )
                    throw '$msg "$place" already disrupted';
            };
            default: throw '$msg. There is no "$place" in.';
        }
        this._changeBodyPartHP( place, target, container, value );
    }





    

    private function _changeBodyPartHP( place:String, target:String, bodyPart:BodyPart, value:Int ):Void{
        //var currentValue:Int = this._getHealthPointsFromContainerInt( bodyPart, target );
        //var difference:Int = currentValue + value;
        switch( target ){
            case "current":{
                // direct damage to part
                var currentHP:Int = this._getHealthPointsFromContainerInt( bodyPart, target ) + value;
                this._setHealthPointsToCointainer( bodyPart, target, currentHP );
                var currentStatus:String = this._getBodyPartStatus( bodyPart );
                var status:String = this._calculateStatusForBodyPart( bodyPart );
                if( currentStatus != status ){
                    if( this._checkForDeath( place ))
                        this._death();
                    else
                        this._calulateDependencies( place );
                }

            };
            case "modifier":{
                // modifed from stat or inventory items or effects;
                var modifierValue:Int = this._getHealthPointsFromContainerInt( bodyPart, target ) + value;
                this._setHealthPointsToCointainer( bodyPart, target, modifierValue );
                var newCurrentHP:Int = this._calculateCurrentHealthPointsBodyPartInt( place ) + value;
                if( newCurrentHP <= 0 ) // проверяем отрицательное значение, если вдруг модификатор пришел отрицательный, а часть тела была уже повреждена до минимума.
                    newCurrentHP = 1;

                this._setHealthPointsToCointainer( bodyPart, "current", newCurrentHP );
            };
            case "base":{
                var baseValue:Int = this._getHealthPointsFromContainerInt( bodyPart, target ) + value;
                if( baseValue < 0 )
                    baseValue = 0;

                this._setHealthPointsToCointainer( bodyPart, target, baseValue );
                var newCurrentHP:Int = this._calculateCurrentHealthPointsBodyPartInt( place ) + value;
                if( newCurrentHP <= 0 )
                    newCurrentHP = 1;

                this._setHealthPointsToCointainer( bodyPart, "current", newCurrentHP );
            };
        }
    }

    private function _calulateDependencies( place:String ):Void{
        this._checkAndChangeBodyPartsDependense( place );
    }

    private function _checkAndChangeBodyPartsDependense( place:String ):Void{
        var bodyPart:BodyPart = this._getBodyPartContainer( place );
        var status:String = this._getBodyPartStatus( bodyPart );
        var container:BodyPart;
        switch( place ){
            case "leftArm":{
                if( status == "disrupted" )
                    container = this.leftHand.Wrist;
            };
            case "rightArm":{
                if( status == "disrupted" )
                    container = this.rightHand.Wrist;
            };
            case "leftFoot":{
                if( status == "disrupted" )
                    container =  this.leftLeg.Sole;
            };
            case "rightFoot":{
                if( status == "disrupted" )
                    container = this.rightLeg.Sole;
            }
            default: return;
        }
        this._setStatusToBodyPart( container, status );
        this._setHealthPointsToCointainer( container, "current", 0 );
    }

    private function _checkForDeath( place ):Bool{
        var bodyPart:BodyPart = this._getBodyPartContainer( place );
        var status:String = this._getBodyPartStatus( bodyPart ); 
        if( status == "disrupted" ){
            if( place == "heart" || place == "torso" || place == "head" || place == "brain" )
                return true;

            if( place == "leftLung" || place == "rightLung" ){
                if( this.torso.LeftLung.Status == "disrupted" && this.torso.RightLung.Status == "disrupted" )
                    return true;
            }            
        }
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

    private function _configureLeg( params:Dynamic, place:String ):Void{
        var msg:String = this._parent.errMsg();
        var container:Dynamic;
        if( place == "left" ){
            this.leftLeg = { Foot: null, Sole: null };
            container = this.leftLeg;
        }else{
            this.rightLeg = { Foot: null, Sole: null };
            container = this.rightLeg;
        }

        for( key in Reflect.fields( params )){
            var partParams:Dynamic = Reflect.getProperty( params, key );
            switch( key ){
                case "foot": container.Foot = this._addParamsToBodyPart( partParams );
                case "sole": container.Sole = this._addParamsToBodyPart( partParams );
                default: throw '$msg _configureRightLeg. There is no "$key" in config.';
            }
        }
    }

    private function _configureHand( params:Dynamic, place:String ):Void{
        var msg:String = this._parent.errMsg();
        var container:Dynamic;
        if( place == "left" ){
            this.leftHand = { Arm: null, Wrist: null };
            container = this.leftHand;
        }else{
            this.rightHand = { Arm: null, Wrist: null };
            container = this.rightHand;
        }

        for( key in Reflect.fields( params )){
            var partParams:Dynamic = Reflect.getProperty( params, key );
            switch( key ){
                case "arm": container.Arm = this._addParamsToBodyPart( partParams );
                case "wrist": container.Wrist = this._addParamsToBodyPart( partParams );
                default: throw '$msg _configureRightHand. There is no "$key" in config.';
            }
        }
    }

    private function _calculateCurrentHealthPointsBodyPartInt( place:String ):Int{
        switch( place ){
            case "head":{
                if( this.head != null ){
                    var headLeftEye:Int = this._getHealthPointsFromContainerInt( this.head.LeftEye, "current" );
                    var headRightEye:Int = this._getHealthPointsFromContainerInt( this.head.RightEye, "current" );
                    var headNose:Int = this._getHealthPointsFromContainerInt( this.head.Nose, "current" );
                    var headMouth:Int = this._getHealthPointsFromContainerInt( this.head.Mouth, "current" );
                    var headBrain:Int = this._getHealthPointsFromContainerInt( this.head.Brain, "current" );
                    return headLeftEye + headRightEye + headNose + headMouth + headBrain;
                }else{
                    return 0;
                }
            };
            case "leftLeg":{
                if( this.leftLeg != null ){
                    var footHP:Int = this._getHealthPointsFromContainerInt( this.leftLeg.Foot, "current" );
                    var soleHP:Int = this._getHealthPointsFromContainerInt( this.leftLeg.Sole, "current" );
                    return footHP + soleHP;
                }else{
                    return 0;
                }
                
            };
            case "rightLeg":{
                if( this.rightLeg != null ){
                    var footHP:Int = this._getHealthPointsFromContainerInt( this.rightLeg.Foot, "current" );
                    var soleHP:Int = this._getHealthPointsFromContainerInt( this.rightLeg.Sole, "current" );
                    return footHP + soleHP;
                }else{
                    return 0;
                }
            };
            case "torso":{
                if( this.torso.Torso == null )
                    throw 'Error in EntityHealthPointsSystem._calculateTotalHealthPointsBodyPartInt. Torso.Torso == NULL!!';

                var leftLung:Int = this._getHealthPointsFromContainerInt( this.torso.LeftLung, "current" );
                var rightLung:Int = this._getHealthPointsFromContainerInt( this.torso.RightLung, "current" );
                var heart:Int = this._getHealthPointsFromContainerInt( this.torso.Heart, "current" );
                var torso:Int = this._getHealthPointsFromContainerInt( this.torso.LeftLung, "current" );
                return leftLung + rightLung + heart + torso;
            };
            case "leftHand":{
                if( this.leftHand != null ){
                    var armHP:Int = this._getHealthPointsFromContainerInt( this.leftHand.Arm, "current" );
                    var wristHP:Int = this._getHealthPointsFromContainerInt( this.leftHand.Wrist, "current" );
                    return armHP + wristHP;
                }else{
                    return 0;
                }
            };
            case "rihtHand":{
                if( this.rightHand != null ){
                    var armHP:Int = this._getHealthPointsFromContainerInt( this.rightHand.Arm, "current" );
                    var wristHP:Int = this._getHealthPointsFromContainerInt( this.rightHand.Wrist, "current" );
                    return armHP + wristHP;
                }else{
                    return 0;
                }
            };
            default: throw 'Error in EntityHealthPointsSystem._calculateCurrentHealthPointsBodyPartInt. "$place" is not valid.';
        }
    }

    private function _calculateTotalHealthPointsBodyPartInt( place:String ):Int{
        switch( place ){
            case "head":{
                if( this.head != null ){
                    var headLeftEye:Int = this._calculateTotalHealthPointsChildBodyPartInt( this.head.LeftEye );
                    var headRightEye:Int = this._calculateTotalHealthPointsChildBodyPartInt( this.head.RightEye );
                    var headNose:Int = this._calculateTotalHealthPointsChildBodyPartInt( this.head.Nose );
                    var headMouth:Int = this._calculateTotalHealthPointsChildBodyPartInt( this.head.Mouth );
                    var headBrain:Int = this._calculateTotalHealthPointsChildBodyPartInt( this.head.Brain );
                    return headLeftEye + headRightEye + headNose + headMouth + headBrain;
                }else{
                    return 0;
                }
            };
            case "leftLeg":{
                if( this.leftLeg != null ){
                    var footHP:Int = this._calculateTotalHealthPointsChildBodyPartInt( this.leftLeg.Foot );
                    var soleHP:Int = this._calculateTotalHealthPointsChildBodyPartInt( this.leftLeg.Sole );
                    return footHP + soleHP;
                }else{
                    return 0;
                }
                
            };
            case "rightLeg":{
                if( this.rightLeg != null ){
                    var footHP:Int = this._calculateTotalHealthPointsChildBodyPartInt( this.rightLeg.Foot );
                    var soleHP:Int = this._calculateTotalHealthPointsChildBodyPartInt( this.rightLeg.Sole );
                    return footHP + soleHP;
                }else{
                    return 0;
                }
            };
            case "torso":{
                if( this.torso.Torso == null )
                    throw 'Error in EntityHealthPointsSystem._calculateTotalHealthPointsBodyPartInt. Torso.Torso == NULL!!';

                var leftLung:Int = this._calculateTotalHealthPointsChildBodyPartInt( this.torso.LeftLung );
                var rightLung:Int = this._calculateTotalHealthPointsChildBodyPartInt( this.torso.RightLung );
                var heart:Int = this._calculateTotalHealthPointsChildBodyPartInt( this.torso.Heart );
                var torso:Int = this._calculateTotalHealthPointsChildBodyPartInt( this.torso.LeftLung );
                return leftLung + rightLung + heart + torso;
            };
            case "leftHand":{
                if( this.leftHand != null ){
                    var armHP:Int = this._calculateTotalHealthPointsChildBodyPartInt( this.leftHand.Arm );
                    var wristHP:Int = this._calculateTotalHealthPointsChildBodyPartInt( this.leftHand.Wrist );
                    return armHP + wristHP;
                }else{
                    return 0;
                }
            };
            case "rihtHand":{
                if( this.rightHand != null ){
                    var armHP:Int = this._calculateTotalHealthPointsChildBodyPartInt( this.rightHand.Arm );
                    var wristHP:Int = this._calculateTotalHealthPointsChildBodyPartInt( this.rightHand.Wrist );
                    return armHP + wristHP;
                }else{
                    return 0;
                }
            };
            default: throw 'Error in EntityHealthPointsSystem._calculateTotalHealthPointsBodyPartInt. "$place" is not valid.';
        }
    }

    private inline function _calculateTotalHealthPointsChildBodyPartInt( container:BodyPart ):Int{
        if( container != null )
            return this._getHealthPointsFromContainerInt( container, "base" ) + this._getHealthPointsFromContainerInt( container, "modifier" );
        else
            return 0;
    }

    private function _setStatusToBodyPart( container:BodyPart, status:String ):Void{
        container.Status = status;
    }

    private function _setPartTypeToBodyPart( container:BodyPart, partType:String ):Void{
        container.PartType = partType;
    }

    private function _getHealthPointsFromContainerInt( container:BodyPart, place:String ):Int{
        if( container == null )
            return 0;

        var value:Int;
        switch( place ){
            case "current": value = switch( container.HP.Current ){ case HealthPoint( v ): v; };
            case "modifier": value = switch( container.HP.Modifier ){ case HealthPoint( v ): v; };
            case "base": value = switch( container.HP.Base ){ case HealthPoint( v ): v; };
            default: throw 'Error in EntityHealthPointSystem._getHealthPointsFromContainerInt. "$place" is not valid!';
        }
        return value;
    }

    private function _setHealthPointsToCointainer( container:BodyPart, place:String, value:Int ):Void{
        switch( place ){
            case "current": container.HP.Current = HealthPoint( value );
            case "base": container.HP.Base = HealthPoint( value );
            case "modifier": container.HP.Modifier = HealthPoint( value );
            default: throw 'Error in EntityHealthPointSystem._setHealthPointToContainer. "$place" is not valid!';
        }
    }

    private inline function _getBodyPartStatus( bodyPart:BodyPart ):String{
        return bodyPart.Status;
    }

    private function _getBodyPartContainer( bodyPart:String ):BodyPart{
        switch( bodyPart ){
            case "head": return this.head.Head;
            case "leftEye": return this.head.LeftEye;
            case "rightEye": return this.head.RightEye;
            case "nose": return this.head.Nose;
            case "mouth": return this.head.Mouth;
            case "brain": return this.head.Brain;
            case "torso": return this.torso.Torso;
            case "leftLung": return this.torso.LeftLung;
            case "rightLung": return this.torso.RightLung;
            case "heart": return this.torso.Heart;
            case "leftArm": return this.leftHand.Arm;
            case "rightArm": return this.rightHand.Arm;
            case "leftWrist": return this.leftHand.Wrist;
            case "rightWrits": return this.rightHand.Wrist;
            case "leftFoot": return this.leftLeg.Foot;
            case "leftSole": return this.leftLeg.Sole;
            case "rightFoot": return this.rightLeg.Foot;
            case "rightSole": return this.rightLeg.Sole;
            default: throw 'Error in EntityHealthPointsSystem._getBodyPartContainer. "$bodyPart" is not valid.';
        }
    }

    private function _calculateStatusForBodyPart( place:BodyPart ):String{
        var hp:Int = this._getHealthPointsFromContainerInt( place, "current" );
        var damagedStatus:Int = Math.round( hp * ( this._percentToDamagedPart ));
        var brokenStatus:Int = Math.round( hp * ( this._percentToBrokenPart ));// 15% - status broken;        

        if( hp <= 0 )
            return "disrupted";
        else if( hp < brokenStatus && hp > 0 )
            return "broken";
        else if( hp < damagedStatus && hp > brokenStatus )
            return "damaged";
        else
            return "healthy";
    }

    private function _addParamsToBodyPart( config:Dynamic ):BodyPart{
        var bodyPart:BodyPart = { HP: { Current: HealthPoint( 0 ), Modifier: HealthPoint( 0 ), Base: HealthPoint( 0 ) }, Status: "n/a", PartType: "n/a" };
        var msg:String = this._parent.errMsg();
        var baseHP:Int = Reflect.getProperty( config, "baseHP" );
        var currentHP:Int = Reflect.getProperty( config, "currentHP" );
        var partType:String = Reflect.getProperty( config, "partType" );
        var partStatus:String = Reflect.getProperty( config, "status" );

        if( Math.isNaN( baseHP ) || baseHP < 0 ) 
            throw '$msg EntityHealthPointsSystem._addParamsToBodyPart. HP "$baseHP" is not valid';

        this._setHealthPointsToCointainer( bodyPart, "base", baseHP );
        if( currentHP <= -1 || Math.isNaN( currentHP ))
            currentHP = baseHP;
        
        this._setHealthPointsToCointainer( bodyPart, "current", currentHP );
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