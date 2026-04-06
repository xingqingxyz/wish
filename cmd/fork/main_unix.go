//go:build !windows

package main

import (
	"os"
	"syscall"
)

var execPath string

func main() {
	_ = syscall.Exec(execPath, os.Args, nil)
}
