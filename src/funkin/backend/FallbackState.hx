package funkin.backend;

class FallbackState extends MusicBeatState {
    var txt:FlxText;
    var bg:FlxSprite;

    override function create() {
        super.create();

        add(bg = new FlxSprite());
        bg.loadGraphic(Paths.image('menuFallback'));
        bg.color = 0x202020;
        bg.screenCenter();

        add(txt = new FlxText(0, 0, 720, "", 32));
        txt.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        txt.borderSize = 2.5;
        txt.text = "HEY!!\nThe menu you're trying to go to is either non-existent, or currently being rewritten.\n\nRedirecting you back to main menu...";
        txt.screenCenter();

        new FlxTimer().start(2.5, (_) -> MusicBeatState.switchState(new funkin.states.MainMenuState()));
    }
}