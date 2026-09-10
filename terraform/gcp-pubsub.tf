resource "google_pubsub_topic" "snowpipe" {
  name = "${var.environment}-gcs-events"
}

resource "google_pubsub_subscription" "snowpipe" {
  name  = "${var.environment}-gcs-events-sub"
  topic = google_pubsub_topic.snowpipe.id
}

data "google_storage_project_service_account" "gcs_account" {
}

resource "google_pubsub_topic_iam_member" "gcs_publisher" {
  topic  = google_pubsub_topic.snowpipe.name
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"
}

resource "google_storage_notification" "snowpipe" {
  bucket         = var.gcp_bucket_name
  payload_format = "JSON_API_V1"
  topic          = google_pubsub_topic.snowpipe.id

  event_types = [
    "OBJECT_FINALIZE"
  ]

  depends_on = [
    google_pubsub_topic_iam_member.gcs_publisher
  ]
}

resource "snowflake_notification_integration" "gcp" {
  name    = upper("${var.environment}_GCS_PUBSUB_INT")
  enabled = true

  notification_provider        = "GCP_PUBSUB"
  gcp_pubsub_subscription_name = google_pubsub_subscription.snowpipe.id
}

resource "google_pubsub_subscription_iam_member" "snowflake_subscriber" {
  subscription = google_pubsub_subscription.snowpipe.name
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${snowflake_notification_integration.gcp.gcp_pubsub_service_account}"
}

resource "google_project_iam_member" "snowflake_monitoring_viewer" {
  project = var.gcp_project_id
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${snowflake_notification_integration.gcp.gcp_pubsub_service_account}"
}