# MarkdownToPlaygroundConverter
Converts to and from markdown to playground format. 

### A handy utilty that converts a markdown file into a playground markdown file and the otherway around.

Created by Paul Ossenbruggen on 10/22/17.
Copyright © 2017 Paul Ossenbruggen. All rights reserved.

    Markdown Converter:

    Tool for convering Swift Playgrounds into or out of Markdown(.md) format so they can be displayed in Github nicely.

    -p  --toPlayground        [Markdown File Path] Converts from Markdown file to Playground.
    -m  --toMarkdown         [Playground File Path] Converts from Playground file to Markdown.
    -h  --help               This help

Example Usage convert to playground, put it on your path or run it with full path to built program.
    
    MarkdownConverter -toPlayground Markdown.md > MyPlayground.playground/Contents.swift
    MarkdownConverter -toMarkdown MyPlayground.playground/Contents.swift > Markdown.md
    
Main Structs which has good example code for how to do a simple CommandLine tool in Swift using Functional programming concepts in Swift 4:

* CommandTool which takes the command line arguments and dispatches to handlers for the differnt operations as well as displaying help for the arguments.
* Converter which actually does the conversion process to and from the differnt formats. The toMatches function breaks the file up into lines, which is then handed to the two coversion types. 
