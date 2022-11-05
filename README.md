# Azalea
> 🌹 Azalea Music Player ✨ — An extensible and highly customizable music player!

Azalea is a new terminal music player, different from the others.
Azalea aims to be fully customizable and scriptable in Lua, changing
small things like the music path to being able to rewrite the UI fully to
your liking.

> **Warning**
> Azalea has only just started development, which means that is will be missing
lots of basic functionality and its Lua API will **NOT** be stable.

# Compiling
Azalea relies on miniaudio/malgo to play audio, which requires CGO and
a C compiler.

Azalea can be compiled with the following commands:  
```
git clone https://github.com/Rosettea/Azalea
cd Azalea
go get
go build
```  

Now, there will be an `azalea` executable in the current directory.  

# Configuration
Azalea can be scripted with a Lua file, located either in `~/.config/azalea/init.lua`
or `azalea.lua` in the current directory.

# Contributing
`bliss.mp3` is a test file, which is the track BLISS by Phonkha and 
featuring KIL KROOK if you need any audio to test.

Currently there are not a lot of rules when contributing code, and there
is not a lot to test. I will not bother with any small PRs like README
changes since getting Azalea to a first version is top priority.

Code contributions and API proposals should be discussed via a Github
issue first before implementing. Go code must NOT be gofmt formatted
and Lua code should use single quotes with `()` omitted for functions
that take a single string argument.

# License
MIT
