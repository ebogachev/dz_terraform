terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.84.0"
    }
  }
}
// Configure the Yandex.Cloud provider
provider "yandex" {
  token                    = "y0_AgAAAAAWwGszAATuwQAAAADXq32XRqeeKjFcQ4OUOoTVrkZbqP-jrVE"
  cloud_id                 = "b1gjhmfkuco0frulr7e6"
  folder_id                = "b1gfrqukuqmb1jiddbr8"
  zone                     = "ru-central1-a"
}

resource "yandex_compute_instance" "vm-test1" {
  name        = "test1"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8k5kam36qhmnojj8je" # ОС (Ubuntu, 20.04 LTS)
    }
  }

  network_interface {
    subnet_id = "e9b91jlodqkgqgrm2op0" # одна из дефолтных подсетей
    nat = true # автоматически установить динамический ip
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
