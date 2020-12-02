---
layout: post
title: Geocoding with Elm, Geocod.io, and Google Maps
---

This past weekend I built a small Elm application to explore [Geocoding](https://en.wikipedia.org/wiki/Geocoding).

It demonstrates several of the parts of [Elm](https://elm-lang.org) I have found essential to building a functioning web app. These include:
1. Basic Elm [Architecture](https://guide.elm-lang.org/architecture/) (e.g. model-view-update)
2. Interaction with JS via Elm [ports](https://guide.elm-lang.org/interop/ports.html)
3. Interaction with [HTTP](https://guide.elm-lang.org/effects/http.html) APIs via the [elm/http](https://package.elm-lang.org/packages/elm/http/latest/) package
4. Working with [JSON](https://guide.elm-lang.org/effects/json.html) documents via the [elm/json](https://package.elm-lang.org/packages/elm/json/latest/) package

The app displays locations (latitude & longitude) of an address in the US or Canada you provide, or as fetched from your web browser's navigator.geolocation object.

Addresses are resolved using the geocod.io API as shown below,
  `curl "https://api.geocod.io/v1.6/geocode?q=1109+N+Highland+St%2c+Arlington+VA&api_key=YOUR_API_KEY"`

Along the way, I encountered a bunch of new things, with Elm itself, and with npm packages [Webpack](https://www.npmjs.com/package/webpack) and [npm-watch](https://www.npmjs.com/package/npm-watch).

The code is posted on github at [aahamlin/elm-geoding](https://github.com/aahamlin/elm-geocoding).

## Elm

### Nest field updates

In my model, I use nested [records](https://elm-lang.org/docs/records) and found that updating nested record fields required (and was nicely solved by) defining a function to update the nested field values using the following syntax:


```

type alias Form =
    { street : String
    , city : String
    , state : String
    }

type alias Model =
    { form : Form
    , apiKeys : ApiKeys
    , latLng : Maybe LatLng
    , pageState : PageState
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FormStreetMsg str ->
            ( { model | form = updateNestedField model.form (\f -> { f | street = str }) }, Cmd.none )



updateNestedField : form -> (form -> form) -> form
updateNestedField form fn =
    fn form

```

I found a number of posts on the [r/elm](https://www.reddit.com/r/elm/) sub-reddit on the nested field update topic but this solution seems much cleaner to me.

### Updating VDOM caused errors

Originally, I was using Browser.Document API but discovered, upon adding the functionality to dynamically update the <google-map> and <google-map-marker> elements of the google-map webcomponent, that updating the VDOM outside of Elm causes Elm to lose track of DOM element, resulting in the error: "Uncaught TypeError: Cannot read property 'childNodes' of undefined".

See Elm Discourse [article](https://discourse.elm-lang.org/t/javascript-exception-cannot-read-property-childnodes-of-undefined-with-extension-dark-reader/2748).


## npm


### webpack to externalize API_KEYs

Use [html-webpack-plugin](https://www.npmjs.com/package/html-webpack-plugin) and [dotenv-webpack](https://www.npmjs.com/package/dbotenv-webpack) to externalize your API_KEYs from source control. Notice that the plaintext keys will exist in your HTML after the build. Both geocod.io and Google Maps allow you to apply IP Address restrictions on your keys to protect usage based on allow web addresses.

### webpack-cli
The latest version of webpack-cli continually errored with a MODULE_NOT_FOUND error. I found from older projects of mine that webpack-cli@3 works successfully. Installation: `npm install webpack-cli@3 -D --legacy-peer-deps`.

### npm-watch

Watching Elm files with `npm-watch` requires adding the 'elm' extension to the watch patterns.
```
    "watch": {
        "build:debug": {
            "patterns": [
                "src/*.elm"
            ],
            "extensions": [
                "elm"
            ]
        }
    },

```



## Acknowledgements

Display of the Google Map makes use of [Simonh1000](https://github.com/simonh1000)'s modifications to the [google-maps](https://github.com/simonh1000/elm-google-map-webcomponent) web component. Changed files for maps and markers are committed in the `assets` directory.
