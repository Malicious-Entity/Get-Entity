    #Requires -Version 2.0
    [cmdletbinding()]
    Param (
        [parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [int]$Throttle = 15,
		[parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=1)]
		[string]$location,
		[parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=2)]
		[string]$user,
		[parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=3)]
		[string]$password,
		[parameter(Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=4)]
		[string]$GroupName = "Administrators"
			)
    Begin {
        #Function that will be used to process runspace jobs
        Function Get-RunspaceData {
            [cmdletbinding()]
            param(
                [switch]$Wait
            )
            Do {
                $more = $false         
                Foreach($runspace in $runspaces) {
                    If ($runspace.Runspace.isCompleted) {
                        $runspace.powershell.EndInvoke($runspace.Runspace)
                        $runspace.powershell.dispose()
                        $runspace.Runspace = $null
                        $runspace.powershell = $null
                        $Script:i++                  
                    } ElseIf ($runspace.Runspace -ne $null) {
                        $more = $true
                    }
                }
                If ($more -AND $PSBoundParameters['Wait']) {
                    Start-Sleep -Milliseconds 100
                }   
                #Clean out unused runspace jobs
                $temphash = $runspaces.clone()
                $temphash | Where {
                    $_.runspace -eq $Null
                } | ForEach {
                    Write-Verbose ("Removing {0}" -f $_.computer)
                    $Runspaces.remove($_)
                }             
            } while ($more -AND $PSBoundParameters['Wait'])
        }
            
        
        $Script:report = @()    
        
        Write-Verbose ("Building hash table for NT parameters")
        $NThash = @{
            ErrorAction = "Stop"
        } 
                
        #Define hash table for Get-RunspaceData function
        $runspacehash = @{}

        #Define Scriptblock for runspaces
        $scriptblock = {
		Param (
			$Computer,
			$user,
			$password,
			$NTQuery,
			$NTQueryResult,
            $GroupName
			)
			If (Test-Connection -ComputerName $Computer -Count 2 -Quiet) {
			try {
			cmdkey /add:$Computer /user:$user /pass:$password
			
			echo cmdkey /add:$Computer /user:$user /pass:$password
			
			$NTQuery = [ADSI]("WinNT://$Computer/Administrators")
			
			[String]$NTQueryResult = $NTQuery.PsBase.Invoke("Members") | foreach { $_.GetType().InvokeMember("ADSpath", 'GetProperty', $null, $_, $null)}
			
			$NTQueryResult.Substring(8)
				} Catch {Write-Warning ("{0}" -f $_.Exception.Message)}
			
			cmdkey /delete:$Computer
    
        																	} else{"Host $Computer Seems Down or Unreachable, Skipping"}
					}
        
        Write-Verbose ("Creating runspace pool and session states")
        $sessionstate = [system.management.automation.runspaces.initialsessionstate]::CreateDefault()
        $runspacepool = [runspacefactory]::CreateRunspacePool(1, $Throttle, $sessionstate, $Host)
        $runspacepool.Open()  
        
        Write-Verbose ("Creating empty collection to hold runspace jobs")
        $Script:runspaces = New-Object System.Collections.ArrayList        
    }
    Process {        
		$computername = Get-Content -Path $location
		$totalcount = $computername.count
        Write-Verbose ("Querying Administrators on " + $totalcount + " systems")        
        ForEach ($Computer in $computername) {
           
           $Computer = [System.Net.Dns]::GetHostAddresses($Computer) | Where-Object IPAddressToString -NotLike "*:*" | select -ExpandProperty IPAddressToString
           $powershell = [powershell]::Create().AddScript($ScriptBlock).AddArgument($Computer).AddArgument($user).AddArgument($password)

           $powershell.RunspacePool = $runspacepool
           
           $temp = "" | Select-Object PowerShell,Runspace,Computer
           $Temp.Computer = $Computer
           $temp.PowerShell = $powershell
           
           $temp.Runspace = $powershell.BeginInvoke()
           Write-Verbose ("Adding {0} collection" -f $temp.Computer)
           $runspaces.Add($temp) | Out-Null
           
           Write-Verbose ("Checking status of runspace jobs")
           Get-RunspaceData @runspacehash
		   																
																		}           
        }                        
    End {                     
        Write-Verbose ("Finish processing the remaining runspace jobs: {0}" -f (@(($runspaces | Where {$_.Runspace -ne $Null}).Count)))
        $runspacehash.Wait = $true
        Get-RunspaceData @runspacehash
        
        Write-Verbose ("Closing the runspace pool")
        $runspacepool.close()               
    }
