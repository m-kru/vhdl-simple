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

## Naming conventions

### Entity names

There are no abbreviations in the entity names as these are *nomina propria*.

### Generic names

Generics names start with **G_**.

Some entities share some generic names, which always indicate the same functionality:
- **G_DISABLED_VALUE** - value assigned to outputs when module is disabled (default **'0'**),
- **G_REGISTER_OUTPUTS** - option to register outputs (default **true**),
- **G_RESET_VALUE** - value for output or internal state on reset (default **'0'**),
- **G_INIT_VALUE** - initial value for output or internal state (default **'0'**),
- **G_INPUT_WIDTH** - width of input (**no** default value),
- **G_OUTPUT_WIDTH** - width of output (**no** default value),
- **G_WIDTH** - width of input *and* output (**no** default value).

### Port names

Port names end with suffix indicating theirs direction: **_i**, **_o**.

Some entities share some port names, which always indicate the same functionality:
- **addr_i** - address input,
- **d_i** - data input,
- **clk_i** - clock input,
- **clk_en_i** - clock enable input,
- **q_o** - data output,
- **rst_i** - reset input,
- **stb_i** - strobe input,
- **wr_en_i** - write enable input.
