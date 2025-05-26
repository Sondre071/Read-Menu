# Read-Menu

- A clean, disposable menu to render an array of options.

## Installation

- Clone the repo into your windows modules folder.
  - Or alternatively into any folder within your PSScriptPath.

## Usage

- Invoke the module using the keyword `Read-Menu`.

### Parameters

The only parameter requirement is that at least one option is passed in somehow. The rest is optional.

- Options: An array of options.
- ExitOption: A string to be placed at the end, and returned when exiting the menu using `esc`, `q` or `h`.
- Header: A string to render the title of the menu screen.
- HeaderWidth: The number of columns the menu title will be added to.
  - Defauls to 40.
- Subheaders: An array to render beneath the menu header.
- MenuTextColor: The foreground color of the selected index, and the title.
  - Defaults to yellow.

## Example
```console
$options = ('Pull', 'Fetch all', 'Commit', 'Add new command')

$action = Read-Menu -Header 'Select action' -Options $options -ExitOption 'Exit'

switch($action) {
  case 'Pull':
    ...

  case 'Fetch all':
    ...

  case 'Commit':
    ...

  case 'Add new command':
    ...

  case 'Exit':
    return
}
```
![image](https://github.com/user-attachments/assets/7731cb6d-accf-46b5-970a-5a276b89cc37)
