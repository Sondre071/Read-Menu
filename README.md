# Read-Menu
- A clean, disposable menu to render options from an array.

## Installation
- Clone the repo into your windows modules folder.
  - Or alternatively any other folder within your PSScriptPath.

## Usage
- Invoke the module with the keyword `Read-Menu`.

### Parameters
The only parameter requirement is that at least one option is passed in somehow. The rest is optional
- FirstOptions: An array of options to be placed in front.
- Options: An array of options to be placed in the middle.
- LastOptions: An array of options to be placed at the end.
- ExitOption: A string to be placed at the very end.
- MenuTitle: A string to render the title of the menu screen.
- TitleWidth: The number of columns the menu title will be padded to.
  - Default to 40.
- MenuTextColor: The foreground color of the selected index, and the title.
  - Defaults to yellow.
- CleanUpAfter: Clean up the menu and move the cursor back into base position upon returning.

## Example
`$action = Read-Menu -MenuTitle 'Git menu' -Options ('Pull', 'Fetch all', 'Commit', 'Push with lease', 'Add new action') -ExitOption 'Exit' -CleanUpAfter `
