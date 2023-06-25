function Format-PropertyFile {
  <#
  .Synopsis
    Short description
  .DESCRIPTION
    Long description
  .EXAMPLE
    Example of how to use this cmdlet
#>
  [CmdletBinding()]
  Param
  (
    # path to property file
    [Parameter(Mandatory = $true,
      Position = 0,
      HelpMessage = "Path to the property file")]    
    [ValidateNotNullOrEmpty()]
    [string]$PropertyFile,

    # Path to template file
    [Parameter(Mandatory = $true,
      Position = 1,
      HelpMessage = "Property")]
    [ValidateNotNullOrEmpty()]
    [string]$TemplateFile,
        
    # Defines if a backup of the original config file should be made
    [Parameter(Mandatory = $false)]
    [switch]$Backup
  )

  # check if files exist
  if ([System.IO.File]::Exists($PropertyFile)) {
    Try { [system.io.file]::OpenWrite($PropertyFile).close() }
    Catch { Throw "Unable to write to output file $PropertyFile" }
  }
  if ([System.IO.File]::Exists($TemplateFile)) {
    Try { [system.io.file]::OpenRead($TemplateFile).close() }
    Catch { Throw "Unable to write to output file $TemplateFile" }
  }
  if ($backup) {
    #copy file
    $propertyFileInfo = [System.IO.FileInfo]::new($PropertyFile)
    Copy-Item -Path $PropertyFile -Destination ($propertyFileInfo.FullName + ".backup")
  }
  #get content of files
  $property = ConvertFrom-PropertyFile -Path $PropertyFile -Verbose
  $template = ConvertFrom-PropertyFile -Path $TemplateFile -Verbose

  #set all propertes in template inactive 
  $templateRaw = [System.Collections.Generic.List[String]]::new((Get-Content $TemplateFile -Raw -ErrorAction Stop) -split [System.Environment]::NewLine)
  foreach ($templateProp in ($template | Where-Object IsActive -EQ true)) {
      $templateRaw[$templateProp.line] = "#" + $templateRaw[$templateProp.line]
    }

    # var switches to true if an the there is one or more properies not on the template
    $unknownProperty = $false
    # Create new proptery file from template with existing properties. Unknown properties will be added to the end of the file
    foreach ($configProp in ($property | Where-Object isActive -EQ $true)) {
      $prop = $template | Where-Object { $_.property -eq $configProp.property } 
      if ($prop) {
        #Write-Host "found $($configProp.property)" -ForegroundColor Green
        Write-Verbose "Updating property $($configProp.property) with value $($configProp.Value)"
        $templateRaw[$prop.line] = $configProp.property + "=" + $configProp.Value
      }
      else {
        Write-Warning "$($configProp.property) not in not in template. Property will be added to the end of the file"
        Write-Verbose "Updating property $($configProp.property) with value $($configProp.Value)"
        if (! $unknownProperty) {
          $unknownProperty = $true
          $templateRaw.Add("#############################################################################")
          $templateRaw.Add("#                        PROPERTIES NOT IN TEMPLATE                         #")
          $templateRaw.Add("#############################################################################")
          $templateRaw.Add("")
        }
        $templateRaw.Add(($configProp.property + "=" + $configProp.Value))
      }
    }

    #create a single string to make sure you don add a trailing new line
    $templateRaw = $templateRaw -join [System.Environment]::NewLine    
    # overwrite the orig property file with new one
    try {
      Write-Verbose "Saving property file"
      if ($psversiontable.PSVersion.Major -ge 6) {
        $templateRaw | Out-File -FilePath $PropertyFile -Force -Encoding utf8NoBOM
      }
      else {
        $encoding = [System.Text.UTF8Encoding]::new($false)
        [System.IO.File]::WriteAllText($PropertyFile, $templateRaw, $encoding)
      }

    }
    catch {
      $PSCmdlet.ThrowTerminatingError($_)
    }

  }

# SIG # Begin signature block
# MIIR0wYJKoZIhvcNAQcCoIIRxDCCEcACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUKnCp/qkMyNGqqFGhMfPZvGmm
# /0yggg4fMIIGsDCCBJigAwIBAgIQCK1AsmDSnEyfXs2pvZOu2TANBgkqhkiG9w0B
# AQwFADBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBUcnVzdGVk
# IFJvb3QgRzQwHhcNMjEwNDI5MDAwMDAwWhcNMzYwNDI4MjM1OTU5WjBpMQswCQYD
# VQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xQTA/BgNVBAMTOERpZ2lD
# ZXJ0IFRydXN0ZWQgRzQgQ29kZSBTaWduaW5nIFJTQTQwOTYgU0hBMzg0IDIwMjEg
# Q0ExMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA1bQvQtAorXi3XdU5
# WRuxiEL1M4zrPYGXcMW7xIUmMJ+kjmjYXPXrNCQH4UtP03hD9BfXHtr50tVnGlJP
# DqFX/IiZwZHMgQM+TXAkZLON4gh9NH1MgFcSa0OamfLFOx/y78tHWhOmTLMBICXz
# ENOLsvsI8IrgnQnAZaf6mIBJNYc9URnokCF4RS6hnyzhGMIazMXuk0lwQjKP+8bq
# HPNlaJGiTUyCEUhSaN4QvRRXXegYE2XFf7JPhSxIpFaENdb5LpyqABXRN/4aBpTC
# fMjqGzLmysL0p6MDDnSlrzm2q2AS4+jWufcx4dyt5Big2MEjR0ezoQ9uo6ttmAaD
# G7dqZy3SvUQakhCBj7A7CdfHmzJawv9qYFSLScGT7eG0XOBv6yb5jNWy+TgQ5urO
# kfW+0/tvk2E0XLyTRSiDNipmKF+wc86LJiUGsoPUXPYVGUztYuBeM/Lo6OwKp7AD
# K5GyNnm+960IHnWmZcy740hQ83eRGv7bUKJGyGFYmPV8AhY8gyitOYbs1LcNU9D4
# R+Z1MI3sMJN2FKZbS110YU0/EpF23r9Yy3IQKUHw1cVtJnZoEUETWJrcJisB9IlN
# Wdt4z4FKPkBHX8mBUHOFECMhWWCKZFTBzCEa6DgZfGYczXg4RTCZT/9jT0y7qg0I
# U0F8WD1Hs/q27IwyCQLMbDwMVhECAwEAAaOCAVkwggFVMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwHQYDVR0OBBYEFGg34Ou2O/hfEYb7/mF7CIhl9E5CMB8GA1UdIwQYMBaA
# FOzX44LScV1kTN8uZz/nupiuHA9PMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAK
# BggrBgEFBQcDAzB3BggrBgEFBQcBAQRrMGkwJAYIKwYBBQUHMAGGGGh0dHA6Ly9v
# Y3NwLmRpZ2ljZXJ0LmNvbTBBBggrBgEFBQcwAoY1aHR0cDovL2NhY2VydHMuZGln
# aWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcnQwQwYDVR0fBDwwOjA4
# oDagNIYyaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJv
# b3RHNC5jcmwwHAYDVR0gBBUwEzAHBgVngQwBAzAIBgZngQwBBAEwDQYJKoZIhvcN
# AQEMBQADggIBADojRD2NCHbuj7w6mdNW4AIapfhINPMstuZ0ZveUcrEAyq9sMCcT
# Ep6QRJ9L/Z6jfCbVN7w6XUhtldU/SfQnuxaBRVD9nL22heB2fjdxyyL3WqqQz/WT
# auPrINHVUHmImoqKwba9oUgYftzYgBoRGRjNYZmBVvbJ43bnxOQbX0P4PpT/djk9
# ntSZz0rdKOtfJqGVWEjVGv7XJz/9kNF2ht0csGBc8w2o7uCJob054ThO2m67Np37
# 5SFTWsPK6Wrxoj7bQ7gzyE84FJKZ9d3OVG3ZXQIUH0AzfAPilbLCIXVzUstG2MQ0
# HKKlS43Nb3Y3LIU/Gs4m6Ri+kAewQ3+ViCCCcPDMyu/9KTVcH4k4Vfc3iosJocsL
# 6TEa/y4ZXDlx4b6cpwoG1iZnt5LmTl/eeqxJzy6kdJKt2zyknIYf48FWGysj/4+1
# 6oh7cGvmoLr9Oj9FpsToFpFSi0HASIRLlk2rREDjjfAVKM7t8RhWByovEMQMCGQ8
# M4+uKIw8y4+ICw2/O/TOHnuO77Xry7fwdxPm5yg/rBKupS8ibEH5glwVZsxsDsrF
# hsP2JjMMB0ug0wcCampAMEhLNKhRILutG4UI4lkNbcoFUCvqShyepf2gpx8GdOfy
# 1lKQ/a+FSCH5Vzu0nAPthkX0tGFuv2jiJmCG6sivqf6UHedjGzqGVnhOMIIHZzCC
# BU+gAwIBAgIQB8y3gJN6uTiyF6kQnSMcPzANBgkqhkiG9w0BAQsFADBpMQswCQYD
# VQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xQTA/BgNVBAMTOERpZ2lD
# ZXJ0IFRydXN0ZWQgRzQgQ29kZSBTaWduaW5nIFJTQTQwOTYgU0hBMzg0IDIwMjEg
# Q0ExMB4XDTIxMDkyOTAwMDAwMFoXDTI0MTIxNzIzNTk1OVowbDELMAkGA1UEBhMC
# REUxGzAZBgNVBAgMEkJhZGVuLVfDvHJ0dGVtYmVyZzESMBAGA1UEBxMJS2FybHNy
# dWhlMRUwEwYDVQQKEwxNRURBVklTIEdtYkgxFTATBgNVBAMTDE1FREFWSVMgR21i
# SDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAJ6c0pQ27UL28kCY9poh
# CkdrTVpDjQpyh1xR9ORYdeQj/h/UbO8D6oM1vlnmA0SR58WHVD2neUsFAu1N4tfg
# 2LAMaRGYgE1lnVlD4JJXYKvQ2NwgFon4z7s6JqzY4yOfEj3c2JXAu0SkxV2lv4f8
# DzQ/fODeqzuEbPQtbq9mq5EuUIIghq+uu6SQ0+pfhOc8+Jqmz/bKy6q0cvznPGCu
# AUUtF2Ynz1ljxa/85XSnn1ZuOAWUYZ8dEvJuhZwqvewpGL7sX/FGhZhk5SwZcMy3
# i7u1T4T8+CrkSzKK2rrX6jucT+tR12/6juf9MFHI+6Vjd0sVF7YyXece2/sCulL1
# 3YywlzTkbXVbN0Bgf9lXNbFtqO+EpuVegn9VDkzb+k0+y1/GxLUX0xbb/2vzVRMa
# Eu69fXtXQIXXDj1Up7/K2LoB/K2Jj0O9ywsiDZ6v3Xr8HDl/71i0mDaO2EyoDA0M
# C6IzkQJKLRbHEWASFFCwa/POuLXIOUztaWGg+Mq1mljV3nFiDaxuOc3bwS2Kkmbi
# jWyNPDZgowjsIdtmjUSRjIac5DmtQOK8ZYM5toOSaVYXgM+fhyq1+/mXtL/8gZg2
# IYSXLc3deNu9Ax42OvToTnlerSglNI8MX/+l/g1vZ/R9nWpHAAGyBj04vL7hzx4/
# XNUuwCl+w5Pu9s6I/moQG9zZAgMBAAGjggIGMIICAjAfBgNVHSMEGDAWgBRoN+Dr
# tjv4XxGG+/5hewiIZfROQjAdBgNVHQ4EFgQU7vqVgD5BA3noltXBANiXfkd80ygw
# DgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMIG1BgNVHR8Ega0w
# gaowU6BRoE+GTWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0
# ZWRHNENvZGVTaWduaW5nUlNBNDA5NlNIQTM4NDIwMjFDQTEuY3JsMFOgUaBPhk1o
# dHRwOi8vY3JsNC5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRDb2RlU2ln
# bmluZ1JTQTQwOTZTSEEzODQyMDIxQ0ExLmNybDA+BgNVHSAENzA1MDMGBmeBDAEE
# ATApMCcGCCsGAQUFBwIBFhtodHRwOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwgZQG
# CCsGAQUFBwEBBIGHMIGEMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2Vy
# dC5jb20wXAYIKwYBBQUHMAKGUGh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9E
# aWdpQ2VydFRydXN0ZWRHNENvZGVTaWduaW5nUlNBNDA5NlNIQTM4NDIwMjFDQTEu
# Y3J0MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQADggIBAHcY+1sWdAcoA8HS
# oOs76kDX6XEi6ObiSI83loYxt5Xr62f0nTLBWSVFlZLpgg8mXlIzMIjwYaSe7S9p
# Pl+C3hs0c1GXj1KJyMnetlmxxpssxNDk0hJwEwjsCzrWICzJ0wKYW5yGBDwYXknU
# lexaJIG68n+5sYhpaLNxXTrSYwKBzJph3UXgUHvBuVrSNT2p6/qrSBzKpO4Vq/bU
# Pygkd/BSyDpL6KsNcg5h1DhKANgZOu+MFFmqwd6sduaKgHAwigZH+07emUEi7TzF
# cL5QOSJnRtpAkTGlDpoq7szeSgPSYBRKc91a8bRy3irWzXeyKGKGlryGVNldtVnM
# UEmWT3p8GiB/pNdX2c4A2MgakuTVLYX3THVST9s8Jgr5feTQhxyp9ldEYoaAFB+s
# FwGnVYeU6AJ/8/4wjqT5S2Ov7sQWPL4K4LhmkH590FA4LqtZw3r++SjTfPvd4ifR
# ngD6sEaUSv5FLb7qVLBI13LZot0xJ1bCVCU+IdpAKR8QcY+gwIeXy++JndeDRaBo
# idLcxFKmhx8Q1DslwbRu+L/Ao+RdWZbZY+6S9CRF7i23LirCBrOZhwvWeEsAHR22
# pxpw/nFpFNFp4AToz5yx37H2taNi3vf2U0b9BWvEdPCTtMBdHwFrx0Eqqbosq/ei
# qWtMbx1ISQ/8RigvFGEluj11VJuqMYIDHjCCAxoCAQEwfTBpMQswCQYDVQQGEwJV
# UzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xQTA/BgNVBAMTOERpZ2lDZXJ0IFRy
# dXN0ZWQgRzQgQ29kZSBTaWduaW5nIFJTQTQwOTYgU0hBMzg0IDIwMjEgQ0ExAhAH
# zLeAk3q5OLIXqRCdIxw/MAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKAC
# gAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsx
# DjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTTcAuy3HoD382XfZPoL7fp
# K/vikzANBgkqhkiG9w0BAQEFAASCAgBCW2gpngl3cuzKQsqAxs42zIYK0Z9e1XUl
# YHhWYMRntWok491uUrf9hqrX6RXEnrKDNH5EGZfOEgMj6N2LGkaXxg6kYaWG7Xka
# eqG3yOXugHBEBVAbM4VyMlfbv+6PxnoRSU58x1vNO5rxGDXX8Y9Fiy2ZVR7FAB9f
# A4uZCCscmvlarwxjlqdoOSPtEaiK198EMyWoaSpMfsK04AX+DqIxoXZDsqJTFM8U
# tJpX8Z6V6JaZVbaUzsMEwF0/tufWqZ71b8nWE3DYXIaRErwbmEgDVr85b0mkjyUO
# Vo7jVHVAlPml53Vdvqg8Pctj47w5XEYbWlOPPgxar/zsf70BqP0SRaZxLITcaZfQ
# 2V6M6BJg40oxJw4EIPWRKzIHXXZ0hCeXvaKLYX/wHN/pEx7NNw3dkAX2dgucQ25P
# 2iCr2DvsKNAfSk0bjyzqDY6/y1ge8v0WGkwOqijtEf6wbfg952anAtVMVYC2znO+
# 48rH3gw43TOVZNdk/IT2OnJBn+JwX+n7gZTrzHt6U25eH0OZdI+DmcRWuPEgOmpp
# klj3qhzYDTj0Jhyt+5cMcOF4PXHe9Vw8Xef9EZrH6Q+FB4Lj7mq2ckPBTpmAkRHX
# +RvD5DkKjh14OvlZyKd2KmmEo/bwYRAcvnUiurqMlUlBydLPajXCGYSJc7fKpz7N
# klbp1ThM5Q==
# SIG # End signature block
