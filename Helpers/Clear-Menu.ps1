function Clear-Menu {
    [OutputType([void])]
    param (
        [Parameter(Mandatory)]
        [int]$Height
    )

    # Jump $Height lines up and clear everything below.
    Write-Host "`e[$($Height)A" -NoNewLine
    Write-Host "`e[0J" -NoNewLine
}