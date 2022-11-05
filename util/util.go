// TODO: make this a separate package (that hilbish can also import)
// since this is just copied code from hilbish

package util

import (
	"bufio"
	"io"
	"strings"
	"os"
	"os/user"

	rt "github.com/arnodel/golua/runtime"
)

// Document adds a documentation string to a module.
// It is accessible via the __doc metatable.
func Document(module *rt.Table, doc string) {
	mt := module.Metatable()
	
	if mt == nil {
		mt = rt.NewTable()
		module.SetMetatable(mt)
	}

	mt.Set(rt.StringValue("__doc"), rt.StringValue(doc))
}

// SetField sets a field in a table, adding docs for it.
// It is accessible via the __docProp metatable. It is a table of the names of the fields.
func SetField(rtm *rt.Runtime, module *rt.Table, field string, value rt.Value, doc string) {
	// TODO:    ^ rtm isnt needed, i should remove it
	SetFieldDoc(module, field, doc)
	module.Set(rt.StringValue(field), value)
}

// SetFieldDoc sets the __docProp metatable for a field on the
// module.
func SetFieldDoc(module *rt.Table, field, doc string) {
	mt := module.Metatable()

	if mt == nil {
		mt = rt.NewTable()
		module.SetMetatable(mt)
	}

	docProp := mt.Get(rt.StringValue("__docProp"))
	if docProp == rt.NilValue {
		docPropTbl := rt.NewTable()
		mt.Set(rt.StringValue("__docProp"), rt.TableValue(docPropTbl))
		docProp = mt.Get(rt.StringValue("__docProp"))
	}

	docProp.AsTable().Set(rt.StringValue(field), rt.StringValue(doc))
}

// SetFieldProtected sets a field in a protected table. A protected table
// is one which has a metatable proxy to ensure no overrides happen to it.
// It sets the field in the table and sets the __docProp metatable on the
// user facing table.
func SetFieldProtected(module, realModule *rt.Table, field string, value rt.Value, doc string) {
	SetFieldDoc(module, field, doc)
	realModule.Set(rt.StringValue(field), value)
}

// DoString runs the code string in the Lua runtime.
func DoString(rtm *rt.Runtime, code string) error {
	chunk, err := rtm.CompileAndLoadLuaChunk("<string>", []byte(code), rt.TableValue(rtm.GlobalEnv()))
	if chunk != nil {
		_, err = rt.Call1(rtm.MainThread(), rt.FunctionValue(chunk))
	}

	return err
}

// DoFile runs the contents of the file in the Lua runtime.
func DoFile(rtm *rt.Runtime, path string) error {
	f, err := os.Open(path)
	defer f.Close()

	if err != nil {
		return err
	}
	
	reader := bufio.NewReader(f)
	c, err := reader.ReadByte()
	if err != nil && err != io.EOF {
		return err
	}

	// unread so a char won't be missing
	err = reader.UnreadByte()
	if err != nil {
		return err
	}

	var buf []byte
	if c == byte('#') {
		// shebang - skip that line
		_, err := reader.ReadBytes('\n')
		if err != nil && err != io.EOF {
			return err
		}
		buf = []byte{'\n'}
	}

	for {
		line, err := reader.ReadBytes('\n')
		if err != nil {
			if err == io.EOF {
				break
			}
			return err
		}
		
		buf = append(buf, line...)
	}

	clos, err := rtm.LoadFromSourceOrCode(path, buf, "bt", rt.TableValue(rtm.GlobalEnv()), false)
	if clos != nil {
		_, err = rt.Call1(rtm.MainThread(), rt.FunctionValue(clos))
	}

	return err
}

// HandleStrCallback handles function parameters for Go functions which take
// a string and a closure.
func HandleStrCallback(t *rt.Thread, c *rt.GoCont) (string, *rt.Closure, error) {
	if err := c.CheckNArgs(2); err != nil {
		return "", nil, err
	}
	name, err := c.StringArg(0)
	if err != nil {
		return "", nil, err
	}
	cb, err := c.ClosureArg(1)
	if err != nil {
		return "", nil, err
	}

	return name, cb, err
}

// ForEach loops through a Lua table.
func ForEach(tbl *rt.Table, cb func(key rt.Value, val rt.Value)) {
	nextVal := rt.NilValue
	for {
		key, val, _ := tbl.Next(nextVal)
		if key == rt.NilValue {
			break
		}
		nextVal = key

		cb(key, val)
	}
}

// ExpandHome expands ~ (tilde) in the path, changing it to the user home
// directory.
func ExpandHome(path string) string {
	if strings.HasPrefix(path, "~") {
		curuser, _ := user.Current()
		homedir := curuser.HomeDir

		return strings.Replace(path, "~", homedir, 1)
	}

	return path
}

// AbbrevHome changes the user's home directory in the path string to ~ (tilde)
func AbbrevHome(path string) string {
	curuser, _ := user.Current()
	if strings.HasPrefix(path, curuser.HomeDir) {
		return "~" + strings.TrimPrefix(path, curuser.HomeDir)
	}

	return path
}
