//go:build !windows

package main

import (
	"os"
	"syscall"
)

var execPath = "/usr/bin/env"

func main() {
	_ = syscall.Exec(execPath, os.Args, nil)
}
