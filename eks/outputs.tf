output "cluster_name" {
  description = "Cluster Name"
  value       = aws_eks_cluster.test_cluster.name
}

output "cluster_endpoint" {
  description = "Cluster Endpoint"
  value       = aws_eks_cluster.test_cluster.endpoint
}