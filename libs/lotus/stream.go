package lotus

import (
	"io"
	"time"
)

type stream struct{
	source io.ReadSeeker
	sampleRate uint32
	pos int64
}

func (st *stream) handleSamples(out, in []byte, framecount uint32) {
	io.ReadFull(st.source, out)
	st.pos += int64(len(out))
}
