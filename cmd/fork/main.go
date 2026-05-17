//go:build windows

package main

import (
	"errors"
	"os"
	"os/exec"
)

var execPath = `C:\Program Files\Git\usr\bin\env.exe`

func main() {
	cmd := exec.Command(execPath, os.Args[1:]...)
	path := "C:\\Program Files\\Git\\usr\\bin;C:\\Program Files\\Git\\mingw64\\bin;" + os.Getenv("Path")
	cmd.Env = append(os.Environ(), "Path="+path)
	cmd.Stdin = os.Stdin
	cmd.Stderr = os.Stderr

	cmd.Stdout = os.Stdout
	err := cmd.Run()
	if errors.Is(err, &exec.ExitError{}) {
		panic(err)
	}

	os.Exit(cmd.ProcessState.ExitCode())
}
