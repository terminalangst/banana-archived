package funkin.backend.fps;

import openfl.display.Bitmap;
import openfl.display.BitmapData;

/** Code originally by GhostGlowDev, I cleaned it up a bit **/

class FPS extends openfl.display.Sprite {
    var _bitmap(get, default):BitmapData;
    var _color(default, set):Int = 0xFF000000;

    function get__bitmap():BitmapData return new BitmapData(1, 1, _color);
    function set__color(value:Int):Int {
        _color = value;
        get__bitmap();

        return _color;
    }

    public var counter:funkin.backend.fps.Counter;
    public var bg:Bitmap;

    public function new() {
        super();

        if (_bitmap == null) _bitmap = new BitmapData(1, 1, _color);

        addChild(bg = new Bitmap(_bitmap));
        bg.alpha = 0.6;
        bg.visible = ClientPrefs.data.showFPS;

        addChild(counter = new funkin.backend.fps.Counter(10, 3, 0xFFFFFF));
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