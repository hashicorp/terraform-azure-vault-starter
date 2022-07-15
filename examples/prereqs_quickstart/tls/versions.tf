/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

terraform {
  required_version = ">= 1.2.1"

  required_providers {
    azurerm = ">=3.0"
    random  = ">=1.0"

    # tls = ">=1.0"
    # https://github.com/hashicorp/terraform-provider-tls/issues/205
    tls = {
      source  = "troyready/tls"
      version = "3.1.50"
    }
  }
}
