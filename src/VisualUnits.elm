module VisualUnits exposing (..)

type alias Vu = Int
type alias Px = Int

calculatevu : {width: Px , height: Px} -> Vu
calculatevu dims =
    (min dims.width dims.height) // 100

