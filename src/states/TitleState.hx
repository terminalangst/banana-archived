package states;

/** DEATH TO TITLE JSON!! **/

import flixel.group.FlxGroup;
import openfl.Assets;

// engine imports
import shaders.ColorSwap;

class TitleState extends MusicBeatState {
    public static var initialized:Bool = false;
    public static var closedState:Bool = false;

    var skippedIntro:Bool = false;
    var transitioning:Bool = false;

    var curWacky:Array<String> = [];
    var textGroup:FlxGroup = new FlxGroup();
    var swagsters = new ColorSwap();

    // title sprite shit
    var logo:FlxSprite;
    var girlfriend:FlxSprite;
    var danceLeft:Bool = false; // ???
    var titleText:FlxSprite;
    var ngSpr:FlxSprite;

    // all this is related to titleEnter.png btw LMAOOOO
    var newTitle:Bool = false;
    var tTimer:Float = 0;
    var textCol:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC];
    var textAlpha:Array<Float> = [1, .64];

    override public function create():Void {
        Paths.clearStoredMemory();
        Paths.clearUnusedMemory();

        curWacky = FlxG.random.getObject(getIntroText());

        super.create();

        new FlxTimer().start(.25, (_) -> startIntro());
    }

    function startIntro() {
        if (!initialized && FlxG.sound.music == null) FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
        Conductor.bpm = 102;

        add(logo = new FlxSprite(-128, -110));
        logo.frames = Paths.getSparrowAtlas('logoBumpin');
        logo.animation.addByPrefix('bump', 'logo bumpin', 24, false);
        logo.animation.play('bump');
        logo.updateHitbox();

        add(girlfriend = new FlxSprite(520, 40));
        girlfriend.frames = Paths.getSparrowAtlas('gfDanceTitle');
        girlfriend.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 ,13 ,14], "", 24, false);
        girlfriend.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
        girlfriend.animation.play('danceRight');

        add(titleText = new FlxSprite(100, 576));
        titleText.frames = Paths.getSparrowAtlas('titleEnter');
        titleText.animation.addByPrefix('idle', 'ENTER IDLE', 24);
        titleText.animation.addByPrefix('press', ClientPrefs.data.flashing ? 'ENTER PRESSED' : 'ENTER FREEZE', 24);
        titleText.animation.play('idle');
        titleText.updateHitbox();

        add(textGroup);

        add(ngSpr = new FlxSprite(0, FlxG.height * 0.52, Paths.image('newgrounds_logo')));
        ngSpr.visible = false;
        ngSpr.scale.scale(0.8);
        ngSpr.screenCenter(X);
        ngSpr.updateHitbox();

        logo.alpha = girlfriend.alpha = titleText.alpha = 0.001;
        if (ClientPrefs.data.shaders) logo.shader = girlfriend.shader = swagsters.shader;

        if (initialized) skipIntro(); else initialized = true;
    }

    override function update(elapsed:Float) {

        final pressedEnter:Bool = FlxG.gamepads.lastActive?.justPressed.START || FlxG.keys.justPressed.ENTER || controls.ACCEPT;
        if (FlxG.sound.music != null) Conductor.songPosition = FlxG.sound.music.time;

        if (initialized && !transitioning && skippedIntro) {

            if (newTitle && !pressedEnter) {
                tTimer += FlxMath.bound(elapsed, 0, 1);
                if(tTimer > 2) tTimer -= 2;
                
                var timer:Float = tTimer;
                if (timer >= 1) timer = (-timer) + 2;
                timer = FlxEase.quadInOut(timer);

                titleText.color = FlxColor.interpolate(textCol[0], textCol[1], timer);
                titleText.alpha = FlxMath.lerp(textAlpha[0], textAlpha[1], timer);
            }

            if (pressedEnter) {
                FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1);
                transitioning = true;

                titleText.color = FlxColor.WHITE;
                titleText.alpha = 1;
                if (titleText != null) titleText.animation.play('press');
                FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

                new FlxTimer().start(1, (_) -> {
                    MusicBeatState.switchState(new MainMenuState());
                    closedState = true;
                });
            }
        }

        if (pressedEnter && !skippedIntro) skipIntro();

        if (swagsters != null) {
            if(controls.UI_LEFT) swagsters.hue -= elapsed * 0.1;
            if(controls.UI_RIGHT) swagsters.hue += elapsed * 0.1;
        }

        super.update(elapsed);
    }

	function createCoolText(textArray:Array<String>, ?offset:Float = 0) {
		for (i=>text in textArray) {
			var money:Alphabet = new Alphabet(0, 0, text, true);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
            textGroup.add(money);
		}
	}

	function addMoreText(text:String, ?offset:Float = 0) {
        var coolText:Alphabet = new Alphabet(0, 0, text, true);
        coolText.screenCenter(X);
        coolText.y += (textGroup.length * 60) + 200 + offset;
        textGroup.add(coolText);
	}

    function deleteCoolText() while (textGroup.members.length > 0) textGroup.remove(textGroup.members[0], true);


	function getIntroText():Array<Array<String>> {
		var fullText:String = Assets.getText(Paths.txt('introText'));
		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray) swagGoodArray.push(i.split('--'));
        return swagGoodArray;
	}

    private var sickBeats:Int = 0;
    override function beatHit() {
        super.beatHit();

        if(logo != null) logo.animation.play('bump', true);
        if(girlfriend != null) {
            danceLeft = !danceLeft;
            if (danceLeft) girlfriend.animation.play('danceRight'); else girlfriend.animation.play('danceLeft');
        }

        if (!closedState) {
            sickBeats++;
            switch (sickBeats) {
                case 1:
                    FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
                    FlxG.sound.music.fadeIn(4, 0, 0.7);
                case 2:
                    createCoolText(['The', 'Funkin Crew Inc'], 40);
                case 4:
                    addMoreText('presents', 40);
                case 5:
                    deleteCoolText();
                case 6:
                    createCoolText(['In association with'], -40);
                case 8:
                    addMoreText('Newgrounds', -40);
                    ngSpr.visible = true;
                case 9:
                    deleteCoolText();
                    ngSpr.destroy();
                case 10:
                    createCoolText([curWacky[0]]);
                case 12:
                    addMoreText(curWacky[1]);
                case 13:
                    deleteCoolText();
                case 14:
                    addMoreText('Friday');
                case 15:
                    addMoreText('Night');
                case 16:
                    addMoreText('Funkin');
                case 17:
                    skipIntro();
            }
        }
    }

    function skipIntro() {
        if(!skippedIntro) {
            remove(textGroup);
            ngSpr.destroy();
            newTitle = true;
            logo.alpha = girlfriend.alpha = titleText.alpha = 1;

            FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1);

            skippedIntro = true;
        }
    }
}