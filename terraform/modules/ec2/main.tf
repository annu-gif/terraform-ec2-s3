# IAM Role
resource "aws_iam_role" "this" {
  name = "ec2-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "s3" {
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["s3:GetObject", "s3:ListBucket"]
      Resource = [
        var.bucket_arn,
        "${var.bucket_arn}/*"
      ]
    }]
  })
}

resource "aws_iam_instance_profile" "this" {
  role = aws_iam_role.this.name
}

# Security Group
resource "aws_security_group" "this" {
  name = "web-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2
resource "aws_instance" "this" {
  ami                  = "ami-0c02fb55956c7d316"
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.this.name
  security_groups      = [aws_security_group.this.name]

  user_data = <<-EOF
              #!/bin/bash
              yum install -y httpd aws-cli
              systemctl start httpd
              systemctl enable httpd
              aws s3 sync s3://${var.bucket_name} /var/www/html
              EOF

  tags = {
    Name = "terraform-ec2-web"
  }
}

