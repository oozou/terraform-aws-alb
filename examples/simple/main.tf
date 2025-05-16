module "alb" {

  source = "../.."

  # Generics
  prefix = var.prefix
  environment = var.environment
  name = var.name
  tags = var.tags

  vpc_id                       = var.vpc_id
  public_subnet_ids            = var.subnet_ids
  is_public_alb                = true
  is_create_alb_security_group = true

}
