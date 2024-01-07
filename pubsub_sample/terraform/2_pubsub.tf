resource "google_pubsub_topic" "demo" {
  name = "demo-topic"
}

resource "google_pubsub_subscription" "demo" {
  name  = "demo-subscription"
  topic = google_pubsub_topic.demo.name

  ack_deadline_seconds = 300
  message_retention_duration = "600s"

}