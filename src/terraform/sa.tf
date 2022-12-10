resource "yandex_iam_service_account" "ig-sa" {
  name        = "ig-sa"
  description = "service account to manage IG"
}

resource "yandex_resourcemanager_folder_iam_binding" "editor" {
  folder_id = var.yandex_folder_id
  role      = "editor"
  members = [
    "serviceAccount:${yandex_iam_service_account.ig-sa.id}",
  ]
  depends_on = [
    yandex_iam_service_account.ig-sa,
  ]
}