package;

import openfl.display.Sprite;

class UserInterface{

    public var uiSprite:Sprite;

    private var _parent:Game;
    

    public function new( game:Game, sprite:Sprite ):Void{
        this._parent = game;
        this.uiSprite = sprite;
    }

    public function show():Void{
        this.uiSprite.visible = true;
    }

    public function hide():Void{
        this.uiSprite.visible = false;
    }
}