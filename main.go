package main

import (
	"fmt"
	"os"
	"os/signal"
	"syscall"
	"time"

	"azalea/util"
	"azalea/libs/lotus"
	"azalea/libs/lowkey"

	rt "github.com/arnodel/golua/runtime"
	"github.com/arnodel/golua/lib"
	"github.com/arnodel/golua/lib/debuglib"
)

func main() {
	go handleSignals()

	r := rt.New(nil)
	r.PushContext(rt.RuntimeContextDef{
		MessageHandler: debuglib.Traceback,
	})
	lib.LoadAll(r)

	lib.LoadLibs(r, lotus.Loader)
	lk, _ := lowkey.New()
	lib.LoadLibs(r, lk.Loader)

	exports := map[string]util.LuaExport{
		"sleep": util.LuaExport{sleep, 1, false},
	}

	util.SetExports(r, r.GlobalEnv(), exports)

	err := util.DoFile(r, "data/init.lua")
	if err != nil {
		lk.Cleanup()
		fmt.Println(err)
		os.Exit(1)
	}

	exit := make(chan bool)
	<-exit
}

func handleSignals() {
	c := make(chan os.Signal)
	signal.Notify(c, os.Interrupt, syscall.SIGTERM)

	for s := range c {
		switch s {
		case os.Interrupt, syscall.SIGTERM:
			os.Exit(0)
		}
	}
}

func sleep(t *rt.Thread, c *rt.GoCont) (rt.Cont, error) {
	secs, err := c.IntArg(0)
	if err != nil {
		return nil, err
	}

	time.Sleep(time.Duration(secs) * time.Second)
	return c.Next(), nil
}
