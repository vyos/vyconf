# What do you mean by "software appliance configuration framework"?

We define a software appliance as a package that contains an operating system and
one or more applications designed to work together and perform a single task.

For instance, one can make a database appliance that consists of an operating system,
a database server, a database management frontend, and a monitoring application.
Those all serve a single purpose, to operate a database.

# The problem

Some applications combine the configuration interface and the user interface
(this is often the case with web applications). Some do not need much configuration.
The problem is that managing a software appliance still involves appliance-wide tasks
that either have to be performed manually or need a custom configuration interface.

Firewall management is a common example. With the example above, you likely can
manage database access rules from a database management application, but
firewall is usually an operating system component that has to be managed outside
of that application.

Besides, systems tend to grow big and include a large number of machines that need
to be managed. One can accomplish this by connecting appliances to a configuration
management system and work directly with its components, but the primary advantage
of an appliance is being self-contained, and this approach violates it.

# The (proposed) solution

To be a true appliance (in the same sense to hardware appliances), an appliance
should offer a single configuration API that allows to manage all relevant components.

This is what VyConf aims to provide. You may think of it as evolution of YaST, Alterator,
or webmin: a glue between applications and the world, a way to join multiple applications
under a single interface.

The other problem, apart from unification, that we are aiming to solve is robustness
and reliability. Many applications simply take any configuration and fail to start
if it's incorrect, correctness verification is left up to the users. For an appliance
it's preferrable when in case of user error the incorrect configuration is not applied
at all.

The other problem is that configuration of individual applications may be correct,
but the overall appliance configuration may not, e.g. if the user set an application
to listen on specific address, but did not configure the network interface accordingly.

A possible solution to this is to make configuration stateful and atomic. First a 
proposed configuration is built, then it's commited, and if any stage fails, it's
rolled back to its previous state. This also simplifies accounting and allows to keep
configuration revision history and rollback to previous revisions.

# What exactly VyConf is

VyConf is a daemon that keeps the current configuration, provides API for changing it,
and calls procedures that generate actual applications (or operatinf system) configuration
and apply it.

## Concepts

**Running config** is the config currently used by the system. It is represented as a tree
made of named nodes and values associated with them. It can be loaded from a configuration
file or modified via the API.


**Interface definition** defines allowed node names and hierarchies. It is loaded from
interface definition files provided by application handlers.

**Config tree** is the internal representation of the config (running or proposed).

**Reference tree** is the internal representation of the interface definition.

## Configuration lifecycle

At boot time, system-wide configuration is initialized by loading the configuration file.

After that, it may be changed through the API calls from *config sessions*. Primary operations
are "set" (creates a node or changes its value) and "delete" (deletes a node). Every config
session has its own *proposed configuration* tree. When the user is ready to apply it, they
initiate commit.

Commit includes three stages: *verify*, *generate*, *apply*. Every *application handler*
has programs (or procedures within one program) to perform those stages.

First, all *verify* procedures are called. They read the system-wide config and check if it's
correct. If this stage fails, the commit is aborted.

After that, all *generate* procedures are executed. They generate actual config files for applications
included in the appliance. Previous application configs are saved for the case rollback is needed.

When configs are generated, *apply* procedures are called. If any of those fails, application configs
are restored and commit is aborted.
