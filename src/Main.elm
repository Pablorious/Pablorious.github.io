module Main exposing (main)
import Html
import Browser
import Element exposing (..)
import Element.Font as Font
import Element.Background as Background
import Element.Border as Border
import Element.Input
import Browser.Events as E
import Browser.Dom as D
import Html exposing(node)
import Bilingual exposing (..)
import VisualUnits exposing (..)
import Solarized exposing (..)
import Templates exposing (..)

type alias Model =
    { style: Style
    , color_converter_visible: Bool
    , language: Language
    , width : Px
    , height: Px
    , vu: Vu
    }

type alias Flags =
    { width: Px
    , height: Px
    }

initialModel : Flags -> (Model, Cmd a)
initialModel flags =
    ( { style = Dark
    , color_converter_visible = False
    , language = English
    , width = flags.width
    , height = flags.height
    , vu = calculatevu {width = flags.width, height = flags.height}
    }, Cmd.none)

type Msg = NoAction 
         | ToggleStyle
         | ToggleLanguage
         | ToggleColorConverterVisible
         | NewViewportze { width: Px, height: Px }
         | GotInitialViewport D.Viewport


subscriptions : Model -> Sub Msg
subscriptions _ =
    E.onResize (\w h  -> NewViewportze {width = w, height = h})

view : Model -> Html.Html Msg
view model =
    layout 
        (page_attributes model.style)
        <| column
            (dynamic_column_style model.width model.height model.vu model.style)
            [ row (main_column_element model.style) 
                [ style_toggle_button model.vu model.style model.language
                , language_toggle_button model.vu model.language
                ]
            , title_card model.vu model.style model.language
            , resume model.vu model.style model.language
            , github_link model.vu model.style model.language
            , color_converter model.vu model.style model.language model.color_converter_visible
            , section model.vu model.style model.language
            , useful_websites model.vu model.style model.language
            ]

page_attributes style =
    [ width fill
        , padding 10
        , spacing 10
        , Background.color 
            <| translate_generic style Background
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

dashed_spacer : Style -> Element Msg
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

section vu style language =
   row [ width fill
        , centerY
        , spacing 5]
        [ dashed_spacer style
        , el 
            [ Font.size (3 * vu)
            , Font.color <| translate_generic style Comment
            ] 
            (text <|
                choose_language
                    { english = "this websites resources"
                    , spanish = "recursos de este sitio web"
                    } language
            )
        , dashed_spacer style
        ]

useful_websites: Vu -> Style -> Language -> Element Msg
useful_websites vu style language = 
    wrappedRow
    [spacing 5, width fill] 
    [website_link  
        { url = "https://elm-lang.org/"
        , image_src = "images/elm.svg"
        , image_desc = 
            { english = "Elm Icon"
            , spanish = "Icono de Elm-UI"
            }
        , url_label = 
            { english = "Elm"
            , spanish = "Elm"
            }
        } vu style language
    , website_link
        { url = "https://package.elm-lang.org/packages/mdgriffith/elm-ui/latest/   "
        , image_src = "images/elm.svg"
        , image_desc = 
            { english = "Elm-UI Icon"
            , spanish = "Icono de Elm-UI"
            }
        , url_label = 
            { english = "Elm-UI"
            , spanish = "Elm-IU"
            }
        } vu style language
    , website_link
        { url = "https://en.wikipedia.org/wiki/Solarized"
        , image_src = "images/wikipedia.svg"
        , image_desc = 
            { english = "Wikipedia Icon"
            , spanish = "Icono de Wikipedia"
            }
        , url_label = 
            { english = "Solarized Colorscheme"
            , spanish = "Esquema de Colored Solarizados"
            }
        } vu style language
    ]


style_toggle_button: Vu -> Style -> Language -> Element Msg
style_toggle_button vu style language = 
    Element.Input.button 
        [] 
        { onPress = Just ToggleStyle
        , label = image 
            [ width <| px (5 * vu) 
            , height <| px (5 * vu)
            , ( if (style == Dark)
                then rotate 3.141592
                else rotate 0
                )
            ] 
            { src = "images/yin-yang.svg" 
            , description = 
                choose_language 
                { english = "toggle style" 
                , spanish = "alternar estilo" 
                } language
            }
        }

language_toggle_button: Vu -> Language -> Element Msg
language_toggle_button vu language = 
        Element.Input.button [Font.size <| (6 * vu)] 
            { onPress = Just ToggleLanguage
            , label = text <| 
                choose_language
                { english = "🇦🇷"
                , spanish = "🇺🇸"
                } language
            }

title_image: Vu -> Language -> Element Msg
title_image vu language = 
    image 
        [ centerX
        , centerY
        , width fill
        , height <| px (30 * vu)] 
        { src = "images/solarized_butterfly.png"
        , description = choose_language 
            { english = "Nasa photo of The Butterfly Nebula, colorswapped to be represented within the solarized colorscheme."
            , spanish = "Fotografía de la NA de la Nebulosa de la Mariposa, cambiada de colores para representarla dentro del esquema de colores solarizados."
            } language
        }

title_card : Vu -> Style -> Language -> Element Msg
title_card vu style language = 
    column 
        [ centerX
        , Border.width 1
        , Border.rounded 5
        , Border.color <| translate_generic style Comment
        , Background.color <| translate_generic style Header
        , width fill
        , height fill
        , spacing vu
        , inFront <| column [ centerY
                            , width fill
                            , below <| name vu style language
                            , padding vu
                            ] 
                            [profile_pic vu style language]
        ]
        [ title_image vu language, el [ height <| px (30 * vu)] Element.none ]

profile_pic: Vu -> Style -> Language -> Element Msg
profile_pic vu style language = 
    image 
        [ centerX
        , centerY
        , width <| px (27 * vu)
        , height <| px (27 * vu)
        , Border.rounded 150
        , Border.width 1
        , Border.color <| translate_generic style Comment
        , clip
        ] 
        { src = "images/my_face.jpg"
        , description = 
            choose_language 
            { english = "Picture of a long haired man in a suit smiling near a picture of musician playing saxophone"
            , spanish = "Imagen de un hombre de pelo largo con traje sonriendo cerca de una imagen de un músico tocando el saxofón"
            }
            language
        }

name: Vu -> Style -> Language -> Element Msg
name vu style language = el 
    [ centerX
    , centerY
    , padding 5 
    , Font.size (8 * vu)
    , Font.center
    , Font.color <| translate Red
    , Background.color <| translate_generic style Header
    , below <| (el [width fill, Font.size ( 4 * vu )
        , Font.color <| translate_generic style Comment
        , Font.center ] (text 
            <| choose_language 
                { english = "Programmer / Mathematician / Designer / Musician"
                , spanish = "Programador / Matemático / Diseñador / Músico" 
                } language
            ))
    ]
    (text "Pablo Reboredo-Segovia")


color_converter_toggle_button: Vu -> Language -> Element Msg
color_converter_toggle_button vu language = 
    row [width fill]
    [
        icon_image vu language
        { src = "images/tools.svg"
        , desc = 
            { english = "Hammer icon" 
            , spanish = "Icono de martillo" 
            }
        }
        ,
        Element.Input.button 
            [ width fill
            , centerX
            , Font.center
            ] 
            { onPress = Just ToggleColorConverterVisible
            , label = el 
                [ centerX 
                , Font.size (6 * vu)
                ] 
                (text 
                    <| choose_language 
                        { english = "Color Converter" 
                        , spanish = "Convertidor de Colores"
                        } language
                )
            }
    ]

color_converter vu style language visible =
    if visible then
        column (main_column_element style)
        [ color_converter_toggle_button vu language
        , el [width fill ] 
            <| html <| node "color-converter" [] [] 
        ]
    else
        el (main_column_element style) <| color_converter_toggle_button vu language

resume: Vu -> Style -> Language -> Element Msg
resume vu style language = 
    row 
    ( main_column_element style ) 
    [ icon_image vu language 
        { src = "images/file.svg"
        , desc = 
            { english = "Resume Icon"
            , spanish = "Icono de un Currículum"
            }
        }
    , Element.newTabLink 
        [ width fill
        , centerX
        , Font.size (6 * vu)
        , Font.center
        ] 
        { url = "documents/resume.pdf"
        , label = text 
            <| choose_language 
                { english = "Resume" 
                , spanish = "Currículum" 
                } language
        }
    ]

github_link : Vu -> Style -> Language -> Element Msg
github_link vu style language = row (main_column_element style)
    [ icon_image vu language
        { src = "images/github.svg" 
        , desc = 
            { english = "Github Icon" 
            , spanish = "Icono de github" 
            }
        }
    , Element.newTabLink 
        [ Font.size (6 * vu)
        , Font.center
        , width fill
        ] 
        { url = "https://github.com/Pablorious"
        , label = text "Github"
        } 
    ]

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        NoAction ->
            (model, Cmd.none)
        ToggleStyle ->
            case model.style of
                Dark -> ({model | style = Light}, Cmd.none)
                Light -> ({model | style = Dark}, Cmd.none)
        ToggleLanguage ->
            case model.language of
                English -> ({model | language = Spanish}, Cmd.none)
                Spanish -> ({model | language = English}, Cmd.none)
        ToggleColorConverterVisible ->
            if model.color_converter_visible then
                ({model | color_converter_visible = False}, Cmd.none)
            else
                ({model | color_converter_visible = True}, Cmd.none)
        NewViewportze dims ->
            ({model | width = dims.width, height = dims.height, vu = calculatevu dims}, Cmd.none)
        GotInitialViewport vp ->
            let 
                w =  round vp.scene.width
                h = round vp.scene.height
            in
            ({model | width = w, height = h}, Cmd.none)

main : Program Flags Model Msg
main =
    Browser.element
        { init =  initialModel
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
