variable "storage_driver_name" {
    default = "solidfire-san"
}

variable "username" {
  
}

variable "password" {
  
}

variable "svm" {
  
}

variable "managementLIF" {
  
}

variable "dataLIF" {
  
}


variable "inventory_file_contents" {
  
}

variable "ansible_user" {
  
}


variable "ansible_password" {
  
}

variable "dependency" {
  description = "output from parent module (for dependency)"
  default = ""
}

variable "s3_region" {
  default = "us-west-2"
}

variable "s3_bucket" {

}

variable "s3_key" {
  
}