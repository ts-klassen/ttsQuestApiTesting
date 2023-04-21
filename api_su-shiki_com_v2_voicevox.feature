Feature: testing v2 voicevox api

  Background:
    * def ur = 'https://api.su-shiki.com/'
    * url ur
    * def key = java.lang.System.getenv('TTSQUEST_API_KEY');
    * def sleep = function(millis){ java.lang.Thread.sleep(millis) }
    * sleep(3000)

  Scenario: get voicevox version
    Given url ur+'v2/voicevox\/'
    And params {key: #(key)}
    When method get
    Then status 200
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    And assert responseHeaders['Content-Type'][0]=='application/json'

  Scenario: get voicevox speakers
    Given url ur+'v2/voicevox/speakers\/'
    And params {key: #(key)}
    When method get
    Then status 200
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    And assert responseHeaders['Content-Type'][0]=='application/json'

  Scenario: get voicevox audio
    Given url ur+'v2/voicevox/audio\/'
    And params {key: #(key), text: 'こんにちは'}
    When method get
    Then status 200
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    And assert responseHeaders['Content-Type'][0]=='audio/x-wav'

# POST

  Scenario: post voicevox version
    Given url ur+'v2/voicevox\/'
    And header Content-Type = 'application/x-www-form-urlencoded'
    And form fields {key: #(key)}
    When method post
    Then status 200
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    And assert responseHeaders['Content-Type'][0]=='application/json'

  Scenario: post voicevox speakers
    Given url ur+'v2/voicevox/speakers/\/'
    And header Content-Type = 'application/x-www-form-urlencoded'
    And form fields {key: #(key)}
    When method post
    Then status 200
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    And assert responseHeaders['Content-Type'][0]=='application/json'

  Scenario: post voicevox audio
    Given url ur+'v2/voicevox/audio\/'
    And header Content-Type = 'application/x-www-form-urlencoded'
    And form fields {key: #(key), text: 'こんにちは'}
    When method post
    Then status 200
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    And assert responseHeaders['Content-Type'][0]=='audio/x-wav'

# speaker id

  Scenario: get voicevox audio
    Given path 'v2/voicevox/audio\/'
    And params {key: #(key), text: 'こんにちは', speaker: 1}
    When method get
    Then status 200
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    And assert responseHeaders['Content-Type'][0]=='audio/x-wav'

  Scenario: get voicevox audio
    Given url ur+'v2/voicevox/audio\/'
    And params {key: #(key), text: 'こんにちは', speaker: -1}
    When method get
    Then status 400
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    And assert responseHeaders['Content-Type'][0]=='application/json'

  # It will work for post because speaker param is only for get.
  Scenario: post voicevox audio
    Given url ur+'v2/voicevox/audio\/'
    And header Content-Type = 'application/x-www-form-urlencoded'
    And form fields {key: #(key), text: 'こんにちは', speaker: -1}
    When method post
    Then status 200
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    And assert responseHeaders['Content-Type'][0]=='audio/x-wav'

  Scenario: Access-Control-Allow-Origin on 403 and 404
    When method get
    Then status 403
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    When method post
    Then status 404
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    Given url ur+'notFound'
    When method get
    Then status 404
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    When method post
    Then status 404
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'

  Scenario: api point usage
    Given url ur+'v2/api\/'
    And params {key: #(key)}
    When method get
    Then status 200
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    And assert responseHeaders['Content-Type'][0]=='application/json'
    * def points = response.points
    * print points

    Given url ur+'v2/api\/'
    And params {key: #(key)}
    When method get
    Then status 200
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    And assert responseHeaders['Content-Type'][0]=='application/json'
    And assert points - response.points == 1500

    Given url ur+'v2/voicevox/audio\/'
    And params {key: #(key), text: 'こんにちは'}
    When method get
    Then status 200
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    And assert responseHeaders['Content-Type'][0]=='audio/x-wav'

    Given url ur+'v2/api\/'
    And params {key: #(key)}
    When method get
    Then status 200
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    And assert responseHeaders['Content-Type'][0]=='application/json'
    * print  points - response.points
    And assert points - response.points == 3*1500 + 300*5


  Scenario: not enough points
    Given url ur+'v2/voicevox\/'
    And params {key: notEnoughPoints}
    When method get
    Then status 403
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    And assert responseHeaders['Content-Type'][0]=='application/json'
    And assert response.errorMessage == "notEnoughPoints"

    Given url ur+'v2/voicevox/speakers\/'
    And params {key: notEnoughPoints}
    When method get
    Then status 403
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    And assert responseHeaders['Content-Type'][0]=='application/json'
    And assert response.errorMessage == "notEnoughPoints"

    Given url ur+'v2/voicevox/audio\/'
    And params {key: notEnoughPoints, text: 'こんにちは'}
    When method get
    Then status 403
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    And assert responseHeaders['Content-Type'][0]=='application/json'
    And assert response.errorMessage == "notEnoughPoints"

    Given url ur+'v2/api\/'
    And params {key: notEnoughPoints}
    When method get
    Then status 403
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    And assert responseHeaders['Content-Type'][0]=='application/json'
    And assert response.errorMessage == "notEnoughPoints"


  Scenario: invalid api key
    Given url ur+'v2/voicevox\/'
    And params {key: invalidApiKey}
    When method get
    Then status 403
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    And assert responseHeaders['Content-Type'][0]=='application/json'
    And assert response.errorMessage == "invalidApiKey"

    Given url ur+'v2/voicevox/speakers\/'
    And params {key: invalidApiKey}
    When method get
    Then status 403
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    And assert responseHeaders['Content-Type'][0]=='application/json'
    And assert response.errorMessage == "invalidApiKey"

    Given url ur+'v2/voicevox/audio\/'
    And params {key: invalidApiKey, text: 'こんにちは'}
    When method get
    Then status 403
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    And assert responseHeaders['Content-Type'][0]=='application/json'
    And assert response.errorMessage == "invalidApiKey"

    Given url ur+'v2/api\/'
    And params {key: invalidApiKey}
    When method get
    Then status 403
    And assert responseHeaders['Access-Control-Allow-Origin'][0]=='*'
    And assert responseHeaders['Content-Type'][0]=='application/json'
    And assert response.errorMessage == "invalidApiKey"
