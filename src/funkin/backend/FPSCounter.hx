package funkin.backend;

import haxe.Timer;
import openfl.text.TextField;
import openfl.text.TextFormat;
import flixel.FlxG;
import flixel.util.FlxStringUtil;

class FPSCounter extends TextField {
    public var currentFPS(default, null):Int;
    // iirc this just shows the garbage collector memory, sooo.. it's literally inaccurate
    public var memory(get, never):Float;
    public var memoryPeak:Float = 0;
    @:noCompletion private var times:Array<Float>;

    public function new(x:Float = 10, y:Float = 3 , col:Int = 0x000000) {
        super();

        this.x = x;
        this.y = y;

        currentFPS = 0;

        background = true;
        backgroundColor = 0x000000;
        visible = ClientPrefs.data.showFPS;

        selectable = false;
        mouseEnabled = false;
        autoSize = LEFT;
        multiline = true;

        defaultTextFormat = new TextFormat("vcr.ttf", 14, col);
        text = '0 FPS || 0MB / 0MB';

        times = [];
    }

    var deltaTimeout:Float = 0.0;

    private override function __enterFrame(deltaTime:Float):Void {
        final now:Float = Timer.stamp() * 1000;
        times.push(now);
        while (times[0] < now - 1000) times.shift();

        if (deltaTimeout < 50) {
            deltaTimeout += deltaTime;
            return;
        }
        
        currentFPS = times.length < FlxG.updateFramerate ? times.length : FlxG.updateFramerate;
        deltaTimeout = 0.0;

        memoryPeak = Math.max(memoryPeak, memory);

        update_text();
    }

    public dynamic function update_text():Void {
        text = '${currentFPS} FPS || ${FlxStringUtil.formatBytes(memory)} / ${FlxStringUtil.formatBytes(memoryPeak)}';
        textColor = currentFPS < FlxG.updateFramerate * 0.5 ? 0xFFFF0000 : 0xFFFFFF;
    }
    inline function get_memory():Float return cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_USAGE);
}
