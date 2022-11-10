provider "aws" {
    access_key = "AKIAXBMESHIKEYJEYBKG"
    secret_key = "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"
    region = "eu-central-1"
}

resource "aws_instance" "phonebook_instance" {
    ami = "ami-070b208e993b59cea"
    instance_type = "t2.micro"
}
