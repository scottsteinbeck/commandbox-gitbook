# CommandBox GitBook Exporter

A CommandBox module for converting a GitBook into a PDF/eBook.  This is an open source community module and not endorsed or affiliated with GitBook.  You are welcome to contribte to this project via pull request.  The code is written in CFML, a modern JVM scripting language which totally r0x0rs.

## Installation

Use of this module requires CommandBox, a CLI tool for all operating systems.  CommandBox can be installed via HomeBrew, deb/yum repos, or direct download.  

https://commandbox.ortusbooks.com/setup/installation

Once you have `box`, install this module with the following command:

```bash
box install commandbox-gitbook
```

To check for updates, run the following command

```bash
box update --system
```

## CommandBox Basics

CommandBox (or `box` as the binary is named) commands can be run as follows:

```bash
box gitbook toc
```

or for a better experience, you can enter the CommandBox shell (similar to Bash) 

```bash
box
```

and then run your command without the `box` portion since you're already "inside" of box.  

```bash
CommandBox> gitbook toc
```

This provides a faster experience and also allows you to use the built in tab-completion that the box shell provides for all commands, params, and values.

More information here: https://commandbox.ortusbooks.com/usage/execution

CommandBox allows named or positional parameters, so the following are equivalent.

```bash
CommandBox> gitbook toc /path/to/export current
CommandBox gitbook toc sourcePath=/path/to/export version=current
```

## GitBook commands

The `gitbook` namespace has three commands. 

* `gitbook versions` - Show all the versions of a book
* `gitbook toc` - Show the table of contents for a specific version of a book
* `gitbook export` - Export the content into a PDF or HTML. (More formats coming soon)

### Acquire your book export

In order to use the command, you will need to export the contents of your book from the Gitbook.com website.  Under `Advanced`, expand `Danger Zone` and click the red `Export` button.  Make sure you don't hit `Delete` instead!
You will download a zip fie containing JSON files and images that describe all of the content in your book.

You can point to the zip when you run a command  

```bash
CommandBox> gitbook toc /path/to/export.zip
```

Or you can unzip the archive and point to the folder which will prevent the temp fies from being deleted every time you run an export:

```bash
CommandBox> gitbook toc /path/to/exportFolder
```

The recommended and easiest approach is simply to unzip the archive, `cd` into the root of the unzipped book export and run the commands from there.  They will "find" the book via convention.

```bash
CommandBox> cd /path/to/exportFolder/
CommandBox gitbook toc
```

### List Book Versions

List the versions of a book export and the book title with the `gitbook versions` command.

```bash
CommandBox> gitbook versions

My Book Title

 - 1.0.0 (master)
 - 1.0.2
```

In the example above, `1.0.0` is the title of the version, but `master` is the branch or folder name used to store it.

### List Book Table Of Contents

List the TOC from a given version of a book export and the book title with the `gitbook toc` command.  By default, the default verson of the book will be used.

```bash
CommandBox> gitbook toc

My Book Title (1.0.2)

  Section 1

  Section 2
    ├── Sub Page A
    └── Sub Page B

  Section 3
    ├─┬ Sub Page C
    | └── Sub Sub Page D
    └── Sub Page E
```

To view the TOC for a specif version of the book, pass in the title of the version you wish to see.

```bash
CommandBox> gitbook toc version=1.0.0
```

### Export Book Contents

The `gitbook export` command is likely what you're here for.  It will parse the JSON export files, download any missing assets, render HTML partials for each page, and then export that to PDF or other formats (coming soon).

```bash
CommandBox> gitbook export
```

You can specify the book export and version you want to export:

```bash
CommandBox> gitbook export sourcePath=/path/to/ExportFolder version=1.5.6
```
### Export formats

By default, all formats will be created (HTML, PDF).  You can export only formats you want (whitelist):
```bash
CommandBox> gitbook export --PDF
CommandBox> gitbook export --HTML
```
or turn off formats you don't want
```bash
CommandBox> gitbook export --noPDF
CommandBox> gitbook export --noHTML
```

Note, `--PDF` is the same as `PDF=true` and `--noPDF` is the same as `PDF=false`.

### General Export Settings

You can control several general export settings by passing additional params to the command.  To see all the options run `gitbook export help`.

* `coverPageImageFile` - Full or absolute path to an image file to completely replace the default book cover page.
* `codeHighlighlightTheme` - A valid CSS theme for the Pygments syntax highlighter. See here: http://jwarby.github.io/jekyll-pygments-themes/
* `showTOC` - Set to false to not render a Table Of Contents for the book (defaults to true)
* `showPageNumbers` - Set to false to not render page numbers in header/footer (defaults to true)
* `showTitleInPage` - Set to false to not render page title in header/footer (defaults to true)

Example: 

```bash
CommandBox> gitbook export coverPageImageFile=myBookCover.jpg codeHighlighlightTheme=fruity --noShowTOC --noShowPageNumbers --noShowTitleInPage
```
 
Hint, when using the interactive CommandBox shell, you can use tab completion to get suggestions on possible Pygments themes and file system completion. 

### PDF Page Export Settings

There are a handful of export settings that are passed to the underlying PDF engine to help control the page size.  To see all the options run `gitbook export help`.

* `pageheight` - Page height in inches (default) or centimeters. Only applies to pagetype=custom
* `pagewidth` - Page width in inches (default) or centimeters. Only applies to pagetype=custom
* `pagetype` - Page sizes. legal, letter, A4, A5, B5, Custom
* `orientation` - Page orientation. Specify either of the following: portrait (default), landscape
* `margintop` - Top margin in inches (default) or centimeters
* `marginbottom` - Bottom margin in inches (default) or centimeters
* `marginleft` - Left margin in inches (default) or centimeters
* `marginright` - Right margin in inches (default) or centimeters
* `unit` - Default unit ("in" or "cm") for pageheight, pagewidth, and margin parameters

Example: 

```bash
CommandBox> gitbook export pageType=letter orientation=landscape
``` 

```bash
CommandBox> gitbook export pageType=custom pageHeight=9.5 pageWidth=6.25 unit=in margintop=.5 marginbottom=.5 marginleft=1 marginright=1
```

## Authors

* *Scott Steinbeck* - https://twitter.com/uniquetrio2000
* *Brad Wood* - https://twitter.com/bdw429s

Development of this module was sponsored in part by Ortus Solutions. 
https://ortussolutions.com/

## Support
This is an open source and free module.  The source code is located here, and written in CFML:

https://github.com/scottsteinbeck/commandbox-gitbook

Please enter tickets for any issues you have:

https://github.com/scottsteinbeck/commandbox-gitbook/issues

If you just want to ask a question, you can reach the authors as `@bdw429s` and `@Scott Steinbeck` on this public Slack team: https://boxteam.herokuapp.com/

