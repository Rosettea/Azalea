package lowkey

import (
	"azalea/util"

	rt "github.com/arnodel/golua/runtime"
	"github.com/arnodel/golua/lib/packagelib"
	"github.com/gdamore/tcell/v2"
)

type Lowkey struct{
	scr tcell.Screen
	Loader packagelib.Loader
}

func New() (*Lowkey, error) {
	s, err := tcell.NewScreen()
	if err != nil {
		return nil, err
	}

	if err := s.Init(); err != nil {
		return nil, err
	}

	l := &Lowkey{
		scr: s,
	}
	l.Loader = packagelib.Loader{
		Load: l.loaderFunc,
		Name: "lowkey",
	}

	return l, nil
}
func (l *Lowkey) loaderFunc(rtm *rt.Runtime) (rt.Value, func()) {
	exports := map[string]util.LuaExport{
		"clear": util.LuaExport{l.lkclear, 0, false},
		"pollEvent": util.LuaExport{l.lkpollEvent, 0, false},
		"cleanup": util.LuaExport{l.lkcleanup, 0, false},
	}

	mod := rt.NewTable()
	util.SetExports(rtm, mod, exports)

	return rt.TableValue(mod), nil
}

func (l *Lowkey) lkclear(t *rt.Thread, c *rt.GoCont) (rt.Cont, error) {
	return c.Next(), nil
}

func (l *Lowkey) lkcleanup(t *rt.Thread, c *rt.GoCont) (rt.Cont, error) {
	l.scr.Fini()

	return c.Next(), nil
}

func (l *Lowkey) lkpollEvent(t *rt.Thread, c *rt.GoCont) (rt.Cont, error) {
	n := c.Next()
	rtm := t.Runtime

	ev := l.scr.PollEvent()
	switch e := ev.(type) {
		case *tcell.EventKey:
			n.Push(rtm, rt.StringValue("key"))
			n.Push(rtm, rt.IntValue(int64(e.Key())))
			n.Push(rtm, rt.IntValue(int64(e.Rune())))
	}

	return n, nil
}
