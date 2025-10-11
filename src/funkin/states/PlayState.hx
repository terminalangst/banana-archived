package funkin.states;

import funkin.backend.Highscore;
import funkin.backend.StageData;
import funkin.backend.WeekData;
import funkin.backend.Song;

class PlayState extends MusicBeatState
{
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
}
