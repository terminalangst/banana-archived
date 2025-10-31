package funkin.backend.fps;

import openfl.display.Bitmap;
import openfl.display.BitmapData;

/** Code originally by GhostglowDev, I cleaned it up a bit **/

class FPS extends openfl.display.Sprite {
    var _bitmap(get, null):BitmapData;
    var _color:FlxColor = 0xFF000000;

    function get__bitmap():BitmapData return new BitmapData(1, 1, _color);

    public var counter:funkin.backend.fps.Counter;
    public var bg:Bitmap;

    public function new() {
        super();

        addChild(bg = new Bitmap(_bitmap));
        bg.alpha = 0.6;

        addChild(counter = new Counter(10, 3, 0xFFFFFF));

        visible = ClientPrefs.data.showFPS;
    }

    private override function __enterFrame(deltaTime:Float) {
        if (visible) {
            @:privateAccess counter.__enterFrame(deltaTime);
            update(deltaTime);
        }
    }

    public dynamic function update(elapsed:Float) {
        if (bg != null && counter != null) {
            bg.x = counter.x - 2;
            bg.y = counter.y - 2;

            bg.scaleX = counter.width + 6;
            bg.scaleY = counter.height + 6;
        }
    }
}