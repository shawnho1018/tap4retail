# TAP4Retail
目前這個專案下方包含2個子專案：

## guestbook-java
主要作為API Server實踐的Java Sample Code，基於Maven。裡面包含了監控JVM與產生Trace的相關機制。

## pubsub_sample
主要包含了此次Infrastucture的建置機制，Builder基於Gradle，以及基於PubSub數量而進行AutoScaling的機制。

## promo-evaluator

A sample prototype for implementing event-driven architecture with Spring Boot, Graalvm, Google Pub/Sub and MongoDb. 

Please run below command to pull this submodule
```
git submodule update --init --recursive
```

## spring-cloud-gcp

- The source code comes from https://github.com/GoogleCloudPlatform/spring-cloud-gcp
- https://github.com/GoogleCloudPlatform/spring-cloud-gcp/tree/main/spring-cloud-gcp-samples/spring-cloud-gcp-pubsub-sample 

## stress-tests
### Locust
這個專案介紹了Locust的分散式測試框架