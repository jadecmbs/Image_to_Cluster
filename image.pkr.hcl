packer {
  required_plugins {
    docker = {
      version = ">= 1.0.8"
      source  = "github.com/hashicorp/docker"
    }
  }
}

source "docker" "nginx_custom" {
  image  = "nginx:latest"
  commit = true
}

build {
  name = "my-custom-nginx"
  sources = [
    "source.docker.nginx_custom"
  ]

   provisioner "file" {
    source      = "index.html"
    destination = "/usr/share/nginx/html/index.html"
  }

  # On peut ajouter des commandes (optionnel)
  provisioner "shell" {
    inline = ["chmod 644 /usr/share/nginx/html/index.html"]
  }

  # On donne un nom à l'image finale
  post-processor "docker-tag" {
    repository = "my-nginx-image"
    tag        = ["latest"]
  }
}
