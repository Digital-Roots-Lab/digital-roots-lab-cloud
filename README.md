# Digital Roots Lab — Cloud Environment

This repository defines the cloud infrastructure for **Digital Roots Lab**, using Terraform to manage and provision resources on DigitalOcean.

The environment includes:
- Container registry for application images  
- Databases for persistent data storage  
- Object storage buckets (Spaces) for application files and media  

---

## Requirements

- [Terraform](https://developer.hashicorp.com/terraform/downloads) ≥ 1.6  
- A [DigitalOcean account](https://cloud.digitalocean.com/registrations/new)  
- A Personal Access Token with `read` and `write` permissions  

## Terraform Variables

The following variables must be defined in your `terraform.tfvars` file or passed as environment variables.

| Variable | Description |
|-----------|-------------|
| `do_token` | DigitalOcean Personal Access Token used to authenticate Terraform requests. |
| `do_bucket_access_id` | Access ID for your DigitalOcean Spaces storage |
| `do_bucket_secret_key` | Secret Key paired with the Access ID, used to authenticate with Spaces. |

The last two variables can be retrieved or created under *Object Storage → Access Keys*