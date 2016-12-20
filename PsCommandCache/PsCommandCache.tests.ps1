#
# This is a PowerShell Unit Test file.
# You need a unit test framework such as Pester to run PowerShell Unit tests. 
# You can download Pester from http://go.microsoft.com/fwlink/?LinkID=534084
#

Remove-module PsCommandCache 

Describe "PsCommandCache Module" {
	Context "Module Import" {
		It "import Should Succeed" {
			Import-Module "D:\Projects\Visual Studio\2015\PsToolBox\PsCommandCache\PsCommandCache.psm1" | Should Not Throw
		}
		It "contains Function Invoke-CachedCommand" {
			Get-Command Invoke-CachedCommand | Should Be $true
		}
		It "contains Function Get-CachedCommand" {
			Get-Command Get-CachedCommand | Should Be $true
		}
		It "contains Function Remove-CachedCommand" {
			Get-Command Remove-CachedCommand | Should Be $true
		}
	}	
}
	
Describe "Invoke-CachedCommand" {		
	Import-Module 'D:\Projects\Visual Studio\2015\PsToolBox\PsCommandCache\PsCommandCache.psm1'
	It "should Throw when no parameters are specified" {	
		{Invoke-CachedCommand} | Should Throw
	}
	It "should Throw when the ScriptBlock parameter is not named or not of the ScriptBlock type" {	
		{Invoke-CachedCommand "blablabla"} | Should Throw
		{Invoke-CachedCommand -ScriptBlock "blablabla"} | Should Throw
	}
	It "should return an anwser of the expected type " {
		$ScriptBlock = {Get-Date}
		Invoke-CachedCommand -ScriptBlock $ScriptBlock | Should BeOfType DateTime
		
		New-Item 'TestDrive:\test.txt'
		$ScriptBlock = {Get-Item 'TestDrive:\test.txt' }
		Invoke-CachedCommand -ScriptBlock $ScriptBlock | Should BeOfType System.IO.FileInfo  				
	}
	It "should output the cached result when TTL is not exceeded." {
		
		#Setup
		$ContentA = "AAAAAAAAAAAA"; $ContentB = "BBBBBBBBBBBB"; 
		
		Set-Content 'TestDrive:\test.txt' -Value $ContentA
		Invoke-CachedCommand -ScriptBlock {Get-Content 'TestDrive:\test.txt'} | Should Be $ContentA
		
		Set-Content 'TestDrive:\test.txt' -Value $ContentB
		Invoke-CachedCommand -ScriptBlock {Get-Content 'TestDrive:\test.txt'} | Should Be $ContentA
		Invoke-CachedCommand -ScriptBlock {Get-Content 'TestDrive:\test.txt'} | Should Not Be $ContentB
	}
	It "should output the uncached result when TTL is exceeded." {		
		
		#Setup
		$ContentA = "AAAAAAAAAAAA"; $ContentB = "BBBBBBBBBBBB"; 
		
		#Set TTL tot NOW = Instant Expire!
		Set-Content 'TestDrive:\test.txt' -Value $ContentA
		Invoke-CachedCommand -ScriptBlock {Get-Content 'TestDrive:\test.txt'} -TTL (Get-date) | Should Be $ContentA
		
		#To be sure!
		Start-Sleep -Seconds 1

		Set-Content 'TestDrive:\test.txt' -Value $ContentB
		Invoke-CachedCommand -ScriptBlock {Get-Content 'TestDrive:\test.txt'} | Should Be $ContentB
		Invoke-CachedCommand -ScriptBlock {Get-Content 'TestDrive:\test.txt'} | Should Not Be $ContentA
	}
}
