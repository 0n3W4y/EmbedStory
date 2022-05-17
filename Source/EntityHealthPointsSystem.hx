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
    private var _painForDamagedPart:Int = 23;
    private var _painForBrokenPart:Int = 58;
    private var _painForDisruptedOrRemovedPart:Int = 92;
    private var _eatingSpeedDamagedPart:Int = 250;
    private var _eatingSpeedBrokenPart:Int = 500;


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

        this._updateTotalHP();
        this._updateCurrentTotalHP();
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

    public function changeHPModifierForAllBodyParts( value:Int ):Void {
        var array:Array<String> = this.getAvailableBodyPartsString();
        for( i in 0...array.length ){
            this.changeBodyPartHP( array[ i ], "modifier", value );
        }
        this._updateTotalHP();
        this._updateCurrentTotalHP();
    }

    public function canChangeBodyPartHP( place:String, target:String, value:Int ):Bool{
        var container:BodyPart = this._getBodyPartContainer( place );
        if( container == null )
            return false;

        switch( target ){
            case "modifier":{
                var currentHP:Int = this._calculateCurrentHealthPointsChildBodyPartInt( container );
                var difference:Int  = currentHP + value;
                if( difference <= 0 )
                    return false;
            }
            case "base":{
                var baseValue:Int = this._getHealthPointsFromContainerInt( container, "base" ) + value;
                if( baseValue <= 0 )
                    return false;
            }
            case "current":{};
            default: throw 'Error in EntityHealthPointsSystem.canChangeBodyPart. "$target" is not valid.';
        }
        return true;
    }

    public function changeBodyPartHP( place:String, target:String, value:Int ):Void{
        var bodyPart:BodyPart = this._getBodyPartContainer( place );
        switch( target ){
            case "current":{
                // direct damage to part
                var currentHP:Int = this._getHealthPointsFromContainerInt( bodyPart, target );
                var calculatedCurrentHP:Int = this._calculateCurrentHealthPointsChildBodyPartInt( bodyPart );
                var modifiedCurrentHP:Int = currentHP + value;
                if( modifiedCurrentHP < 0 ){
                    modifiedCurrentHP = 0;
                }else if( modifiedCurrentHP > calculatedCurrentHP )
                    modifiedCurrentHP = calculatedCurrentHP;
                    
                
                this._setHealthPointsToCointainer( bodyPart, target, modifiedCurrentHP );
                var diffirenceHP:Int = modifiedCurrentHP - currentHP;
                var totalCurrentHP:Int = switch( this.currentHP ){ case HealthPoint( v ): v;};
                totalCurrentHP += diffirenceHP;
                this.currentHP = HealthPoint( totalCurrentHP );

                var currentStatus:String = bodyPart.Status;
                var status:String = this._calculateStatusForBodyPart( bodyPart );
                if( currentStatus != status ){
                    if( this._checkForDeath( place ))
                        this._death();
                    else{
                        this._calculateDependencies( place );
                    }
                }
            };
            case "modifier":{
                // modifed from stat or inventory items or effects;
                var modifierValue:Int = this._getHealthPointsFromContainerInt( bodyPart, target ) + value;
                this._setHealthPointsToCointainer( bodyPart, target, modifierValue );
                var newCurrentHP:Int = this._calculateCurrentHealthPointsChildBodyPartInt( bodyPart ) + value;
                var bodyPartStatus:String = bodyPart.Status;
                if(( bodyPartStatus != "disrupted" || bodyPartStatus != "removed" ) && newCurrentHP <= 0 )
                    newCurrentHP = 1; // проверяем отрицательное значение, если вдруг модификатор пришел отрицательный, а часть тела была уже повреждена до минимума.

                this._setHealthPointsToCointainer( bodyPart, "current", newCurrentHP );
            };
            case "base":{
                var baseValue:Int = this._getHealthPointsFromContainerInt( bodyPart, target ) + value;
                if( baseValue < 0 )
                    baseValue = 0;

                this._setHealthPointsToCointainer( bodyPart, target, baseValue );
                var newCurrentHP:Int = this._calculateCurrentHealthPointsChildBodyPartInt( bodyPart ) + value;
                var bodyPartStatus:String = bodyPart.Status;
                if(( bodyPartStatus != "disrupted" || bodyPartStatus != "removed" ) && newCurrentHP <= 0  )
                    newCurrentHP = 1;

                this._setHealthPointsToCointainer( bodyPart, "current", newCurrentHP );
            };
        }
    }

    public function canRemoveBodyPart( place:String ):Bool{
        var bodyPart:BodyPart = this._getBodyPartContainer( place );
        if( bodyPart == null )
            return false;

        if( bodyPart.Status == "removed" )
            return false;

        return true;
    }

    public function removeBodyPart( place:String ):Void{
        var bodyPart:BodyPart = this._getBodyPartContainer( place );        
        this._setHealthPointsToCointainer( bodyPart, "current", 0 );
        this._setStatusToBodyPart( bodyPart, "removed" );
        this._calculateDependencies( place );
    }

    public function canAddBodyPart( place:String ):Bool{
        var container:BodyPart = this._getBodyPartContainer( place );
        if( container == null )
            return false;

        if( container.Status != "removed" )
            return false;
        
        return true;            
    }

    public function addBodyPart( place:String, config:BodyPart ):Void{
        var container:BodyPart = _getBodyPartContainer( place );
        container.HP.Base = config.HP.Base;
        container.PartType = config.PartType;
        container.Status = config.Status;

        var currentHP:Int = this._calculateCurrentHealthPointsChildBodyPartInt( container );
        this._setHealthPointsToCointainer( container, "current", currentHP );

        this._updateTotalHP();
        this._updateCurrentTotalHP();
        this._calculateDependencies( place );   
    }

    public function getAvailableBodyPartsString():Array<String>{
        var array:Array<String> = [];
        if( this.head != null ){
            var head:BodyPart = this.head.Head;
            if( head != null && ( head.Status != "disrupted" || head.Status != "removed" ))
                array.push( "head" );

            var leftEye:BodyPart = this.head.LeftEye;
            if( leftEye != null && ( leftEye.Status != "disrupted" || leftEye.Status != "removed" ))
                array.push( "leftEye" );

            var rightEye:BodyPart = this.head.RightEye;
            if( rightEye != null && ( rightEye.Status != "disrupted" || rightEye.Status != "removed" ))
                array.push( "rightEye" );

            var nose:BodyPart = this.head.Nose;
            if( nose != null && ( nose.Status != "disrupted" || nose.Status != "removed" ))
                array.push( "nose" );

            var mouth:BodyPart = this.head.Mouth;
            if( mouth != null && ( mouth.Status != "disrupted" || mouth.Status != "removed" ))
                array.push( "mouth" );
        }

        if( this.leftLeg != null ){
            var leftFoot:BodyPart = this.leftLeg.Foot;
            if( leftFoot != null && ( leftFoot.Status != "disrupted" || leftFoot.Status != "removed" ))
                array.push( "leftFoot" );
            
            var leftSole:BodyPart = this.leftLeg.Sole;
            if( leftSole != null && ( leftSole.Status != "disrupted" || leftSole.Status != "removed" ))
                array.push( "leftSole" );
        }

        if( this.leftHand != null ){
            var leftArm:BodyPart = this.leftHand.Arm;
            if( leftArm != null && ( leftArm.Status != "disrupted" || leftArm.Status != "removed" ))
                array.push( "leftArm" );

            var leftWrist:BodyPart = this.leftHand.Wrist;
            if( leftWrist != null && ( leftWrist.Status != "disrupted" || leftWrist.Status != "removed" ))
                array.push( "leftWrist" );
        }

        if( this.rightLeg != null ){
            var rightFoot:BodyPart = this.rightLeg.Foot;
            if( rightFoot != null && ( rightFoot.Status != "disrupted" || rightFoot.Status != "removed" ))
                array.push( "rightFoot" );

            var rightSole:BodyPart = this.rightLeg.Sole;
            if( rightSole != null && ( rightSole.Status != "disrupted" || rightSole.Status != "removed" ))
                array.push( "rightSole" );
        }

        if( this.rightHand != null ){
            var rightArm:BodyPart = this.rightHand.Arm;
            if( rightArm != null && ( rightArm.Status != "disrupted" || rightArm.Status != "removed" ))
                array.push( "rightArm" );

            var rightWrist:BodyPart = this.rightHand.Wrist;
            if( rightWrist != null && ( rightWrist.Status != "disrupted" || rightWrist.Status != "removed" ))
                array.push( "rightWrist" );
        }
        return array;
    }





    


    private function _updateTotalHP():Void{
        var headHP:Int = this._calculateTotalHealthPointsBodyPartInt( "head" );
        var leftHandHP:Int = this._calculateTotalHealthPointsBodyPartInt( "leftHand" );
        var rightHandHP:Int = this._calculateTotalHealthPointsBodyPartInt( "rightHand" );
        var leftLegHP:Int = this._calculateTotalHealthPointsBodyPartInt( "leftLeg" );
        var rightLegHP:Int = this._calculateTotalHealthPointsBodyPartInt( "rightLeg" );
        var torsoHP:Int = this._calculateTotalHealthPointsBodyPartInt( "torso" );

        this.totalHp = HealthPoint( headHP + leftHandHP + rightHandHP + leftLegHP + rightLegHP + torsoHP );
    }

    private function _updateCurrentTotalHP():Void{
        var headHP:Int = this._calculateCurrentTotalHealthPointsBodyPartInt( "head" );
        var leftHandHP:Int = this._calculateCurrentTotalHealthPointsBodyPartInt( "leftHand" );
        var rightHandHP:Int = this._calculateCurrentTotalHealthPointsBodyPartInt( "rightHand" );
        var leftLegHP:Int = this._calculateCurrentTotalHealthPointsBodyPartInt( "leftLeg" );
        var rightLegHP:Int = this._calculateCurrentTotalHealthPointsBodyPartInt( "rightLeg" );
        var torsoHP:Int = this._calculateCurrentTotalHealthPointsBodyPartInt( "torso" );

        this.currentHP = HealthPoint( headHP + leftHandHP + rightHandHP + leftLegHP + rightLegHP + torsoHP );
    }

    private function _changeBodyPartHP( place:String, target:String, bodyPart:BodyPart, value:Int ):Void{
        
    }

    private function _calculateStatusDependencies( place:String, oldStatus:String ):Void{
        var bodyPart:BodyPart = this._getBodyPartContainer( place );
        var status:String = bodyPart.Status;
        var requirement:EntityRequirementSystem = this._parent.requirement;
        var stats:EntityStatsSystem = this._parent.stats;
        switch( place ){
            case "mouth": {                
                if( status == "disrupted" || status == "removed" ){
                    requirement.canEat = false;
                    requirement.hasMouth = false;
                    switch( oldStatus ){
                        case "broken":{};
                        case "healthy":{};
                        case "damaged":{};
                    }
                    stats.changePain( this._painForDisruptedOrRemovedPart );
                }else if( status == "damaged" ){
                    requirement.canEat = true;
                    requirement.hasMouth = true;
                    if( oldStatus == "broken" ){
                        stats.changePain( this._painForDamagedPart );
                        //eating speed 75%
                    }else if( oldStatus == "healthy" ){
                        stats.changePain( this._painForDamagedPart + this._painForBrokenPart );
                    }else{

                    }
    
                }else if( status == "broken" ){
                    requirement.canEat = true;
                    requirement.hasMouth = true;
                    if( oldStatus == "healthy" ){
                        stats.changePain( this._painForBrokenPart );
                        //eating speed 25%
                    }
                    
                }else{
                    requirement.canEat = true;
                    requirement.hasMouth = true;
                    //eating speed = 100%;
                }
            }
            case "nose":{};
            case "leftEye":{};
            case "rightEye":{};
            case "leftLung":{};
            case "rightLung": {};
            case "leftWrist":{};
            case "leftArm":{};
            case "rightWrist":{};
            case "rightArm":{};
            case "leftFoot":{};
            case "leftSole":{};
            case "rightFoot":{};
            case "rightSole":{};
        }
        //TODO: decrease skills and stats value;
        //TODO: Add pain to stats;
        this._checkAndChangeBodyPartsStatusDependense( place );
    }

    private function _checkAndChangeBodyPartsStatusDependense( place:String ):Void{
        var status:String = this._getBodyPartStatus( place );
        var container:BodyPart;
        var newPlace:String = "n/a";
        switch( place ){
            case "leftArm":{
                if( status == "disrupted" ){
                    container = this.leftHand.Wrist;
                    newPlace = "leftWrist";
                }
            };
            case "rightArm":{
                if( status == "disrupted" ){
                    container = this.rightHand.Wrist;
                    newPlace = "rightWrist";
                }
            };
            case "leftFoot":{
                if( status == "disrupted" ){
                    container =  this.leftLeg.Sole;
                    newPlace = "leftSole";
                }
            };
            case "rightFoot":{
                if( status == "disrupted" ){
                    container = this.rightLeg.Sole;
                    newPlace = "rightSole";
                }
            }
            default: return;
        }
        if( newPlace == "n/a" )
            return;

        this._setStatusToBodyPart( container, status );
        this._setHealthPointsToCointainer( container, "current", 0 );
        this._calculateStatusDependencies( newPlace );
    }

    private function _checkForDeath( place ):Bool{
        var status:String = this._getBodyPartStatus( place ); 
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

    private function _calculateCurrentTotalHealthPointsBodyPartInt( place:String ):Int{
        switch( place ){
            case "head":{
                if( this.head != null ){
                    var headLeftEye:Int = this._getHealthPointsFromContainerInt( this.head.LeftEye, "current" );
                    var headRightEye:Int = this._getHealthPointsFromContainerInt( this.head.RightEye, "current" );
                    var headNose:Int = this._getHealthPointsFromContainerInt( this.head.Nose, "current" );
                    var headMouth:Int = this._getHealthPointsFromContainerInt( this.head.Mouth, "current" );
                    var headBrain:Int = this._getHealthPointsFromContainerInt( this.head.Brain, "current" );
                    var headHead:Int = this._getHealthPointsFromContainerInt( this.head.Head, "current" );
                    return headLeftEye + headRightEye + headNose + headMouth + headBrain + headHead;
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
                var torso:Int = this._getHealthPointsFromContainerInt( this.torso.Torso, "current" );
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
                    var headLeftEye:Int = this._calculateCurrentHealthPointsChildBodyPartInt( this.head.LeftEye );
                    var headRightEye:Int = this._calculateCurrentHealthPointsChildBodyPartInt( this.head.RightEye );
                    var headNose:Int = this._calculateCurrentHealthPointsChildBodyPartInt( this.head.Nose );
                    var headMouth:Int = this._calculateCurrentHealthPointsChildBodyPartInt( this.head.Mouth );
                    var headBrain:Int = this._calculateCurrentHealthPointsChildBodyPartInt( this.head.Brain );
                    return headLeftEye + headRightEye + headNose + headMouth + headBrain;
                }else{
                    return 0;
                }
            };
            case "leftLeg":{
                if( this.leftLeg != null ){
                    var footHP:Int = this._calculateCurrentHealthPointsChildBodyPartInt( this.leftLeg.Foot );
                    var soleHP:Int = this._calculateCurrentHealthPointsChildBodyPartInt( this.leftLeg.Sole );
                    return footHP + soleHP;
                }else{
                    return 0;
                }
                
            };
            case "rightLeg":{
                if( this.rightLeg != null ){
                    var footHP:Int = this._calculateCurrentHealthPointsChildBodyPartInt( this.rightLeg.Foot );
                    var soleHP:Int = this._calculateCurrentHealthPointsChildBodyPartInt( this.rightLeg.Sole );
                    return footHP + soleHP;
                }else{
                    return 0;
                }
            };
            case "torso":{
                if( this.torso.Torso == null )
                    throw 'Error in EntityHealthPointsSystem._calculateTotalHealthPointsBodyPartInt. Torso.Torso == NULL!!';

                var leftLung:Int = this._calculateCurrentHealthPointsChildBodyPartInt( this.torso.LeftLung );
                var rightLung:Int = this._calculateCurrentHealthPointsChildBodyPartInt( this.torso.RightLung );
                var heart:Int = this._calculateCurrentHealthPointsChildBodyPartInt( this.torso.Heart );
                var torso:Int = this._calculateCurrentHealthPointsChildBodyPartInt( this.torso.LeftLung );
                return leftLung + rightLung + heart + torso;
            };
            case "leftHand":{
                if( this.leftHand != null ){
                    var armHP:Int = this._calculateCurrentHealthPointsChildBodyPartInt( this.leftHand.Arm );
                    var wristHP:Int = this._calculateCurrentHealthPointsChildBodyPartInt( this.leftHand.Wrist );
                    return armHP + wristHP;
                }else{
                    return 0;
                }
            };
            case "rihtHand":{
                if( this.rightHand != null ){
                    var armHP:Int = this._calculateCurrentHealthPointsChildBodyPartInt( this.rightHand.Arm );
                    var wristHP:Int = this._calculateCurrentHealthPointsChildBodyPartInt( this.rightHand.Wrist );
                    return armHP + wristHP;
                }else{
                    return 0;
                }
            };
            default: throw 'Error in EntityHealthPointsSystem._calculateTotalHealthPointsBodyPartInt. "$place" is not valid.';
        }
    }

    private inline function _calculateCurrentHealthPointsChildBodyPartInt( container:BodyPart ):Int{
        if( container != null )
            return this._getHealthPointsFromContainerInt( container, "base" ) + this._getHealthPointsFromContainerInt( container, "modifier" );
        else
            return 0;
    }

    private function _changeStatusInBodyPart( place:String, status:String ):Void{
        var container:BodyPart = this._getBodyPartContainer( place );
        container.Status = status;
        this._calculateStatusDependencies( place );
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

    private inline function _getBodyPartStatus( place:String ):String{
        var bodyPart:BodyPart = this._getBodyPartContainer( place );
        if( bodyPart == null )
            return "n/a";

        return bodyPart.Status;
    }

    private function _getBodyPartContainer( bodyPart:String ):BodyPart{
        switch( bodyPart ){
            case "head", "leftEye", "rightEye", "nose", "mouth", "brain":{
                if( this.head == null )
                    return null;

                switch( bodyPart ){
                    case "head": return this.head.Head;
                    case "leftEye": return this.head.LeftEye;
                    case "rightEye": return this.head.RightEye;
                    case "nose": return this.head.Nose;
                    case "mouth": return this.head.Mouth;
                    case "brain": return this.head.Brain;
                    default: return null;
                }
            }
            case "torso", "leftLung", "rightLung", "heart":{
                if( this.torso == null )
                    return null;

                switch( bodyPart ){
                    case "torso": return this.torso.Torso;
                    case "leftLung": return this.torso.LeftLung;
                    case "rightLung": return this.torso.RightLung;
                    case "heart": return this.torso.Heart;
                    default: return null;
                }
            }
            case "leftArm", "leftWrist": {
                if( this.leftHand == null )
                    return null;

                if( bodyPart == "leftArm" )
                    return this.leftHand.Arm;
                else
                    return this.leftHand.Wrist;
            }
            case "rightArm", "rightWrist":{
                if( this.rightHand == null )
                    return null;

                if( bodyPart == "rightArm" )
                    return this.rightHand.Arm;
                else
                    return this.rightHand.Wrist;
            }
            case "leftFoot", "leftSole":{
                if( this.leftLeg == null )
                    return null;

                if( bodyPart == "leftFoot" )
                    return this.leftLeg.Foot;
                else
                    return this.leftLeg.Sole;
            }
            case "rightFoot", "rightSole":{
                if( this.rightLeg == null )
                    return null;

                if( bodyPart == "rightFoot" )
                    return this.rightLeg.Foot
                else
                    return this.rightLeg.Sole;
            }
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