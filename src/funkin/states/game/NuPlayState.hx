package funkin.states.game;

/** The actual rewrite. **/

import funkin.objects.*;
import funkin.states.game.Modifiers;

import haxe.Json;
import flixel.input.keyboard.FlxKey;
#if !flash import openfl.filters.ShaderFilter; #end

class NuPlayState extends MusicBeatState {

    // holy fucking SHITLOAD of variables brah..
    public var noteKillOffset:Float = 350; // despawns notes, especially extremely late ones to cause a miss

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

    // story mode stuff
    public static var isStoryMode:Bool = false; // check for if you're playin a week or not.
    public static var storyWeek:Int = 0; // week 1, 2, 3, etc.
    public static var storyPlaylist:Array<String> = []; // i don't know shit about what this does.
    public static var storyDifficulty:Int = 1; // assuming this is for difficulties like "easy, normal and hard"

    public var spawnTime:Float = 200; // for spawning notes

    // chars
    public var dad:Null<Character> = null; // opponent
    public var gf:Null<Character> = null; // girlfriend
    public var bf:Null<Character> = null; // boyfriend, or the player

    // note and strumline stuffs, everything here is self explanatory and doesn't need documentation on what they do, i hope.
    public var notes:FlxTypedGroup<Note>;
    public var despawnNotes:Array<Note> = [];
    public var eventNote:Array<Note.EventNote> = [];
    public var strumline:FlxTypedGroup<StrumNote> = new FlxTypedGroup<StrumNote>();
    public var opponentStrums:FlxTypedGroup<StrumNote> = new FlxTypedGroup<StrumNote>();
    public var playerStrums:FlxTypedGroup<StrumNote> = new FlxTypedGroup<StrumNote>();
    public var noteSplashGrp:FlxTypedGroup<NoteSplash> = new FlxTypedGroup<NoteSplash>();

    // rating and combo stuff
    public var combo:Int = 0;
    public var ratingData:Array<funkin.backend.Rating> = funkin.backend.Rating.loadDefault();

    // song shit
    public static var SONG:Null<funkin.backend.Song.SwagSong> = null; // hello my little song!
    public var inst:FlxSound; // self-explanatory
    public var playerVocals:FlxSound; // FFFFFFFFFUUUCK.
    public var opponentVocals:FlxSound; // YEEESSS.
    private var curSong:String = ""; // self-explanatory aswell.
    var songPercent:Float = 0;
    var songLength:Float = 0;
    private var generatedMusic:Bool = false; // for checking if the music has been loaded or whatev.
    public var startingSong:Bool = false; // fucking self explanatory
    public var endingSong:Bool = false; // SAME FOR THIS TOO.
    public var songSpeed(default, set):Float = 1;
    public var songSpeedTween:FlxTween; // all three of these variables are for song speed stuff.
    public var playbackRate(default, set):Float = 1; // you can make your song sound fast and more high pitched, or slow and more low pitched, take your pick pal!

    public var missDamage:Float = 0.05;

    // camera shit
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera; // default camera target
	public var camCountdown:FlxCamera;
    public var cameraSpeed:Float = 1;
    public var defaultCamZoom:Float;
    public var daPixelZoom:Float = 6; // so the pixel sprites don't look stretched.

    // score n' miss
    public var songScore:Int = 0;
    public var campaignScore:Int = 0;
    public var misses:Int = 0;
    public var campaignMisses:Int = 0;
    public var songHits:Int = 0;

    // actual game shit, methinks, hopefully, most likely, SIXWANNNN...
    public static var deathCounter:Int = 0;

    public static var seenCutscene:Bool = false;
    public var inCutscene:Bool = false;
    public var skipCountdown:Bool = false;

    public static var instance:NuPlayState; // this is for hscript or smth.

    public var introSuffix:String = '';

    private var singAnims:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
    private var keysArray:Array<String> = ['note_left', 'note_down', 'note_up', 'note_right'];

    public var songName:String;

    // stage callbacks
    public var startCallback:Void->Void = null;
    public var endCallback:Void->Void = null;

    // i gen don't know what the purpose of this is but alr!
    private static var _lastModDir:String = '';

    override public function create() {
        trace('banana');

        _lastModDir = Mods.currentModDirectory;
        Paths.clearStoredMemory();
        Paths.clearUnusedMemory();

        instance = this; // for hscript or smth like that.

        if (FlxG.sound.music != null) FlxG.sound.music.stop();

        // gameplay settings
        playbackRate = ClientPrefs.getGameplaySetting('songspeed');
        Modifiers.healthGain = ClientPrefs.getGameplaySetting('healthgain');
        Modifiers.healthLoss = ClientPrefs.getGameplaySetting('healthloss');
        Modifiers.instaKillOnMiss = ClientPrefs.getGameplaySetting('instakill');
        Modifiers.practiceMode = ClientPrefs.getGameplaySetting('practice');
        Modifiers.cpuControlled = ClientPrefs.getGameplaySetting('botplay');
        Modifiers.guitarHeroSustains = ClientPrefs.data.guitarHeroSustains;
        
        // camera init shit
        camGame = initPsychCamera();
        camHUD = new FlxCamera();
        camCountdown = new FlxCamera();
        camHUD.bgColor.alpha = camCountdown.bgColor.alpha = 0;

        FlxG.cameras.add(camHUD, false);
        FlxG.cameras.add(camCountdown, false);
        persistentUpdate = persistentDraw = true;
        
        Conductor.mapBPMChanges(SONG);
        Conductor.bpm = SONG.bpm;

        songName = Paths.formatToSongPath(SONG.song);
        if (SONG.stage == null || SONG.stage.length < 1) SONG.stage = StageData.vanillaSongStage(Paths.formatToSongPath(funkin.backend.Song.loadedSongName));
        curStage = SONG.stage;

        var stageData:StageFile = StageData.getStageFile(curStage);
        defaultCamZoom = stageData.defaultZoom;
        if (stageData.stageUI != null && stageData.stageUI.trim().length > 0) stageUI = stageData.stageUI;
        else stageUI = stageData.isPixelStage == true ? "pixel" : "normal";

        dad = new Character(0, 0, SONG.player2);
        bf = new Character(0, 0, SONG.player1, true);

        var comboGroup:FlxSpriteGroup = new FlxSpriteGroup();
        add(comboGroup);
        var noteGroup:FlxTypedGroup<flixel.FlxBasic> = new FlxTypedGroup<flixel.FlxBasic>();
        add(noteGroup);
        noteGroup.add(strumline);
        noteGroup.add(noteSplashGrp);

        FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
        noteGroup.cameras = comboGroup.cameras = [camHUD];

        startingSong = true;
        //FlxG.stage.addEventListener(openfl.events.KeyboardEvent.KEY_DOWN, onKeyPress);
        //FlxG.stage.addEventListener(openfl.events.KeyboardEvent.KEY_UP, onKeyRelease);


        // Precaching stuff to prevent lag spikes
        if(ClientPrefs.data.hitsoundVolume > 0) Paths.sound('hitsound');
        for (i in 1...4) Paths.sound('missnote$i');
        Paths.image('alphabet');
        if (funkin.states.substates.PauseSubState.songName != null) Paths.music(funkin.states.substates.PauseSubState.songName);
        else if (Paths.formatToSongPath(ClientPrefs.data.pauseMusic) != 'none') Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic));

        var splash:NoteSplash = new NoteSplash();
        noteSplashGrp.add(splash);
        splash.alpha = 0.000001;
        super.create();

        /*cacheCountdown();
		cachePopUpScore();*/
    }

    function set_songSpeed(value:Float):Float {
        if (generatedMusic) {
            var ratio:Float = value / songSpeed;
            if (ratio != 1) {
                for (note in notes.members) note.resizeByRatio(ratio);
                for (note in despawnNotes) note.resizeByRatio(ratio);
            }
        }

        songSpeed = value;
        noteKillOffset = Math.max(Conductor.stepCrochet, 350 / songSpeed * playbackRate);
        return value;
    }

    function set_playbackRate(value:Float):Float {
        #if FLX_PITCH
        if (generatedMusic) {
            playerVocals.pitch = opponentVocals.pitch = FlxG.sound.music.pitch = value;

            var ratio:Float = playbackRate / value;
            if (ratio != 1) {
                for (note in notes.members) note.resizeByRatio(ratio);
                for (note in despawnNotes) note.resizeByRatio(ratio);
            }
        }

        playbackRate = FlxG.animationTimeScale = value;
        Conductor.offset = Reflect.hasField(NuPlayState.SONG, 'offset') ? (NuPlayState.SONG.offset / value) : 0;
        Conductor.safeZoneOffset = (ClientPrefs.data.safeFrames / 60) * 1000 * value;
        playbackRate = 1.0;
        #end
        return playbackRate;
    }
}