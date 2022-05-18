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
    private var _painForDamagedPart:Int = 7;
    private var _painForBrokenPart:Int = 29;
    private var _painForDisruptedOrRemovedPart:Int = 53;
    private var _eatingSpeedDamagedPart:Int = 250;
    private var _eatingSpeedBrokenPart:Int = 500;

    private var _errMsg:String;


    public function new( parent:Entity, params:EntityHealthPointsSystemConfig ):Void{
        this._parent = parent;
        this.isDead = false;
        this._errMsg = this._parent.errMsg() + "EntityHealthPointsSystem.";

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
        var msg:String = this._errMsg;
        msg = '$msg + in init. ';
        if( torso == null )
            throw '$msg Torso is null!';

        var currentTotalHP:Int = switch( this.currentHP ){ case HealthPoint( v ): v;}
        if( currentTotalHP <= 0 )
            throw '$msg Current Total HP is not valid!';

        var totalHP:Int = switch( this.totalHp ){ case HealthPoint( v ): v;}
        if( totalHP <= 0 )
            throw '$msg Total HP is not valid!';
    }

    public function postInit():Void{
        var msg:String = this._errMsg;
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
                var currentHP:Int = this._calculateCurrentHealthPointsChildBodyPart( place );
                var difference:Int  = currentHP + value;
                if( difference <= 0 )
                    return false;
            }
            case "base":{
                var baseValue:Int = this._getHealthPointsFromBodyPart( place, "base" ) + value;
                if( baseValue <= 0 )
                    return false;
            }
            case "current":{};
            default: throw 'Error in EntityHealthPointsSystem.canChangeBodyPart. "$target" is not valid.';
        }
        return true;
    }

    public function changeBodyPartHP( place:String, target:String, value:Int ):Void{
        var currentStatus:String = this._getBodyPartStatus( place );
        switch( target ){
            case "current":{
                // direct damage to part
                var currentHP:Int = this._getHealthPointsFromBodyPart( place, target );
                var calculatedCurrentHP:Int = this._calculateCurrentHealthPointsChildBodyPart( place );
                var modifiedCurrentHP:Int = currentHP + value;
                if( modifiedCurrentHP < 0 ){
                    modifiedCurrentHP = 0;
                }else if( modifiedCurrentHP > calculatedCurrentHP )
                    modifiedCurrentHP = calculatedCurrentHP;
                    
                
                this._setHealthPointsToBodyPart( place, target, modifiedCurrentHP );
                var diffirenceHP:Int = modifiedCurrentHP - currentHP;
                var totalCurrentHP:Int = switch( this.currentHP ){ case HealthPoint( v ): v;};
                totalCurrentHP += diffirenceHP;
                this.currentHP = HealthPoint( totalCurrentHP );

                var status:String = this._calculateStatusForBodyPart( place );
                if( currentStatus != status ){
                    if( this._checkForDeath( place ))
                        this._death();
                    else{
                        this._calculateStatusDependencies( place, currentStatus );
                    }
                }
            };
            case "modifier":{
                // modifed from stat or inventory items or effects;
                var modifierValue:Int = this._getHealthPointsFromBodyPart( place, target ) + value;
                this._setHealthPointsToBodyPart( place, target, modifierValue );
                var newCurrentHP:Int = this._calculateCurrentHealthPointsChildBodyPart( place ) + value;
                if(( currentStatus != "disrupted" || currentStatus != "removed" ) && newCurrentHP <= 0 )
                    newCurrentHP = 1; // проверяем отрицательное значение, если вдруг модификатор пришел отрицательный, а часть тела была уже повреждена до минимума.

                this._setHealthPointsToBodyPart( place, "current", newCurrentHP );
            };
            case "base":{
                var baseValue:Int = this._getHealthPointsFromBodyPart( place, target ) + value;
                if( baseValue < 0 )
                    baseValue = 0;

                this._setHealthPointsToBodyPart( place, target, baseValue );
                var newCurrentHP:Int = this._calculateCurrentHealthPointsChildBodyPart( place ) + value;
                if(( currentStatus != "disrupted" || currentStatus != "removed" ) && newCurrentHP <= 0  )
                    newCurrentHP = 1;

                this._setHealthPointsToBodyPart( place, "current", newCurrentHP );
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
        this._setHealthPointsToBodyPart( place, "current", 0 );
        var status:String = this._getBodyPartStatus( place );
        this._changeStatusInBodyPart( place, "removed" );
        this._calculateStatusDependencies( place, status );
    }

    public function canAddBodyPart( place:String ):Bool{
        var container:BodyPart = this._getBodyPartContainer( place );
        if( container == null )
            return false;

        if( container.Status != "removed" )
            return false;
        
        return true;            
    }

    public function addBodyPart( place:String, config:Dynamic ):Void{
        var oldStatus:String = this._getBodyPartStatus( place );
        this._addParamsToBodyPart( place, config );

        var currentHP:Int = this._calculateCurrentHealthPointsChildBodyPart( place );
        this._setHealthPointsToBodyPart( place, "current", currentHP );

        this._updateTotalHP();
        this._updateCurrentTotalHP();
        this._calculateStatusDependencies( place, oldStatus );   
    }

    public function getAvailableBodyPartsString():Array<String>{
        var array:Array<String> = [ "head", "leftEye", "rightEye", "nose", "mouth", "brain", "heart", "leftLung", "rightLung", "torso", "leftArm", "rightArm", "leftWrist", "rightWrist",
                                    "leftFoot", "rightFoot", "leftSole", "rightSole" ];
        var result:Array<String> = [];
        for( i in 0...array.length ){
            var part:String = array[ i ];
            var bodyPart:BodyPart = this._getBodyPartContainer( part );
            if( bodyPart != null ){
                var status:String = this._getBodyPartStatus( part );
                if( status != "disrupted" || status != "removed" )
                    result.push( part );
            }
        }
        return result;
    }





    


    private function _updateTotalHP():Void{
        var headHP:Int = this._calculateTotalHealthPointsBodyPart( "head" );
        var leftHandHP:Int = this._calculateTotalHealthPointsBodyPart( "leftHand" );
        var rightHandHP:Int = this._calculateTotalHealthPointsBodyPart( "rightHand" );
        var leftLegHP:Int = this._calculateTotalHealthPointsBodyPart( "leftLeg" );
        var rightLegHP:Int = this._calculateTotalHealthPointsBodyPart( "rightLeg" );
        var torsoHP:Int = this._calculateTotalHealthPointsBodyPart( "torso" );

        this.totalHp = HealthPoint( headHP + leftHandHP + rightHandHP + leftLegHP + rightLegHP + torsoHP );
    }

    private function _updateCurrentTotalHP():Void{
        var headHP:Int = this._calculateCurrentTotalHealthPointsBodyPart( "head" );
        var leftHandHP:Int = this._calculateCurrentTotalHealthPointsBodyPart( "leftHand" );
        var rightHandHP:Int = this._calculateCurrentTotalHealthPointsBodyPart( "rightHand" );
        var leftLegHP:Int = this._calculateCurrentTotalHealthPointsBodyPart( "leftLeg" );
        var rightLegHP:Int = this._calculateCurrentTotalHealthPointsBodyPart( "rightLeg" );
        var torsoHP:Int = this._calculateCurrentTotalHealthPointsBodyPart( "torso" );

        this.currentHP = HealthPoint( headHP + leftHandHP + rightHandHP + leftLegHP + rightLegHP + torsoHP );
    }

    private function _calculatePartTypeDependencies():Void {
        //TODO!!!!;
    }

    private function _calculateStatusDependencies( place:String, oldStatus:String ):Void{
        //TODO:!!!!!
        var status:String = this._getBodyPartStatus( place );
        var requirement:EntityRequirementSystem = this._parent.requirement;
        var stats:EntityStatsSystem = this._parent.stats;
        var inventory:EntityInventorySystem = this._parent.inventory;
        switch( place ){
            case "mouth": {    
                switch( status ){
                    case "disrupted", "removed":{
                        requirement.canEat = false;
                        requirement.hasMouth = false;
                        var painValue:Int = this._painForDisruptedOrRemovedPart;
                        switch( oldStatus ){
                            case "broken":{};
                            case "damaged": painValue += this._painForBrokenPart;
                            case "healthy": painValue += this._painForBrokenPart + this._painForDamagedPart;
                        }
                        stats.changePain( painValue );
                    };
                    case "broken":{
                        requirement.canEat = true;
                        requirement.hasMouth = true;
                        var painValue:Int = this._painForBrokenPart;
                        switch( oldStatus ){
                            case "disrupted", "removed": painValue = 0;
                            case "damaged":{};
                            case "healthy": painValue += this._painForDamagedPart;
                        }
                        stats.changePain( painValue );
                    };
                    case "damaged":{
                        requirement.canEat = true;
                        requirement.hasMouth = true;
                        var painValue:Int = this._painForDamagedPart;
                        switch( oldStatus ){
                            case "disrupted", "removed": painValue = 0;
                            case "broken": painValue = 0;
                            case "healthy":{};
                        }
                        stats.changePain( painValue );
                    };
                    case "healthy":{
                        requirement.canEat = true;
                        requirement.hasMouth = true;
                    };
                }
            }
            case "nose":{
                switch( status ){
                    case "disrupted", "removed":{
                        switch( oldStatus ){
                            case "broken":{};
                            case "damaged":{};
                            case "healthy":{};
                        }
                    };
                    case "broken":{
                        switch( oldStatus ){
                            case "disrupted", "removed":{};
                            case "damaged":{};
                            case "healthy":{};
                        }
                    };
                    case "damaged":{
                        switch( oldStatus ){
                            case "disrupted", "removed":{};
                            case "broken":{};
                            case "healthy":{};
                        }
                    };
                    case "healthy":{};
                }
            };
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
        var newPlace:String = "n/a";
        if( status != "disrupted" || status != "removed" )
            return;

        switch( place ){
            case "leftArm": newPlace = "leftWrist";
            case "rightArm": newPlace = "rightWrist";
            case "leftFoot": newPlace = "leftSole";
            case "rightFoot": newPlace = "rightSole";
            default: return;
        }

        var oldStatus:String = this._getBodyPartStatus( newPlace );
        this._changeStatusInBodyPart( newPlace, status );
        this._setHealthPointsToBodyPart( newPlace, "current", 0 );
        this._calculateStatusDependencies( newPlace, oldStatus );
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
        var msg:String = this._errMsg;
        this.head = { Head: null, LeftEye: null, RightEye: null, Mouth: null, Brain: null, Nose: null }
        for( key in Reflect.fields( params )){
            var partParams:Dynamic = Reflect.getProperty( params, key );
            switch( key ){
                case "head": {
                    this.head.Head = this._createBodyPart();
                    this._addParamsToBodyPart( "head", partParams );
                }
                case "leftEye": {
                    this.head.LeftEye = this._createBodyPart();
                    this._addParamsToBodyPart( "leftEye", partParams );
                }
                case "rightEye": {
                    this.head.RightEye = this._createBodyPart();
                    this._addParamsToBodyPart( "rightEye", partParams );
                }
                case "mouth": {
                    this.head.Mouth = this._createBodyPart();
                    this._addParamsToBodyPart( "mouth", partParams );
                }
                case "brain": {
                    this.head.Brain = this._createBodyPart();
                    this._addParamsToBodyPart( "brain", partParams );
                }
                case "nose": {
                    this.head.Nose = this._createBodyPart();
                    this._addParamsToBodyPart( "nose", partParams );
                }
                default: throw '$msg. _configureHead. There is no "$key" in config';
            }
        }
    }

    private function _configureTorso( params:Dynamic ):Void{
        var msg:String = this._errMsg;
        this.torso = { Torso: null, LeftLung: null, RightLung: null, Heart: null };
        for( key in Reflect.fields( params )){
            var partParams:Dynamic = Reflect.getProperty( params, key );
            switch( key ){
                case "torso": {
                    this.torso.Torso = this._createBodyPart();
                    this._addParamsToBodyPart( "torso", partParams );
                }
                case "leftLung": {
                    this.torso.LeftLung = this._createBodyPart();
                    this._addParamsToBodyPart( "leftLung", partParams );
                }
                case "rightLung": {
                    this.torso.RightLung = this._createBodyPart();
                    this._addParamsToBodyPart( "rightLung", partParams );
                }
                case "heart": {
                    this.torso.Heart = this._createBodyPart();
                    this._addParamsToBodyPart( "heart", partParams );
                }
                default: throw '$msg _configureTorso. There is no "$key" in config.';
            }
        }
    }

    private function _configureLeg( params:Dynamic, place:String ):Void{
        var msg:String = this._errMsg;
        var container:Leg;
        var newPlace:String = place;
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
                case "foot": {
                    container.Foot = this._createBodyPart();
                    newPlace += "Foot";
                    this._addParamsToBodyPart( newPlace, partParams );
                }
                case "sole": {
                    container.Sole = this._createBodyPart();
                    newPlace += "Sole";
                    this._addParamsToBodyPart( newPlace, partParams );
                }
                default: throw '$msg _configureRightLeg. There is no "$key" in config.';
            }
        }
    }

    private function _configureHand( params:Dynamic, place:String ):Void{
        var msg:String = this._errMsg;
        var container:Hand;
        var newPlace:String = place;
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
                case "arm": {
                    container.Arm = this._createBodyPart();
                    newPlace += "Arm";
                    this._addParamsToBodyPart( newPlace, partParams );
                }
                case "wrist": {
                    container.Wrist = this._createBodyPart();
                    newPlace += "Wrist";
                    this._addParamsToBodyPart( newPlace, partParams );
                }
                default: throw '$msg _configureRightHand. There is no "$key" in config.';
            }
        }
    }

    private function _calculateCurrentTotalHealthPointsBodyPart( place:String ):Int{
        switch( place ){
            case "head":{
                if( this.head != null ){
                    var headLeftEye:Int = this._getHealthPointsFromBodyPart( "leftEye", "current" );
                    var headRightEye:Int = this._getHealthPointsFromBodyPart( "rightEye", "current" );
                    var headNose:Int = this._getHealthPointsFromBodyPart( "nose", "current" );
                    var headMouth:Int = this._getHealthPointsFromBodyPart( "mouth", "current" );
                    var headBrain:Int = this._getHealthPointsFromBodyPart( "brain", "current" );
                    var headHead:Int = this._getHealthPointsFromBodyPart( "head", "current" );
                    return headLeftEye + headRightEye + headNose + headMouth + headBrain + headHead;
                }else{
                    return 0;
                }
            };
            case "leftLeg":{
                if( this.leftLeg != null ){
                    var footHP:Int = this._getHealthPointsFromBodyPart( "leftFoot", "current" );
                    var soleHP:Int = this._getHealthPointsFromBodyPart( "leftSole", "current" );
                    return footHP + soleHP;
                }else{
                    return 0;
                }
                
            };
            case "rightLeg":{
                if( this.rightLeg != null ){
                    var footHP:Int = this._getHealthPointsFromBodyPart( "rightFoot", "current" );
                    var soleHP:Int = this._getHealthPointsFromBodyPart( "rightSole", "current" );
                    return footHP + soleHP;
                }else{
                    return 0;
                }
            };
            case "torso":{
                if( this.torso.Torso == null )
                    throw 'Error in EntityHealthPointsSystem._calculateCurrentTotalHealthPointsBodyPart. Torso.Torso == NULL!!';

                var leftLung:Int = this._getHealthPointsFromBodyPart( "leftLung", "current" );
                var rightLung:Int = this._getHealthPointsFromBodyPart( "rightLung", "current" );
                var heart:Int = this._getHealthPointsFromBodyPart( "heart", "current" );
                var torso:Int = this._getHealthPointsFromBodyPart( "torso", "current" );
                return leftLung + rightLung + heart + torso;
            };
            case "leftHand":{
                var armHP:Int = this._getHealthPointsFromBodyPart( "leftArm", "current" );
                var wristHP:Int = this._getHealthPointsFromBodyPart( "leftWrist", "current" );
                return armHP + wristHP;
            };
            case "rightHand":{
                var armHP:Int = this._getHealthPointsFromBodyPart( "rightArm", "current" );
                var wristHP:Int = this._getHealthPointsFromBodyPart( "rightWrist", "current" );
                return armHP + wristHP;
            };
            default: throw 'Error in EntityHealthPointsSystem._calculateCurrentHealthPointsBodyPartInt. "$place" is not valid.';
        }
    }

    private function _calculateTotalHealthPointsBodyPart( place:String ):Int{
        switch( place ){
            case "head":{
                var headLeftEye:Int = this._calculateCurrentHealthPointsChildBodyPart( "leftEye" );
                var headRightEye:Int = this._calculateCurrentHealthPointsChildBodyPart( "rightEye" );
                var headNose:Int = this._calculateCurrentHealthPointsChildBodyPart( "nose" );
                var headMouth:Int = this._calculateCurrentHealthPointsChildBodyPart( "mouth" );
                var headBrain:Int = this._calculateCurrentHealthPointsChildBodyPart( "brain" );
                return headLeftEye + headRightEye + headNose + headMouth + headBrain;
            };
            case "leftLeg":{
                var footHP:Int = this._calculateCurrentHealthPointsChildBodyPart( "leftFoot" );
                var soleHP:Int = this._calculateCurrentHealthPointsChildBodyPart( "leftSole" );
                return footHP + soleHP;                
            };
            case "rightLeg":{
                var footHP:Int = this._calculateCurrentHealthPointsChildBodyPart( "rightFoot" );
                var soleHP:Int = this._calculateCurrentHealthPointsChildBodyPart( "rightSole" );
                return footHP + soleHP;
            };
            case "torso":{
                if( this.torso.Torso == null )
                    throw 'Error in EntityHealthPointsSystem._calculateTotalHealthPointsBodyPartInt. Torso.Torso == NULL!!';

                var leftLung:Int = this._calculateCurrentHealthPointsChildBodyPart( "leftLung" );
                var rightLung:Int = this._calculateCurrentHealthPointsChildBodyPart( "rightLung" );
                var heart:Int = this._calculateCurrentHealthPointsChildBodyPart( "heart" );
                var torso:Int = this._calculateCurrentHealthPointsChildBodyPart( "torso" );
                return leftLung + rightLung + heart + torso;
            };
            case "leftHand":{
                if( this.leftHand != null ){
                    var armHP:Int = this._calculateCurrentHealthPointsChildBodyPart( "leftArm" );
                    var wristHP:Int = this._calculateCurrentHealthPointsChildBodyPart( "leftWrist" );
                    return armHP + wristHP;
                }else{
                    return 0;
                }
            };
            case "rihtHand":{
                var armHP:Int = this._calculateCurrentHealthPointsChildBodyPart( "rightArm" );
                var wristHP:Int = this._calculateCurrentHealthPointsChildBodyPart( "rightWrist" );
                return armHP + wristHP;
            };
            default: throw 'Error in EntityHealthPointsSystem._calculateTotalHealthPointsBodyPartInt. "$place" is not valid.';
        }
    }

    private inline function _calculateCurrentHealthPointsChildBodyPart( place:String ):Int{
        var container:BodyPart = this._getBodyPartContainer( place );
        if( container != null )
            return this._getHealthPointsFromBodyPart( place, "base" ) + this._getHealthPointsFromBodyPart( place, "modifier" );
        else
            return 0;
    }

    private function _changeStatusInBodyPart( place:String, status:String ):Void{
        if( status == "healthy" || status == "broken" || status == "damaged" || status == "disrupted" || status == "removed" ){
            var oldStatus:String = this._getBodyPartStatus( place );
            this._setBodyPartStatus( place, status );
            this._calculateStatusDependencies( place, oldStatus );
        }else{
            var msg:String = this._errMsg + "_changeStatusInBodyPart.";
            throw '$msg . "$status" is not valid.';
        }
    }

    private function _changePartTypeInBodyPart( place:String, partType:String ):Void{
        if( partType == "natural" || partType == "wood" || partType == "steel" || partType == "carbon" || partType == "cybernetic" ){
            this._setPartTypeToBodyPart( place, partType );
            this._calculatePartTypeDependencies();
        }else{
            var msg:String = this._errMsg + "_changePartTypeInBodyPart.";
            throw '$msg . "$partType" is not valid.';
        }
    }

    private function _getPartTypeBodyPart( place:String ):String{
        var msg:String = this._errMsg + "_getPartTypeBodyPart.";
        var container:BodyPart = this._getBodyPartContainer( place );
        if( container == null )
            throw '$msg "$place" does not exist.';

        return container.Status;
    }

    private function _setPartTypeToBodyPart( place:String, partType:String ):Void{
            var msg:String = this._errMsg + "_setPartTypeToBodyPart.";
            var container:BodyPart = this._getBodyPartContainer( place );
            if( container == null )
                throw '$msg "$place" does not exist.';
            
            container.PartType = partType;
    }

    private function _getHealthPointsFromBodyPart( place:String, target:String ):Int{
        var msg:String = this._errMsg + "_getHealthPointsFromBodyPartInt.";
        var container:BodyPart = this._getBodyPartContainer( place );
        if( container == null )
            throw '$msg "$place" does not exist.';

        var value:Int;
        switch( target ){
            case "current": value = switch( container.HP.Current ){ case HealthPoint( v ): v; };
            case "modifier": value = switch( container.HP.Modifier ){ case HealthPoint( v ): v; };
            case "base": value = switch( container.HP.Base ){ case HealthPoint( v ): v; };
            default: throw '$ "$target" is not valid!';
        }
        return value;
    }

    private function _setHealthPointsToBodyPart( place:String, target:String, value:Int ):Void{
        var msg:String = this._errMsg + "_setHealthPointToContainer.";
        var container:BodyPart = this._getBodyPartContainer( place );
        if( container == null )
            throw '$msg "$place" is not valid';

        switch( target ){
            case "current": container.HP.Current = HealthPoint( value );
            case "base": container.HP.Base = HealthPoint( value );
            case "modifier": container.HP.Modifier = HealthPoint( value );
            default: throw '$msg "$target" is not valid!';
        }
    }

    private function _getBodyPartStatus( place:String ):String{
        var bodyPart:BodyPart = this._getBodyPartContainer( place );
        if( bodyPart == null )
            return "n/a";

        return bodyPart.Status;
    }

    private function _setBodyPartStatus( place:String, status:String ):Void{
        var msg:String = this._errMsg + "_setBodyPartStatus";
        var bodyPart:BodyPart = this._getBodyPartContainer( place );
        if( bodyPart == null )
            throw '$msg "$place" does not exist';

        bodyPart.Status = status;
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

    private function _calculateStatusForBodyPart( place:String ):String{
        var msg:String = this._errMsg + "_calculateStatusForBodyPart.";
        var bodyPart:BodyPart = this._getBodyPartContainer( place );
        if( bodyPart == null )
            throw '$msg "$place" does not exist.';

        var hp:Int = this._getHealthPointsFromBodyPart( place, "current" );
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

    private function _addParamsToBodyPart( place:String, config:Dynamic ):Void{
        var msg:String = this._errMsg;
        var baseHP:Int = Reflect.getProperty( config, "baseHP" );
        var currentHP:Int = Reflect.getProperty( config, "currentHP" );
        var partType:String = Reflect.getProperty( config, "partType" );
        var partStatus:String = Reflect.getProperty( config, "status" );

        if( Math.isNaN( baseHP ) || baseHP < 0 ) 
            throw '$msg EntityHealthPointsSystem._addParamsToBodyPart. HP "$baseHP" is not valid';

        this._setHealthPointsToBodyPart( place, "base", baseHP );
        if( currentHP <= -1 || Math.isNaN( currentHP ))
            currentHP = baseHP;
        
        this._setHealthPointsToBodyPart( place, "current", currentHP );
        if( partType == null )
            this._setPartTypeToBodyPart( place, "natural" );
        else
            this._setPartTypeToBodyPart( place, partType );

        if( partStatus == null )
            this._setBodyPartStatus( place, "healthy" );
        else
            this._setBodyPartStatus( place, partStatus );

    }

    private function _createBodyPart():BodyPart{
        return { HP: { Current: HealthPoint( 0 ), Modifier: HealthPoint( 0 ), Base: HealthPoint( 0 ) }, Status: "n/a", PartType: "n/a" };
    }

    private function _death():Void{
        this.isDead = true;
    }
}