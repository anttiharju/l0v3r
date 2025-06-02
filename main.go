package main

import (
	"context"
	"os"

	"github.com/anttiharju/go-starter/internal/cli"
	"github.com/anttiharju/go-starter/internal/exitcode"
	"github.com/anttiharju/go-starter/internal/interrupt"
)

func main() {
	go interrupt.Listen(exitcode.Interrupt, os.Interrupt)

	ctx := context.Background()
	exitcode := cli.Start(ctx, os.Args[1:])
	os.Exit(int(exitcode))
}
