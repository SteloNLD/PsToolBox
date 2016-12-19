

$PsCommandCache = @()

[CmdletBinding]

Function Invoke-CachedCommand {
	Param (		
		[Parameter(Mandatory=$true)][scriptblock]$ScriptBlock,
		[Parameter(Mandatory=$false)][datetime]$TTL = (get-date).AddMinutes(5)
	)
	
	if (($PsCommandCache | Select CachedCommand) -ccontains $ScriptBlock) {
			return $PsCommandCache | Where-Object {$_.CachedCommand -ceq $ScripBlock}
	}
	else {	
		try{$CachedOutput = & $ScriptBlock} 
		catch{Log-Error $_; return $_}
	}

	#Create New Cache Item
	$CacheItem = New-Object PSObject
	$CacheItem | Add-Member -type NoteProperty -Name 'CachedCommand' -Value $ScriptBlock
	$CacheItem | Add-Member -type NoteProperty -Name 'TTL' -Value $TTL
	$CacheItem | Add-Member -type NoteProperty -Name 'CachedResults' -Value $CachedOutput
		
	#Add Cache Item to the Cache
	$PsCommandCache += $CacheItem

	#Return Cached Results.
	Return $CachedOutput
}
Export-Command Invoke-CachedCommand