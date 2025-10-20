package;

#if desktop import funkin.backend.ALSoftConfig; #end // just so DCE doesn't remove this.

#if (linux && !debug)
@:cppInclude('./funkin/external/gamemode_client.h')
@:cppFileCode('#define GAMEMODE_AUTO')
#end

class Main extends openfl.display.Sprite {
    // versions (inspired from NightmareVision)
    public static final bananaVersion = '0.1.0';
    public static final psychVersion = '1.0.4';
    public static final funkinVersion = '0.2.8';

    public static var counter:funkin.backend.FPSCounter;
    public static final meta = { width: 1280, height: 720, initialState: funkin.backend.Init, framerate: 60, skipSplash: true, startFullscreen: false }; // i do not need to explain what each thing in this fucking variable does.

    // ignore everything after this comment, your code should go into scripts, or onto the states if you're hardcoding.

    public static function main():Void openfl.Lib.current.addChild(new Main());

    public function new() {
        super();

        #if (cpp && windows) funkin.backend.Native.fixScaling(); #end
        #if VIDEOS_ALLOWED hxvlc.util.Handle.init(#if (hxvlc >= "1.8.0") ['--no-lua'] #end); #end

        Mods.loadTopMod();
        FlxG.save.bind('funkin', CoolUtil.getSavePath());
        funkin.backend.Highscore.load();

        #if HSCRIPT_ALLOWED
		crowplexus.iris.Iris.warn = function(x, ?pos:haxe.PosInfos) {
			crowplexus.iris.Iris.logLevel(WARN, x, pos);
			var newPos:funkin.backend.scripting.HScript.HScriptInfos = cast pos;
			if (newPos.showLine == null) newPos.showLine = true;
			var msgInfo:String = (newPos.funcName != null ? '(${newPos.funcName}) - ' : '')  + '${newPos.fileName}:';
			if (newPos.showLine == true) msgInfo += '${newPos.lineNumber}:';
			msgInfo += ' $x';
			/*if (PlayState.instance != null) PlayState.instance.addTextToDebug('WARNING: $msgInfo', FlxColor.YELLOW);*/
		}
		crowplexus.iris.Iris.error = function(x, ?pos:haxe.PosInfos) {
			crowplexus.iris.Iris.logLevel(ERROR, x, pos);
			var newPos:funkin.backend.scripting.HScript.HScriptInfos = cast pos;
			if (newPos.showLine == null) newPos.showLine = true;
			var msgInfo:String = (newPos.funcName != null ? '(${newPos.funcName}) - ' : '')  + '${newPos.fileName}:';
			if (newPos.showLine == true) msgInfo += '${newPos.lineNumber}:';
			msgInfo += ' $x';
			/*if (PlayState.instance != null) PlayState.instance.addTextToDebug('ERROR: $msgInfo', FlxColor.RED);*/
		}
		crowplexus.iris.Iris.fatal = function(x, ?pos:haxe.PosInfos) {
			crowplexus.iris.Iris.logLevel(FATAL, x, pos);
			var newPos:funkin.backend.scripting.HScript.HScriptInfos = cast pos;
			if (newPos.showLine == null) newPos.showLine = true;
			var msgInfo:String = (newPos.funcName != null ? '(${newPos.funcName}) - ' : '')  + '${newPos.fileName}:';
			if (newPos.showLine == true) msgInfo += '${newPos.lineNumber}:';
			msgInfo += ' $x';
			/*(if (PlayState.instance != null) PlayState.instance.addTextToDebug('FATAL: $msgInfo', 0xFFBB0000);*/
		}
        #end

        var game = new flixel.FlxGame(meta.width, meta.height, meta.initialState, meta.framerate, meta.framerate, meta.skipSplash, meta.startFullscreen);
        @:privateAccess game._customSoundTray = funkin.objects.FunkinSoundTray;
        addChild(game);

        Controls.instance = new Controls();
        ClientPrefs.loadDefaultKeys();

        #if !mobile 
        counter = new funkin.backend.FPSCounter(10, 3, 0xFFFFFF);
        addChild(counter);
        openfl.Lib.current.stage.align = "tl";
        openfl.Lib.current.stage.scaleMode = openfl.display.StageScaleMode.NO_SCALE;
        #end

        #if (linux || mac) 
        var icon = lime.graphics.Image.fromFile("icon.png");
        openfl.Lib.current.stage.window.setIcon(icon);
        #end

        #if CRASH_HANDLER openfl.Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(openfl.events.UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash); #end
        #if DISCORD_ALLOWED DiscordClient.prepare(); #end

        // shader coords fix or smth
        FlxG.signals.gameResized.add(function (w, h) {
            if (FlxG.cameras != null) for (cam in FlxG.cameras.list) if (cam != null && cam.filters != null) resetSpriteCache(cam.flashSprite);
            if (FlxG.game != null) resetSpriteCache(FlxG.game);
        });
    }

    static function resetSpriteCache(sprite:openfl.display.Sprite):Void { @:privateAccess { sprite.__cacheBitmap = null; sprite.__cacheBitmapData = null; } }

    // following code is by SqirraMoon ! I cleaned it up a 'lil.
    #if CRASH_HANDLER
    function onCrash(e:openfl.events.UncaughtErrorEvent):Void {
		var errMsg:String = "";
		var path:String;
		var callStack:Array<haxe.CallStack.StackItem> = haxe.CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

        dateNow = dateNow.replace(" ", "-");
        dateNow = dateNow.replace(":", ",");
        path = "./crash" + "BananaEngine_" + dateNow + ".txt";

        for (stackItem in callStack) {
            switch (stackItem) {
                case FilePos(s, file, line, column): errMsg += file + "(line " + line + ")\n";
                default: Sys.println(stackItem);
            }
        }
        errMsg += "\nUncaught Error: " + e.error;
        errMsg += "\nPlease report this error to the Github Page: https://github.com/terminalangst/BananaEngine";
        errMsg += "\n\n> Crash Handler written by: sqirra-rng / SqirraMoon";

        if (!FileSystem.exists("./crash/")) FileSystem.createDirectory("./crash/");
        File.saveContent(path, errMsg + "\n");

        Sys.println(errMsg);
		Sys.println("Crash dump saved in " + haxe.io.Path.normalize(path));

        lime.app.Application.current.window.alert(errMsg, "Error!");
        #if DISCORD_ALLOWED DiscordClient.shutdown(); #end
        Sys.exit(1);
    }
    #end
}