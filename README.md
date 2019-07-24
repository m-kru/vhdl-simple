# vhdl\_simple
Library for simple VHDL entities.

## Introduction
vhdl\_simple is library for simple VHDL entities, that are often reused in different designs.
Simple refers to the functionality of the entity, not necessarily to the implementation of the entity.

This library is from scratch intended to be used with [FuseSoc](https://github.com/olofk/fusesoc), but of course it can be used with any build tool/system.
Just ignore `.core` files.
Similar entities are also implemented in different VHDL libraries available on the Internet, so theoretically providing `.core` files should be enough.
However, those repositories are maintained by different people and they were not implemented with FuseSoc in mind.
Therefore, the goals of vhdl\_simple library are to:
- Never break backward functional compatibility.
- Never introduce changes, that would force updating entity instantiation.

Thanks to these, version is not needed in FuseSoc VLNV (Vendor:Library:Name:Version) tags.
