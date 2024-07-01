# Paketo Jammy Base Stack

## What is a stack?
See Paketo's [stacks documentation](https://paketo.io/docs/concepts/stacks/).

## What is this stack for?
Ideal for:
- Java apps and .NET Core apps
- Go apps that require some C libraries
- Node.js/Python/Ruby/etc. apps **without** many native extensions

## How do I uild multi-platform stack?

Chech the help:
```
./create.sh -h
create.sh [OPTIONS]

Creates the stack using the descriptor, build and run Dockerfiles in
the repository.

OPTIONS
  --help       -h   prints the command usage
  --secret          provide a secret in the form key=value. Use flag multiple times to provide multiple secrets
  --registry        registry (ex: harbor.h2o-4-11809.h2o.vmware.com/tanzubuild) use this to build multiplatform "linux/amd64" and "linux/arm64" to be published as ${REGISTRY}/paketo/run-jammy-base:jammy" and ${REGISTRY}/paketo/build-jammy-base:jammy"
```
## What's in the build and run images of this stack?
This stack's build and run images are based on Ubuntu Jammy Jellyfish.

- To see the **list of all packages installed** in the build or run image for a given release,
see the `jammy-base-stack-{version}-build-receipt.cyclonedx.json` and 
`jammy-base-stack-{version}-run-receipt.cyclonedx.json` attached to each
[release](https://github.com/paketo-buildpacks/jammy-base-stack/releases). For a quick overview
of the packages you can expect to find, see the [stack descriptor file](stack/stack.toml).

- To generate a package receipt based on existing `build.oci` and `run.oci` archives, use [`scripts/receipts.sh`](scripts/receipts.sh).

## How can I contribute?
Contribute changes to this stack via a Pull Request. Depending on the proposed changes,
you may need to [submit an RFC](https://github.com/paketo-buildpacks/rfcs) first.

### How do I test the stack locally?
Run [`scripts/test.sh`](scripts/test.sh).
