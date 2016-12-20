

$PsCommandCache = New-Object System.Collections.ArrayList

[CmdletBinding]

Function Invoke-CachedCommand {
	Param (		
		[Parameter(Mandatory=$true)][scriptblock]$ScriptBlock,
		[Parameter(Mandatory=$false)][datetime]$TTL = (get-date).AddMinutes(5)
	)
	
	$CacheItem = ($Script:PsCommandCache | Where-Object {$_.CachedCommand -ceq $Scriptblock.ToString()})
	
	if (($CacheItem -ne $null) -and ($CacheItem.TTL -le (Get-Date))) {
			$Script:PsCommandCache.Remove($CacheItem)
			$CacheItem = $null
	}	

	if ($CacheItem -eq $null)
	{
		#Create New Cache Item	
		$CacheItem = New-Object PSObject
		$CacheItem | Add-Member -type NoteProperty -Name 'CachedCommand' -Value $ScriptBlock.ToString()
		$CacheItem | Add-Member -type NoteProperty -Name 'TTL' -Value $TTL
		$CacheItem | Add-Member -type NoteProperty -Name 'CachedResult' -Value $null
		
		try{
			$CacheItem.CachedResult = (& $ScriptBlock)
		}
		catch{
			Log-Error $_
		}		
		
		#Add cache item to the global cache	
		$Script:PsCommandCache.Add($CacheItem)
	}

	#Return cached result.
	Return $CacheItem.CachedResult
}

[CmdletBinding]

Function Get-CachedCommand {
	
	#Return selected cache items from the global cache
	Return $Script:PsCommandCache
}