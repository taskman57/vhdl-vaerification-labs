```text
[Start Simulation]
               |
               v
    +--------------------------+
    |      Initialization      |
    | - Set signals to default |
    | - Execute processes      |
    +--------------------------+
               |
               v
+--------> +--------------------------+ 
|          |      Determine Next      | 
|          |    Simulation Time (Tc)  | 
|          +--------------------------+ 
|                      |
|                      v
|          +--------------------------+ 
|          |   Advance Time to Tc     |
|          +--------------------------+
|                      |
|                      v
|          +--------------------------+ <-----------+
|          |       Update Phase       |             |
|          | - Apply scheduled values |             |
|          +--------------------------+             |
|                      |                            |
|                      v                            |
|          +--------------------------+       (Are there new)
|          |      Wake-up Phase       |       (events for Tc?)
|          | - Trigger processes      |             |
|          +--------------------------+             |
|                      |                            |
|                      v                            |
|          +--------------------------+             |
|          |      Execute Phase       |             |
|          | - Run active processes   |             |
|          | - Schedule new updates   |             |
|          +--------------------------+             |
|                      |                            |
|             (Yes, new updates scheduled) ---------+
|                      |
|             (No updates scheduled)
|                      |
|                      v
|          +--------------------------+
|          |  Is Simulation Finished? |
|          |  (Time limit / No events)|
|          +--------------------------+
|            |                      |
|         (No)                   (Yes)
|            |                      |
+------------+                      v
                               [End Simulation]
```