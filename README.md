# ttsQuestApiTesting
A Karate Testing for api.tts.quest

## Requisites
- Java 11
- karate-1.4.0.jar
But may work on other versions.

## Testing
First, export your tts.quest api key to your env.
```
export TTSQUEST_API_KEY='your_api_key'
```

To run the tests on bash, 
```
java -jar /path/to/karate-1.4.0.jar name_of.feature
```
where `name_of.feature` is the feature file and `/path/to/karate-1.4.0.jar` is the karate jar file. `karate-1.4.0.jar` can be found [here](https://github.com/karatelabs/karate/releases).

Recomend creating an alias.
```
alias karate='/usr/bin/java -jar /path/to/karate-1.4.0.jar'
```

Now you can simply run
```
karate name_of.feature
```

You might have to install Java Runtime Environment and give permittion to your jar file.
```
sudo apt install openjdk-11-jre-headless
chmod +x /path/to/karate-1.4.0.jar
```
