package lotus

import (
	"io"
	"os"

	"azalea/util"

	rt "github.com/arnodel/golua/runtime"
	"github.com/arnodel/golua/lib/packagelib"
	"github.com/gen2brain/malgo"
	"github.com/hajimehoshi/go-mp3"
)

type player struct{
	ctx *malgo.AllocatedContext
	device *malgo.Device
	st stream
}

var Loader = packagelib.Loader{
	Load: loaderFunc,
	Name: "lotus",
}
var lotusInstance *player

func loaderFunc(rtm *rt.Runtime) (rt.Value, func()) {
	exports := map[string]util.LuaExport{
		"play": util.LuaExport{lplay, 1, false},
	}

	mod := rt.NewTable()
	util.SetExports(rtm, mod, exports)

	lotusInstance, _ = newPlayer()

	return rt.TableValue(mod), nil
}

func lplay(t *rt.Thread, c *rt.GoCont) (rt.Cont, error) {
	if err := c.Check1Arg(); err != nil {
		return nil, err
	}

	filename, err := c.StringArg(0)
	if err != nil {
		return nil, err
	}

	err = lotusInstance.Start(filename)
	if err != nil {
		return nil, err
	}
	lotusInstance.Play()

	return c.Next(), nil
}

func newPlayer() (*player, error) {
	ctx, err := malgo.InitContext(nil, malgo.ContextConfig{}, func(message string) {
		// TODO: log to some location that doesnt interrupt ui?
	})
	if err != nil {
		return nil, err
	}

	return &player{
		ctx: ctx,
	}, nil
}

func (p *player) uninit() {
	p.ctx.Uninit()
	p.ctx.Free()
}

func (p *player) Start(filename string) error {
	file, err := os.Open(filename)
	if err != nil {
		return err
	}

	decoder, err := mp3.NewDecoder(file)
	if err != nil {
		return err
	}
	sampleRate := uint32(decoder.SampleRate())

	p.st = stream{
		source: decoder,
		sampleRate: sampleRate,
	}

	deviceConfig := malgo.DefaultDeviceConfig(malgo.Playback)
	deviceConfig.Playback.Format = malgo.FormatS16
	deviceConfig.Playback.Channels = 2
	deviceConfig.SampleRate = p.st.sampleRate
	deviceConfig.PeriodSizeInFrames = 2048
	deviceConfig.Alsa.NoMMap = 1

	if p.device != nil {
		p.device.Uninit()
	}

	dev, err := malgo.InitDevice(p.ctx.Context, deviceConfig, malgo.DeviceCallbacks{
		Data: p.st.handleSamples,
	})
	if err != nil {
		dev.Uninit()
		return err
	}

	p.device = dev
	return nil
}

func (p *player) IsPlaying() bool {
	return p.device.IsStarted()
}

func (p *player) Play() error {
	return p.device.Start()
}

func (p *player) Pause() error {
	return p.device.Stop()
}
