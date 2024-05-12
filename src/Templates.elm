module Templates exposing (..)
import Solarized exposing(..)
import Element exposing (..)
import Element.Border as Border
import Element.Input
import Element.Background as Background
import Element.Font as Font
import Bilingual exposing (..)
import VisualUnits exposing (..)

main_template model list = 
    page_attributes model.style
        <| column
        (dynamic_column_style model.width model.height model.vu model.style)
        <| List.map (\x -> x model.vu model.style model.language) list

main_column_element style = 
    [ Border.width 1
    , Border.color <| translate_generic style Comment
    , Border.rounded 10
    , Background.color <| translate_generic style Header 
    , centerX
    , padding 10
    , spacing 10
    , width fill]

page_attributes style =
    layout
    ([ width fill
        , padding 10
        , spacing 10
        , Background.color 
            <| translate_generic style Background
    , Font.family [ Font.typeface "Computer Modern Serif"]
        ])

solid_spacer style =
    el [ width fill
        , height (px 1)
        , Background.color 
            <| translate_generic style Comment
        ] none
dashed_spacer style = 
    column [width fill ] 
        [ el 
            [ width fill
            , height (px 2)
            , Border.widthEach 
                { bottom = 1
                , left = 0
                , right = 0
                , top = 0
                }
            , Border.color 
                <| translate_generic style Comment
            , Border.dashed
            ]
            none
        , el 
            [ width fill
            , height (px 2)
            ] 
            none
        ]



dynamic_column_style w h vu style = 
    [ width 
        ( if w > h then 
            fill |> maximum  (max 768 <| 150 * vu)
        else
            fill
        )
    , centerX
    , Font.color <| translate_generic style Foreground
    , spacing 5
    ]


icon_image vu language {src, desc} =
    image
        [ width <| px (6 * vu)
        , height <| px (6 * vu)
        ]
        { src = src
        , description = choose_language desc language
        }

website_list vu style language websites =
    wrappedRow
    [spacing 5, width fill]
    <| List.map (\web_link ->
        Element.newTabLink [width fill]
        { url = web_link.url
        , label =
            row ( (main_column_element style ) ++ [Border.color (translate_generic style Comment)])
                [ icon_image vu language { src = web_link.image_src, desc = web_link.image_desc}
                , el 
                    [ width fill, Font.center, Font.size (6 * vu)] 
                    (text <| choose_language web_link.url_label language)
                ]
        }
    )  
    websites

solarized_button vu style language info=
    Element.Input.button 
        []
        { onPress = info.onPress
        , label =
            (menu_bar_item_attributes vu style)
            { src = info.src
            , description = choose_language info.desc language
            }
        }

section info vu style language=
    row [ width fill
        , centerY
        , spacing 5]
        [ dashed_spacer style
        , el 
            [ Font.size (3 * vu)
            , Font.color <| translate_generic style Comment
            ] 
            <| text 
            <| choose_language info language
            , dashed_spacer style
        ]



menu_bar_item_attributes vu style = 
    image
    [ width <| px (5 * vu) 
    , height <| px (5 * vu)
    , ( if (style == Dark)
        then rotate 3.141592
        else rotate 0 
      )
    ]

