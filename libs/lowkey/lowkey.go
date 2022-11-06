package lowkey

import (
	"unicode/utf8"

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
		"paint": util.LuaExport{l.lkpaint, 4, false},
		"size": util.LuaExport{l.lksize, 0, false},
		"update": util.LuaExport{l.lkupdate, 0, false},
	}

	mod := rt.NewTable()
	util.SetExports(rtm, mod, exports)

	return rt.TableValue(mod), nil
}

func (l *Lowkey) lkclear(t *rt.Thread, c *rt.GoCont) (rt.Cont, error) {
	return c.Next(), nil
}

func (l *Lowkey) Cleanup() {
	l.scr.Fini()
}

func (l *Lowkey) lkcleanup(t *rt.Thread, c *rt.GoCont) (rt.Cont, error) {
	l.Cleanup()

	return c.Next(), nil
}

func (l *Lowkey) lkupdate(t *rt.Thread, c *rt.GoCont) (rt.Cont, error) {
	l.scr.Show()

	return c.Next(), nil
}

func (l *Lowkey) lksize(t *rt.Thread, c *rt.GoCont) (rt.Cont, error) {
	w, h := l.scr.Size()

	return c.PushingNext(t.Runtime, rt.IntValue(int64(w)), rt.IntValue(int64(h))), nil
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

func (l *Lowkey) lkpaint(t *rt.Thread, c *rt.GoCont) (rt.Cont, error) {
	x, _ := c.IntArg(0)
	y, _ := c.IntArg(1)
	char, _ := c.StringArg(2)
	color, _ := c.TableArg(3)

	bgTbl := color.Get(rt.StringValue("bg")).AsTable()
	bgR := bgTbl.Get(rt.StringValue("r")).AsInt()
	bgG := bgTbl.Get(rt.StringValue("g")).AsInt()
	bgB := bgTbl.Get(rt.StringValue("b")).AsInt()
	bg := tcell.NewRGBColor(int32(bgR), int32(bgG), int32(bgB))

	fgTbl := color.Get(rt.StringValue("fg")).AsTable()
	fgR := fgTbl.Get(rt.StringValue("r")).AsInt()
	fgG := fgTbl.Get(rt.StringValue("g")).AsInt()
	fgB := fgTbl.Get(rt.StringValue("b")).AsInt()
	fg := tcell.NewRGBColor(int32(fgR), int32(fgG), int32(fgB))

	style := tcell.StyleDefault.Background(bg).Foreground(fg)
	ch, _ := utf8.DecodeRuneInString(char)
	l.scr.SetContent(int(x), int(y), ch, nil, style)

	return c.Next(), nil
}
