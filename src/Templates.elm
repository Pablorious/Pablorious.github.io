module Templates exposing (..)
import Solarized exposing(..)
import Element exposing (..)
import Element.Border as Border
import Element.Background as Background
import Element.Font as Font
import Bilingual exposing (..)
import VisualUnits exposing (..)

main_column_element style = 
    [ Border.width 1
    , Border.color <| translate_generic style Comment
    , Border.rounded 5
    , Background.color <| translate_generic style Header 
    , centerX
    , padding 10
    , spacing 10
    , width fill]

icon_image vu language {src, desc} =
    image
        [ width <| px (6 * vu)
        , height <| px (6 * vu)
        ]
        { src = src
        , description = choose_language desc language
        }

website_link {url, url_label, image_src, image_desc} vu style language =
    Element.newTabLink [width fill]
    { url = url
    , label =
        row (main_column_element style )
        [ icon_image vu language
            { src = image_src
            , desc = image_desc
            }
        , el [width fill, Font.center, Font.size (6 * vu)] (text <| choose_language 
            url_label language)
        ]
    }


