data "local_file" "alpine_stackscript" {
    filename = "${path.root}/../bin/alpine-util"
}
resource "linode_stackscript" "alpine_stackscript" {
  label = "alpine-util"
  description = "Creates bash utility functions suitable for Alpine ash"
  script = data.local_file.alpine_stackscript.content
  images = [local.linode_default_image]
  rev_note = "v26"
}
