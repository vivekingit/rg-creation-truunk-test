resource_group_name = "rg-application-production"
location            = "eastus"
environment         = "production"
enable_nsg          = true

# Allowed IP ranges for NSG rules
# Update these with your actual IP ranges
allowed_ip_ranges = [
  "10.0.0.0/8",      # Internal network
  "172.16.0.0/12",   # Internal network
  # Add your specific public IP ranges here
]

tags = {
  Project            = "Application-X"
  CostCenter         = "Production"
  Owner              = "SRE-TeamB"
  Compliance         = "Required"
  BackupPolicy       = "Daily"
  DisasterRecovery   = "Enabled"
}
