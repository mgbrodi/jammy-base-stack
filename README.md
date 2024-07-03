# Paketo Jammy Base Stack

## What is a stack?
See Paketo's [stacks documentation](https://paketo.io/docs/concepts/stacks/).

## What is this stack for?
Ideal for:
- Java apps and .NET Core apps
- Go apps that require some C libraries
- Node.js/Python/Ruby/etc. apps **without** many native extensions

## How do I build multi-platform for "linux/amd64" and "linux/arm64" stack?

Check the help:
```
./create.sh -h
create.sh [OPTIONS]

Creates the stack using the descriptor, build and run Dockerfiles in
the repository.

OPTIONS
  --help       -h   prints the command usage
  --secret          provide a secret in the form key=value. Use flag multiple times to provide multiple secrets
  --registry        registry (ex: harbor.h2o-4-11809.h2o.vmware.com/paketo) use this to build multiplatform "linux/amd64" and "linux/arm64" to be published as harbor.h2o-4-11809.h2o.vmware.com/paketo/run-jammy-base:jammy" and harbor.h2o-4-11809.h2o.vmware.com/paketo/build-jammy-base:jammy"
```

Run:
`./create.sh --registry <YOUR REGISTRY>`
to create and push the multi-platform image to <YOUR REGISTRY>.

Verify the dual manifest:
```
skopeo inspect docker://<YOUR REGISTRY>build-jammy-base:jammy --raw | jq
skopeo inspect docker://<YOUR REGISTRY>run-jammy-base:jammy --raw | jq
```

To add support for more platforms modify `[build.args]` and `[run.args]` sections in `stack-multi-platform.toml` with the appropriate repository information.


To execute the provided tests for multi-platform images you need to test separately _for each archietcture_:
In the machine you currently built the image go ahead and run the test script.

Connect to a machine with the chipset you need to test. 
For the sake of the example let's assume you already tested on an _amd_ and now need to text on and _arm_.

```
git clone this repository (https://github.com/tanzu-build/jammy-base-stack.git)
cd jammy-base-stack
checkout multiplatform-amdarm
mkdir build
skopeo copy docker://<YOUR REGISTRY>/build-jammy-base:jammy oci-archive://<ABSOLUTE PATH TO YOUR build directory just created>/jammy-base-stack/skopeo/build.oci --override-arch arm64 --override-os linux
skopeo copy docker://<YOUR REGISTRY>/run-jammy-base:jammy oci-archive://<ABSOLUTE PATH TO YOUR build directory just created>/jammy-base-stack/skopeo/build.oci --override-arch arm64 --override-os linux
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
