data "local_file" "alpine_nginx" {
    filename = "${path.root}/../bin/alpine-nginx"
}
resource "linode_stackscript" "alpine_nginx_stackscript" {
  label = "alpine-nginx"
  description = "Functions to install Nginx suitable for Alpine ash"
  script = data.local_file.alpine_nginx.content
  images = [local.linode_default_image]
  rev_note = "v8"
}
output "nginx_stackscript_id" {
  value = linode_stackscript.alpine_nginx_stackscript.id
}
