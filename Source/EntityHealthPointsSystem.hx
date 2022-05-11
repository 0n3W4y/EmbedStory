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
        this.updateCurrentTotalHP();
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

    public function updateCurrentTotalHP():Void{
        var headHP:Int = this._calculateCurrentTotalHealthPointsBodyPartInt( "head" );
        var leftHandHP:Int = this._calculateCurrentTotalHealthPointsBodyPartInt( "leftHand" );
        var rightHandHP:Int = this._calculateCurrentTotalHealthPointsBodyPartInt( "rightHand" );
        var leftLegHP:Int = this._calculateCurrentTotalHealthPointsBodyPartInt( "leftLeg" );
        var rightLegHP:Int = this._calculateCurrentTotalHealthPointsBodyPartInt( "rightLeg" );
        var torsoHP:Int = this._calculateCurrentTotalHealthPointsBodyPartInt( "torso" );

        this.currentHP = HealthPoint( headHP + leftHandHP + rightHandHP + leftLegHP + rightLegHP + torsoHP );
    }

    public function changeHPModifierForAllBodyParts( value:Int ):Void {
        if( this.head != null ){
            if( this.head.Brain != null )
                this.changeBodyPartHP( "brain", "modifier", value );
        }
        //TODO:
        this.updateTotalHP();
        this.updateCurrentTotalHP();
    }

    public function canChangeBodyPartModifier():Bool{

    }

    public function canChangeBodyPartBase():Bool{

    }

    public function changeBodyPartHP( place:String, target:String, value:Int ):Void{
        var container:BodyPart = this._getBodyPartContainer( place );
        var msg:String = this._parent.errMsg();
        msg = '$msg in changeBodyPartHP. ';
        if( container == null )
            throw '$msg "$place" not valid';

        switch( place ){
            case "head", "leftEye", "rightEye", "nose", "mouth", "brain": {
                if( this.head == null ) 
                    throw '$msg head does not exist'; 
            };
            case "leftArm", "leftWrist": {
                if( this.leftHand == null ) 
                    throw '$msg Left hand does not exist'; 
            };
            case "rightArm", "rightWrist": {
                if( this.rightHand == null ) 
                    throw '$msg Right Hand does not exist'; 
            };
            case "leftFoot", "leftSole": {
                if( this.leftLeg == null ) 
                    throw '$msg Left Leg does not exist'; 
            };
            case "rightFoot", "rightSole": {
                if( this.rightLeg == null ) 
                    throw '$msg Right Leg does not exist'; 
            };
            case "torso", "leftLung", "rightLung", "heart": {
                if( this.torso == null ) 
                    throw '$msg torso does not exist'; 
            };
            default: throw '$msg. Can not change "$place".';
        }
        this._changeBodyPartHP( place, target, container, value );
    }

    public function removeBodyPart( place:String ):Void{
        var bodyPart:BodyPart = this._getBodyPartContainer( place );
        if( bodyPart == null )
            throw 'Error in EntityHealthPointsSystem.removeBodyPart. Can not remove "$place", not exist.';
        
        this._setHealthPointsToCointainer( bodyPart, "current", 0 );
        this._setStatusToBodyPart( bodyPart, "removed" );
               
    }

    public function addBodyPart( place:String, config:Dynamic ):Void{
        var container:BodyPart = this._getBodyPartContainer( place );
        if( container != null )
            throw 'Error in EntityHealthPointsSystem.addBodyPart. Can not add body part to "$place", already have a part.';

        switch( place ){
            case "leftEye": this.head.LeftEye = this._addParamsToBodyPart( config );
            case "rightEye": this.head.RightEye = this._addParamsToBodyPart( config );
            case "mouth": this.head.Mouth = this._addParamsToBodyPart( config );
            case "nose": this.head.Nose = this._addParamsToBodyPart( config );
            case "brain": this.head.Brain = this._addParamsToBodyPart( config );
            case "head": this.head.Head = this._addParamsToBodyPart( config );
            case "leftArm": this.leftHand.Arm = this._addParamsToBodyPart( config );
            case "rightArm": this.rightHand.Arm = this._addParamsToBodyPart( config );
            case "leftWrist": this.leftHand.Wrist = this._addParamsToBodyPart( config );
            case "rightWrist": this.rightHand.Wrist = this._addParamsToBodyPart( config );
            case "leftFoot": this.leftLeg.Foot = this._addParamsToBodyPart( config );
            case "rightFoot": this.rightLeg.Foot = this._addParamsToBodyPart( config );
            case "leftSole": this.leftLeg.Sole = this._addParamsToBodyPart( config );
            case "rightSole": this.rightLeg.Sole = this._addParamsToBodyPart( config );
            case "torso": this.torso.Torso = this._addParamsToBodyPart( config );
            case "leftLung": this.torso.LeftLung = this._addParamsToBodyPart( config );
            case "rightLung": this.torso.RightLung = this._addParamsToBodyPart( config );
            case "heart": this.torso.Heart = this._addParamsToBodyPart( config );
        }

        var stats:EntityStatsSystem = this._parent.stats;
        var inventory:EntityInventorySystem = this._parent.inventory;
        var statModifier:Int = 0;
        if( stats != null )
            statModifier += stats.getModifierForBodyPart();

        if( inventory != null )
            statModifier += inventory.getFullStat( "healthPoints" );

        var newContainer:BodyPart = this._getBodyPartContainer( place );
        this._setHealthPointsToCointainer( newContainer, "modifier", statModifier );
        var currentHP:Int = this._calculateCurrentHealthPointsChildBodyPartInt( newContainer );
        this._setHealthPointsToCointainer( newContainer, "current", currentHP );
        //TODO: do changes into stats and skills if needed;        
    }





    

    private function _changeBodyPartHP( place:String, target:String, bodyPart:BodyPart, value:Int ):Void{
        //var currentValue:Int = this._getHealthPointsFromContainerInt( bodyPart, target );
        //var difference:Int = currentValue + value;
        var msg:String = this._parent.errMsg();
        msg += 'EntityHealthPointsSystem._changeBodyPartHP.';

        switch( target ){
            case "current":{
                // direct damage to part
                if( this._getBodyPartStatus( bodyPart ) == "disrupted" )
                    throw '$msg "$place" already disrupted';

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

                var currentStatus:String = this._getBodyPartStatus( bodyPart );
                var status:String = this._calculateStatusForBodyPart( bodyPart );
                if( currentStatus != status ){
                    if( this._checkForDeath( place ))
                        this._death();
                    else{
                        this._calulateDependencies( place );
                    }
                }
            };
            case "modifier":{
                // modifed from stat or inventory items or effects;
                var modifierValue:Int = this._getHealthPointsFromContainerInt( bodyPart, target ) + value;
                this._setHealthPointsToCointainer( bodyPart, target, modifierValue );
                var newCurrentHP:Int = this._calculateCurrentHealthPointsChildBodyPartInt( bodyPart ) + value;

                if( this._getBodyPartStatus( bodyPart ) != "disrupted" && newCurrentHP <= 0 )
                    newCurrentHP = 1; // проверяем отрицательное значение, если вдруг модификатор пришел отрицательный, а часть тела была уже повреждена до минимума.

                this._setHealthPointsToCointainer( bodyPart, "current", newCurrentHP );
            };
            case "base":{
                var baseValue:Int = this._getHealthPointsFromContainerInt( bodyPart, target ) + value;
                if( baseValue < 0 )
                    baseValue = 0;

                this._setHealthPointsToCointainer( bodyPart, target, baseValue );
                var newCurrentHP:Int = this._calculateCurrentHealthPointsChildBodyPartInt( bodyPart ) + value;

                if( this._getBodyPartStatus( bodyPart ) != "disrupted" && newCurrentHP <= 0  )
                    newCurrentHP = 1;

                this._setHealthPointsToCointainer( bodyPart, "current", newCurrentHP );
            };
        }
    }

    private function _calulateDependencies( place:String ):Void{
        //TODO: decrease skills and stats value;
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

    private function _calculateCurrentTotalHealthPointsBodyPartInt( place:String ):Int{
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