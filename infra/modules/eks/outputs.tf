output "node_security_group_id" {
  description = "The ID of the security group attached to the EKS worker nodes."
  value       = aws_security_group.node_group.id
}
