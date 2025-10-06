package states;

/** FUCK THE COLUMNS. **/

import flixel.FlxObject;
import flixel.effects.FlxFlicker;

class MainMenuState extends MusicBeatState {
    public static var curSelected:Int = 0;
    
    // menu stuff
    var menuItems:FlxTypedGroup<FlxSprite>;
    var optionStuff:Array<String> = CoolUtil.coolTextFile(Paths.txt('menu/items'));
    var bg:FlxSprite;
    var magenta:FlxSprite;
    var camFollow:FlxObject;
    var ver:String = 'Banana Engine v' + Main.bananaVersion + ' | Psych Engine v' + Main.psychVersion + " | Friday Night Funkin' v" + Main.funkinVersion;
    var verText:FlxText;
    var selectedSomethin:Bool = false;

    override function create() {
        super.create();

        #if DISCORD_ALLOWED DiscordClient.changePresence("Main Menu", null); #end
        persistentUpdate = true;

        var yScroll:Float = .25;
        add(bg = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat')));
        bg.color = 0xFFFDE871;

        add(magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat')));
        magenta.color = 0xFFFD719B;
        magenta.visible = false;

        for (m in [bg, magenta]) {
            m.scrollFactor.set(0, yScroll);
            m.setGraphicSize(Std.int(m.width * 1.175));
            m.updateHitbox();
            m.screenCenter();
        }

        add(camFollow = new FlxObject(0, 0, 1, 1));
        add(menuItems = new FlxTypedGroup<FlxSprite>());

        for (i => option in optionStuff) {
            var item:FlxSprite = createMenuItem(option, 0, (i * 140) + 100);
            item.y += (4 - optionStuff.length) * 75;
            item.screenCenter(X);
        }

        add(verText = new FlxText(12, FlxG.height - 25, 0, ver));
        verText.scrollFactor.set();
        verText.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        verText.borderSize = 1.5;

        changeItem();
        FlxG.camera.follow(camFollow, null, 0.075);
    }

    function createMenuItem(name:String, x:Float, y:Float):FlxSprite {
        var menuItem:FlxSprite;
        menuItems.add(menuItem = new FlxSprite(x, y));
        menuItem.frames = Paths.getSparrowAtlas('mainmenu/$name');
        menuItem.animation.addByPrefix('idle', '$name idle', 24, true);
        menuItem.animation.addByPrefix('selected', '$name selected', 24, true);
        menuItem.animation.play('idle');
        menuItem.updateHitbox();
        menuItem.scrollFactor.set();

        return menuItem;
    }

    function changeItem(change:Int = 0) {
        curSelected = FlxMath.wrap(curSelected + change, 0, menuItems.length - 1);
        FlxG.sound.play(Paths.sound('scrollMenu'));

        for (item in menuItems) {
            item.animation.play('idle');
            item.centerOffsets();
        }

        var selectedItem:FlxSprite;
        selectedItem = menuItems.members[curSelected];
        selectedItem.animation.play('selected');
        selectedItem.centerOffsets();
        camFollow.y = selectedItem.getGraphicMidpoint().y;
    }

    override function update(elapsed:Float) {
        if (FlxG.sound.music != null && FlxG.sound.music.volume < 0.8) FlxG.sound.music.volume += 0.5 * elapsed;

        if (!selectedSomethin) {
            if (controls.UI_UP_P || controls.UI_DOWN_P) changeItem(controls.UI_UP_P ? -1 : 1);
            if (controls.BACK) {
                selectedSomethin = true;
                FlxG.sound.play(Paths.sound('cancelMenu'));
                MusicBeatState.switchState(new TitleState());
            }
            if (controls.ACCEPT) {
                selectedSomethin = true;
                FlxG.sound.play(Paths.sound('confirmMenu'));

                if (ClientPrefs.data.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);
                
                var item:FlxSprite;
                var option:String;
                option = optionStuff[curSelected];
                item = menuItems.members[curSelected];

                FlxFlicker.flicker(item, 1, 0.06, false, false, function(flick:FlxFlicker) {
                    switch(option) {
                        case 'storymode': MusicBeatState.switchState(new states.StoryMenuState());
                        case 'freeplay': MusicBeatState.switchState(new states.FreeplayState());
                        case 'credits': MusicBeatState.switchState(new states.CreditsState());
                        case 'options':
                            MusicBeatState.switchState(new options.OptionsState());
                            options.OptionsState.onPlayState = false;
                            if (states.PlayState.SONG != null) {
                                states.PlayState.SONG.arrowSkin = states.PlayState.SONG.splashSkin = null;
                                states.PlayState.stageUI = 'normal';
                            }
                        default:
                            trace('Menu Item ${option} doesn\'t do anything');
							selectedSomethin = false;
							item.visible = true;
                    }
                });

                for (memb in menuItems) {
                    if(memb == item) continue;
                    FlxTween.tween(memb, {alpha: 0}, 0.4, {ease: FlxEase.quadOut});
                }
            }

            #if desktop
            if (controls.justPressed('debug_1')) {
                selectedSomethin = true;
                MusicBeatState.switchState(new states.editors.MasterEditorMenu());
            }
            #end
        }

        super.update(elapsed);
    }
}