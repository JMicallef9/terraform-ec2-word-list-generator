variable "bucket_name" {
    description = "S3 bucket name"
    type = string
}

variable "local_filepath" {
    description = "Local file to upload before EC2 runs"
    type = string
}

variable "input_key" {
    description = "S3 key for uploaded input file"
    type = string
}

variable "key_name" {
    description = "Name of EC2 .pem key"
    type = string
}

variable "local_key_path" {
    description = "Path to the local SSH .pem key"
    type = string
    default = "~.ssh/${var.key_name}.pem"
}