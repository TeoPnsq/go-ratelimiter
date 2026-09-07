$ErrorActionPreference = 'Stop'

Set-Location (Resolve-Path (Join-Path $PSScriptRoot '..'))

function Invoke-Checked {
    param(
        [string]$Label,
        [string]$File,
        [string[]]$Arguments
    )

    Write-Host "==> $Label"
    & $File @Arguments
    if ($LASTEXITCODE -ne 0) {
        Write-Error "failed: $Label (exit $LASTEXITCODE)"
        exit $LASTEXITCODE
    }
}

$goBin = (go env GOPATH).Trim() + '\bin'
if (-not (Get-Command golangci-lint -ErrorAction SilentlyContinue)) {
    if (Test-Path (Join-Path $goBin 'golangci-lint.exe')) {
        $env:Path = "$goBin;$env:Path"
    } else {
        Write-Error "golangci-lint is not on PATH. Install it: go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@latest"
        exit 1
    }
}

Invoke-Checked 'go vet' go @('vet', './...')
Invoke-Checked 'golangci-lint' golangci-lint @('run', './...')
Invoke-Checked 'go test' go @('test', '-race', '-shuffle=on', './...')

Write-Host 'All checks passed.'
