data "local_file" "alpine_util" {
    filename = "${path.root}/../bin/alpine-util"
}
resource "linode_stackscript" "alpine_util_stackscript" {
  label = "alpine-util"
  description = "Creates bash utility functions suitable for Alpine ash"
  script = data.local_file.alpine_util.content
  images = [local.linode_default_image]
  rev_note = "v27"
}
output "util_stackscript_id" {
  value = linode_stackscript.alpine_util_stackscript.id
}
