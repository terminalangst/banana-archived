package funkin.backend;

/** MMM, BANANA! **/

import flixel.FlxG;

class Init extends MusicBeatState {
    override public function create() {
        // Why were these even in TitleState of all places dude.
        ClientPrefs.loadPrefs();
        AlphaCharacter.loadAlphabetData();
        if (FlxG.save.data.fullscreen != null) FlxG.fullscreen = FlxG.save.data.fullscreen;
        if (FlxG.save.data.weekCompleted != null) funkin.states.StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;

        // Flixel defaults !
        FlxG.fixedTimestep = false;
        FlxG.game.focusLostFramerate = 60;
        FlxG.keys.preventDefaultKeys = [TAB];
		FlxG.mouse.visible = false;
        FlxSprite.defaultAntialiasing = ClientPrefs.data.antialiasing;

        super.create();

        // This method is NOT ass, DON'T kill yourself, Kelsey from September 25th 2025! :D (Oh yeah, I borrowed this method from data5 LMFAO, haii data!)
        var openinState:Class<MusicBeatState> = FlxG.save.data.flashing == null && !funkin.states.WarningState.leftState ? funkin.states.WarningState : funkin.states.TitleState;
        MusicBeatState.switchState(Type.createInstance(openinState, []));
    }
}