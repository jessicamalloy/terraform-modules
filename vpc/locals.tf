locals {
    /*
     * Based on the number of availability zones set flags used to create subnets.
     */
    build_public_b = var.number_of_azs == 1 ? 0 : 1
    build_public_c = var.number_of_azs == 3 ? 1 : 0
    build_private_a = var.create_private_subnets ? 1 : 0
    build_private_b = var.create_private_subnets && var.number_of_azs > 1 ? 1 : 0
    build_private_c = var.create_private_subnets && var.number_of_azs == 3 ? 1 : 0
    /*
     * Dynamically construct list of public subnets for output.
     */
    public_subnets_init = local.build_public_b == 1 ? [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b[0].id] : [aws_subnet.public_subnet_a.id]
    public_subnets = local.build_public_c == 1 ? concat(local.public_subnets_init, [aws_subnet.public_subnet_c[0].id]) : local.public_subnets_init
    /*
     * Dynamically construct list of private subnets for output.
     */
    private_subnets_init = var.create_private_subnets ? [aws_subnet.private_subnet_a[0].id] : []
    private_subnets_init_b = local.build_private_b == 1 ? concat(local.private_subnets_init, [aws_subnet.private_subnet_b[0].id]) : local.private_subnets_init
    private_subnets = local.build_private_c == 1 ? concat(local.private_subnets_init_b, [aws_subnet.private_subnet_c[0].id]) : local.private_subnets_init_b
}
