terraform {
  cloud {
    organization = "alpha_6"

    workspaces {
      name = "Dev"
    }
  }
}