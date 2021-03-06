provider "aws" {
  region = "eu-central-1"
}

module "digital-ocean" {
  source = "git::https://github.com/poseidon/typhoon//digital-ocean/container-linux/kubernetes?ref=c42139beaa1d14917b4b53e1c0597c637bde6266"

  # Digital Ocean
  cluster_name = "${var.cluster_name}"
  region       = "${var.digitalocean_region}"
  dns_zone     = "${var.dns_zone}"

  # configuration
  ssh_fingerprints = ["${var.ssh_fingerprint}"]
  asset_dir        = "${var.asset_dir}"

  # optional
  image        = "${var.os_image}"
  worker_count = "${var.worker_count}"
  worker_type  = "s-2vcpu-2gb"
}

module "workers" {
  source = "git::https://github.com/poseidon/typhoon//aws/container-linux/kubernetes/workers?ref=c42139beaa1d14917b4b53e1c0597c637bde6266"
  name   = "${var.cluster_name}"

  # AWS
  vpc_id          = "${aws_vpc.network.id}"
  subnet_ids      = aws_subnet.public.*.id
  security_groups = ["${aws_security_group.worker.id}"]
  worker_count    = "${var.gpu_worker_count}"
  instance_type   = "${var.gpu_worker_type}"
  os_image        = "${var.os_image}"
  target_groups   = var.worker_target_groups

  kubeconfig         = "${module.digital-ocean.kubeconfig-admin}"
  ssh_authorized_key = "${var.ssh_authorized_key}"
}
