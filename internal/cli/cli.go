package cli

import (
	"context"

	"github.com/anttiharju/go-starter/internal/exitcode"
	"github.com/anttiharju/go-starter/internal/version"
)

func Start(_ context.Context, _ []string) exitcode.Exitcode {
	return version.Print()
}
