### Container App ###

variable "group_id" {
  type = string
}

variable "location" {
  type = string
}

variable "name" {
  type = string
}

variable "environment" {
  type = string
}

### Ingress ###

variable "external" {
  type    = bool
  default = true
}

variable "ingress_target_port" {
  type = number
}

### Dapr ###

variable "dapr_appId" {
  type = string
}

variable "dapr_appPort" {
  type = number
}

### Container ###

variable "container_image" {
  type = string
}

variable "container_envs" {
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}
