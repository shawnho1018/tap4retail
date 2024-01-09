locals {
  create_trigger_cmd="gcloud builds triggers create cloud-source-repositories --name restful --region asia-east1 --branch-pattern=main --build-config=cloudbuild.yaml"
  delete_trigger_cmd="gcloud builds triggers delete cloud-source-repositories --quiet restful"
}
resource "google_sourcerepo_repository" "momo-repo" {
  name = "momo-repository"
}
resource "null_resource" "create-trigger" {
  depends_on = [google_sourcerepo_repository.momo-repo]
  triggers = {
    create_trigger_cmd = local.create_trigger_cmd
    #delete_trigger_cmd = local.delete_trigger_cmd
    region = var.gcp_region
    repo = google_sourcerepo_repository.momo-repo.name
  }
  provisioner "local-exec" {
    when = create
    command = "${self.triggers.create_trigger_cmd} --region ${self.triggers.region} --repo ${self.triggers.repo}"
  }
  provisioner "local-exec" {
    when = destroy
    command = "${self.triggers.delete_trigger_cmd}"
  }
}
# resource "terraform_data" "create-trigger" {
#   # Defines when the provisioner should be executed
#   triggers_replace = [
#     # The provisioner is executed then the `id` of the EC2 instance changes
#     google_sourcerepo_repository.momo-repo.id
#   ]

#   provisioner "local-exec" {
#     command = local.create_trigger_cmd
#   }
# }