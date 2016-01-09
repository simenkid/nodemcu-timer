nodemcu-timer
========================
Current version: v1.0.0 (stable)  
Compatible Lua version: 5.1.x  
<br />

## Table of Contents

1. [Overiew](#Overiew)  
2. [Installation](#Installation)  
3. [APIs](#APIs)  
4. [Example: LED Blinks](#LED)  


<a name="Overiew"></a>  
## 1. Overview  

The [**nodemcu**](https://github.com/nodemcu/nodemcu-firmware) `tmr` module has 7 timers (id=0~6) for you to schedule your things with `tmr.alarm()`. You would face a problem of managing callbacks with the specified timer ids to start or stop the scheduled alarms. This is the reason why **nodemcu-timer** comes out. With **nodemcu-timer**, you don't have to worry about whether a timer is available or not. It is a soft timer utility that allows you to schedule tasks with Javascript(/node.js) style APIs in your **nodemcu** project, i.e., `setTimeout()` and `clearTimeout()`.  
  
**nodemcu-timer** uses a single timer to simulate the behavior of `setTimeout()`, `setInterval()`, and `setImmediate()`. Only one task executes when a tick fires (excepts those scheduled by [`setImmediate()`](#API_setImmediate)), thus **nodemcu-timer** does not guarantee that the callback will fire at exact timing but as close as possilbe. When a callback is _setImmediate_, it will be executed at right next tick immediately even if there are other tasks being due at the same time. The internal timer will automatically start when a scheduled task enqueues, and automatically stopped when there is no task in queues. **nodemcu-timer** uses only a single timer (id=6 by default) internally, and you are free to use other 5 timers that `tmr` provides.  

If you like to code something in asynchronous style on **nodemcu**, might I sugguest [**lua-events**](https://github.com/simenkid/lua-events)? They are working well with each other to help arrange your asynchronous flow, e.g. your function can defer its callback and return right away.  

[**Note**]  
This module internally polls its task queues every 2ms. When you call `setTimeout()` and `setInterval()`, it is better to give the `delay` with an even number, e.g., `setTimeout(callback, 2000)` will fire the callback in 2 seconds. It is okay for `delay` to be odd, it will minus 1 to be even implicitly and will result in a timing error as short as 1ms. I think this small error is negligible if you are scheduling your task with an interval beyond few hundreds of ms.  
(I didn't use a tick of 1ms, because `tmr` is a bad ass when you give him a repeat interval of 1ms. If you do so, nodemcu will crash and I don't know why.)  

<a name="Installation"></a>
## 2. Installation

> $ git clone https://github.com/simenkid/nodemcu-timer.git
  
Just include the file `timer.lua` or use the minified one `timer_min.lua` in your project.  
If you are with the **nodemcu** on ESP8266, it would be good for you to compile `*.lua` text file into `*.lc` bytecode to further lower memory usage.  

* FS/Memory footprint  

    * timer.lua: ~3.9 KB(file size) / ~20 KB (heap available after loaded)  
    * timer_min.lua: ~2.0 KB(size) / ~20 KB (heap)  
    * timer.lc: ~3.2 KB(size) / ~25 KB (heap)  
    * timer.lc + events.lc: ~17.7 KB (heap)  
    <br />

<a name="APIs"></a>
## 3. APIs

* [timer.setTimeout()](#API_setTimeout)
* [timer.clearTimeout()](#API_clearTimeout)
* [timer.setInterval()](#API_setInterval)
* [timer.clearInterval()](#API_clearInterval)
* [timer.setImmediate()](#API_setImmediate)
* [timer.clearImmediate()](#API_clearImmediate)
* [timer.set()](#API_set)

*************************************************
### timer utility
Exposed by `require 'timer'`  
  
```lua
local timer = require 'timer'  -- or 'timer_min'
```

<br />

<a name="API_setTimeout"></a>
### setTimeout(callback, delay[, ...])
Schedules a one-time callback after `delay` ms. This API returns a timer-object(`tobj`) for possible use with clearTimeout(). You can also pass parameters to the callback via the variadic arguments.

  
**Arguments:**  

1. `callback` (_function_): The function to be scheduled.
2. `delay` (_number_): Time in milisecond, an even number would be better.
3. `...` (_variadic arguments_): The arguments pass to your callback.

**Returns:**  
  
* (_object_) Timer-object.

**Examples:**

```lua
-- fires after 10 seconds
local tobj = timer.setTimeout(function ()
    print('I am fired')
end, 10000)

```
  
********************************************

<a name="API_clearTimeout"></a>
### clearTimeout(tobj)
Removes the timeout timer-object from triggering.
  
**Arguments:**  

1. `tobj` (_object_): Timer-object to remove.

**Returns:**  
  
* (_none_) nil

**Examples:**

```lua
local greet = function ()
    print('Bonjour!')
end

local tmout = timer.setTimeout(greet, 5000)

timer.clearTimeout(tmout)
```
  
********************************************

<a name="API_setInterval"></a>
### setInterval(callback, delay, ...)
Schedules a callback to be executed every `delay` ms. This API returns a timer-object(`tobj`) for possible use with clearInterval(). You can also pass parameters to the callback via the variadic arguments.  

If `delay` is larger than 2147483647 ms (~25 days) or less than 2, **nodemcu-timer** will use 2 as the `delay`. 
  
**Arguments:**  

1. `callback` (_function_): The function to be scheduled.
2. `delay` (_number_): Time in milisecond, an even number would be better.
3. `...` (_variadic arguments_): The arguments pass to your callback.
  
**Returns:**  
  
* (_object_) Timer-object.

**Examples:**

```lua
local tobj = timer.setInterval(function ()
    print('Hello')
end, 2000)
```
  
********************************************

<a name="API_clearInterval"></a>
### clearInterval(tobj)
Removes a time-object of interval from repeatly triggering.
  
**Arguments:**  

1. `tobj` (_object_): Timed-object to remove.
  
**Returns:**  
  
* (_none_) nil

**Examples:**

```lua
local count = 0
local repeater = timer.setInterval(function ()
    count = count + 1
    print(count ' times triggered!')
end, 1000)

timer.clearInterval(repeater)
```
  
Be careful if you are trying to cancel the scheduled task inside itself. The following example won't work!

```lua
local count = 0
local repeater = timer.setInterval(function ()
    count = count + 1
    if (count == 5) then
        -- This will not work. 
        timer.clearInterval(repeater)
    end
end, 1000)
```
  
This is because the `repeater` variable is not referencing properly. It is a problem of Lua. All you have to do is to decalre your local variable first, and then assign something to it. Here is an example:

```lua
local count = 0
local repeater  -- declare first
-- and then assign
repeater = timer.setInterval(function ()
    count = count + 1
    if (count == 5) then
        -- This will work. 
        timer.clearInterval(repeater)
    end
end, 1000)
```
  
********************************************

<a name="API_setImmediate"></a>
### setImmediate(callback, ...)
Schedules a callback to be immediately executed at next tick, its priority is higher than those tasks set by `setTimeout()` and `setInterval()`. This API returns a timer-object(`tobj`) for possible use with clearImmediate(). You can also pass parameters to the callback via the variadic arguments.  

The callbacks for immediate execution enqueues in the order in which they were created. All immediate callbacks in the queue will be invoked right away when a tick fires. If you queue an immediate callback from inside an executing callback, that immediate callback won't be invoked until the next tick comes. Remember that do not shcedule a long task for immediate execution as possible.

  
**Arguments:**  

1. `callback` (_function_): The function to be scheduled.
2. `...` (_variadic arguments_): The arguments pass to your callback.
  
**Returns:**  
  
* (_object_) Timer-object.

**Examples:**

```lua
local tobj = timer.setImmediate(function ()
    print(gpio.read(0))
end)
```
  
********************************************

<a name="API_clearImmediate"></a>
### clearImmediate(tobj)
Removes an immediate time-object from triggering. 
  
**Arguments:**  

1. `tobj` (_object_): Timed-object to remove.

**Returns:**  
  
* (_none_) nil

**Examples:**

```lua
local tobj = timer.setImmediate(function ()
    print(gpio.read(0))
end)

timer.clearImmediate(tobj)
```
  

********************************************

<a name="API_set"></a>
### set(tid)
Change the internal timer accroding to the specified timer id (default is 6). Be aware of that all callbacks in queue will be cleared when you change to a new timer. It is suggested to use this function within your code of initialization only.

 You can use the property `timer.id` to know which timer is used as an internal one.
  
**Arguments:**  

1. `tid` (_number_): Id of the timer to use. If it is the same with the current id, nothing will happen.

**Returns:**  
  
* (_none_) nil

**Examples:**

```lua
print(timer.id)    -- 6

timer.set(2)
print(timer.id)    -- 2
```

  
<a name="LED"></a>  
## 4. Example: LED Blinks

* The first old-fashioned example is to repeatly turn on an LED for 1 second and turn if off for another second. (my LED is configured with active-low to gpio)  

```lua
local timer = require 'timer'

local LED_PIN1 = 0
gpio.mode(LED_PIN1, gpio.OUTPUT)

local sw1 = true
timer.setInterval(function ()
    if (sw1) then
        gpio.write(LED_PIN1, gpio.LOW)
    else
        gpio.write(LED_PIN1, gpio.HIGH)
    end
    sw1 = not sw1
end, 1000)
```

* The second one shows a generic blinkLED() function used to blink LEDs. It's reentrant and you don't have to worry about which timer is available. Instead, what you have to do is to manage a time-object(a scheduled task) and not the timer itself.  
This example drives three LEDs that blink with different rate and repeat with different times. Each of them is triggered at 1234ms, 3528ms, and 5104ms after scheduled. Try to schedule these simple blinking things with `tmr`, and you may find that it is really a pain in the ass. This is why I made **nodemcu-timer** to shcedule things - to fix my own ass.  

```lua
local timer = require 'timer'

local LED_PIN1, LED_PIN2, LED_PIN3 = 0, 1, 2

gpio.mode(LED_PIN1, gpio.OUTPUT)
gpio.mode(LED_PIN2, gpio.OUTPUT)
gpio.mode(LED_PIN3, gpio.OUTPUT)

function blinkLED(led, times, interval)
    local sw, count, tobj = true, 0

    tobj = timer.setInterval(function ()
        if (sw) then
            gpio.write(led, gpio.LOW)
        else
            gpio.write(led, gpio.HIGH)
            count = count + 1
        end
        sw = not sw
  
        if (count == times) then
            timer.clearInterval(tobj)
            gpio.write(led, gpio.HIGH)
        end
    end, interval)
end

timer.setTimeout(function ()
    blinkLED(LED_PIN1, 5, 560)
end, 1234)

timer.setTimeout(function ()
    blinkLED(LED_PIN2, 3, 1024)
end, 3528)

timer.setTimeout(function ()
    blinkLED(LED_PIN3, 10, 200)
end, 5104)
```
  
<br />
<a href="http://www.youtube.com/watch?feature=player_embedded&v=lgxL6kICU7w" target="_blank"><img src="http://img.youtube.com/vi/lgxL6kICU7w/0.jpg" alt="led demo" width="320" height="240" border="10" />
<br />
********************************************
<br />
## License  
MIT