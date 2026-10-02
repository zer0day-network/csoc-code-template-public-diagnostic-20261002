# Service Template

Service-neutral repository baseline for CSOC GitHub Foundation.

This release is derived from the reviewed CI and infrastructure layout in
`csoc-foundation/csoc-monitor` at commit
`5b4d9894fe76faca8c5c4a4a4f9e0ac0564c5b3a`.
It does not contain the Monitor application, customer data, credentials, tenant
identifiers or preconfigured deployment destinations.

## Ownership Boundaries

The template supplies versioned files. CSOC GitHub Foundation creates the repository
and applies visibility, teams, environments and merge settings separately. AppZone
infrastructure is provisioned through reviewed platform PRs, never by generating
this repository.

Workload units and deployment workflows must be generated and reviewed for each
service. This initial release runs validation only and cannot deploy to Azure.
The `issues` repository profile remains empty and does not use this template.

## Validate

Requires PowerShell 7.4+ and OpenTofu 1.12.3 on PATH. Alternatively, pass
`-TofuPath` with the path to a verified OpenTofu executable.

```powershell
./Test-ServiceTemplate.ps1
```

The validation workflow also runs PowerShell static analysis, HCL formatting checks
and GitHub Actions security analysis. It has read-only repository permissions and
does not receive cloud credentials.

## Release Contract

The template default branch and release tag must identify the same approved commit.
GitHub's template-generation API copies the default branch, not an arbitrary tag.
The factory verifies the immutable repository ID and commit before generation,
then checks that the generated Git tree matches the approved release.

Freeze this repository at its released commit. Prepare the next release in a new
versioned template repository so existing pins remain usable. Do not move release
tags. Changes to `.factory-template.json` require the same review as executable files.

The initial template is private. Public generation requires separate explicit
approval in the factory's template profile as well as the requester's acknowledgement.