# Linkding Usage Tracking Overlay

This repository maintains an optional, per-user usage-tracking patch for
[Linkding](https://github.com/sissbruecker/linkding). It keeps the upstream
source repository untouched while producing a versioned custom Docker image.

Usage tracking is disabled by default. When enabled in General Settings,
bookmark visits are counted locally for the current user and bookmarks can be
sorted by **Most Used**.

## Version

- Upstream Linkding: `v1.46.2`
- Patch release: `usage.1`
- Docker image: `dafal/linkding:v1.46.2-usage.1`

## Local Build

Docker Buildx and Git are required.

```bash
./scripts/build.sh
```

Override the image name if needed:

```bash
IMAGE=example/linkding ./scripts/build.sh
```

## Deployment

Copy `compose.example.yaml`, configure the data directory and environment file,
then start the service with Docker Compose. Always back up the SQLite database
before moving an existing installation to a new upstream or patch version.

## Updating

1. Change `UPSTREAM_VERSION` to a new Linkding release tag.
2. Apply the existing patch to that release with `git apply --3way`.
3. Resolve upstream conflicts and regenerate `patches/usage-tracking.patch`.
4. Increment `PATCH_VERSION`.
5. Let CI validate tests, migrations, lint, and the Docker build.
6. Publish and deploy the new immutable image tag.

The production Compose configuration should use a versioned image tag, never
`latest`.
