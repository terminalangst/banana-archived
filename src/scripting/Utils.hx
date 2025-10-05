package scripting;

class Utils {
    public static final Function_Stop:String = "##scripting_FUNCTIONSTOP";
    public static final Function_Continue:String = "##scripting_FUNCTIONCONTINUE";
    public static final Function_StopAll = "##scripting_FUNCTIONSTOPALL";

    public static inline function getTargetInstance()
        return PlayState.instance == null ? FlxG.state : PlayState.instance.isDead ? substates.GameOverSubstate.instance : PlayState.instance;
}