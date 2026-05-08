package main

import (
	"fmt"
	"io"
	"log"
	"os"
	"os/exec"
	"strings"

	"charm.land/glamour/v2"
	"charm.land/lipgloss/v2"
	"github.com/spf13/cobra"
	"golang.org/x/term"
)

var version = "3.0.0"

var (
	baseUrl          string
	color            string
	pager            string
	paging           string
	style            string
	wordWrap         int
	inlineTableLinks bool
	preserveNewLines bool
	tableWrap        bool
)

var cmd = &cobra.Command{
	Use:     "glow [file]..",
	Short:   "Render markdown in terminal.",
	Version: version,
	Args:    cobra.MinimumNArgs(0),
	PreRunE: func(cmd *cobra.Command, args []string) error {
		isOutTty := term.IsTerminal(int(os.Stdout.Fd()))
		switch color {
		case "always":
		case "auto":
			if !isOutTty {
				style = "notty"
			}
		case "never":
			style = "notty"
		default:
			return fmt.Errorf("glow: unknown color: %s", color)
		}
		switch style {
		case "auto":
			if lipgloss.HasDarkBackground(os.Stdin, os.Stdout) {
				style = "dark"
			} else {
				style = "light"
			}
		case "ascii", "dark", "light", "pink", "notty", "dracula", "tokyo-night":
		default:
			if info, err := os.Stat(style); err != nil || info.IsDir() {
				return fmt.Errorf("glow: invalid style path: %s", style)
			}
		}
		switch pager {
		case "auto":
			if pager = os.Getenv("PAGER"); pager == "" {
				pager = "less"
			}
		}
		switch paging {
		case "auto":
			if isOutTty {
				paging = "always"
			} else {
				paging = "never"
			}
		}
		return nil
	},
	RunE: run,
}

func init() {
	cmd.Flags().StringVar(&baseUrl, "base-url", "", "base url for relative links")
	cmd.Flags().StringVar(&color, "color", "auto", "ansi color output (auto|always|never)")
	cmd.Flags().StringVar(&pager, "pager", "auto", "pager to use (auto|builtin|none|[path])")
	cmd.Flags().StringVar(&paging, "paging", "auto", "enable paging (auto|always|never)")
	cmd.Flags().StringVarP(&style, "style", "s", "auto", "style or path to style json file (auto|ascii|dark|light|pink|notty|dracula|tokyo-night|[path])")
	cmd.Flags().IntVarP(&wordWrap, "word-wrap", "w", 80, "word wrap width (0 for no wrap)")
	cmd.Flags().BoolVarP(&inlineTableLinks, "inline-table-links", "i", true, "inline table links")
	cmd.Flags().BoolVarP(&preserveNewLines, "preserve-new-lines", "n", false, "preserve new lines")
	cmd.Flags().BoolVarP(&tableWrap, "table-wrap", "t", false, "table wrap")
	_ = cmd.RegisterFlagCompletionFunc("color", func(cmd *cobra.Command, args []string, toComplete string) ([]cobra.Completion, cobra.ShellCompDirective) {
		return []string{"auto", "always", "never"}, cobra.ShellCompDirectiveDefault
	})
	_ = cmd.RegisterFlagCompletionFunc("paging", func(cmd *cobra.Command, args []string, toComplete string) ([]cobra.Completion, cobra.ShellCompDirective) {
		return []string{"auto", "always", "never"}, cobra.ShellCompDirectiveDefault
	})
	_ = cmd.RegisterFlagCompletionFunc("pager", func(cmd *cobra.Command, args []string, toComplete string) ([]cobra.Completion, cobra.ShellCompDirective) {
		return []string{"auto", "builtin", "none"}, cobra.ShellCompDirectiveDefault
	})
	_ = cmd.RegisterFlagCompletionFunc("style", func(cmd *cobra.Command, args []string, toComplete string) ([]cobra.Completion, cobra.ShellCompDirective) {
		return []string{"auto", "ascii", "dark", "light", "pink", "notty", "dracula", "tokyo-night"}, cobra.ShellCompDirectiveDefault
	})
}

func getWriter() (*os.File, *exec.Cmd) {
	if paging != "always" {
		return os.Stdout, nil
	}
	r, w, err := os.Pipe()
	if err != nil {
		return os.Stdout, nil
	}
	pagerArgs := strings.Fields(pager)
	pagerCmd := exec.Command(pagerArgs[0], pagerArgs[1:]...)
	pagerCmd.Stdin = r
	pagerCmd.Stdout = os.Stdout
	pagerCmd.Stderr = os.Stderr
	if err := pagerCmd.Start(); err != nil {
		return os.Stdout, nil
	}
	return w, pagerCmd
}

func run(cmd *cobra.Command, args []string) error {
	opts := []glamour.TermRendererOption{
		glamour.WithStylePath(style),
		glamour.WithWordWrap(wordWrap),
		glamour.WithInlineTableLinks(inlineTableLinks),
		glamour.WithTableWrap(tableWrap),
	}
	if baseUrl != "" {
		opts = append(opts, glamour.WithBaseURL(baseUrl))
	}
	if preserveNewLines {
		opts = append(opts, glamour.WithPreservedNewLines())
	}
	r, err := glamour.NewTermRenderer(opts...)
	if err != nil {
		return err
	}
	if len(args) == 0 {
		args = []string{"-"}
	}
	writer, pagerCmd := getWriter()
	pagerEch := make(chan error, 1)
	if pagerCmd != nil {
		go func() {
			pagerEch <- pagerCmd.Wait()
		}()
	}
	defer func() {
		_ = writer.Close()
		if pagerCmd != nil {
			<-pagerEch
		}
	}()
	for _, arg := range args {
		var bytes []byte
		var err error
		if arg == "-" {
			bytes, err = io.ReadAll(os.Stdin)
		} else {
			bytes, err = os.ReadFile(arg)
		}
		if err != nil {
			return err
		}
		bytes, err = r.RenderBytes(bytes)
		if err != nil {
			return err
		}
		ech := make(chan error)
		go func() {
			_, err := writer.Write(bytes)
			ech <- err
		}()
		select {
		case err = <-pagerEch:
			pagerEch <- nil
			return err
		case err = <-ech:
			if err != nil {
				return err
			}
		}
	}
	return nil
}

func main() {
	err := cmd.Execute()
	if err != nil {
		log.Fatal(err)
	}
}
