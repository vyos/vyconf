vyconf
=======

**Note:** VyConf is an early stage of development and need your contributions!

VyConf is a software appliance configuration framework.

The maintainer pronounces it as "vyeconf", but it's up to you how to pronounce it.

We define software appliance as a set of an operating system, one or more applications,
and a high level interface for configuring and managing the system and applications.

Typical examples of software appliances in this sense are (VyOS)[http://vyos.io],
(OPNSense)[https://opnsense.org/], (Zentyal)[http://www.zentyal.org/] and others.

Typically they are seen as a way to improve ease of use, by providing a management interface
more convenient than editing the config files, and integrating different applications together.
However, largely missed and unexplored opportunity is using appliance approach to improve
reliability and robustness. And, making appliances the right way is hard since you have to
implement a lot of things from scratch.

VyConf tries to simplify this daunting task and allow appliance developers to focus on the
GUI frontend and the logic for generating application configs. It's being written primarily
for VyOS, but it's not locked into it, and not limited to routers or firewalls.

## The big ideas of VyConf

System-wide config in a human readable plaintext file, thus easy backup and versioning.

Stateful approach: every user gets their own copy of the configuration, and can make changes,
view diffs, run consistency checks, and so on, without any effect on the system. The user is then
free to commit or discard the changes.

Safety first: system-wide config consistency checks must pass before it gets to generating
application configs and restarting services. If anything goes wrong, the system can rollback
to previous revision.

## VyConf operation

VyConf runs as a daemon (vyconfd) that listens on a UNIX domain socket and communicates with
its clients. Clients provided with VyConf are a non-interactive CLI client, an interactive shell,
and an HTTP bridge.

## Details

For details of the VyConf architecture, see the architecture.md document.

## Hacking

VyConf development is discussed in the (VyOS phabricator)[https://phabricator.vyos.net/project/profile/1/]
and the #vyos IRC channel on Freenode.

Don't forget to add unit tests for things you add or change!

If you are new to OCaml, you need to install (opam)[http://opam.ocaml.org/] first, then you need to install
the compiler (e.g. "opam switch 4.03.0"), then install the build tools and build dependencies:

```
opam install oasis
opam install xml-light lwt ppx_deriving_yojson pcre ounit
```

I also recommend that you setup utop (a great interactive REPL) and setup your editor with merlin to
see the inferred types. For GNU Emacs, consider installing tuareg-mode.

Don't hesitate to ask if you have any setup or build issues, and specifically for OCaml issues,
there's #ocaml channel on Freenode too.
