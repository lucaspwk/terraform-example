/* Setup our aws provider */
provider "aws" {
  access_key  = "${var.access_key}"
  secret_key  = "${var.secret_key}"
  region      = "${var.region}"
}
resource "aws_instance" "master" {
  ami           = "ami-cb5ae7af"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.swarm.name}"]
  key_name = "${var.key}"
  connection {
    user = "ubuntu"
    private_key = "${file("ssh/${var.key}.pem")}"
  }
  provisioner "file" {
    source = "proj"
    destination = "/home/ubuntu/"
  }
  provisioner "remote-exec" {
    inline = [
      # Install docker
      "sudo curl -fsSL https://get.docker.com | sh",
      # Install docker-compose
      "sudo curl -L https://github.com/docker/compose/releases/download/1.25.3/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose",
      # Init cluster Swarm
      "sudo docker swarm init",
      # Write token to be used by workers (slaves)
      "sudo docker swarm join-token --quiet worker > /home/ubuntu/token",
      "sudo chmod +x /usr/local/bin/docker-compose",
      "cd proj",
      # Build docker image
      "sudo docker-compose build",
      # Start cluster Swarm
      "sudo docker stack deploy --compose-file docker-compose.yml restapp",
    ]
  }
  tags = { 
    Name = "swarm-master"
  }
}

resource "aws_instance" "slave" {
  count         = 2
  ami           = "ami-cb5ae7af"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.swarm.name}"]
  key_name = "${var.key}"
  connection {
    user = "ubuntu"
    private_key = "${file("ssh/${var.key}.pem")}"
  }
  provisioner "file" {
    source = "${var.key}.pem"
    destination = "/home/ubuntu/${var.key}.pem"
  }
  provisioner "file" {
    source = "proj"
    destination = "/home/ubuntu/"
  }
  provisioner "remote-exec" {
    inline = [
      # Install docker
      "sudo curl -fsSL https://get.docker.com | sh",
      # Install docker-compose
      "sudo curl -L https://github.com/docker/compose/releases/download/1.25.3/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose",
      "sudo chmod 400 /home/ubuntu/${var.key}.pem",
      # Copy token file from master
      "sudo scp -o StrictHostKeyChecking=no -o NoHostAuthenticationForLocalhost=yes -o UserKnownHostsFile=/dev/null -i ${var.key}.pem ubuntu@${aws_instance.master.private_ip}:/home/ubuntu/token .",
      # Join workers in cluster Swarm
      "sudo docker swarm join --token $(cat /home/ubuntu/token) ${aws_instance.master.private_ip}:2377"
    ]
  }
  tags = { 
    Name = "swarm-${count.index}"
  }
}