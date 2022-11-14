# resource "aws_cloudformation_stack" "phonebook" {
#   name = "phonebook"
#   parameters = {
#     VpcId = aws_vpc.my_vpc.id
#   }
#   template_body = data.http.phonebook.response_body
# }

# data "http" "phonebook" {
#   url = "https://raw.githubusercontent.com/aws-samples/simple-phonebook-web-application/master/CloudFormation.yaml"
# }