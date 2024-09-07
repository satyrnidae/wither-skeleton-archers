<#
    Powershell Data Pack Build Toolchain v2.1
    Licensed under ACSL-1.4. Some Rights Reserved.
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory=$False)]
    [Switch] $SkipCleanup
)

function Copy-DataFiles() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True,Position=1)]
        [String[]] $Exclude,
        [Parameter(Mandatory=$True,Position=2)]
        [String] $Source,
        [Parameter(Mandatory=$True,Position=3)]
        [String] $Destination
    )

    if (-not (Test-Path -LiteralPath $Source -PathType Container)) {
        throw "Unable to locate source directory: $Source"
    }
    if (Test-Path -LiteralPath $Destination -PathType Container) {
        Remove-Item -LiteralPath $Destination -Force -Verbose:$VerbosePreference -ErrorAction:$ErrorActionPreference
    }
    New-Item -Path $Destination -ItemType Directory -Verbose:$VerbosePreference -ErrorAction:$ErrorActionPreference | Out-Null

    Get-ChildItem -LiteralPath $Source -Exclude $Exclude -Verbose:$VerbosePreference -ErrorAction:$ErrorActionPreference | ForEach-Object {
        Copy-Item -Recurse $_ $Destination -Verbose:$VerbosePreference -ErrorAction:$ErrorActionPreference
    }
}

function Expand-DataFiles() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True,Position=1)]
        [PSObject] $Options,
        [Parameter(Mandatory=$True,Position=2)]
        [String] $Directory
    )

    $Options.expandOpts | ForEach-Object {
        $TempFile = (Join-Path $Directory $_)

        if (Test-Path -LiteralPath $TempFile -PathType Leaf) {
            $IntermediateContents = (Get-Content -LiteralPath $TempFile -Raw) -replace '\$\{([a-zA-Z_\.]+)}', '$($Options.${1})'
            Remove-Item -LiteralPath $TempFile -Force -Verbose:$VerbosePreference -ErrorAction:$ErrorActionPreference
            # Rename resourcepack.mcmeta
            if ($_ -match "resourcepack\.mcmeta") {
                $TempFile = (Join-Path $Directory "pack.mcmeta")
                if (Test-Path -LiteralPath $TempFile -PathType Leaf) {
                    Remove-Item -LiteralPath $TempFile -Force -Verbose:$VerbosePreference -ErrorAction:$ErrorActionPreference
                }
            }
            $ExecutionContext.InvokeCommand.ExpandString($IntermediateContents) | Out-File -LiteralPath $TempFile -Encoding utf8 -Verbose:$VerbosePreference -ErrorAction:$ErrorActionPreference
        } else {
            if (Test-Path -LiteralPath $TempFile -PathType Container) {
                Write-Warning "Nothing to expand for ${TempFile}: Is a directory."
            } else {
                Write-Verbose "Nothing to expand for ${TempFile}: Not present."
            }
        }
    }
}


Push-Location $PSScriptRoot

try {

    # Read options
    $Options = ConvertFrom-Json (Get-Content -Raw build.jsonc)
    $ArchiveName = "out/$($Options.version)/$($Options.baseArchiveName)-$($Options.version)"
    $JarExe = (Join-Path $Options.jdkHome 'bin/jar.exe')

    if (Test-Path ./temp/ -PathType Container) {
        Remove-Item -Recurse ./temp/ -Force -Verbose:$VerbosePreference -ErrorAction:$ErrorActionPreference
    }

    # Create new temporary directories
    New-Item ./temp/ -ItemType Directory -Verbose:$VerbosePreference -ErrorAction:$ErrorActionPreference | Out-Null

    # Copy mod items to new temp folder
    if (Test-Path -LiteralPath $JarExe -PathType Leaf) {
        $JarName = "$ArchiveName+mod.jar"
        if (Test-Path -LiteralPath $JarName -PathType Leaf) {
            Remove-Item -LiteralPath $JarName -Force -Verbose:$VerbosePreference -ErrorAction:$ErrorActionPreference
        }

        Copy-DataFiles -Exclude @(".build",".git",".gitignore",".vscode","src","./pack.mcmeta") -Source ../ -Destination ./temp/mod/ -Verbose:$VerbosePreference -ErrorAction:$ErrorActionPreference -Debug:$DebugPreference
        Expand-DataFiles -Options $Options -Directory ./temp/mod/ -Verbose:$VerbosePreference -ErrorAction:$ErrorActionPreference -Debug:$DebugPreference

        Push-Location ./temp/mod/
        try {
            & $JarExe -cf "../../$JarName" ./*
        } finally {
            Pop-Location
        }
    } else {
        Write-Warning "Skipped mod jar creation: Could not find jar.exe. Ensure jdkHome is defined in your build options file."
    }

    # Copy datapack items to new temp folder
    if (Test-Path ../data/ -PathType Container) {
        $DataZipName = "$ArchiveName+data.zip"
        if (Test-Path -LiteralPath $DataZipName -PathType Leaf) {
            Remove-Item -LiteralPath $DataZipName -Force -Verbose:$VerbosePreference -ErrorAction:$ErrorActionPreference
        }

        Copy-DataFiles -Exclude @(".build",".git",".gitignore",".vscode","src","assets","*.mod.json","META-INF","resourcepack.mcmeta") -Source ../ -Destination ./temp/datapack/ -Verbose:$VerbosePreference -Debug:$DebugPreference
        Expand-DataFiles -Options $Options -Directory ./temp/datapack/ -Verbose:$VerbosePreference -ErrorAction:$ErrorActionPreference -Debug:$DebugPreference

        Push-Location ./temp/datapack/
        try {
            Compress-Archive @('./data','pack.mcmeta','./pack.png','LICENSE') "../../$DataZipName" -Verbose:$VerbosePreference -ErrorAction:$ErrorActionPreference
        } finally {
            Pop-Location
        }
    } else {
        Write-Warning "Skipped data pack .zip file creation as there were no data files present."
    }

    if (Test-Path ../assets/ -PathType Container) {
        $ResourceZipName = "$ArchiveName+assets.zip"
        if (Test-Path -LiteralPath $ResourceZipName -PathType Leaf) {
            Remove-Item -LiteralPath $ResourceZipName -Force -Verbose:$VerbosePreference -ErrorAction:$ErrorActionPreference
        }

        # Copy resource pack items to new temp folder
        Copy-DataFiles -Exclude @(".build",".git",".gitignore",".vscode","src","*.mod.json","META-INF","data","pack.mcmeta") -Source ../ -Destination ./temp/resourcepack/ -Verbose:$VerbosePreference -ErrorAction:$ErrorActionPreference -Debug:$DebugPreference
        Expand-DataFiles -Options $Options -Directory ./temp/resourcepack/ -Verbose:$VerbosePreference -ErrorAction:$ErrorActionPreference

        Push-Location ./temp/resourcepack/
        try {
            Compress-Archive @('./assets','pack.mcmeta','pack.png','LICENSE') "../../$ResourceZipName" -Verbose:$VerbosePreference -ErrorAction:$ErrorActionPreference
        } finally {
            Pop-Location
        }
    } else {
        Write-Warning "Skipped resource pack .zip file creation as there were no assets present."
    }

    # Cleanup
    if (-not $SkipCleanup) {
        Remove-Item -Recurse -Force ./temp/ -Verbose:$VerbosePreference -ErrorAction:$ErrorActionPreference
    }

} finally {
    Pop-Location
}
