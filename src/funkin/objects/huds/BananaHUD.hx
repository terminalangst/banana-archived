package funkin.objects.huds;

import flixel.group.FlxGroup;

class BananaHUD extends BaseHUD
{
	public function new()
	{
		super();

        healthBar = new Bar(0, FlxG.height * (!ClientPrefs.data.downScroll ? 0.89 : 0.11), 'healthBar', function() return PlayState.instance.health, 0, 2);
		healthBar.screenCenter(X);
		healthBar.leftToRight = false;
		healthBar.scrollFactor.set();
		healthBar.visible = !ClientPrefs.data.hideHud;
		healthBar.alpha = ClientPrefs.data.healthBarAlpha;
		reloadHealthBarColors();
		add(healthBar);

		iconP1 = new HealthIcon(PlayState.instance.boyfriend.healthIcon, true);
		add(iconP1);

		iconP2 = new HealthIcon(PlayState.instance.dad.healthIcon, false);
		add(iconP2);

        for(iconz in [iconP1, iconP2]) {
            iconz.y = healthBar.y - 75;
            iconz.visible = !ClientPrefs.data.hideHud;
            iconz.alpha = ClientPrefs.data.healthBarAlpha;
        }
	}

    override public function update(elapsed:Float) {
		super.update(elapsed);

		updateIconsScale(elapsed);
		updateIconsPosition();
    }

    override public function beatHit() {
        for(iconz in [iconP1, iconP2]) {
            iconz.scale.set(1.2, 1.2);
            iconz.updateHitbox();
        }
    }

	override public function healthThingies(value:Float) {
		var newPercent:Null<Float> = FlxMath.remapToRange(FlxMath.bound(healthBar.valueFunction(), healthBar.bounds.min, healthBar.bounds.max), healthBar.bounds.min, healthBar.bounds.max, 0, 100);
		healthBar.percent = (newPercent != null ? newPercent : 0);

		iconP1.animation.curAnim.curFrame = (healthBar.percent < 20) ? 1 : 0; //If health is under 20%, change player icon to frame 1 (losing icon), otherwise, frame 0 (normal)
		iconP2.animation.curAnim.curFrame = (healthBar.percent > 80) ? 1 : 0; //If health is over 80%, change opponent icon to frame 1 (losing icon), otherwise, frame 0 (normal)
	}

	public dynamic function updateIconsScale(elapsed:Float) {
        var playbackRate = PlayState.instance.playbackRate;

        for(iconz in [iconP1, iconP2]) {
            var mult:Float = FlxMath.lerp(1, iconz.scale.x, Math.exp(-elapsed * 9 * playbackRate));
            iconz.scale.set(mult, mult);
            iconz.updateHitbox();
        }
	}

	public dynamic function updateIconsPosition() {
		var iconOffset:Int = 26;
		iconP1.x = healthBar.barCenter + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
		iconP2.x = healthBar.barCenter - (150 * iconP2.scale.x) / 2 - iconOffset * 2;
	}

	override public function reloadHealthBarColors() {
		healthBar.setColors(FlxColor.fromRGB(PlayState.instance.dad.healthColorArray[0], PlayState.instance.dad.healthColorArray[1], PlayState.instance.dad.healthColorArray[2]), 
		FlxColor.fromRGB(PlayState.instance.boyfriend.healthColorArray[0], PlayState.instance.boyfriend.healthColorArray[1], PlayState.instance.boyfriend.healthColorArray[2]));
	}
}