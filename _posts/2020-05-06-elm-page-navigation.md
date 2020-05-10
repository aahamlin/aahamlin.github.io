---
title: Basic page navigation with Elm 0.19.1
layout: post
---

[Elm](https://elm-lang.org) is a functional language for building web pages. I first discovered Elm back around 2015, before my life went haywire. Getting back to it now, I decided to break down the single page application example, [rtfeldmand/elm-spa-example](https://github.com/rtfeldman/elm-spa-example), to make sure I understand the basics better. (Also, this uses webpack for builds and Bootstrap 4.3 CSS for themes.)

I have broken this into 4 parts:
1. Types and records
1. Credential caching
1. Protect pages 
1. Load cached credentials


## Types and Records

First, what is the difference between and usage of all the different types? Example code usually names the main type Model. But the Model can be a union type or a record. And then there are the TitleCase type definitions, and type annotations with camelCase type variables. There is an elm-guide page about [type annotations](https://github.com/elm-guides/elm-for-js/blob/master/How%20to%20Read%20a%20Type%20Annotation.md), that covers things in more details. The initial [commit](https://github.com/aahamlin/elm-pages-sample/commit/7b7be86711d1ee30e64ae7735fe05dde72607ba4) sets up 3 pages: Home, Login, Settings and allows you to navigate between them.

To break my mind's laziness and force an understanding of the Model and Msg types. I defined them as AppModel and AppMsg.

```
type AppModel
    = Redirect Session
    | NotFound Session
    | Home Home.Model
    | Login Login.Model
    | Settings Settings.Model


type AppMsg
    = UrlChanged Url
    | LinkClicked UrlRequest
    | GoToHome Home.Msg
    | GoToLogin Login.Msg
    | GoToSettings Settings.Msg
    | GotSession Session
```

Note: my initial misunderstanding of the AppMsg type by naming the Enum entries "GoTo...". This (and other) mistakes are corrected in the final commit. I have corrected the following references.

Looking at the `update` function, specifically, the function type annotation states that the function takes an AppMsg, an AppModel, and returns a tuple of AppModel, Cmd AppMsg. This is in the Main.elm and uses TitleCase type names. 

```
update : AppMsg -> AppModel -> ( AppModel, Cmd AppMsg )
update msg model =
  ...
```

Compare this to the [Browser.application](https://package.elm-lang.org/packages/elm/browser/latest/Browser#application) `update` definition.

```
application :
    { init : flags -> Url -> Key -> ( model, Cmd msg )
    , view : model -> Document msg
    , update : msg -> model -> ( model, Cmd msg )
    , subscriptions : model -> Sub msg
    , onUrlRequest : UrlRequest -> msg
    , onUrlChange : Url -> msg
    }
    -> Program flags model msg
```

The type variables (camelCase) are msg and model, and Cmd. [Cmd](https://package.elm-lang.org/packages/elm/core/latest/Platform.Cmd) is an elm core type that tells the runtime that it has something to do. Comparing the application definition with our Main.elm update definition, it's clear see how our concrete types AppModel and AppMsg are being inserted into the framework of our app. In our implementation `msg` is any `AppMsg` and `model` is any `AppModel`.

Next, taking a look at the home page in Page/Home.elm. This defines a record type Model and one Msg. The page has its own `update` function that looks almost identical to Main's, but it uses its locally defined types. The Home module's update function takes a Home.Msg and Home.Model and returns a tuple of ( Home.Model, Cmd Home.Msg ).

```
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( GotSession session, _ ) ->
            ( { model | session = session }, Cmd.none )
			
```

Looking back at the AppModel and AppMsg definitions in our Main module, we can see how the page's Model and Msg types are accessed by the functions in Main to dispatch the events to our pages.

This occurs in the `update` function and uses the helper `updateWith`.

```
update : AppMsg -> AppModel -> ( AppModel, Cmd AppMsg )
update msg model =
    case Debug.log "update" ( msg, model ) of
        ...
        ( GotHomeMsg subMsg, Home home ) ->
            Home.update subMsg home
                |> updateWith Home GotHomeMsg

updateWith : (subModel -> AppModel) -> (subMsg -> AppMsg) -> ( subModel, Cmd subMsg ) -> ( AppModel, Cmd AppMsg )
updateWith toModel toMsg ( subModel, subCmd ) =
    ( toModel subModel
    , Cmd.map toMsg subCmd
    )
```

The `updateWith` function uses type variables. This allows support for all possible types in the pages. The function call works like this.
1. Main.update receives a *AppMsg=(GotHomeMsg Home.Msg)* and an *AppModel=(Home Home.Model)*
2. Calls Home.update with the provided Home.Msg  and Home.Model values. The return is a tuple of *(Home.Model, Cmd Home.Msg)*
3. Calls updateWith AppModel Home and AppMsg GotHomeMsg and the returned tuple from the previous step
4. updateWith resolves the type variables based on the returned tuple and **maps** the page's Model and Msg to the AppModel and AppMsg types

I have not found a direct explanation of the type variables usage in updateWith, e.g. (subModel -> AppModel) and (subMsg -> AppMsg) but my interpretation from this project is _"subModel = any entry in the AppModel type enum"_.

## Credential Caching

Now that we can change pages. Let's look at the JSON encoding and decoding happening in the elm-spa-example. This [commit](https://github.com/aahamlin/elm-pages-sample/commit/6797fca7c592138bc655c42bafe2e261d6ecb142) holds a number of changes, including renaming User to Viewer module (taken straight from elm-spa-example), but the interesting bits cover the login functionality.

There is a login button, mocking up a token credential value and serializing it to JSON for localStorage. 

**note:** There is no actual authn/z happening for this example. You can see the original spa for that.

The Login button is added to the `view` function and triggers the `DoLogin` msg when clicked. 

```
type Msg
    = DoLogin
    | CompletedLogin (Result String Viewer)
    | GotSession Session


view : Model -> { title : String, content : Html Msg }
view model = { title = "Login"
    , content =
	    div []
            [ div [] [ text "Login content" ]
            , br [] []
            , button
                [ onClick DoLogin ]
                [ text "Login" ]
            ]
    }
}
```

During the `update` function, the DoLogin msg returns a Cmd CompletedLogin msg. It accomplishes this by calling `Task.perform`. Like, `Http.send` this is an Elm function that produces `Cmd msg` outputs. In our case, the Login page produces a `Cmd Login.Msg`, as shown by the `update` function's type annotation which is using an uppercase Msg rather than a lowercase msg.

The `fakeLogin` function runs the task for us, in other words, the `Task` creates the `Cmd msg` return value. And `Task.succeed` returns the success Result which contains a Viewer created from the token credential produced by `Api.login`. See the Msg type, `CompletedLogin (Result String Viewer)` 

```

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =	update msg model =
    case ( msg, model ) of
	   DoLogin ->
	       ( model
		   , Task.perform CompletedLogin (fakeLogin "bob")
		   )

	   CompletedLogin (Err err) ->
		   ( { model | problems = err }
		   , Cmd.none
		   )

	   CompletedLogin (Ok viewer) ->
		   ( model
		   , Viewer.store viewer
		   )

fakeLogin : String -> Task x (Result String Viewer)
fakeLogin usernameVal =
    let
        cred =
            Api.login usernameVal
    in
    Ok (Viewer cred)
        |> Task.succeed
```

_To see the creation and storage of the token credential, look at some of the Api.elm file. The `login` function creates a fake credential containing some placeholder token values._

The returned credential is used to create a `Viewer` which is then returned on the `CompletedLogin` success path. This, in turn, calls `Viewer.store` which calls `Api.storeCredential`. This is when we encounter the next important piece, JSON encoding and callout to localStorage via Elm ports. The following functions demonstrate the flow up to the callout to JavaScript via ports.

```
storeCredential : Credential -> Cmd msg
storeCredential credential =
    Just (encodeCredential credential)
        |> storeCache
		

encodeCredential : Credential -> Value
encodeCredential (Credential uname tokens) =
    Encode.object
        [ ( "user"
          , Encode.object
                [ ( "username", Username.encode uname )
                , ( "tokens", Tokens.encode tokens )
                ]
          )
        ]

port storeCache : Maybe Value -> Cmd msg
```

For simplicity and testability, I split out a new module `Tokens` with its own `encode` function. There is a corresponding `Tokens.decoder` and, while the JavaScript interop cannot be tested with `elm-test`, we can test the round-trip encode -> decode calls with the following unit test.

```
suite : Test
suite =
    describe "Tokens"
        [ test "serialization" <|
            {- Test round-trip serialization of our tokens.
               This data type crosses our application boundary over our ports,
               from Elm to Javascript (localStorage) and back again, so we
               want to be sure we can decode what we previously encoded.
            -}
            \_ ->
                let
                    tokens =
                        { idToken = "id-token-1234"
                        , refreshToken = "refresh-token-1234"
                        , accessToken = "access-token-1234"
                        }
                in
                Tokens.encode tokens
                    -- necessary intermediary step from Encode.Value to Decode.Value
                    |> Encode.encode 0
                    |> Decode.decodeString Tokens.decoder
                    |> Expect.ok
        ]
```

Completing the code walk-through of this stage, look at the `src/index.js` file to see the JavaScript interop side of Elm ports. This is where the localStorage read/write occurs. It's simple.


## Protect Pages

Preventing unauthorized users from seeing content many options. In this [commit](https://github.com/aahamlin/elm-pages-sample/commit/8a055a633aecefb6513400d80338916b343588f2) I just redirect to the Home page, but the later [commit](https://github.com/aahamlin/elm-pages-sample/commit/61f69982e0f2dd5061380bd3cc741696cecaeff5) redirects to the Login page and specifies a returnRoute to go back to the protected resource after completing the login flow. 

**TODO** I am going to come back to this in the near future. A couple of different working versions are in the commit history but I think integrating this with the Page module itself will be more robust.

## Load Cached Credentials

Lastly, this [commit](https://github.com/aahamlin/elm-pages-sample/commit/a3f88f246d601642c69b711ec29d632f4e21344a) completes the round-trip of the Login flow by reading the credentials previously stored in localStorage, decoding the values into a `Viewer` and emitting a `GotSession Session` msg that updates the state of the app to reflect that there is a logged in user.

When the Elm client is initialized, it is now passed the `flags` argument. This is the string value of JSON object previously stored in `Api.storeCredential`. From elm-spa-example, we utilize our `Api.application` function to decode this string into a Json.Decode.Value and then into a Viewer object, maybe. Looking specifically at the decoding portion of our Api.application function.

```
let
   maybeViewer =
     Decode.decodeValue Decode.string flags
        |> Result.andThen (Decode.decodeString (storageDecoder viewerDecoder))
        |> Result.toMaybe
in
...
```

The `storageDecoder` function grabs the value from the "user" field and decodes it using the `Viewer.decoder` function. If everything decodes properly a `Just Viewer` is returned, otherwise `Nothing`. The `main` function uses this value to reflect a logged in user and subscriptions to the `onStoreChange` port are called with the Session value and views will update as appropriate.

If you have added an eventListener on the JavaScript side, the logging in and logging out will support multiple tabs on your web browser.

```
window.addEventListener("storage", function(evt) {
    if (evt.storageArea === localStorage && evt.key === storageKey ) {
	app.ports.onStoreChange.send(evt.newValue);
    }
}, false);
```

I hope that this clarifies some of the details of the elm-spa-example application for you.
