resource "tls_private_key" "ca" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "ca" {
  private_key_pem       = tls_private_key.ca.private_key_pem
  validity_period_hours = 87600

  is_ca_certificate    = true
  set_authority_key_id = true
  allowed_uses         = ["cert_signing", "crl_signing"]

  subject {
    common_name  = "ibm.com"
    organization = "cloud"
  }
}

resource "tls_private_key" "client" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "client" {
  private_key_pem = tls_private_key.client.private_key_pem

  subject {
    common_name  = "client.ibm.com"
    organization = "Example"
  }
}

resource "tls_locally_signed_cert" "client" {
  cert_request_pem   = tls_cert_request.client.cert_request_pem
  ca_private_key_pem = tls_self_signed_cert.ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem

  validity_period_hours = 87600

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "key_agreement",
    "client_auth",
  ]
}

resource "tls_private_key" "server" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "server" {
  private_key_pem = tls_private_key.server.private_key_pem

  subject {
    common_name  = "server.ibm.com"
    organization = "Example"
  }
}

resource "tls_locally_signed_cert" "server" {
  cert_request_pem   = tls_cert_request.server.cert_request_pem
  ca_private_key_pem = tls_self_signed_cert.ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem

  validity_period_hours = 87600

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "key_agreement",
    "server_auth",
  ]
}

resource "local_file" "ca_cert" {
  content  = tls_self_signed_cert.ca.cert_pem
  filename = "import_certs/ca.pem"
}

resource "local_file" "client_key" {
  content  = tls_private_key.client.private_key_pem
  filename = "import_certs/client_key.pem"
}

resource "local_file" "client_cert" {
  content  = tls_locally_signed_cert.client.cert_pem
  filename = "import_certs/client_cert.pem"
}

resource "local_file" "server_key" {
  content  = tls_private_key.server.private_key_pem
  filename = "import_certs/server_key.pem"
}

resource "local_file" "server_cert" {
  content  = tls_locally_signed_cert.server.cert_pem
  filename = "import_certs/server_cert.pem"
}

resource "ibm_sm_imported_certificate" "sm_imported_certificate_server" {
  instance_id     = local.sec_mgr_id
  region          = var.region_name
  name            = "vpc_import_cert_server"
  description     = "VPC test imported certificate for server"
  labels          = ["my-imported-server"]
  secret_group_id = ibm_sm_secret_group.sm_secret_group.secret_group_id
  certificate     = tls_locally_signed_cert.server.cert_pem
  intermediate    = tls_self_signed_cert.ca.cert_pem
  private_key     = tls_private_key.server.private_key_pem
}

resource "ibm_sm_imported_certificate" "sm_imported_certificate_client" {
  instance_id     = local.sec_mgr_id
  region          = var.region_name
  name            = "vpc_import_cert_client"
  description     = "VPC test imported certificate for client"
  labels          = ["my-imported-client"]
  secret_group_id = ibm_sm_secret_group.sm_secret_group.secret_group_id
  certificate     = tls_locally_signed_cert.client.cert_pem
  intermediate    = tls_self_signed_cert.ca.cert_pem
  private_key     = tls_private_key.client.private_key_pem
}
