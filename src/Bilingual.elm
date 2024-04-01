module Bilingual exposing (..)

type Language = English | Spanish

type alias BilingualString =
    { spanish: String
    , english: String
    }

choose_language : BilingualString -> Language -> String
choose_language bstring language = 
    case language of 
        English -> bstring.english
        Spanish -> bstring.spanish
