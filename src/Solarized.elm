module Solarized exposing (..)
import Element as E

type Style = Dark | Light

type SolarizedColor =
    Base03 | Base02 | Base01 | Base00 | Base0 |
    Base1 | Base2 | Base3 | Yellow | Orange |
    Red | Magenta | Violet | Blue | Cyan | Green

type Generic =
    Foreground | Background | Comment | Header | Emphasis 

style_generic: Style -> Generic -> SolarizedColor
style_generic style swap =
    case style of
        Dark -> 
            case swap of
                Foreground -> Base0
                Background -> Base03
                Comment -> Base01
                Header -> Base02
                Emphasis -> Base1
        Light ->
            case swap of
                Foreground -> Base00
                Background -> Base3
                Header -> Base2
                Emphasis -> Base01
                Comment -> Base1

translate: SolarizedColor -> E.Color
translate color =
    case color of
        Base03  -> E.rgb255   0  43  54
        Base02  -> E.rgb255   7  54  66 
        Base01  -> E.rgb255  88 110 117 
        Base00  -> E.rgb255 101 123 131 
        Base0   -> E.rgb255 131 148 150 
        Base1   -> E.rgb255 147 161 161 
        Base2   -> E.rgb255 238 232 213 
        Base3   -> E.rgb255 253 246 227 
        Yellow  -> E.rgb255 181 137   0 
        Orange  -> E.rgb255 203  75  22 
        Red     -> E.rgb255 220  50  47 
        Magenta -> E.rgb255 211  54 130 
        Violet  -> E.rgb255 108 113 196 
        Blue    -> E.rgb255  38 139 210 
        Cyan    -> E.rgb255  42 161 152 
        Green   -> E.rgb255 133 153   0 

translate_generic : Style -> Generic -> E.Color
translate_generic style generic =
    translate
    <| style_generic style generic


