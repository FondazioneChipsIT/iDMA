## Summary

| Name                                               | Offset   |   Length | Description                                               |
|:---------------------------------------------------|:---------|---------:|:----------------------------------------------------------|
| mem_ctrl.[`cg_rst`](#cg_rst)                       | 0x0      |        4 | Clock gate and reset control                              |
| mem_ctrl.[`timing_cfg`](#timing_cfg)               | 0x4      |        4 | PHY timing configuration                                  |
| mem_ctrl.[`clk_div`](#clk_div)                     | 0x8      |        4 | Clock divider                                             |
| mem_ctrl.[`mba0`](#mba0)                           | 0xc      |        4 | Memory base address 0 (chip 0)                            |
| mem_ctrl.[`mba1`](#mba1)                           | 0x10     |        4 | Memory base address 1 (chip 1)                            |
| mem_ctrl.[`device`](#device)                       | 0x14     |        4 | Device type configuration                                 |
| mem_ctrl.[`ram_opt`](#ram_opt)                     | 0x18     |        4 | RAM optimization options                                  |
| mem_ctrl.[`irq_en`](#irq_en)                       | 0x1c     |        4 | Interrupt enable                                          |
| mem_ctrl.[`burst_cfg`](#burst_cfg)                 | 0x20     |        4 | Burst / chip-select optimization (1D only, no 2D support) |
| mem_ctrl.[`protocol`](#protocol)                   | 0x24     |        4 | Protocol type (hyper, SD, eMMC)                           |
| mem_ctrl.[`transaction_type`](#transaction_type)   | 0x28     |        4 | Transaction type (data, reg r/w, SD command)              |
| mem_ctrl.[`response_type`](#response_type)         | 0x2c     |        4 | Expected response type (for SD/eMMC commands)             |
| mem_ctrl.[`data_size`](#data_size)                 | 0x30     |        4 | Transfer size                                             |
| mem_ctrl.[`external_address`](#external_address)   | 0x34     |        4 | External address                                          |
| mem_ctrl.[`internal_address`](#internal_address)   | 0x38     |        4 | Internal address                                          |
| mem_ctrl.[`trans_auto`](#trans_auto)               | 0x3c     |        4 | Automatic mode enable                                     |
| mem_ctrl.[`wdata`](#wdata)                         | 0x40     |        4 | Scalar write data for reg r/w transactions                |
| mem_ctrl.[`rdata`](#rdata)                         | 0x44     |        4 | Scalar read data for reg r/w transactions                 |
| mem_ctrl.[`transaction_valid`](#transaction_valid) | 0x48     |        4 | Launch transaction                                        |
| mem_ctrl.[`status`](#status)                       | 0x4c     |        4 | Controller status                                         |

## cg_rst
Clock gate and reset control
- Offset: `0x0`
- Reset default: `0x0`
- Reset mask: `0x3`

### Fields

```wavejson
{"reg": [{"name": "clock_gate_en", "bits": 1, "attr": ["rw"], "rotate": -90}, {"name": "rst_n", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 30}], "config": {"lanes": 1, "fontsize": 10, "vspace": 150}}
```

|  Bits  |  Type  |  Reset  | Name          | Description                       |
|:------:|:------:|:-------:|:--------------|:----------------------------------|
|  31:2  |        |         |               | Reserved                          |
|   1    |   rw   |   0x0   | rst_n         | Peripheral reset (1=out of reset) |
|   0    |   rw   |   0x0   | clock_gate_en | Clock gate enable                 |

## timing_cfg
PHY timing configuration
- Offset: `0x4`
- Reset default: `0x0`
- Reset mask: `0xffffffff`

### Fields

```wavejson
{"reg": [{"name": "latency_access", "bits": 10, "attr": ["rw"], "rotate": 0}, {"name": "read_write_recovery", "bits": 4, "attr": ["rw"], "rotate": -90}, {"name": "rwds_delay_line", "bits": 3, "attr": ["rw"], "rotate": -90}, {"name": "additional_latency_autocheck_en", "bits": 1, "attr": ["rw"], "rotate": -90}, {"name": "cs_max", "bits": 14, "attr": ["rw"], "rotate": 0}], "config": {"lanes": 1, "fontsize": 10, "vspace": 330}}
```

|  Bits  |  Type  |  Reset  | Name                            | Description                         |
|:------:|:------:|:-------:|:--------------------------------|:------------------------------------|
| 31:18  |   rw   |   0x0   | cs_max                          | Max chip-select assertion time      |
|   17   |   rw   |   0x0   | additional_latency_autocheck_en | Additional latency autocheck enable |
| 16:14  |   rw   |   0x0   | rwds_delay_line                 | RWDS delay line                     |
| 13:10  |   rw   |   0x0   | read_write_recovery             | Read/write recovery cycles          |
|  9:0   |   rw   |   0x0   | latency_access                  | Access latency                      |

## clk_div
Clock divider
- Offset: `0x8`
- Reset default: `0x0`
- Reset mask: `0xff`

### Fields

```wavejson
{"reg": [{"name": "clk_div", "bits": 8, "attr": ["rw"], "rotate": 0}, {"bits": 24}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name    | Description         |
|:------:|:------:|:-------:|:--------|:--------------------|
|  31:8  |        |         |         | Reserved            |
|  7:0   |   rw   |   0x0   | clk_div | Clock divider value |

## mba0
Memory base address 0 (chip 0)
- Offset: `0xc`
- Reset default: `0x0`
- Reset mask: `0xffffffff`

### Fields

```wavejson
{"reg": [{"name": "mba0", "bits": 32, "attr": ["rw"], "rotate": 0}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description                    |
|:------:|:------:|:-------:|:-------|:-------------------------------|
|  31:0  |   rw   |   0x0   | mba0   | Base address for memory chip 0 |

## mba1
Memory base address 1 (chip 1)
- Offset: `0x10`
- Reset default: `0x0`
- Reset mask: `0xffffffff`

### Fields

```wavejson
{"reg": [{"name": "mba1", "bits": 32, "attr": ["rw"], "rotate": 0}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description                    |
|:------:|:------:|:-------:|:-------|:-------------------------------|
|  31:0  |   rw   |   0x0   | mba1   | Base address for memory chip 1 |

## device
Device type configuration
- Offset: `0x14`
- Reset default: `0x0`
- Reset mask: `0xf`

### Fields

```wavejson
{"reg": [{"name": "device", "bits": 1, "attr": ["rw"], "rotate": -90}, {"name": "dt0", "bits": 1, "attr": ["rw"], "rotate": -90}, {"name": "dt1", "bits": 1, "attr": ["rw"], "rotate": -90}, {"name": "sdio_en", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 28}], "config": {"lanes": 1, "fontsize": 10, "vspace": 90}}
```

|  Bits  |  Type  |  Reset  | Name    | Description           |
|:------:|:------:|:-------:|:--------|:----------------------|
|  31:4  |        |         |         | Reserved              |
|   3    |   rw   |   0x0   | sdio_en | SDIO/eMMC mode enable |
|   2    |   rw   |   0x0   | dt1     | Device timing param 1 |
|   1    |   rw   |   0x0   | dt0     | Device timing param 0 |
|   0    |   rw   |   0x0   | device  | Device select         |

## ram_opt
RAM optimization options
- Offset: `0x18`
- Reset default: `0x0`
- Reset mask: `0x7`

### Fields

```wavejson
{"reg": [{"name": "cross_boundary_en", "bits": 1, "attr": ["rw"], "rotate": -90}, {"name": "opt_read_enable", "bits": 2, "attr": ["rw"], "rotate": -90}, {"bits": 29}], "config": {"lanes": 1, "fontsize": 10, "vspace": 190}}
```

|  Bits  |  Type  |  Reset  | Name              | Description                  |
|:------:|:------:|:-------:|:------------------|:-----------------------------|
|  31:3  |        |         |                   | Reserved                     |
|  2:1   |   rw   |   0x0   | opt_read_enable   | Optimized read enable        |
|   0    |   rw   |   0x0   | cross_boundary_en | Cross boundary access enable |

## irq_en
Interrupt enable
- Offset: `0x1c`
- Reset default: `0x0`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "irq_en", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description                    |
|:------:|:------:|:-------:|:-------|:-------------------------------|
|  31:1  |        |         |        | Reserved                       |
|   0    |   rw   |   0x0   | irq_en | Enable interrupt on done/error |

## burst_cfg
Burst / chip-select optimization (1D only, no 2D support)
- Offset: `0x20`
- Reset default: `0x0`
- Reset mask: `0xf`

### Fields

```wavejson
{"reg": [{"name": "cs_auto_burst_enable", "bits": 2, "attr": ["rw"], "rotate": -90}, {"name": "cs_maximum_check_enable", "bits": 2, "attr": ["rw"], "rotate": -90}, {"bits": 28}], "config": {"lanes": 1, "fontsize": 10, "vspace": 250}}
```

|  Bits  |  Type  |  Reset  | Name                    | Description             |
|:------:|:------:|:-------:|:------------------------|:------------------------|
|  31:4  |        |         |                         | Reserved                |
|  3:2   |   rw   |   0x0   | cs_maximum_check_enable | CS maximum check enable |
|  1:0   |   rw   |   0x0   | cs_auto_burst_enable    | CS auto burst enable    |

## protocol
Protocol type (hyper, SD, eMMC)
- Offset: `0x24`
- Reset default: `0x0`
- Reset mask: `0x3`

### Fields

```wavejson
{"reg": [{"name": "protocol", "bits": 2, "attr": ["rw"], "rotate": -90}, {"bits": 30}], "config": {"lanes": 1, "fontsize": 10, "vspace": 100}}
```

|  Bits  |  Type  |  Reset  | Name     | Description   |
|:------:|:------:|:-------:|:---------|:--------------|
|  31:2  |        |         |          | Reserved      |
|  1:0   |   rw   |   0x0   | protocol | Protocol type |

## transaction_type
Transaction type (data, reg r/w, SD command)
- Offset: `0x28`
- Reset default: `0x0`
- Reset mask: `0x7`

### Fields

```wavejson
{"reg": [{"name": "transaction_type", "bits": 3, "attr": ["rw"], "rotate": -90}, {"bits": 29}], "config": {"lanes": 1, "fontsize": 10, "vspace": 180}}
```

|  Bits  |  Type  |  Reset  | Name             | Description      |
|:------:|:------:|:-------:|:-----------------|:-----------------|
|  31:3  |        |         |                  | Reserved         |
|  2:0   |   rw   |   0x0   | transaction_type | Transaction type |

## response_type
Expected response type (for SD/eMMC commands)
- Offset: `0x2c`
- Reset default: `0x0`
- Reset mask: `0xf`

### Fields

```wavejson
{"reg": [{"name": "response_type", "bits": 4, "attr": ["rw"], "rotate": -90}, {"bits": 28}], "config": {"lanes": 1, "fontsize": 10, "vspace": 150}}
```

|  Bits  |  Type  |  Reset  | Name          | Description   |
|:------:|:------:|:-------:|:--------------|:--------------|
|  31:4  |        |         |               | Reserved      |
|  3:0   |   rw   |   0x0   | response_type | Response type |

## data_size
Transfer size
- Offset: `0x30`
- Reset default: `0x0`
- Reset mask: `0x3ff`

### Fields

```wavejson
{"reg": [{"name": "data_size", "bits": 10, "attr": ["rw"], "rotate": 0}, {"bits": 22}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name      | Description            |
|:------:|:------:|:-------:|:----------|:-----------------------|
| 31:10  |        |         |           | Reserved               |
|  9:0   |   rw   |   0x0   | data_size | Transfer size in bytes |

## external_address
External address
- Offset: `0x34`
- Reset default: `0x0`
- Reset mask: `0xffffffff`

### Fields

```wavejson
{"reg": [{"name": "external_address", "bits": 32, "attr": ["rw"], "rotate": 0}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name             | Description      |
|:------:|:------:|:-------:|:-----------------|:-----------------|
|  31:0  |   rw   |   0x0   | external_address | External address |

## internal_address
Internal address
- Offset: `0x38`
- Reset default: `0x0`
- Reset mask: `0xffffffff`

### Fields

```wavejson
{"reg": [{"name": "internal_address", "bits": 32, "attr": ["rw"], "rotate": 0}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name             | Description      |
|:------:|:------:|:-------:|:-----------------|:-----------------|
|  31:0  |   rw   |   0x0   | internal_address | Internal address |

## trans_auto
Automatic mode enable
- Offset: `0x3c`
- Reset default: `0x0`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "auto", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description      |
|:------:|:------:|:-------:|:-------|:-----------------|
|  31:1  |        |         |        | Reserved         |
|   0    |   rw   |   0x0   | auto   | Auto mode enable |

## wdata
Scalar write data for reg r/w transactions
- Offset: `0x40`
- Reset default: `0x0`
- Reset mask: `0xffffffff`

### Fields

```wavejson
{"reg": [{"name": "wdata", "bits": 32, "attr": ["rw"], "rotate": 0}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description                       |
|:------:|:------:|:-------:|:-------|:----------------------------------|
|  31:0  |   rw   |   0x0   | wdata  | Value to write to remote register |

## rdata
Scalar read data for reg r/w transactions
- Offset: `0x44`
- Reset default: `0x0`
- Reset mask: `0xffffffff`

### Fields

```wavejson
{"reg": [{"name": "rdata", "bits": 32, "attr": ["ro"], "rotate": 0}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description                     |
|:------:|:------:|:-------:|:-------|:--------------------------------|
|  31:0  |   ro   |    x    | rdata  | Value read from remote register |

## transaction_valid
Launch transaction
- Offset: `0x48`
- Reset default: `0x0`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "transaction_valid", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 190}}
```

|  Bits  |  Type  |  Reset  | Name              | Description       |
|:------:|:------:|:-------:|:------------------|:------------------|
|  31:1  |        |         |                   | Reserved          |
|   0    |   rw   |   0x0   | transaction_valid | Transaction valid |

## status
Controller status
- Offset: `0x4c`
- Reset default: `0x0`
- Reset mask: `0x7`

### Fields

```wavejson
{"reg": [{"name": "busy", "bits": 1, "attr": ["ro"], "rotate": -90}, {"name": "done", "bits": 1, "attr": ["ro"], "rotate": -90}, {"name": "error", "bits": 1, "attr": ["ro"], "rotate": -90}, {"bits": 29}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description           |
|:------:|:------:|:-------:|:-------|:----------------------|
|  31:3  |        |         |        | Reserved              |
|   2    |   ro   |    x    | error  | Transaction error     |
|   1    |   ro   |    x    | done   | Transaction completed |
|   0    |   ro   |    x    | busy   | Controller busy       |

