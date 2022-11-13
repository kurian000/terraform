variable "cidr_block" {
    type = list (string)
    default = [ "172.20.0.0/16","172.20.10.0/24" ] 
}
variable "ports" {
    type = list (number)
    default = [ 22,80,8080,8081,443,10248,6443]
  
}
variable "ami" {
    type=string
    default = "ami-0b614a5d911900a9b"
}
variable "instance_type" {
  type=string
  default = "t2.medium"
}