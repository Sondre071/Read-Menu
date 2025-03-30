# Read-Menu

- A clean, disposable menu to render options from an array.

## Installation

- Clone the repo into your windows modules folder.
  - Or alternatively into any folder within your PSScriptPath.

## Usage

- Invoke the module using the keyword `Read-Menu`.

### Parameters

The only parameter requirement is that at least one option is passed in somehow. The rest is optional
- Options: An array of options to be placed in the middle.
- ExitOption: A string to be placed at the end, and returned when exiting the menu using `esc` or `q`.
- MenuTitle: A string to render the title of the menu screen.
- TitleWidth: The number of columns the menu title will be padded to.
  - Default to 40.
- MenuTextColor: The foreground color of the selected index, and the title.
  - Defaults to yellow.
- CleanUpAfter: Clean up the menu and move the cursor back into base position upon returning.

## Example

`$options = ('Pull', 'Fetch all', 'Commit', 'Add new command')`

`$action = Read-Menu -MenuTitle 'Select action' -Options $options -ExitOption 'Exit' -CleanUpAfter `
