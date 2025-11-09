data "aws_ami" "AMI_al2023" {
	most_recent = true
    owners = ["137112412989"]

	filter {
		name = "name"
		values = ["al2023-ami-2023*-x86_64"]
		}
}

resource "aws_instance" "word_list_ec2" {
	ami = data.aws_ami.AMI_al2023.id
	instance_type = "t3.micro"

	key_name = var.key_name
	vpc_security_group_ids = [aws_security_group.allow-ssh.id]
    subnet_id = aws_subnet.main.id

	iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

	user_data = <<-EOF
				#!/bin/bash
				set -e
				dnf update -y
				dnf install -y docker
				systemctl start docker
				systemctl enable docker
				usermod -aG docker ec2-user
				sleep 10
				docker pull jmicallef9/word-list-generator-ec2:latest
              EOF

	tags = {
		Name = "word_list_ec2"
		}
}