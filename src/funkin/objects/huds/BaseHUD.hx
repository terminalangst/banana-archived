package funkin.objects.huds;

import flixel.group.FlxGroup;
import funkin.objects.Bar;

@:access(states.PlayState)

// base structure of how huds r handled

class BaseHUD extends FlxGroup
{
	public var healthBar:Bar;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;

	public function new()
	{
		super();
	}
	
	public function stepHit():Void {}
	
	public function beatHit():Void {}
	
	public function sectionHit():Void {}

	public function healthThingies(health:Float) {}

	public function reloadHealthBarColors() {}
}