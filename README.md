# terraform-ibm-cloud-vpn-server-example
terraform configuration example for ibm cloud VPN server setup, and use this a reference implementation for vpn server terraform configuration

What will be done in this vpn-server terraform configuration example:
1. Create the IBM Cloud secrets manager instance with trial plan.
2. Generate the server certificate/key and client certificate/key locally, or generate the certificate/keys via private certificate capability in IBM secrets manager service.
3. Import the server/client certificate/key to secrets manager instance. For IBM secerts manager generated private certificate, please skip this step. 
4. Create one VPC and one subnet
5. Create one subnet
6. Create a security group with inbound and outbound rules to allow all traffics.
7. Create the VPN server within the subnet, security group, and server/client certificates in secerts manager instance.
8. Download the VPN client profile and configure the client certicate and key in the client profile.


# Run the configuration

## Export IBM Cloud API Key
export IBMCLOUD_API_KEY=<YOUR_IBM_CLOUD_API_KEY>

## Initialize the directory
This is only done once while you intialized your terraform directory.

`terraform init`


## Show the plan
`terraform plan`


## Apply the configuration
`terraform apply`