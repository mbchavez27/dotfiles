#clear prompt
Clear-Host []

#winfetch
Set-Alias winfetch pwshfetch-test-1

#oh my posh and git
$env:POSH_GIT_ENABLED = $true
oh-my-posh --init --shell pwsh --config 'C:\Users\mbchavez\.config\powershell\mbchavez.omp.json' | Invoke-Expression

#Termincal Icons and Readline
Import-Module -Name Terminal-Icons
Import-Module PSReadLine

#Readline Settings
Set-PSReadLineOption -BellStyle None 
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -PredictionViewStyle InlineView

#Fzf Settings
Import-Module PSFzf
Set-PsFzfOption -PSReadLineChordProvider 'Ctrl+f' -PSReadLineChordReverseHistory 'Ctrl+r'

#Alias
Set-Alias vim nvim
Set-Alias vi nvim
Set-Alias lg lazygit
Set-Alias g git
Set-Alias ll ls
Set-Alias grep findstr
Set-Alias tig 'C:\Program Files\Git\usr\bin\tig.exe'
Set-Alias less 'C:\Program Files\Git\usr\bin\less.exe'

#Utilities 
function which ($command) {
    Get-Command -Name $command -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

