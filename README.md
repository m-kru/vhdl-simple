# vhdl-simple
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
Words within entity names start with uppercase letter.

### Generic names

All entities share generics naming convention.
{FOO} indicates name of the output port or internal signal.

| Name | Type | Default | Description |
| :---: | :---: | :---: | :---: |
| {FOO}_DISABLED_VALUE | port specific | 0 | Value of *foo* output port when module is disabled (`en_i = '0'`). |
| {FOO}_INIT_VALUE | port/signal specific | 0 | Initial value of *foo* output port or *foo* internal signal. 
| {FOO}_RESET_VALUE | port/signal specific | 0 | Value of *foo* output port or *foo* internal signal after reset (asynchronous or synchronous). |
| INPUT_WIDTH | `positive` | - | Width of input. |
| OUTPUT_WIDTH | `positive` | - | Width of output. |
| REGISTER_OUTPUTS | `boolean` | `true` | Option to register outputs. |
| WIDTH | `positive` | - | Width of input *and* output. |

### Port names

Port names end with suffix indicating theirs direction: **_i**, **_o**.

Some entities share some port names, which always indicate the same functionality:

| Name | Type | Default | Description |
| :---: | :---: | :---: | :---: |
| addr_i | `std_logic_vector` | - | Address input. |
| arstn_i | `std_logic` | `'1'` | Asynchronous negative reset input. |
| d_i | entity specific | - | Data input. |
| clk_i | `std_logic` | - | Clock inpout. |
| clk_en_i | `std_logic` | `'1'` | Clock enable input. |
| en_i | `std_logic` | `'1'` | Functionality enable input. |
| q_o | entity specific | `Q_INIT_VALUE` | Data output. |
| rst_i | `std_logic` | `'0'` | Synchronous positive reset input. |
| stb_i | `std_logic` | - | Strobe input. |
| wr_en_i | `std_logic` | - | Write enable input. |
