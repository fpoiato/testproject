variable "aws_region" {
  description = "Regiao AWS (CloudFront exige certificados ACM em us-east-1)"
  type        = string
  default     = "us-east-1"
}

variable "production_live_color" {
  description = "Cor ativa do blue/green de producao (qual alias/distribuicao o app. usa)"
  type        = string
  default     = "blue"
  validation {
    condition     = contains(["blue", "green"], var.production_live_color)
    error_message = "production_live_color deve ser blue ou green"
  }
}

variable "github_owner" {
  description = "Owner do repositorio GitHub"
  type        = string
  default     = "fpoiato"
}

variable "github_repo" {
  description = "Nome do repositorio GitHub"
  type        = string
  default     = "testproject"
}

variable "pipeline_alert_email" {
  description = "Email para alertas de falha de pipeline"
  type        = string
  default     = "nandopoiato@gmail.com"
}

variable "codebuild_log_retention_days" {
  description = "Retencao de logs (dias) dos CodeBuild"
  type        = number
  default     = 7
}
