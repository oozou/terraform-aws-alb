module "alb" {

  source = "../.."

  # Generics
  generics_info = var.generics_info

  vpc_id                       = var.vpc_id
  public_subnet_ids            = var.subnet_ids
  is_public_alb                = true
  is_create_alb_security_group = true

}
