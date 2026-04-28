# CLAUDE.md

## Project purpose
Software appliance configuration framework. Future config-session daemon for VyOS — owns the verify/generate/apply state machine, atomic commits, rollback, and protobuf IPC. Per the in-repo README: "VyConf is an early stage of development. It's incomplete and cannot be used yet." Production VyOS still uses the `vyos-1x` Python config layer that wraps `vyos1x-config` via `libvyosconfig`.

## Tech stack
- OCaml. `dune` build system, `opam` package manager (`vyconf.opam`, `dune-project`).
- License: LGPL-2.1-or-later WITH OCaml-LGPL-linking-exception.
- Build deps (`vyconf.opam`): `menhir`, `dune (>=1.4.0)`, `ocaml-protoc`, `ounit2`, `lwt (>=4.1.0)`, `lwt_ppx`, `lwt_log`, `fileutils`, `ppx_deriving`, `ppx_deriving_yojson`, `ocplib-endian`, `xml-light`, `toml`, `sha`, `pcre2`.

## Build / test / run
```
opam install . --deps-only
dune build -p vyconf
dune runtest         # ounit2 test suite under test/
```

## Repository layout
- `src/` — daemon source (lwt-based async I/O, protobuf IPC).
- `data/` — schema/config samples.
- `scripts/` — helper scripts.
- `test/` — `ounit2` unit tests.
- `architecture.md`, `README.md` — design docs.
- `dune-project`, `vyconf.opam` — build manifest.

## Cross-repo context
Sibling to `vyos/vyos1x-config` (the OCaml library that owns the actual config-tree data layer). `vyconf` is the daemon that will eventually own runtime config sessions on top of `vyos1x-config`. Currently the production runtime instead uses Python (`vyos-1x/python/vyos/configtree.py`) calling into `libvyosconfig0` (built from `vyos-1x/libvyosconfig/`, which wraps `vyos1x-config`). When `vyconf` lands, conf-mode/op-mode scripts in `vyos-1x` will talk to it via protobuf IPC.

## Conventions
- Commit/PR title: `component: T12345: description` (Phorge task ID at https://vyos.dev). Enforced by `vyos/.github` reusable.
- Default branch: `current`. Release-train branches: `current`, `circinus`, `sagitta`, `equuleus`.
- Mergify backports via `@Mergifyio backport <branch>`.
- OCaml core repos (this, `vyos1x-config`, `vyos-utils`) follow MIT/LGPL upstream norms.

## Mirror relationship
Mirror twin: `VyOS-Networks/vyconf` (mirror status not confirmed live in the gen-1 pipeline; treat `vyos/*` as canonical).

## Notes for future contributors
- This is pre-1.0 — APIs and IPC shapes are unstable. Coordinate any cross-repo changes with the `vyos-1x` and `vyos1x-config` maintainers.
- `dune subst` step (`["dune" "subst"] {pinned}`) only runs from a pinned/published opam install; vendored builds skip it.
- Architecture doc at `architecture.md` explains the verify/generate/apply phasing — read it before adding new commit semantics.

---

This file is mirrored on Confluence: [`vyos/vyconf`](https://internal.confluence.vyos.com/wiki/spaces/VYOS/pages/818184628). The Confluence page also carries the per-repo audit data (settings, workflows, secret counts, hygiene) that complements this CLAUDE.md. Edit either side; resync via the documentation pipeline.
