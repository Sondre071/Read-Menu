# Read-Menu

- A clean, disposable menu to render an array of options.

## Installation

- Clone the repo into your windows modules folder.
  - Or alternatively into any folder within your PSScriptPath.

## Usage

- Invoke the module using the keyword `Read-Menu`.

### Parameters

The only requirement is that at least one option is passed in. The rest is optional.
Options can be one of two things. Anything able to be printed, or an object with a ".Name"-accessible property.

- Options: An array of options.
- ExitOption: An option placed at the end, and returned when exiting the menu using `esc`, `q` or `h`.
- Header: A string to render the title of the menu screen.
- HeaderWidth: The number of columns the menu title will be added to.
  - Defaults to 40.
- Subheaders: An array of strings to render beneath the menu header.
  - An empty string at the end can be used for padding.
- Color: The foreground color of the selected index, header, and subheaders.
  - Defaults to yellow.

## Example

```powershell
$options = ('Pull', 'Push', 'Fetch all', 'Commit')

$action = Read-Menu `
    -Header 'Select action' `
    -Subheaders ('Pull is set to ff-only.', '') `
    -Options $options `
    -ExitOption 'Exit'

switch($action) {
  'Pull': {
    ...
  }

  'Push': {
    ...
  }

  'Fetch all': {
    ...
  }

  'Commit' {
    ...
  }

  'Exit': {
    return
  }
}
```
