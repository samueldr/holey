`holey`
=======

Porcelain over `cgpt` to effortlessly create a "holey" or "holesome" GPT table
on a disk.


Usage
-----

```
holey init [size]
holey add <type> [size]
```

`holey` will default to a 2 MiB sized hole in the GPT. That size should be
enough for most allwinner u-boot with SPL embedded, with plenty of room
to spare.

All sizes are in MiB.

The types known by `holey` are:

 * `esp`
 * `linux`
 * `swap`


Why?
----

The main use case, for now, is to use a GPT partition scheme on Allwinner
systems that do not have a discrete storage for the firmware.

This way, a genuine GPT partition scheme can be used on the internal storage,
allowing the full proper use of the UEFI bits from u-boot.


How?
----

Following the spec, the GPT looks like that:

```
--------------------------------------
| GPT                                |
--------------------------------------
| LBA 0       | Protective MBR       |
| LBA 1       | Primary GPT Header   |
| LBA 2..33   | Primary GPT Table    |
| LBA 34...   | Usable space...      |
|             |                      |
| .........   | ..................   |
|             |                      |
| LBA -34     | ... usable space.    |
| LBA -33..-2 | Secondary GPT Table  |
| LBA -1      | Secondary GPT Header |
--------------------------------------
```

The default location for the SPL is at 8K, this gives LBA 16.

It would be impossible to embed u-boot on such a GPT layout.

There are two solutions

 1. Reduce the space taken by the GPT Table
 2. Put a hole between the GPT Header and GPT Table

Per the spec, the GPT Table's location and the number of entries in the GPT
Table are defined in the Primary GPT Header. Both options should be viable.
Some tools will not play nice with the changes required.

Reducing the amount of entries in the GPT Table seems to be the least supported
option.

This tool implements the second solution; leaving a gap between the Primary
Header and the Primary Table.

After initializing a disk with this tool, the layout will look like the
following:

```
----------------------------------------
| GPT                                  |
----------------------------------------
| LBA 0         | Protective MBR       |
| LBA 1         | Primary GPT Header   |
| LBA 2..H+1    | Hole                 |
| LBA H+2..H+33 | Primary GPT Table    |
| LBA H+34...   | Usable space...      |
|               |                      |
| .........     | ..................   |
|               |                      |
| LBA -34       | ... usable space.    |
| LBA -33..-2   | Secondary GPT Table  |
| LBA -1        | Secondary GPT Header |
----------------------------------------
```

Where `H` is the size of the hole in sectors.


Tools known to play nice
------------------------

 * `cgpt` (is the plumbing behind this script.)
 * `cfdisk`
 * `fdisk`
 * `gdisk`
