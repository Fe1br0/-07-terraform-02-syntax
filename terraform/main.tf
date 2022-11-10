terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  service_account_key_file = "key.json"
  cloud_id  = "b1g8fcq6eu1hm80n4trb"
  folder_id = "b1gfkdmlpe4oo3iq9fgm"
}


data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}

resource "yandex_vpc_network" "net" {
  name = "Netolgynet"
}

resource "yandex_vpc_subnet" "subnet" {
  name           = "Netologysubnet"
  network_id     = resource.yandex_vpc_network.net.id
  v4_cidr_blocks = ["192.168.101.0/24"]
  zone           = "ru-central1-a"
}

resource "yandex_compute_instance" "vm" {
  zone       = "ru-central1-a"
  name        = "newinstance"
  hostname    = "newinstance.local"
  platform_id = "standard-v1"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 100
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      type     = "network-hdd"
      size     = "20"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat       = true
    ipv6      = false
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
        