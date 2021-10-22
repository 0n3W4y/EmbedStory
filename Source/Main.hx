package;

import openfl.display.Sprite;

class Main extends Sprite {
	public var screenWidth:Int = 1920;
	public var screenHeight:Int = 1080;
	public var gameFps:Int = 60;
	public var game:Game;

	public function new()
	{
		super();
		this.game = new Game( screenWidth, screenHeight, gameFps, this );
	}
}
