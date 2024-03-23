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

type SolarizedStyle = Dark | Light
type Language = Eng | Span

type alias Model =
    { style: SolarizedStyle
    , color_converter_visible: Bool
    , language: Language
    , width : Int
    , height: Int
    }

type alias Flags =
    { width: Int
    , height: Int
    }

initialModel : Flags -> (Model, Cmd a)
initialModel flags =
    ( { style = Dark
    , color_converter_visible = False
    , language = Eng
    , width = flags.width
    , height = flags.height
    }, Cmd.none)


type Msg = NoAction 
         | ToggleStyle
         | ToggleLanguage
         | ToggleColorConverterVisible
         | NewViewportSize Int Int
         | GotInitialViewport D.Viewport


subscriptions : Model -> Sub Msg
subscriptions _ =
    E.onResize (\w h -> NewViewportSize w h)

bilingualstring : String -> String -> Language -> String
bilingualstring english spanish language = 
    case language of 
        Eng -> english
        Span -> spanish

view : Model -> Html.Html Msg
view model =
    layout 
        [ width fill
        , padding 10
        , spacing 10
        , Background.color 
            <| translate_color model.style Background
        ]
        <| column
            [ width (if model.width > model.height then 
                    (fill |> maximum 768)
                else
                    fill)
            , centerX
            , Font.color <| translate_color model.style Foreground
            , spacing 5
            ]
            [ row (main_column_element model.style) 
                [ style_toggle_button model.language
                , language_toggle_button model.language
                ]
            , title_card  model.style model.language
            , resume model.style model.language
            , color_converter model.style model.language model.color_converter_visible
            , github_link model.style model.language
            ]

style_toggle_button: Language -> Element Msg
style_toggle_button language = 
    Element.Input.button 
        [] 
        { onPress = Just ToggleStyle
        , label = image 
            [ width <| px 20 
            , height <| px 20] 
            { src = "images/solarized.png" 
            , description = 
                bilingualstring 
                    "toggle style" 
                    "alternar estilo" 
                    language
            }
        }

language_toggle_button: Language -> Element Msg
language_toggle_button language = 
    case language of 
        Eng -> Element.Input.button [] 
            { onPress = Just ToggleLanguage
            , label = text "🇦🇷"
            }

        Span -> Element.Input.button [] 
            { onPress = Just ToggleLanguage
            , label = text "🇺🇸"
            }

color_converter_toggle_button: Language -> Element Msg
color_converter_toggle_button language = 
    row [width fill]
    [
        image 
        []
        { src = "images/hammer.svg"
        , description = 
            bilingualstring 
            "Hammer icon" 
            "Icono de martillo" 
            language 
        }
        ,
        Element.Input.button 
            [ width fill
            , centerX
            , Font.center
            ] 
            { onPress = Just ToggleColorConverterVisible
            , label = el [ centerX] (text 
                <| bilingualstring "Color Converter" "Convertidor de Colores" language)
            }
    ]

color_converter style language visible =
    if visible then
        column (main_column_element style)
        [ color_converter_toggle_button language
        , el [width fill ] 
            <| html <| node "color-converter" [] [] 
        ]
    else
        el (main_column_element style) <| color_converter_toggle_button language

resume style language = 
    row 
    ( main_column_element style ) 
    [ image 
        [ width <| px 20
        , height <| px 20
        ]
        { src = "images/resume.png"
        , description = bilingualstring
            "Resume Icon"
            "Icono de un Currículum"
            language
        }
    , Element.newTabLink 
        [ width fill
        , centerX
        , Font.size 20
        , Font.center
        ] 
        { url = "documents/resume.pdf"
        , label = text 
            <| bilingualstring "Resume" "Currículum" language
        }
    ]

github_link style language = row (main_column_element style)
    [ image 
        [ width <| px 20
        , height <| px 20
        ] 
        { src = "images/github.svg" 
        , description = bilingualstring "Github Icon" "Icono de github" language
        }
    , Element.newTabLink 
        [ Font.size 20
        , Font.center
        , width fill
        ] 
        { url = "https://github.com/Pablorious"
        , label = text "Github"
        }
    ]

title_image: Language -> Element Msg
title_image language = 
    image 
        [ centerX
        , centerY
        , width fill
        , height <| px 150] 
        { src = "images/solarized_butterfly.png"
        , description = bilingualstring 
            "Nasa photo of The Butterfly Nebula, colorswapped to be represented within the solarized colorscheme."
            "Fotografía de la NASA de la Nebulosa de la Mariposa, cambiada de colores para representarla dentro del esquema de colores solarizados."
            language
        }

title_card : SolarizedStyle -> Language -> Element Msg
title_card style language = 
    column 
        [ centerX
        , Border.width 1
        , Border.rounded 5
        , Border.color <| translate_color style Comment
        , Background.color <| translate_color style Header
        , width fill
        , height fill
        , spacing 10
        , inFront <| column [ centerY
                            , width fill
                            , below <| name style
                            , padding 10
                            ] 
                            [profile_pic style language]
        ]
        [ title_image language, el [ height <| px 150] Element.none ]

profile_pic: SolarizedStyle -> Language -> Element Msg
profile_pic style language = 
    image 
        [ centerX
        , centerY
        , width <| px 150
        , height <| px 150
        , Border.rounded 150
        , Border.width 1
        , Border.color <| translate_color style Comment
        , clip] 
        { src = "images/my_face.jpg"
        , description = 
            bilingualstring 
            "Picture of a long haired man in a suit smiling near a picture of musician playing saxophone"
            "Imagen de un hombre de pelo largo con traje sonriendo cerca de una imagen de un músico tocando el saxofón"
            language
        }

name: SolarizedStyle -> Element Msg
name style = el 
    [ centerX
    , centerY
    , padding 5 
    , Font.size 30
    , Font.center
    , Font.color <| solarized_color_to_color Green
    , Background.color <| translate_color style Header
    ]
    (text "Pablo Reboredo-Segovia")

main_column_element: SolarizedStyle -> List (Attribute Msg)
main_column_element style = 
    [ Border.width 1
    , Border.color <| translate_color style Comment
    , Border.rounded 5
    , Background.color <| translate_color style Header 
    , centerX
    , padding 10
    , spacing 10
    , width fill]

translate_color: SolarizedStyle -> SwappingColor -> Color
translate_color style swap =
    solarized_color_to_color
    <| swappingcolor_to_solarized_color style swap

solarized_color_to_color: SolarizedColor -> Color
solarized_color_to_color color =
    case color of
        Base03  -> Element.rgb255   0  43  54
        Base02  -> Element.rgb255   7  54  66 
        Base01  -> Element.rgb255  88 110 117 
        Base00  -> Element.rgb255 101 123 131 
        Base0   -> Element.rgb255 131 148 150 
        Base1   -> Element.rgb255 147 161 161 
        Base2   -> Element.rgb255 238 232 213 
        Base3   -> Element.rgb255 253 246 227 
        Yellow  -> Element.rgb255 181 137   0 
        Orange  -> Element.rgb255 203  75  22 
        Red     -> Element.rgb255 220  50  47 
        Magenta -> Element.rgb255 211  54 130 
        Violet  -> Element.rgb255 108 113 196 
        Blue    -> Element.rgb255  38 139 210 
        Cyan    -> Element.rgb255  42 161 152 
        Green   -> Element.rgb255 133 153   0 

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
                Eng -> ({model | language = Span}, Cmd.none)
                Span -> ({model | language = Eng}, Cmd.none)
        ToggleColorConverterVisible ->
            if model.color_converter_visible then
                ({model | color_converter_visible = False}, Cmd.none)
            else
                ({model | color_converter_visible = True}, Cmd.none)
        NewViewportSize w h ->
            ({model | width = w, height = h}, Cmd.none)
        GotInitialViewport vp ->
            let 
                w =  round vp.scene.width
                h = round vp.scene.height
            in
            ({model | width = w, height = h}, Cmd.none)

type SolarizedColor =
    Base03 | Base02 | Base01 | Base00 | Base0 |
    Base1 | Base2 | Base3 | Yellow | Orange |
    Red | Magenta | Violet | Blue | Cyan | Green

type SwappingColor =
    Foreground | Background | Comment | Header | Emphasis 

swappingcolor_to_solarized_color: SolarizedStyle -> SwappingColor -> SolarizedColor
swappingcolor_to_solarized_color style swap =
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


main : Program Flags Model Msg
main =
    Browser.element
        { init =  initialModel
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
