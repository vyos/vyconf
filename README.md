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
However, a largely missed and unexplored opportunity is using appliance approach to improve
reliability and robustness. And, making appliances the right way is hard since you have to
implement a lot of things from scratch. Done right, an appliance can be more than a sum of its
parts, and can offer something to people who know enough to have configured the applications
included in it by hand, rather than just be a simple way to configure them for people who
don't know what they are doing.

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

## Making your own appliance with VyConf

To give you some idea what making an appliance is supposed to be like:

First, you define the interface you will expose. The system-wide config is represented as
a multi-way tree, you define what nodes are allowed and what values can be attached to them.
This is done declaratively in XML files (for which we provide a RelaxNG schema in data/schemata/interface_definition.rnc).
See test/data/interface_definition_sample.xml for an example.

In the interface definition, you define which component owns which node. When a change is made, the component
responsible for the node is called. A component includes programs or options for three functions: verify (check
consistency of the abstract config), generate (produce configs for applications), and apply (restart services etc.).
The verify stage of every component is called first and if any of those fail, the commit fails. Since every component
can read the entire configuration in a uniform way (as in Vyconf_session.get_value ["interfaces"; "ethernet"; "eth0"; "address"]),
they can run cross-checks to verify that the configuration as a whole is consistent.

What you get automatically from VyConf:
* Parsing and loading the system-wide config (in a human-readable format)
* A library for manipulating the abstract syntax tree of the config, for converting to new versions if you change anything in your node names and structure
* An interactive shell for configuring the system, in the style of JunOS
* An HTTP bridge for remote API calls (from a GUI frontend, management tools etc.)
* Commit and rollback mechanisms for the configuration


## VyConf operation

VyConf runs as a daemon (vyconfd) that listens on a UNIX domain socket and communicates with
its clients. Clients provided with VyConf are a non-interactive CLI client, an interactive shell,
and an HTTP bridge.

## Details

For details of the VyConf architecture, see the architecture.md document.

## Hacking

VyConf development is discussed in the [VyOS phabricator](https://phabricator.vyos.net/project/profile/1/)
and the #vyos IRC channel on Freenode.

Don't forget to add unit tests for things you add or change!

If you are new to OCaml, you need to install [opam](http://opam.ocaml.org/)
first. Then install the correct version of the compiler, the build tools, and
the build dependencies:

```bash
sh <(curl -sL https://raw.githubusercontent.com/ocaml/opam/2.0.2/shell/install.sh)
opam init  --disable-sandboxing
eval $(opam env)
opam switch create 4.07.0
eval $(opam env)
opam install oasis -y
eval $(opam env)
opam install fileutils lwt lwt_ppx lwt_log ocplib-endian ounit pcre ppx_deriving_yojson sha toml xml-light batteries ocaml-protoc ctypes-foreign -y
```

To build the project and run the unit tests, do this:

```bash
./build-setup.sh
./configure --enable-tests
make
make test
make install
```

If the project gets in a weird state, and isn't building correctly, you can clean it up with

```bash
ocaml setup.ml -distclean
```

then build as before.

I also recommend that you setup [utop](https://opam.ocaml.org/blog/about-utop/)
(a great interactive REPL) and setup your editor with
[merlin](https://github.com/ocaml/merlin) to see the inferred types. For GNU
Emacs, consider installing [tuareg-mode](https://github.com/ocaml/tuareg).

Don't hesitate to ask if you have any setup or build issues, and specifically for OCaml issues,
there's #ocaml channel on Freenode too.
