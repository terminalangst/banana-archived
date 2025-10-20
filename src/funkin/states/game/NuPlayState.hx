package funkin.states.game;

import funkin.backend.Song;
import funkin.backend.Rating;
import funkin.objects.Note.EventNote;
import funkin.objects.*;

import haxe.Json;
import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;
#if !flash import openfl.filters.ShaderFilter; #end

class NuPlayState extends MusicBeatState {
    // song speed shit, hoping it's self explanatory.
    public var songSpeedTween:FlxTween;
    //public var songSpeed(default, set):Float = 1;
    public var songSpeedType:String = "multiplicative";

    public var noteKillOffset:Float = 350; // despawns notes, especially extremely late ones to cause a miss
    //public var playbackRate(default, set):Float = 1; // you can make your song sound fast and more high pitched, or slow and more low pitched, take your pick pal!

    // stage shit
    public static var curStage:String = ''; // also self explanatory, the current stage.
    public static var stageUI(default, set):String = "normal"; // switches between normal and pixel.
    public static var uiPrefix:String = ""; // i do not know what the fuck this is for.
    public static var uiPostfix:String = ""; // although this is probably self explanatory, you can set it to be -pixel, -horror, -whateverthefuck.
    public static var isPixelStage(get, never):Bool; // also self explanatory.
    @:noCompletion static function set_stageUI(value:String):String {
        uiPrefix = uiPostfix = "";
        if (value != "normal") uiPrefix = value.split("-pixel")[0].trim();
        if (value == "pixel" || value.endsWith("-pixel")) uiPostfix = "-pixel";

        return stageUI = value;
    }
    @:noCompletion static function get_isPixelStage():Bool return stageUI == "pixel" || stageUI.endsWith("-pixel");

    // song stuffs
    
}