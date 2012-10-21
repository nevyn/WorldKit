EggsAndBaskets example
======================

Most simple example possible, with just table views and syncing clients/servers.

The client is hard-coded to connect to localhost, so run it in the simulator or change the host in the MasterClientDelegate. The server is hard-coded to only serve a single game that you join immediately on connection.

EggsAndBasketsWorld
-------------------

This is the world representation for this particular game. All the other sub-apps use this representation, and feeds it into WorldKit. It contains:
* EABGame: Game subclass as the root class holding everything else
* EABBasket: Entity subclass which can have a name and a number of eggs
* EABEgg: Entity subclass which can have a shape

BasketsIOS
---------

GUI client which immediately connects to localhost and joins that server. Shows a canonical way of connecting, listing games, observing the game world, and manipulating it through actions rather than by modifying the entities directly.

BasketsMacServer
---------

GUI server which lets you directly see and interact with the data model, superuser-like. This is now how you are supposed to write a single-player game with this engine (in that case, just run a server and client in the same app), but rather just a way to visualize the data model.

BasketsDedicated
----------------

Command-line server.

