---
title: Docker and Compose
type: reference
status: active
updated: 2026-09-07
summary: hadolint, image pinning, and keeping secrets out of images and compose files.
---

# Docker and Compose

## Tooling

| Concern | Tool |
|---|---|
| Dockerfile lint | hadolint |
| Compose validation | `docker compose config` |

`docker compose config` runs before any deploy. It resolves interpolation and catches a
malformed file that would otherwise fail halfway through bringing a stack up.

## Images

- Pin to a specific tag. Never `latest` — it makes a deploy unreproducible and a rollback
  guesswork.
- Prefer a digest for anything security-relevant.
- Smallest base that works. Alpine only when the software actually supports musl.

## Secrets

- Never in a Dockerfile, never in `docker-compose.yml`, never in a build arg.
- `.env` is local-only and gitignored. Commit `.env.example` and update it whenever the
  variable shape changes, so a fresh checkout knows what it needs.
- A compose file in a repo mirrors a live deployment. Keep the mapping intact — a repo edit
  that breaks the path mapping breaks the deploy that depends on it.

## Compose conventions

- One service per concern.
- Named volumes for data, bind mounts for configuration.
- An explicit `restart:` policy on every service.
- Healthchecks on anything another service depends on, so `depends_on` means something.
