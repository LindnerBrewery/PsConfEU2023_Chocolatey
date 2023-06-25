function ConvertFrom-PropertyFile
{
<#
  .Synopsis
    Converts a Key=Value formatted property file a custom object
  .DESCRIPTION
    Converts a Key=Value formatted property file a custom object
  .EXAMPLE
    Example of how to use this cmdlet
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, 
            Position = 0)]
        [ValidateNotNullOrEmpty()]
        $Path
    )
    try {
        if (-not (Test-Path $Path -ErrorAction Stop)) {
            Write-Error "Can't find $Path" -ErrorAction stop
        }
        $conf = (Get-Content $Path -Raw -ErrorAction Stop) -split [System.Environment]::NewLine
    
        # find line with param
        for ($i = 0; $i -lt $conf.Count; $i++) {
        
            $split = $conf[$i] -split "="
            #if ($split.count -eq 2 -And (-not $conf[$i].StartsWith("#"))) {
            if ($split.count -eq 2 -And (-not $split[0].Contains(" "))) {
                $Property = $($split[0])
                $isActive = $true
                if ($Property.StartsWith("#")) {
                    $Property = $Property.TrimStart("#")
                    $isActive = $false
                }
    
                [PSCustomObject]@{
                
                    Property = $Property
                    Value    = $($split[1])
                    IsActive = $isActive
                    Line     = $i 
                }
            }
        } 
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}

# SIG # Begin signature block
# MIIR0wYJKoZIhvcNAQcCoIIRxDCCEcACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUyaMgE3n7aXlybuZRKS3uJT3J
# XkCggg4fMIIGsDCCBJigAwIBAgIQCK1AsmDSnEyfXs2pvZOu2TANBgkqhkiG9w0B
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
# DjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQ7rX30fNWraBuc1ZkePD8e
# cPEcMzANBgkqhkiG9w0BAQEFAASCAgBGkKruJuWOpwRhzef1ulWtfwR90vYBx6d3
# SVbfmqQEWQcbFpCeNUfeiB+g+MlhfxkvPSsLYV5bocgTuh5dbvRZWj3R5CT77fn/
# AwEd3z8eS0Xr//A0YLfBeziPAF3xkc5wVlVcVRRQoVbzCbHtNw7fqITjbq15ORHP
# fHx0AbQ/nD3f5B3bgwKLJzhypOqlHBU3MR/XtPErvngSuEM5idrw3FnLsOBzHOz3
# v2OOhcApBu3+QYCRPbMxyox3Z4/XEoW5pp7c2/rEG8svBF4lBIP+REpivwmJhKZj
# oXJNjf3TsFiuXB2rSPf5s9w/SQtxUdwdVW6mM3Ttthgy76vAeEAJDY8jhE3TGzUa
# BzYZM9B8JbN4JfVe27oBf8eqFFtDXNZT+CTEdFFfVWMXnuQL42jUdhgrY+8poUgm
# CdUSw4pX+hJq9cbe7Cy7Cu5pHwEkHDJ4LJbBXIURpPtW8cKx9Y8O7g6V7tC8M7D8
# 5mXSX6eJdDeAooW1e/gGqVmPeeim7uQBzKLCDH0wy1F/DmFMXsbyX9EH9KB53ANU
# 5eUAtIJ4nBEaHUUecxQpomzRU22dFuP9FZGUoYE/8SNanQXXoaCPZfYoVKfXyzrp
# 7kIIqLxGR7NQAHkEU88sEgfwbtw4y7qGeJnN/wBfWZeI3WnEj2VNBhcQxiYqDKpE
# NZSWFTs4pg==
# SIG # End signature block
