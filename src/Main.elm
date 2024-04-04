module Main exposing (main)
import Html exposing(node)
import Html.Attributes
import Browser
import Element exposing (..)
import Element.Font as Font
import Element.Background as Background
import Element.Border as Border
import Element.Input
import Browser.Events as E
import Browser.Dom as D
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
    , style: Bool
    }

darkmode: Bool -> Style
darkmode bool =
    if bool then
        Dark
    else
        Light

isdarkmode: Style -> Bool
isdarkmode style =
    case style of 
        Dark -> True
        Light -> False

stringfrombool : Bool -> String
stringfrombool bool =
    if bool then
        "True"
    else
        "False"

initialModel : Flags -> (Model, Cmd a)
initialModel flags =
    ( 
        { style = darkmode flags.style
        , color_converter_visible = False
        , language = English
        , width = flags.width
        , height = flags.height
        , vu = calculatevu {width = flags.width, height = flags.height}
        }
        , Cmd.none
    )

type Msg = NoAction 
         | ToggleStyle
         | ToggleLanguage
         | ToggleColorConverterVisible
         | NewViewportze { width: Px, height: Px }
         | GotInitialViewport D.Viewport
         | GotStylePreference Bool

subscriptions : Model -> Sub Msg
subscriptions _ =
    E.onResize (\w h  -> NewViewportze {width = w, height = h})

view : Model -> Html.Html Msg
view model =
    main_template model 
    [ menu_bar  
    , title_card 
    , section 
        { english = "my work"
        , spanish = "mi trabajo"
        }
    , resume 
    , github_link 
    , section 
        { english = "web tools I've developed"
        , spanish = "herramientas web que he desarrollado"
        }
    , color_converter model.color_converter_visible
    , section 
        { english = "resources used for this website"
        , spanish = "recursos usado para este sitio web"
        }
    , useful_websites 
    ]

menu_bar : Vu -> Style -> Language -> Element Msg
menu_bar vu style language = 
    row (main_column_element style) 
        [ style_toggle_button vu style language
        , language_toggle_button vu language
        ]

style_toggle_button: Vu -> Style -> Language -> Element Msg
style_toggle_button vu style language = 
    solarized_button vu style language
    { onPress = Just ToggleStyle
     , src = "images/yin-yang.svg" 
    , desc = 
        { english = "toggle style" 
        , spanish = "alternar estilo" 
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
        , height <| px (30 * vu)
        ] 
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
        , inFront 
            <| column
                [ centerY
                , width fill
                , below <| name vu style language
                ] 
                [profile_pic vu style language]
        ]
        [ title_image vu language, solid_spacer style, el [ height <| px (30 * vu)] Element.none ]

profile_pic: Vu -> Style -> Language -> Element Msg
profile_pic vu style language = 
    image 
        [ centerX
        , centerY
        , width <| px (27 * vu)
        , height <| px (27 * vu)
        , Border.rounded 150
        , Border.width 2
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
                { english = "Programmer / Mathematician / Designer"
                , spanish = "Programador / Matemático / Diseñador" 
                } language
            ))
    ]
    (text "Pablo Reboredo-Segovia")

resume: Vu -> Style -> Language -> Element Msg
resume vu style language = 
    Element.newTabLink 
        ( main_column_element style 
        ++
        [ Font.size (6 * vu)
        , Font.center
        , inFront 
        <| el 
            [ alignLeft
            , centerY
            , moveRight 10
            ] 
            <| icon_image vu language 
                { src = "images/file.svg"
                , desc = 
                    { english = "Resume Icon"
                    , spanish = "Icono de un Currículum"
                    }
                }
        ] 
        )
        { url = "documents/resume.pdf"
        , label = text 
            <| choose_language 
                { english = "Resume" 
                , spanish = "Currículum" 
                } language
        }

github_link : Vu -> Style -> Language -> Element Msg
github_link vu style language = 
    Element.newTabLink 
        ( main_column_element style ++
        [ Font.size (6 * vu)
        , Font.center
        , width fill
        , inFront 

        <| el 
            [ alignLeft
            , centerY
            , moveRight 10
            ] 
            <| icon_image vu language 
                { src = "images/github.svg" 
                , desc = 
                    { english = "Github Icon" 
                    , spanish = "Icono de github" 
                    }
                }
        ] 
        )
        { url = "https://github.com/Pablorious"
        , label = text "Github"
        } 

color_converter_toggle_button: Vu -> Language -> Element Msg
color_converter_toggle_button vu language = 
    Element.Input.button 
    [ width fill 
    , Font.center
    , inFront
    <| el 
        [ alignLeft
        , centerY
        ] 
    <| icon_image vu language 
        { src = "images/tools.svg"
        , desc = 
            { english = "Hammer icon" 
            , spanish = "Icono de martillo" 
            }
        } 
    ] 
    { onPress = Just ToggleColorConverterVisible
    , label = 
        el 
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

color_converter : Bool -> Vu -> Style -> Language -> Element Msg
color_converter visible vu style language =
    if visible then
        column (main_column_element style)
        [ color_converter_toggle_button vu language
        , solid_spacer style
        , el [width fill ] 
            <| html 
            <| node "color-converter" 
            [ Html.Attributes.attribute "style"  
                <| stringfrombool 
                <| isdarkmode style
            ] [] 
        ]
    else
        el (main_column_element style) <| color_converter_toggle_button vu language


useful_websites : Px -> Style -> Language -> Element Msg
useful_websites vu style language = 
    website_list vu style language
        [ { url = "https://elm-lang.org/"
            , image_src = "images/elm.svg"
            , image_desc = 
                { english = "Elm Icon"
                , spanish = "Icono de Elm-UI"
                }
            , url_label = 
                { english = "Elm"
                , spanish = "Elm"
                }
            }
        , { url = "https://package.elm-lang.org/packages/mdgriffith/elm-ui/latest/   "
            , image_src = "images/elm.svg"
            , image_desc = 
                { english = "Elm-UI Icon"
                , spanish = "Icono de Elm-UI"
                }
            , url_label = 
                { english = "Elm-UI"
                , spanish = "Elm-IU"
                }
            } 
        , { url = "https://en.wikipedia.org/wiki/Solarized"
            , image_src = "images/wikipedia.svg"
            , image_desc = 
                { english = "Wikipedia Icon"
                , spanish = "Icono de Wikipedia"
                }
            , url_label = 
                { english = "Solarized Colorscheme"
                , spanish = "Esquema de Colores Solarizados"
                }
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
        GotStylePreference bool->
            ({model | style = darkmode bool } , Cmd.none)


main : Program Flags Model Msg
main =
    Browser.element
        { init =  initialModel
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
