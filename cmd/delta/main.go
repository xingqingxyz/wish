package main

import (
	"errors"
	"log"
	"os"
	"os/exec"
	"runtime"
	"syscall"

	"charm.land/lipgloss/v2"
	"golang.org/x/term"
)

func fork(path string, args []string) {
	if runtime.GOOS == "windows" {
		cmd := exec.Command(path, args...)
		cmd.Stdin = os.Stdin
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr

		err := cmd.Run()
		if errors.Is(err, &exec.ExitError{}) {
			panic(err)
		}

		os.Exit(cmd.ProcessState.ExitCode())
	} else {
		_ = syscall.Exec(path, args, nil)
	}
}

func main() {
	if !term.IsTerminal(int(os.Stdout.Fd())) {
		log.Println("not a tty")
	}

	args := os.Args[1:]
	if lipgloss.HasDarkBackground(os.Stdin, os.Stdout) {
		args = append(args, "--dark")
	} else {
		args = append(args, "--light")
	}

	path, err := exec.LookPath("delta")
	if err != nil {
		panic("delta exe not found")
	}

	log.Println(path, args)
	fork(path, args)
}
