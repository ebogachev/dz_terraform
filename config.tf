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
      size     = 10
      type     = "network-hdd"
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
    provisioner "remote-exec" {
        inline = [
          "sudo apt update && sudo apt install -y default-jdk maven git",
          "git clone https://github.com/ebogachev/boxfuse.git",
          "cd boxfuse && mvn package",
          "git init && cp ./target/hello-1.0.war ./ && git add . && git commit -m 'test'",          
          "git push https://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@github.com/ebogachev/boxfuse.git"
        ]
        connection {
            host = self.network_interface.0.nat_ip_address
            type = "ssh"
            user = "ubuntu"
            private_key = "${file("~/.ssh/id_rsa")}"
        } 

    }  
}
resource "yandex_compute_instance" "vm-test2" {
  depends_on = [yandex_compute_instance.vm-test1] # запускаем задание после выполнения 1-го
  name        = "test2"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      size     = 10
      type     = "network-hdd"
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
    provisioner "remote-exec" {
        inline = [
          "sudo apt update && sudo apt install -y tomcat9 git",
          "git clone https://github.com/ebogachev/boxfuse.git",
          "sudo cp ./boxfuse/hello-1.0.war /var/lib/tomcat9/webapps/"
          
        ]
        connection {
            host = self.network_interface.0.nat_ip_address
            type = "ssh"
            user = "ubuntu"
            private_key = "${file("~/.ssh/id_rsa")}"
        } 

    }  
}
