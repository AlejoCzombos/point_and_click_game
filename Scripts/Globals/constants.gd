class_name Constants

## Plain class (NOT an autoload) so it works both as a type (Constants.TransitionType)
## and for shared constants (Constants.slide_duration).

## ---------------- Enums -----------------

enum TransitionType {
	FADE,
	SLIDE,
	SLIDE_BLACK,
}

enum Direction {
	LEFT,
	RIGHT,
}

## ---------------- Consts -----------------

const load_duration: float = 0.25
const slide_duration: float = 0.4
