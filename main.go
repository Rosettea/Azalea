package main

import (
	"fmt"
	"os"
	"path/filepath"

	"azalea/util"
	"azalea/libs/lotus"

	rt "github.com/arnodel/golua/runtime"
	"github.com/arnodel/golua/lib"
	"github.com/arnodel/golua/lib/debuglib"
)

func main() {
	r := rt.New(nil)
	r.PushContext(rt.RuntimeContextDef{
		MessageHandler: debuglib.Traceback,
	})
	lib.LoadAll(r)

	lib.LoadLibs(r, lotus.Loader)

	confDir, _ := os.UserConfigDir()
	azConf := filepath.Join(confDir, "azalea", "init.lua")

	err := util.DoFile(r, azConf)
	if err != nil {
		err = util.DoFile(r, "azalea.lua")
		if err != nil {
			fmt.Println(err)
			os.Exit(1)
		}
	}

	exit := make(chan bool)
	<-exit
}
