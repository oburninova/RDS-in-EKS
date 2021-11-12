variable "project" {
    default = "21b-centos"
}
variable "identifier" {
    default = "postgres"
    type = string
    description = "the name of the database instance"
}
variable "allocated_storage" {
    default = "20"
    type = number
    description = "allocted storage of the db instance"
}
variable "engine" {
    default = "postgres"
    type = string
    description = "specifies the engine type of the db"
}
variable "engine_version" {
    default = "9.6"
    type = number
    description = " the engine version of the db"
}
variable "instance_class" {
    default = "db.t2.micro"
    type = string
    description = " the instance class of the db"
}
variable "name" {
    default = "mydb"
    type = string
    description = "the name of the postgresdb"
}
variable "username" {
    default = "centos"
    type = string
    description = "the username to be use to login into the db"
}
variable "password" {
     default = "project21b"
     type = string
     description = "password of the db"
 }
variable "parameter_group_name" {
    default = "default.postgres9.6"
    type = string
    description = "the parameter group name of the db"
}
variable "skip_final_snapshot" {
    default = true
    type = bool
    description = "to prevent taking a snapshot of the db"
}
variable "multi_az" {
    default = true
    type = bool
    description = "to create a stanby db instance"
}

variable "port" {
    type        = string
    default     = "5432"
    description = "the port of the postgres db"
}
variable "storage_type" {
  type        = string
  default     = "gp2"
  description = "storage type of the db instance"
}
variable "apply_immediately" {
  type        = bool
  default     = "true"
  description = "to apply immediately"
}