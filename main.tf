# create vpc
module "n_vpc" {
  source                         = "../modules/vpc" # specifying path to your vpc module, then list all variables below
  region                         = var.region
  project_name                   = var.project_name
  vpc_cidr                       = var.vpc_cidr
  public_subnet_az1_cidr         = var.public_subnet_az1_cidr
  public_subnet_az2_cidr         = var.public_subnet_az2_cidr
  private_app_subnet_az1_cidr    = var.private_app_subnet_az1_cidr
  private_app_subnet_az2_cidr    = var.private_app_subnet_az2_cidr
  private_data_subnet_az1_cidr   = var.private_data_subnet_az1_cidr
  private_data_subnet_az2_cidr   = var.private_data_subnet_az2_cidr
}


#  create nat gateways
module "nat_gateway" {
  source                        = "../modules/nat-gateway" 
  public_subnet_az1             =  module.n_vpc.public_subnet_az1
  internet_gateway              =  module.n_vpc.internet_gateway
  public_subnet_az2             =  module.n_vpc.public_subnet_az2
  vpc_id                        =  module.n_vpc.vpc_id
  private_app_subnet_az1        =  module.n_vpc.private_app_subnet_az1
  private_data_subnet_az1       =  module.n_vpc.private_data_subnet_az1
  private_app_subnet_az2        =  module.n_vpc.private_app_subnet_az2
  private_data_subnet_az2       =  module.n_vpc.private_data_subnet_az2
  }

# create security groups
module "security_group" {
  source                        = "../modules/security-groups" 
  vpc_id                        =  module.n_vpc.vpc_id
}

# create acm
module "acm" {
  source                        = "../modules/acm" 
  domain_name                   =  var.domain_name
  alternative_name              =  var.alternative_name
}


# create ecs tast execution role
#line 47, remember, we created the project name in the vpc module

module "ecs_task_execution_role" {
  source                        = "../modules/ecs-tasks-execution-role" 
  project_name                  =  module.n_vpc.project_name
}


module "alb" {
  source                        = "../modules/alb"
  project_name                  =  module.n_vpc.project_name
  alb_security_group_id         =  module.security_group.alb_security_group_id
  public_subnet_az1             =  module.n_vpc.public_subnet_az1
  public_subnet_az2             =  module.n_vpc.public_subnet_az2
  vpc_id                        =  module.n_vpc.vpc_id
  certificate_arn               =  module.acm.certificate_arn
}