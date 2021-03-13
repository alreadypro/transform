# transform
Seamlessly change a player's RigType

### Usage

Server

```lua
local Transform = require(path.to.transform)

local transform = Transform.new(player)
transform:R6()
transform:R15()
transform:ChangeRigType("R6")
transform:ChangeRigType(Enum.HumanoidRigType.R6)
```

Client

```lua
require(path.to.transform)
```
