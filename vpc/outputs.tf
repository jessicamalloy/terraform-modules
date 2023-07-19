
/*
 * Id of VPC.
 */
output "id" {
    value = aws_vpc.vpc.id
}

/*
 * Captures the final list of public subnets.
 */
output "public_subnets" {
    value = local.public_subnets
}

/*
 * Captures the final list of private subnets.
 */
output "private_subnets" {
    value = local.private_subnets
}

/*
 * Public subnet "a" id.
 */
output "public_subnet_a_id" {
    value = aws_subnet.public_subnet_a.id
}

/*
 * Public subnet "b" id.
 */
output "public_subnet_b_id" {
    value = local.build_public_b == 1 ? aws_subnet.public_subnet_b[0].id: null
}

/*
 * Public subnet "c" id.
 */
output "public_subnet_c_id" {
    value = local.build_public_c == 1 ? aws_subnet.public_subnet_c[0].id: null
}

/*
 * Private subnet "a" id.
 */
output "private_subnet_a_id" {
    value = local.build_private_a == 1 ? aws_subnet.private_subnet_a[0].id: null
}

/*
 * Private subnet "b" id.
 */
output "private_subnet_b_id" {
    value = local.build_private_b == 1 ? aws_subnet.private_subnet_b[0].id: null
}

/*
 * Private subnet "c" id.
 */
output "private_subnet_c_id" {
    value = local.build_private_c == 1 ? aws_subnet.private_subnet_c[0].id: null
}
