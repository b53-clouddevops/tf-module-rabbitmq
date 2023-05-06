# Creates SPOT Servers
resource "aws_spot_instance_request" "rabbitmq" {
  ami                     = data.aws_ami.lab-image.id
  instance_type           = "t3.micro"
  subnet_id               = data.terraform_remote_state.vpc.outputs.PRIVATE_SUBNET_IDS[0]
  vpc_security_group_ids  = [aws_security_group.allow_rabbit.id]
  wait_for_fulfillment    = true
  iam_instance_profile    = "b53-admin"

  tags = {
    Name = "rabbitmq-${var.ENV}"
  }
}


# Installing RabbitMQ

resource "null_resource" "app" {

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = local.SSH_USERNAME
      password = local.SSH_PASSWORD
      host     = aws_spot_instance_request.rabbitmq.private_ip
      }

      inline = [
          "ansible-pull -U https://github.com/b53-clouddevops/ansible.git -e COMPONENT=rabbitmq -e ENV=dev robot-pull.yml"
        ]
    }
}