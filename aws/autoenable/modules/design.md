# Lambda Invocation Resource Comparison

## `sumologic_s3_logging_lambda_enable` vs `sumologic_async_aws_lambda_invocation`

| Feature | `sumologic_s3_logging_lambda_enable` | `sumologic_async_aws_lambda_invocation` |
|---------|--------------------------------------|----------------------------------------|
| Invocation type | `RequestResponse` (sync) | `Event` (async) |
| Blocking | Yes — blocks until Lambda completes | No — returns immediately with HTTP 202 |
| Purpose | Enable S3 logging for existing AWS resources | Fire-and-forget Lambda trigger (generic) |
| Payload structure | Fixed: `action`, `ResourceType`, `ResourceProperties`, `OldResourceProperties` | Raw JSON `input` passed as-is |
| CRUD lifecycle | Full — Create/Update/Delete all invoke Lambda with different `action` values | Create only — ForceNew on all attributes |
| Update behavior | Re-invokes with old + new `ResourceProperties` for Lambda-side diffing | No update — ForceNew triggers destroy+create |
| Delete behavior | Invokes Lambda with `delete` action to clean up logging config | No-op |
| State tracking | Stores `last_lambda_output` and `last_resource_properties` | Stores `status_code` (202) only |
| triggers | Not supported | ForceNew map — re-invokes on any change |
| aws_profile | Optional — uses named AWS profile for invocation | Optional (ForceNew) — uses named AWS profile for invocation |
| Use case | `s3_logging` module — manage S3 log enablement lifecycle | `loggroup` module — async scan of existing log groups |

## When to use which

- **`sumologic_s3_logging_lambda_enable`** — when the Lambda manages stateful config (create/update/delete S3 logging). Lambda needs to know the previous state to diff changes.
- **`sumologic_async_aws_lambda_invocation`** — when the Lambda is a one-shot scanner/processor that runs to completion in the background. No state to manage; re-run on config change via `triggers`.

---

## `aws_lambda_invocation` vs `sumologic_async_aws_lambda_invocation`

| Feature | `aws_lambda_invocation` | `sumologic_async_aws_lambda_invocation` |
|---------|------------------------|----------------------------------------|
| Invocation type | `RequestResponse` (sync) | `Event` (async) |
| Blocking | Yes — blocks until Lambda completes (up to 900s) | No — returns immediately with HTTP 202 |
| Response payload | Stored in `result` attribute | None (async has no payload) |
| Error detection | Catches Lambda runtime errors via `FunctionError` | Only catches submission errors; runtime errors invisible |
| AWS credentials | Provider's AWS client (`meta.(*conns.AWSClient)`) — inherits provider profile automatically | `aws_profile` attribute or default credential chain |
| aws_profile support | Inherits from `provider "aws"` block — no separate attribute needed | `aws_profile` optional attribute (ForceNew) |
| lifecycle_scope | `CREATE_ONLY` (default) or `CRUD` | N/A — always fire-on-create only |
| input | Required, JSON | Optional, default `"{}"`, JSON |
| qualifier | Optional, default `$LATEST` | Optional, default `$LATEST` |
| triggers | ForceNew map | ForceNew map |
| Update behavior | CRUD mode: re-invokes with old+new input | No update — ForceNew triggers destroy+create |
| Delete behavior | CRUD mode: invokes with `delete` action | No-op |
| State import | Supported | Not supported |
| Computed output | `result` (Lambda response JSON) | `status_code` (int, 202) |
| ID format | `{name}/{qualifier}/{md5(payload)}` | `{name}-{status_code}` |
| Provider | `hashicorp/aws` | `sumologic/sumologic` |

## Why `sumologic_async_aws_lambda_invocation`?

`aws_lambda_invocation` is synchronous-only (`InvocationType: RequestResponse`). The loggroup
auto-enable Lambda scans all existing log groups and can run for several minutes. Using
`aws_lambda_invocation` would block Terraform for that entire duration, potentially hitting
provider timeouts.

`sumologic_async_aws_lambda_invocation` uses `InvocationType: Event` — fire-and-forget.
Terraform gets an HTTP 202 immediately and moves on. The Lambda continues running in the
background independently.

## What was intentionally omitted vs `invocation.go`

| `invocation.go` feature | Our resource | Reason omitted |
|---|---|---|
| `SchemaVersion` + `StateUpgraders` | ✗ | No schema migrations needed |
| `Importer` | ✗ | Fire-and-forget has no importable state |
| `lifecycle_scope` (`CREATE_ONLY` / `CRUD`) | ✗ | Always fire-on-create; ForceNew handles re-invocation |
| `UpdateContext` | ✗ | All attrs are ForceNew — update path never runs |
| `tenant_id` attribute | ✗ | Not needed for Sumo Logic use case |
| `terraform_key` attribute | ✗ | Enriches payload with `tf.action`/`tf.prev_input` for stateful Lambdas — not needed for async |
| `buildInput()` — injects action metadata into payload | ✗ | Lambda receives raw `input` as-is |
| `FunctionError` check on response | ✗ | Async (`Event`) never returns a payload or function error |
| `result` computed attribute | ✗ | Async returns empty payload |
| MD5 hash in resource ID | ✗ | Simple `{function_name}-{status_code}` is sufficient |
| `CustomizeDiff` (3 functions) | ✗ | No CRUD/CREATE_ONLY distinction to validate |
| `meta.(*conns.AWSClient).LambdaClient(ctx)` | ✗ | Uses `aws_profile` attribute + `awsconfig.WithSharedConfigProfile` instead |

**What was kept from the pattern:** `function_name`, `input`, `qualifier`, `triggers` (ForceNew map), `ReadContext` no-op.

Our implementation is ~90 lines vs ~250 lines in `invocation.go`. The complexity in `invocation.go` exists entirely to support CRUD lifecycle management, which has no meaning for async fire-and-forget.

## Trigger-based re-invocation

Because all attributes are `ForceNew: true`, changing any `triggers` value causes Terraform
to destroy + recreate the resource, which re-fires the Lambda. This is the correct pattern
for provisioning-style operations like "scan existing log groups and subscribe them".

```hcl
resource "sumologic_async_aws_lambda_invocation" "loggroup_trigger" {
  function_name = aws_lambda_function.sumo_log_group_existing_lambda_connector[0].function_name
  region        = data.aws_region.current.name
  aws_profile   = var.aws_cli_profile

  triggers = {
    destination_arn = var.destination_arn
    filter          = var.filter_expression
  }
}
```
