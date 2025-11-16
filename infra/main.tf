terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
  backend "gcs" {
    bucket = "storage-terraform-states"
    prefix = "digital-roots-lab-cloud-artemarca/terraform/state"
  }
}

provider "digitalocean" {
  token             = var.do_token
  spaces_access_id  = var.do_bucket_access_id
  spaces_secret_key = var.do_bucket_secret_key
}

resource "digitalocean_project" "project" {
  name        = "digital-roots-lab-cloud"
  description = "Cloud environment for Digital Roots Lab, providing registries, databases, and storage buckets for the company's software systems."
  purpose     = "Organization Infrastructure"
  environment = "Production"
}

# Registry
resource "digitalocean_container_registry" "registry" {
  name                   = "digital-roots-lab"
  subscription_tier_slug = "starter"
}

# Bucket
resource "digitalocean_spaces_bucket" "artemarca_bucket" {
  name   = "artemarca-bucket"
  region = "nyc3"
}

resource "digitalocean_spaces_bucket_cors_configuration" "artemarca_bucket_cors" {
  bucket = digitalocean_spaces_bucket.artemarca_bucket.name
  region = "nyc3"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST", "DELETE"]
    allowed_origins = ["https://artemarca.net"]
    max_age_seconds = 3000
  }
}

# Database
resource "digitalocean_database_cluster" "cluster_postgres_digital_roots_lab" {
  name       = "digital-roots-lab-postgres"
  engine     = "pg"
  version    = "15"
  size       = "db-s-1vcpu-1gb"
  region     = "nyc1"
  node_count = 1
}

resource "digitalocean_database_user" "cluster_user_artemarca" {
  cluster_id = digitalocean_database_cluster.cluster_postgres_digital_roots_lab.id
  name       = "artemarca"
}

resource "digitalocean_database_db" "database_artemarca" {
  cluster_id = digitalocean_database_cluster.cluster_postgres_digital_roots_lab.id
  name       = "artemarca"
}



resource "null_resource" "grant_artemarca_user_privileges" {
  depends_on = [
    digitalocean_database_db.database_artemarca,
    digitalocean_database_user.cluster_user_artemarca
  ]

  provisioner "local-exec" {
    command = <<-EOT
      PGPASSWORD='${digitalocean_database_cluster.cluster_postgres_digital_roots_lab.password}' psql \
        -h ${digitalocean_database_cluster.cluster_postgres_digital_roots_lab.host} \
        -p ${digitalocean_database_cluster.cluster_postgres_digital_roots_lab.port} \
        -U doadmin \
        -d ${digitalocean_database_db.database_artemarca.name} \
        -c "GRANT ALL PRIVILEGES ON DATABASE ${digitalocean_database_db.database_artemarca.name} TO ${digitalocean_database_user.cluster_user_artemarca.name};
        GRANT ALL PRIVILEGES ON SCHEMA public TO ${digitalocean_database_user.cluster_user_artemarca.name};
        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO ${digitalocean_database_user.cluster_user_artemarca.name};"
    EOT
  }
}
