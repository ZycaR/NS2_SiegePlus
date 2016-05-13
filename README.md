# ns2siege+

The two teams will spawn on their side of the map with a LOCKED door(s) in middle (front door). The ready phase is a time of truce. It allows teams to tech up, build defenses and prepare for fight.
Each team will have equal time to build their Resource Towers/defenses and tech upgrades. 
After a set time (designated by the mapper) the alarm will sound, as the front door(s) open, allowing combat.
After a second designated time, a second door will open (siege door). The door allows marines to reach a room giving ARC firing range on the hives.

Winning conditions are same as NS2, kill all Hives or CC's. Also most of the gameplay after first set of door(s) opens.

Basically it's up to the aliens to go offensive and takeover the marine base before siege room opens.
It's beautiful because both sides gets res, meaning full upgrades for both sides.

## Mappers guide

### Basics

Please take to an account these requirements before you start creating siege map.
This is bare minimum what should acceptable siege map design satisfied:
- Both sides get lots of resource towers
- No fighting for the first at least 5 minutes of the round. There's locked doors that prevent combat, to give teams enough time for research basic upgrades.
- Marines have another set of doors in their base with give access to a Siege Room, where they can arc out the alien hives. This door opens after front doors.
- So all three alien hives at tucked together for this reason. 

### Siege+ specific map entities
The map for siege+ gameplay is very similar to original ns2 map. It requires same basic entities like ns2_gamerules, at least two tech. points, mini-map entity, etc.
But there are basically three new additions in advance to allow siege+ gameplay:

##### ns2_gamerules
This is original ns2 entity which dictates gameplay rules. Three siege+ specific properties were added in advance:
> **Front Door Opening Time** .. time since round start to open front doors in seconds.

> **Siege Door Opening Time** .. time since round start to open siege doors in seconds.

> **Sudden Death Time** .. time since round start when CommanStation and Hive cannot be repaired in seconds.

##### ns2siege_funcdoor
Entity representing siege+ special doors entity. The times specified in ns2_gamerules entity are counting down time till these doors are opened. Mapper can configure door behaviour by these build in properties:
> **Door Type** .. choice between Front or Siege type of door.

> **Model** .. select prop. which will be used as door model.

> **Direction** .. You can choose one of six directions the door will move when opening.

> **Move Distance** .. How far the door will be move when opening.

> **Move Speed** .. How fast the door will move.

##### ns2siege_funcmaid
Maid is the volume entity (locations) for killing cysts in it's volume. Usually it's located on marine side of front and siege doors to kill slipping cyst chain as prevention for exploits before specific door is opened. Mappers can place multiple instances for same door. This gives mappers full control over area which needs to be cleaned from cysts!

> **TimerType** .. The maid will stop killing placed cysts when selected timer expires.

> *This property is a choice for all three times: Front door, Siege door or Sudden Death.*

### Siege+ Map List

* **sg_basic** .. small test map (not for public, only educational purpose)
* **sg_trimsiege** .. fully finished and maintained siege+ map

### Mod ID - 281236ae
```sh
Server.exe -mods "281236ae"
```

### SteamWorkshop link

http://steamcommunity.com/sharedfiles/filedetails/?id=672282286
