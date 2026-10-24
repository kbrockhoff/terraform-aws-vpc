# Changelog

## [0.2.0](https://github.com/kbrockhoff/terraform-aws-vpc/compare/v0.1.0...v0.2.0) (2026-10-24)


### ⚠ BREAKING CHANGES

* **cost-estimation:** modules/pricing is now modules/cost-estimation with quantity inputs and only monthly_cost_estimate and cost_breakdown outputs. cost_breakdown keys change: nat_gateway_fixed -> nat_gateway_hours, interface_endpoints_fixed -> interface_endpoint_hours, interface_endpoints_data -> interface_endpoint_data; gateway_endpoints is removed; public_ipv4_addresses and transit_gateway_attachment_hours are added.
* **deployer:** modules/bootstrap is removed, along with its role, github_org, github_repo, environment and state backend inputs and its role and policy outputs. Cut over in this order: apply terraform-aws-cicdrole and modules/deployer with iam_role_name = module.<cicdrole>.role_name; point the pipeline at the <name_prefix>-cicd-deployer role and confirm a plan; then remove the old bootstrap module, which destroys the <name_prefix>-github-actions role.

### Bug Fixes

* **dependencies:** skip CKV_AWS_394 on the availability zones lookup ([5f671d9](https://github.com/kbrockhoff/terraform-aws-vpc/commit/5f671d9972be1a72db1f1f4651dac6d7329f9633))
* **deployer:** stop retagging foreign KMS keys into the module's scope ([46bd148](https://github.com/kbrockhoff/terraform-aws-vpc/commit/46bd1483fc6903a11746f2ba7572fe8cf6a35f17))
* **security-group:** use a parenthesized tag key instead of interpolation ([55ddc90](https://github.com/kbrockhoff/terraform-aws-vpc/commit/55ddc906a3d845d8949f1cd9a158e7aa92b02822))
* **vscode:** point agent instruction settings at root AGENTS.md ([58f13e6](https://github.com/kbrockhoff/terraform-aws-vpc/commit/58f13e647e17b43e24f457729d825424f703a597))


### Code Refactoring

* **cost-estimation:** replace pricing submodule with cost-estimation ([06ebee0](https://github.com/kbrockhoff/terraform-aws-vpc/commit/06ebee0b62130946042a611446327024decdb3ed))
* **deployer:** replace bootstrap submodule with deployer policies ([edd69db](https://github.com/kbrockhoff/terraform-aws-vpc/commit/edd69dbbc5184ffc7e036b6d61df56b7d8a35d95))

## 0.1.0 (2025-08-13)


### Features

* add configurable vpc network tags and improve module quality ([6a3ba60](https://github.com/kbrockhoff/terraform-aws-vpc/commit/6a3ba600067981c9f56c6bad3dfeb9b6543af1e6))
* add private and IPAM examples with comprehensive testing ([7babeec](https://github.com/kbrockhoff/terraform-aws-vpc/commit/7babeec625bc83ea66daaf221b3fd0e816aad266))


### Bug Fixes

* add Terraform module cleanup step before running tests ([9ee87b0](https://github.com/kbrockhoff/terraform-aws-vpc/commit/9ee87b02ac614786f4f901af9fc919091ebcb299))
* **examples:** ensure complete example uses all defined variables ([35fffa7](https://github.com/kbrockhoff/terraform-aws-vpc/commit/35fffa754fe809fe8ab482cfbb3811f52687882f))
* remove duplicate IAM policies in bootstrap submodule ([1fe01a5](https://github.com/kbrockhoff/terraform-aws-vpc/commit/1fe01a58c575092865beaabfd9dd58aac07b942e))
* remove unused variable declarations in modules ([83df3ab](https://github.com/kbrockhoff/terraform-aws-vpc/commit/83df3ab8ad664ea4237463866ca4a1bcc42313ae))
* remove unused variable declarations in modules ([1e906e9](https://github.com/kbrockhoff/terraform-aws-vpc/commit/1e906e94c2379c5a4a4ae559c7eabd00033f1dd7))
* resolve terraform validation errors ([2c082e1](https://github.com/kbrockhoff/terraform-aws-vpc/commit/2c082e14da23da124dbc9a1ee200dbb544db38a5))
* simplify availability zone handling in module ([4b2c7c1](https://github.com/kbrockhoff/terraform-aws-vpc/commit/4b2c7c1859db971729b13ffacce5cf105f567ef9))
* **test:** update test expectations for VPC resources ([253d99a](https://github.com/kbrockhoff/terraform-aws-vpc/commit/253d99ac2f74b16c52eb54a922b4fff816527f7b))
* update go module name and add Terraform init for examples in CI ([eb459e7](https://github.com/kbrockhoff/terraform-aws-vpc/commit/eb459e75ef5d86764266d068dfb141189a843024))
* update IAM policy resources to use specific ARNs instead of wildcards ([2f60ae2](https://github.com/kbrockhoff/terraform-aws-vpc/commit/2f60ae283b71c12b904201e2e7fa0ae6a2b67421))

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
