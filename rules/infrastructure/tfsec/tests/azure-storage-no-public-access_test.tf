# Test fixtures for KIRBY-INF-023 / EEDOM-AZ-001 — Azure Storage Public Access Disabled
# PASS: azurerm_storage_account with allow_nested_items_to_be_public = false
# FAIL: azurerm_storage_account with allow_nested_items_to_be_public = true or attribute omitted

# --------------------------------------------------------------------------
# PASS cases
# --------------------------------------------------------------------------

# PASS: public access explicitly disabled (AzureRM provider v3+ attribute)
resource "azurerm_storage_account" "pass_public_access_disabled" {
  name                     = "passstorage001"
  resource_group_name      = "rg-example"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  allow_nested_items_to_be_public = false # PASS: public blob access disabled — satisfies EEDOM-AZ-001

  tags = {
    Environment = "production"
  }
}

# PASS: public access disabled on a storage account with HTTPS-only and min TLS
resource "azurerm_storage_account" "pass_hardened" {
  name                     = "passstorage002"
  resource_group_name      = "rg-example"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "GRS"

  allow_nested_items_to_be_public = false # PASS: public access disabled
  enable_https_traffic_only       = true
  min_tls_version                 = "TLS1_2"

  tags = {
    Environment = "production"
  }
}

# --------------------------------------------------------------------------
# FAIL cases
# --------------------------------------------------------------------------

# FAIL: public access explicitly enabled — blobs in any public container are world-readable
resource "azurerm_storage_account" "fail_public_access_enabled" {
  name                     = "failstorage001"
  resource_group_name      = "rg-example"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  allow_nested_items_to_be_public = true # FAIL: public blob access enabled — fails EEDOM-AZ-001

  tags = {
    Environment = "staging"
  }
}

# FAIL: attribute omitted — AzureRM provider v3+ defaults allow_nested_items_to_be_public to true
resource "azurerm_storage_account" "fail_public_access_omitted" {
  name                     = "failstorage002"
  resource_group_name      = "rg-example"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  # allow_nested_items_to_be_public omitted — defaults to true in AzureRM v3+, fails EEDOM-AZ-001

  tags = {
    Environment = "staging"
  }
}
