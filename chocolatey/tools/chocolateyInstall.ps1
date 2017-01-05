﻿try {
    $binRoot = Get-BinRoot
    $poshgitPath = join-path $binRoot 'poshgit'

    try {
      if (test-path($poshgitPath)) {
        Write-Host "Attempting to remove existing `'$poshgitPath`' prior to install."
        remove-item $poshgitPath -recurse -force
      }
    } catch {
      Write-Host "Could not remove `'$poshgitPath`'"
    }

    $poshGitInstall = if($env:poshGit -ne $null){ $env:poshGit } else {'https://github.com/dahlbyk/posh-git/zipball/master'}
    Install-ChocolateyZipPackage 'poshgit' $poshGitInstall $poshgitPath
    $pgitDir = Dir "$poshgitPath\*posh-git*\" | Sort-Object -Property LastWriteTime | Select -Last 1

    if(Test-Path $PROFILE) {
        $oldProfile = @(Get-Content $PROFILE)
        $newProfile = @()
        #If old profile exists replace with new one and make sure prompt preservation function is on top
        $pgitExample = "$pgitDir\profile.example.ps1"
        foreach($line in $oldProfile) {
            if ($line -like '*PoshGitPrompt*') { continue; }

            if($line.ToLower().Contains("$poshgitPath".ToLower())) {
                $line = ". '$pgitExample'"
            }
            $newProfile += $line
        }
        Set-Content -path $profile -value $newProfile -Force
    }

    $subfolder = get-childitem $poshgitPath -recurse -include 'dahlbyk-posh-git-*' | select -First 1
    write-debug "Found and using folder `'$subfolder`'"
    $installer = Join-Path $subfolder 'install.ps1'
    & $installer
} catch {
  try {
    if($oldProfile){ Set-Content -path $PROFILE -value $oldProfile -Force }
  }
  catch {}
  throw
}

