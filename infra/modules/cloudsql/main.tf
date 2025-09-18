# A random password for the database user
resource "random_password" "password" {
  length  = 16
  special = true
}

# A secret in GCP Secret Manager to hold the database credentials
resource "google_secret_manager_secret" "this" {
  project   = var.project
  secret_id = "${var.name}-db-creds"

  replication {
    automatic = true
  }

  labels = var.labels
}

# The version of the secret containing the actual password with the username
resource "google_secret_manager_secret_version" "this" {
  secret      = google_secret_manager_secret.this.id
  secret_data = jsonencode({
    username = var.username
    password = random_password.password.result
  })
}

# The main Cloud SQL instance
resource "google_sql_database_instance" "this" {
  name             = var.name
  project          = var.project
  region           = var.region
  database_version = var.database_version

  settings {
    tier = var.tier
    ip_configuration {
      ipv4_enabled    = false # Disables public IP
      private_network = var.network
    }
    user_labels = var.labels
  }

  # This ensures the private networking is set up before the instance is created
  depends_on = [var.service_networking_connection_dependency]
}

# A specific database within the instance
resource "google_sql_database" "database" {
  name     = var.db_name
  project  = var.project
  instance = google_sql_database_instance.this.name
}

# The master user for the database
resource "google_sql_user" "user" {
  name     = var.username
  project  = var.project
  instance = google_sql_database_instance.this.name
  password = random_password.password.result
}
