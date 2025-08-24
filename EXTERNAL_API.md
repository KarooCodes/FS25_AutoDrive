# AutoDrive External API Documentation

This document describes the functions that can be called from external mods to interact with AutoDrive.

To call these functions, you need to have AutoDrive installed and active. You can then access the functions through the global `AutoDrive` table. For example: `AutoDrive:GetPath(...)`.

## Pathfinding

### GetPath

Calculates a path from a given starting point to a destination marker.

**Signature:**
```lua
AutoDrive:GetPath(startX, startZ, startYRot, destinationID, options)
```

**Parameters:**
- `startX`: (number) The starting x-coordinate in world space.
- `startZ`: (number) The starting z-coordinate in world space.
- `startYRot`: (number) The starting rotation in radians.
- `destinationID`: (number) The ID of the destination marker.
- `options`: (table, optional) A table of options:
    - `minDistance`: (number, optional) The minimum distance to search for a nearby waypoint from the starting location. Default is 1.
    - `maxDistance`: (number, optional) The maximum distance to search for a nearby waypoint from the starting location. Default is 20.

**Returns:**
- (table) A table of waypoints representing the path, or `nil` if no path is found. Each waypoint is a table with `x`, `y`, `z`, and `id` fields.

### GetPathVia

Calculates a path from a given starting point to a destination marker, passing through a "via" marker.

**Signature:**
```lua
AutoDrive:GetPathVia(startX, startZ, startYRot, viaID, destinationID, options)
```

**Parameters:**
- `startX`: (number) The starting x-coordinate in world space.
- `startZ`: (number) The starting z-coordinate in world space.
- `startYRot`: (number) The starting rotation in radians.
- `viaID`: (number) The ID of the "via" marker.
- `destinationID`: (number) The ID of the destination marker.
- `options`: (table, optional) A table of options:
    - `minDistance`: (number, optional) The minimum distance to search for a nearby waypoint from the starting location. Default is 1.
    - `maxDistance`: (number, optional) The maximum distance to search for a nearby waypoint from the starting location. Default is 20.

**Returns:**
- (table) A table of waypoints representing the path, or `nil` if no path is found.

## Destinations

### GetAvailableDestinations

Returns a list of all available destinations (markers) on the map.

**Signature:**
```lua
AutoDrive:GetAvailableDestinations()
```

**Parameters:**
- None

**Returns:**
- (table) A table of destination markers. The keys are the marker IDs, and the values are tables with the following fields: `name`, `x`, `y`, `z`, `id`.

### GetClosestPointToLocation

Finds the closest waypoint to a given location.

**Signature:**
```lua
AutoDrive:GetClosestPointToLocation(x, z, minDistance)
```

**Parameters:**
- `x`: (number) The x-coordinate in world space.
- `z`: (number) The z-coordinate in world space.
- `minDistance`: (number) The minimum distance to consider.

**Returns:**
- (number) The ID of the closest waypoint, or -1 if none is found.

### GetParkDestination

Gets the configured parking destination for a vehicle.

**Signature:**
```lua
AutoDrive:GetParkDestination(vehicle)
```

**Parameters:**
- `vehicle`: (table) The vehicle object.

**Returns:**
- (number) The ID of the park destination marker, or `nil` if none is set.

## Driving Control

### StartDriving

Starts AutoDrive for a vehicle, sending it to a destination.

**Signature:**
```lua
AutoDrive:StartDriving(vehicle, destinationID, unloadDestinationID, callBackObject, callBackFunction, callBackArg)
```

**Parameters:**
- `vehicle`: (table) The vehicle to start.
- `destinationID`: (number) The ID of the primary destination marker.
- `unloadDestinationID`: (number) The ID of the unload destination marker. Can be a special value:
    - `-2`: Refuel
    - `-3`: Park
- `callBackObject`: (table, optional) An object to call the callback function on.
- `callBackFunction`: (function, optional) A function to call when the task is finished.
- `callBackArg`: (any, optional) An argument to pass to the callback function.

**Returns:**
- None

### StartDrivingWithPathFinder

Starts AutoDrive for a vehicle to a destination, with pathfinding. This seems to be a wrapper around `StartDriving` with some special handling for parking and refueling.

**Signature:**
```lua
AutoDrive:StartDrivingWithPathFinder(vehicle, destinationID, unloadDestinationID, callBackObject, callBackFunction, callBackArg)
```

**Parameters:**
- `vehicle`: (table) The vehicle to start.
- `destinationID`: (number) The ID of the primary destination marker.
- `unloadDestinationID`: (number) The ID of the unload destination marker.
- `callBackObject`: (table, optional) An object to call the callback function on.
- `callBackFunction`: (function, optional) A function to call when the task is finished.
- `callBackArg`: (any, optional) An argument to pass to the callback function.

**Returns:**
- None

### HoldDriving

Pauses the current driving task for a vehicle.

**Signature:**
```lua
AutoDrive:HoldDriving(vehicle)
```

**Parameters:**
- `vehicle`: (table) The vehicle to pause.

**Returns:**
- None

## Listeners

### registerDestinationListener

Registers a listener to be notified when the list of destinations changes.

**Signature:**
```lua
AutoDrive:registerDestinationListener(callBackObject, callBackFunction)
```

**Parameters:**
- `callBackObject`: (table) The object to call the callback function on.
- `callBackFunction`: (function) The function to call when the destinations change.

**Returns:**
- None

### unRegisterDestinationListener

Unregisters a destination listener.

**Signature:**
```lua
AutoDrive:unRegisterDestinationListener(callBackObject)
```

**Parameters:**
- `callBackObject`: (table) The object that was used to register the listener.

**Returns:**
- None

### notifyDestinationListeners

Notifies all registered destination listeners about a change.

**Signature:**
```lua
AutoDrive:notifyDestinationListeners()
```

**Parameters:**
- None

**Returns:**
- None

## CoursePlay Integration

This section describes functions specifically for integrating with the CoursePlay mod.

### combineIsCallingDriver

Checks if a combine is calling for a driver.

**Signature:**
```lua
AutoDrive:combineIsCallingDriver(combine)
```

**Parameters:**
- `combine`: (table) The combine vehicle object.

**Returns:**
- (boolean) `true` if the combine is calling for a driver, `false` otherwise.

### getCombineOpenPipePercent

Gets the percentage the combine's pipe is open.

**Signature:**
```lua
AutoDrive:getCombineOpenPipePercent(combine)
```

**Parameters:**
- `combine`: (table) The combine vehicle object.

**Returns:**
- (number) The percentage the pipe is open.

### StartCP

Starts CoursePlay at the first waypoint.

**Signature:**
```lua
AutoDrive:StartCP(vehicle)
```

**Parameters:**
- `vehicle`: (table) The vehicle to start CoursePlay on.

**Returns:**
- None

### RestartCP

Restarts a CoursePlay course.

**Signature:**
```lua
AutoDrive:RestartCP(vehicle)
```

**Parameters:**
- `vehicle`: (table) The vehicle to restart CoursePlay on.

**Returns:**
- None

### StopCP

Stops the current CoursePlay course if it is active.

**Signature:**
```lua
AutoDrive:StopCP(vehicle)
```

**Parameters:**
- `vehicle`: (table) The vehicle to stop CoursePlay on.

**Returns:**
- None

### getIsCPActive

Checks if CoursePlay is active on a vehicle.

**Signature:**
```lua
AutoDrive:getIsCPActive(vehicle)
```

**Parameters:**
- `vehicle`: (table) The vehicle to check.

**Returns:**
- (boolean) `true` if CoursePlay is active, `false` otherwise.

### holdCPCombine

Temporarily holds a combine that is running a CoursePlay course.

**Signature:**
```lua
AutoDrive:holdCPCombine(vehicle)
```

**Parameters:**
- `vehicle`: (table) The combine vehicle to hold.

**Returns:**
- None

### getIsCPCombineInPocket

Checks if a CoursePlay-controlled combine is in the "pocket" (waiting for unload).

**Signature:**
```lua
AutoDrive:getIsCPCombineInPocket(vehicle)
```

**Parameters:**
- `vehicle`: (table) The combine vehicle to check.

**Returns:**
- (boolean) `true` if the combine is in the pocket, `false` otherwise.

### getIsCPWaitingForUnload

Checks if a CoursePlay-controlled combine is waiting to be unloaded.

**Signature:**
```lua
AutoDrive:getIsCPWaitingForUnload(vehicle)
```

**Parameters:**
- `vehicle`: (table) The combine vehicle to check.

**Returns:**
- (boolean) `true` if the combine is waiting to be unloaded, `false` otherwise.

### getIsCPTurning

Checks if a CoursePlay-controlled combine is currently turning.

**Signature:**
```lua
AutoDrive:getIsCPTurning(vehicle)
```

**Parameters:**
- `vehicle`: (table) The combine vehicle to check.

**Returns:**
- (boolean) `true` if the combine is turning, `false` otherwise.

### onCpFinished

Event handler for when a CoursePlay course is finished.

**Signature:**
```lua
AutoDrive:onCpFinished()
```

**Parameters:**
- `self`: (table) The vehicle object.

**Returns:**
- None

### handleCPFieldWorker

Handles the transition from CoursePlay to AutoDrive for a field worker.

**Signature:**
```lua
AutoDrive:handleCPFieldWorker(vehicle)
```

**Parameters:**
- `vehicle`: (table) The vehicle object.

**Returns:**
- None

### onCpEmpty

Event handler for when a CoursePlay-controlled vehicle is empty.

**Signature:**
```lua
AutoDrive:onCpEmpty()
```

**Parameters:**
- `self`: (table) The vehicle object.

**Returns:**
- None

### onCpFull

Event handler for when a CoursePlay-controlled vehicle is full.

**Signature:**
```lua
AutoDrive:onCpFull()
```

**Parameters:**
- `self`: (table) The vehicle object.

**Returns:**
- None

### onCpFuelEmpty

Event handler for when a CoursePlay-controlled vehicle is out of fuel.

**Signature:**
```lua
AutoDrive:onCpFuelEmpty()
```

**Parameters:**
- `self`: (table) The vehicle object.

**Returns:**
- None

### onCpBroken

Event handler for when a CoursePlay-controlled vehicle is broken.

**Signature:**
```lua
AutoDrive:onCpBroken()
```

**Parameters:**
- `self`: (table) The vehicle object.

**Returns:**
- None

### getCanAdTakeControl

Checks if AutoDrive can take control from CoursePlay.

**Signature:**
```lua
AutoDrive:getCanAdTakeControl()
```

**Parameters:**
- `self`: (table) The vehicle object.

**Returns:**
- (boolean) `true` if AutoDrive can take control, `false` otherwise.

## Autoloader Integration

This section describes functions for integrating with Autoloader mods.

### hasAL

Checks if an object has Autoloader functionality.

**Signature:**
```lua
AutoDrive:hasAL(object)
```

**Parameters:**
- `object`: (table) The object to check.

**Returns:**
- (boolean) `true` if the object has Autoloader, `false` otherwise.

### setALOn

Turns the Autoloader on for an object.

**Signature:**
```lua
AutoDrive:setALOn(object)
```

**Parameters:**
- `object`: (table) The object to turn the Autoloader on for.

**Returns:**
- None

### setALOff

Turns the Autoloader off for an object.

**Signature:**
```lua
AutoDrive:setALOff(object)
```

**Parameters:**
- `object`: (table) The object to turn the Autoloader off for.

**Returns:**
- None

### activateALTrailers

Activates the Autoloader on a set of trailers.

**Signature:**
```lua
AutoDrive.activateALTrailers(vehicle, trailers)
```

**Parameters:**
- `vehicle`: (table) The main vehicle.
- `trailers`: (table) A list of trailer objects.

**Returns:**
- None

### deactivateALTrailers

Deactivates the Autoloader on a set of trailers.

**Signature:**
```lua
AutoDrive.deactivateALTrailers(vehicle, trailers)
```

**Parameters:**
- `vehicle`: (table) The main vehicle.
- `trailers`: (table) A list of trailer objects.

**Returns:**
- None

### unloadAL

Unloads an object with an Autoloader.

**Signature:**
```lua
AutoDrive:unloadAL(object)
```

**Parameters:**
- `object`: (table) The object to unload.

**Returns:**
- None

### unloadALAll

Unloads all trailers of a vehicle with Autoloaders.

**Signature:**
```lua
AutoDrive:unloadALAll(vehicle)
```

**Parameters:**
- `vehicle`: (table) The vehicle to unload.

**Returns:**
- None

### getALObjectFillLevels

Gets the fill levels of an object with an Autoloader.

**Signature:**
```lua
AutoDrive:getALObjectFillLevels(object)
```

**Parameters:**
- `object`: (table) The object to get the fill levels from.

**Returns:**
- `fillLevel`: (number) The current fill level.
- `fillCapacity`: (number) The total fill capacity.
- `filledToUnload`: (boolean) Whether the unload fill level has been reached.
- `fillFreeCapacity`: (number) The remaining free capacity.

### getALFillTypes

Gets the supported fill types for an Autoloader object.

**Signature:**
```lua
AutoDrive:getALFillTypes(object)
```

**Parameters:**
- `object`: (table) The object to get the fill types from.

**Returns:**
- (table) A list of fill type names.

### getALCurrentFillType

Gets the currently selected fill type of an Autoloader object.

**Signature:**
```lua
AutoDrive:getALCurrentFillType(object)
```

**Parameters:**
- `object`: (table) The object to get the current fill type from.

**Returns:**
- (number) The index of the current fill type.

### setALFillType

Sets the fill type for a vehicle's Autoloader trailers.

**Signature:**
```lua
AutoDrive:setALFillType(vehicle, fillType)
```

**Parameters:**
- `vehicle`: (table) The vehicle.
- `fillType`: (number) The index of the fill type to set.

**Returns:**
- None

## AI Integration

This section describes functions for integrating with the game's built-in AI helper system.

### handleAIFinished

Handles the event when a built-in AI job is finished. Can be used to park the vehicle.

**Signature:**
```lua
AutoDrive:handleAIFinished(vehicle)
```

**Parameters:**
- `vehicle`: (table) The vehicle object.

**Returns:**
- None

### handleAIFieldWorker

Handles the transition from the built-in AI to AutoDrive.

**Signature:**
```lua
AutoDrive:handleAIFieldWorker(vehicle)
```

**Parameters:**
- `vehicle`: (table) The vehicle object.

**Returns:**
- None

### onAIJobFinished

Event handler for when a built-in AI job is finished.

**Signature:**
```lua
AutoDrive:onAIJobFinished()
```

**Parameters:**
- `self`: (table) The vehicle object.

**Returns:**
- None

## Miscellaneous

### GetDriverName

Gets the name of the AutoDrive driver for a vehicle.

**Signature:**
```lua
AutoDrive:GetDriverName(vehicle)
```

**Parameters:**
- `vehicle`: (table) The vehicle object.

**Returns:**
- (string) The name of the driver.
