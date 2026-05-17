package main

import (
	tea "charm.land/bubbletea/v2"
)

type MyModel struct{}

func (m *MyModel) Init() tea.Cmd {
	return nil
}

func (m *MyModel) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	return m, nil
}

func (m *MyModel) View() tea.View {
	return tea.NewView("Hello World!")
}

func main() {
	file, err := tea.LogToFile("debug.log", "debug")
	if err != nil {
		panic(err)
	}

	defer file.Close()

	_, err = tea.NewProgram(&MyModel{}).Run()
	if err != nil {
		tea.Println(err)
	}
}
