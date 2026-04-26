# Test fixtures for KIRBY-INF-024 / EEDOM-AZ-002 — Azure NSG SSH Lockdown
# PASS: azurerm_network_security_rule with source_address_prefix restricted to a specific IP/service tag
# FAIL: azurerm_network_security_rule with source_address_prefix = "*" (any source)
#
# TFSEC LIMITATION: EEDOM-AZ-002 applies to all Allow inbound rules, not only port 22.
# Intentionally public ingress rules (e.g., HTTP/HTTPS load balancer front-ends using a
# service tag) should carry:
#   # tfsec-ignore:EEDOM-AZ-002

# --------------------------------------------------------------------------
# PASS cases
# --------------------------------------------------------------------------

# PASS: SSH restricted to a specific management IP range only
resource "azurerm_network_security_rule" "pass_ssh_restricted" {
  name                        = "allow-ssh-vpn"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "10.0.0.0/8" # PASS: restricted to internal network — satisfies EEDOM-AZ-002
  destination_address_prefix  = "*"
  resource_group_name         = "rg-example"
  network_security_group_name = "nsg-example"
}

# PASS: HTTPS allowed from AzureLoadBalancer service tag — not a wildcard
resource "azurerm_network_security_rule" "pass_https_service_tag" {
  name                        = "allow-https-lb"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "AzureLoadBalancer" # PASS: Azure service tag, not wildcard
  destination_address_prefix  = "*"
  resource_group_name         = "rg-example"
  network_security_group_name = "nsg-example"
}

# PASS: Deny rule with wildcard source — Deny rules are not a threat
resource "azurerm_network_security_rule" "pass_deny_all" {
  name                        = "deny-all-inbound"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*" # PASS: Deny rule — tfsec evaluates access=Allow only for EEDOM-AZ-002
  destination_address_prefix  = "*"
  resource_group_name         = "rg-example"
  network_security_group_name = "nsg-example"
}

# --------------------------------------------------------------------------
# FAIL cases
# --------------------------------------------------------------------------

# FAIL: SSH open to the entire internet — primary target of EEDOM-AZ-002
resource "azurerm_network_security_rule" "fail_ssh_wildcard" {
  name                        = "fail-allow-ssh-any"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*" # FAIL: unrestricted inbound — fails EEDOM-AZ-002
  destination_address_prefix  = "*"
  resource_group_name         = "rg-example"
  network_security_group_name = "nsg-example"
}

# FAIL: RDP open to the entire internet — equally dangerous
resource "azurerm_network_security_rule" "fail_rdp_wildcard" {
  name                        = "fail-allow-rdp-any"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*" # FAIL: unrestricted inbound — fails EEDOM-AZ-002
  destination_address_prefix  = "*"
  resource_group_name         = "rg-example"
  network_security_group_name = "nsg-example"
}
