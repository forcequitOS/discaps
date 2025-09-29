<p align="center">
<img src="https://github.com/forcequitOS/discaps/blob/main/discaps.png?raw=true" width="30%">
</p>

<h2 align="center">A disk activity light on your Caps Lock key.</h2>

**Try it today, you'll love it, or your money back!**

### Install
```
brew install forcequitOS/brew/discaps
```

It couldn't get much simpler than this. 

---
### Run At Startup
**Globally:**

1. Run `sudo brew services start discaps`
2. Grant Input Monitoring permissions in System Settings
3. Run `sudo brew services restart discaps` (Or restart the computer)
---
**Only Current User:**
1. Run `brew services start discaps`
2. Grant Input Monitoring permissions in System Settings
3. Run `brew services restart discaps` (Or log out and log back in)

---
And you're off to the races!

>[!TIP]
This is quite literally the exact same thing as netcaps, but for disk activity, so the same stuff for netcaps also applies here. Check out the sister program, netcaps, [here.](https://github.com/forcequitOS/netcaps)

>[!NOTE]
All functionality of your Caps Lock key is 100% preserved with discaps. Also, discaps is proudly written in Swift. Yay. 

>[!WARNING]
I don't know if this will impact your battery life or if it'll kill your Caps Lock key LED over time. Your mileage may vary. I'm not responsible if this somehow blows up your computer, but it probably shouldn't. 

---
### Usage:

`discaps [arguments]`

**Arguments:**

--silent, -s	- Silences command-line output

--version, -v	- Displays the current version of discaps

--help, -h		- Shows the help menu

That really. Is about it. Have fun. 
