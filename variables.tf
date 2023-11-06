variable "vpc_cidr" {
    default = "10.0.0.0/16"  
}
variable "public_sub1_cidr" {
    default = "10.0.1.0/24"  
}
variable "public_sub2_cidr" {
    default = "10.0.2.0/24"  
}
variable "private_sub_cidr" {
    default = "10.0.3.0/24"  
}
variable "ami" {
    default = "ami-05caa5aa0186b660f"  
}
variable "instance_type" {
    default = "t2.micro"  
}