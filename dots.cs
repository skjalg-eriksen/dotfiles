#!/usr/bin/dotnet run
#:package Spectre.Console@0.55.2
// #:package Spectre.Console.Cli@0.55.0

using Spectre.Console;

// TODO: get all configurations at dots.cs file location
// TODO: treat certain dirs as Module configs, like .config/*, or emacs.d 
List<string> configs = ["Logging", "Caching", "Compression", "Authentication"];

// TODO: list the current state of the feature
// TODO: if possible add filtering/fuzzy searching
var selected = AnsiConsole.Prompt(
    new MultiSelectionPrompt<string>()
        .Title("Toggle [green]features[/]")
        .AddChoices(configs)
);

var enabledConfigs = 0;
foreach (var path in configs)
{
    var state = selected.Contains(path);
    if (state) enabledConfigs++;

    var enabled = Markup.Escape("[X]");
    var disabled = Markup.Escape("[ ]");
    string indicator = state ? $"[green]{enabled}[/]" : $"[gray]{disabled}[/]";

    AnsiConsole.MarkupLine($"  {indicator}\t{path}");
}

AnsiConsole.MarkupLine($" [green]{enabledConfigs}[/] dot features enabled");
AnsiConsole.MarkupLine($" [gray]{configs.Count-enabledConfigs}[/] dot features disabled");
