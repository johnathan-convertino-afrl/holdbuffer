# HOLDBUFFER
### Pipeline backpressure enabled busses.
---

![image](docs/manual/img/AFRL.png)

---

   author: Jay Convertino  
   
   date: 2025.12.16
   
   details: Pipeline backpressure enabled busses including ready.  
   
   license: MIT  

   Actions:  

  [![Lint Status](../../actions/workflows/lint.yml/badge.svg)](../../actions)  
  [![Manual Status](../../actions/workflows/manual.yml/badge.svg)](../../actions)  
  
---

### Version
#### Current
  - V1.0.0 - initial release

#### Previous
  - none

### DOCUMENTATION
  For detailed usage information, please navigate to one of the following sources. They are the same, just in a different format.

  - [HOLDBUFFER.pdf](docs/manual/HOLDBUFFER.pdf)
  - [github page](https://johnathan-convertino-afrl.github.io/holdbuffer/)

### PARAMETERS

* BUS_WIDTH     : Bus width in number of bytes.

### COMPONENTS
#### SRC

* holdbuffer.v

#### TB

* tb_holdbuffer.v
* tb_cocotb.py
* tb_cocotb.v
  
### FUSESOC

* fusesoc_info.core created.
* Simulation uses icarus to run data through the core.

#### Targets

* RUN WITH: (fusesoc run --target=sim VENDER:CORE:NAME:VERSION)
  - default (for IP integration builds)
  - lint
  - sim
  - sim_cocotb
