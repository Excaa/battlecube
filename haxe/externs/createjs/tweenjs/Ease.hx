package createjs.tweenjs;

@:native("createjs.Ease")
extern class Ease
{
	public static function backIn(phase:Float):Float;
	public static function backInOut(phase:Float):Float;
	public static function backOut(phase:Float):Float;

	public static function bounceIn(phase:Float):Float;
	public static function bounceInOut(phase:Float):Float;
	public static function bounceOut(phase:Float):Float;

	public static function circIn(phase:Float):Float;
	public static function circInOut(phase:Float):Float;
	public static function circOut(phase:Float):Float;

	public static function cubicIn(phase:Float):Float;
	public static function cubicInOut(phase:Float):Float;
	public static function cubicOut(phase:Float):Float;

	public static function elasticIn(phase:Float):Float;
	public static function elasticInOut(phase:Float):Float;
	public static function elasticOut(phase:Float):Float;

	public static function get(amount:Float):Float;

	public static function getBackIn(amount:Float):Float->Float;
	public static function getBackInOut(amount:Float):Float->Float;
	public static function getBackOut(amount:Float):Float->Float;

	public static function getElasticIn(amplitude:Float, period:Float):Float->Float;
	public static function getElasticInOut(amplitude:Float, period:Float):Float->Float;
	public static function getElasticOut(amplitude:Float, period:Float):Float->Float;

	public static function getPowIn(pow:Float):Float->Float;
	public static function getPowInOut(pow:Float):Float->Float;
	public static function getPowOut(pow:Float):Float->Float;

	public static function linear(amount:Float):Float;
	public static function none(amount:Float):Float;

	public static function quadIn(amount:Float):Float;
	public static function quadInOut(amount:Float):Float;
	public static function quadOut(amount:Float):Float;

	public static function quartIn(amount:Float):Float;
	public static function quartInOut(amount:Float):Float;
	public static function quartOut(amount:Float):Float;

	public static function quintIn(amount:Float):Float;
	public static function quintInOut(amount:Float):Float;
	public static function quintOut(amount:Float):Float;

	public static function sineIn(amount:Float):Float;
	public static function sineInOut(amount:Float):Float;
	public static function sineOut(amount:Float):Float;
}
