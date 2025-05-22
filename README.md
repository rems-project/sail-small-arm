# Sail small arm

This is a small-scale Arm model, originally by Shaked Flur and Kathyrn Gray and
adapted to current Sail and its new concurrency interface by Brian Campbell,
Thibaut Pérami. It comes from the
[aarch64_small](https://github.com/rems-project/sail/tree/sail2/aarch64_small)
folder in Sail.

The goal is to support enough instruction to support running litmus tests and
small compiler generated functions, while still being small enough that a single
person can read it and understand it.

The `Makefile` currently generates a Rocq model by default, but we welcome PRs to
add other sail backends to the build system.
