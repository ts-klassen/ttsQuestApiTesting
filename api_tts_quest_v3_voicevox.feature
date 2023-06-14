Feature: testing v1 voicevox api

  Background:
    * def ur = 'https://testing.tts.quest/'
    * url ur
    * def key = java.lang.System.getenv('TTSQUEST_API_KEY');
    * def canTakeUpTo = 1;
    * def sleep = function(millis){ java.lang.Thread.sleep(millis) }
    * def text = 'あいうえお'

  Scenario: endpoint test
    Given url ur+'v3/voicevox/synthesis'
    When method get
    Then status 400
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    And assert responseHeaders['Content-Type'][0]=='application/json'
    * match response == {"success":false,"isApiKeyValid":false,"errorMessage":"textRequired"}

    * sleep(2000)

    When method post
    Then status 400
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    And assert responseHeaders['Content-Type'][0]=='application/json'
    And assert response.success==false
    * match response == {"success":false,"isApiKeyValid":false,"errorMessage":"textRequired"}

    When method get
    When method get
    When method get
    When method get
    When method get
    Then status 429
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    And assert responseHeaders['Content-Type'][0]=='application/json'
    And assert response.success==false
    * match response == {success: false, errorMessage: 429, retryAfter: #number}

    When method post
    Then status 429
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    And assert responseHeaders['Content-Type'][0]=='application/json'
    And assert response.success==false
    * match response == {success: false, errorMessage: 429, retryAfter: #number}

    * sleep(2000)


    Given url ur+'v3/voicevox/speakers_array'
    When method get
    Then status 200
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    And assert responseHeaders['Content-Type'][0]=='application/json'

    When method get
    Then status 429
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    And assert responseHeaders['Content-Type'][0]=='application/json'

    Given url ur+'v3/voicevox/speakers_array'
    And params {key: #(key)}
    When method get
    Then status 200
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    And assert responseHeaders['Content-Type'][0]=='application/json'

    Given url ur+'v3/voicevox/speakers_array'
    When method get
    Then status 429
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    And assert responseHeaders['Content-Type'][0]=='application/json'

    * sleep(2000)



  Scenario: create audio
    * def expectedResponse = 
"""
{
    "success": true,
    "isApiKeyValid": true,
    "speakerName": #string,
    "audioStatusUrl": #string,
    "wavDownloadUrl": #string,
    "mp3DownloadUrl": #string,
    "mp3StreamingUrl": #string
} 
"""

    * def expectedStatusResponse = 
"""
{
    "success": true,
    "isAudioReady": #boolean,
    "isAudioError": #boolean,
    "status": #string,
    "speaker": #number,
    "audioCount": #number,
    "updatedTime": #number
} 
"""

    Given url ur+'v3/voicevox/synthesis'
    And params {text: #(text), key: #(key)}
    When method get
    Then status 200
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    And assert responseHeaders['Content-Type'][0]=='application/json'
    * match response == expectedResponse
    * def getResponse = response

    * sleep(1000*canTakeUpTo)

    Given url ur+'v3/voicevox/synthesis'
    And header Content-Type = 'application/x-www-form-urlencoded'
    And form fields {text: #(text), key: #(key)}
    When method post
    Then status 200
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    And assert responseHeaders['Content-Type'][0]=='application/json'
    * match getResponse == response

    * sleep(1000*canTakeUpTo)

    Given url ur+'v3/voicevox/synthesis'
    And params {text: #(text), key: #(key), speaker: 1}
    When method get
    Then status 200
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    And assert responseHeaders['Content-Type'][0]=='application/json'
    * match response == expectedResponse
    * match getResponse != response
    * def getResponse = response

    * sleep(1000*canTakeUpTo)

    Given url ur+'v3/voicevox/synthesis'
    And params {speaker: 1}
    And header Content-Type = 'application/x-www-form-urlencoded'
    And form fields {text: #(text), key: #(key)}
    When method post
    Then status 200
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    And assert responseHeaders['Content-Type'][0]=='application/json'
    * match getResponse == response
    * def audioStatusUrl = response.audioStatusUrl
    * def wavDownloadUrl = response.wavDownloadUrl
    * def mp3DownloadUrl = response.mp3DownloadUrl

    * sleep(1000*canTakeUpTo)

    Given url audioStatusUrl
    When method get
    Then status 200
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    And assert responseHeaders['Content-Type'][0]=='application/json'
    * match response == expectedStatusResponse

    Given url wavDownloadUrl
    When method get
    Then status 200
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    And assert responseHeaders['Content-Type'][0]=='audio/x-wav'

    Given url mp3DownloadUrl
    When method get
    Then status 200
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    And assert responseHeaders['Content-Type'][0]=='audio/mpeg'

    Given url ur+'v3/voicevox/synthesis'
    And params {text: #(text), speaker: -1}
    When method get
    Then status 400
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    And assert responseHeaders['Content-Type'][0]=='application/json'
    * match response == {"success":false,"isApiKeyValid":false,"errorMessage":"invalidSpeaker"}

    * sleep(2000)


  Scenario: api points
    * def expectedGenerateResponse = 
"""
{
    "success": true,
    "isApiKeyValid": true,
    "cost": #number,
    "key": #string
} 
"""
    * def expectedPointsResponse = 
"""
{
    "success": true,
    "isApiKeyValid": true,
    "points": #number
} 
"""

    Given url ur+'v3/key/generate'
    And params {points: 40, time: 60, key: #(key)}
    When method get
    Then status 200
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    And assert responseHeaders['Content-Type'][0]=='application/json'
    * match response == expectedGenerateResponse
    * def subKey = response.key

    * sleep(2000)

    Given url ur+'v3/key/points'
    And params {key: #(subKey)}
    When method get
    Then status 200
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    And assert responseHeaders['Content-Type'][0]=='application/json'
    * match response == expectedPointsResponse
    * match response.points == 39

    * sleep(2000)

    Given url ur+'v3/voicevox/synthesis'
    And params {text: "a", key: #(subKey)}
    When method get
    Then status 200
    And assert response.isApiKeyValid == true

    * sleep(2000)

    Given url ur+'v3/key/points'
    And params {key: #(subKey)}
    When method get
    Then status 200
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    And assert responseHeaders['Content-Type'][0]=='application/json'
    * match response == expectedPointsResponse
    * match response.points == 28

    * sleep(2000)

    Given url ur+'v3/voicevox/synthesis'
    And params {text: "aeiou,あいうえお。12 34", key: #(subKey)}
    When method get
    Then status 200
    And assert response.isApiKeyValid == true

    * sleep(2000)

    Given url ur+'v3/key/points'
    And params {key: #(subKey)}
    When method get
    Then status 200
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    And assert responseHeaders['Content-Type'][0]=='application/json'
    * match response == expectedPointsResponse
    * match response.points == 10

    * sleep(2000)

    Given url ur+'v3/voicevox/synthesis'
    And params {text: "1234567890...", key: #(subKey)}
    When method get
    Then status 200
    And assert response.isApiKeyValid == false

    * sleep(4000)

    Given url ur+'v3/key/points'
    And params {key: #(subKey)}
    When method get
    Then status 200
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    And assert responseHeaders['Content-Type'][0]=='application/json'
    * match response == {"success":true,"isApiKeyValid":false,"points":0}
