package funkin.states;

class WarningState extends MusicBeatState {
    public static var leftState:Bool = false;

    var txt:FlxTypedSpriteGroup<FlxText>;
    var warning:FlxText;
    
    override function create() {
        super.create();

        if (FlxG.sound.music == null) {
            FlxG.sound.playMusic(Paths.music('breakfast'), 0);
            FlxG.sound.music.fadeIn(1, 0, 0.45);
        }


        add(txt = new FlxTypedSpriteGroup<FlxText>());
        txt.alpha = 0.0;

        txt.add(warning = new FlxText(0, 0, FlxG.width));
        warning.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE, CENTER);
        warning.text = "WARNING!!\nThis engine contains flashing lights.\nWanna disable 'em?\n\nPress Enter or Space to disable\nPress Backspace or Escape to ignore";
        warning.screenCenter();

        FlxTween.tween(txt, {alpha: 1.0}, 0.5);
    }

    // this code is ass but fuck you
    override function update(elapsed:Float) {
        if (leftState) {
            super.update(elapsed); 
            return;
        }

        if (controls.ACCEPT) {
            leftState = true;
            FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = true;
            FlxG.sound.music.fadeOut(1, 0);
            ClientPrefs.data.flashing = false;
            ClientPrefs.saveSettings();
            FlxG.sound.play(Paths.sound('confirmMenu'));
            FlxTween.tween(txt, {alpha: 0}, 1.5, {onComplete: (_) -> MusicBeatState.switchState(new TitleState())});
        }

        if (controls.BACK) {
            leftState = true;
            FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = true;
            FlxG.sound.music.fadeOut(1, 0);
            ClientPrefs.saveSettings();
            FlxG.sound.play(Paths.sound('cancelMenu'));
            FlxTween.tween(txt, {alpha: 0}, 1.5, {onComplete: (_) -> MusicBeatState.switchState(new TitleState())});
        }

        super.update(elapsed);
    }
}
