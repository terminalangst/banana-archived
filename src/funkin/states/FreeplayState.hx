package funkin.states;

import funkin.states.substates.ResetScoreSubState;
import funkin.objects.HealthIcon;
import funkin.backend.Highscore;
import funkin.backend.WeekData;
import funkin.backend.Song;
import flixel.math.FlxMath;
import flixel.util.FlxDestroyUtil;
import openfl.utils.Assets;
import haxe.Json;

class FreeplayState extends MusicBeatState
{
	var bg:FlxSprite;
	var intendedColor:Int;

	var songs:Array<SongMetadata> = [];

	var scoreBG:FlxSprite;
	var diffText:FlxText;
	var scoreText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var lerpSelected:Float = 0;

	var curDifficulty:Int = 1;
	private static var curSelected:Int = 0;
	private static var lastDifficultyName:String = Difficulty.getDefault();

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<HealthIcon> = [];

	override function create() {
		persistentUpdate = true;
		WeekData.reloadWeekFiles(false);

		#if DISCORD_ALLOWED DiscordClient.changePresence("Freeplay Menu", null); #end

		for (i in 0...WeekData.weeksList.length) {
			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length) {
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs) {
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
			}
		}
		Mods.loadTopMod();

		add(bg = new FlxSprite().loadGraphic(Paths.image('menuDesat')));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.screenCenter();

		add(grpSongs = new FlxTypedGroup<Alphabet>());

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(90, 320, songs[i].songName, true);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);
			songText.scaleX = Math.min(1, 980 / songText.width);
			songText.snapToPosition();

			Mods.currentModDirectory = songs[i].folder;
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;
			iconArray.push(icon);
			add(icon);
		}
		WeekData.setDirectoryFromWeek();

		if(curSelected >= songs.length) curSelected = 0;
		bg.color = songs[curSelected].color;
		intendedColor = bg.color;
		lerpSelected = curSelected;

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		add(scoreBG = new FlxSprite(scoreText.x - scoreText.width, 0).makeGraphic(1, 66, 0xFF000000));
		scoreBG.alpha = 0.6;

		add(diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24));
		diffText.font = scoreText.font;
		add(scoreText);
		
		changeSelection();
		changeDiff();
		super.create();
	}

	override function update(elapsed:Float) {
		if(WeekData.weeksList.length < 1) return;

        if (controls.UI_UP_P || controls.UI_DOWN_P) changeSelection(controls.UI_UP_P ? -1 : 1);
		if (controls.UI_LEFT_P || controls.UI_RIGHT_P) changeDiff(controls.UI_LEFT_P ? -1 : 1);

		if (controls.BACK) {
			persistentUpdate = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		if(controls.RESET)
		{
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}

		lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 24)));
		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = 'PERSONAL BEST: ' + lerpScore;
		scoreText.x = FlxG.width - scoreText.width - 5;
		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
		diffText.x = scoreBG.x + (scoreBG.width * 0.5) - (diffText.width * 0.5);

		super.update(elapsed);
	}

	function changeDiff(change:Int = 0) {
		curDifficulty = FlxMath.wrap(curDifficulty + change, 0, Difficulty.list.length-1);
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);

		lastDifficultyName = Difficulty.getString(curDifficulty, false);
		var displayDiff:String = Difficulty.getString(curDifficulty);
		diffText.text = '< ' + displayDiff.toUpperCase() + ' >';
	}

	function changeSelection(change:Int = 0) {
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		curSelected = FlxMath.wrap(curSelected + change, 0, songs.length -1);
		var newColor:Int = songs[curSelected].color;
		if(newColor != intendedColor)
		{
			intendedColor = newColor;
			FlxTween.cancelTweensOf(bg);
			FlxTween.color(bg, 1, bg.color, intendedColor);
		}
		for (num => item in grpSongs.members)
		{
			var icon:HealthIcon = iconArray[num];
			item.targetY = num - curSelected;
			item.alpha = 0.6;
			icon.alpha = 0.6;
			if (item.targetY == 0)
			{
				item.alpha = 1;
				icon.alpha = 1;
			}
		}
		Mods.currentModDirectory = songs[curSelected].folder;
		Difficulty.loadFromWeek();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int) {
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}
}

class SongMetadata {
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";
	public var lastDifficulty:String = null;

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Mods.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}