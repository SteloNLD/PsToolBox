#
# This is a PowerShell Unit Test file.
# You need a unit test framework such as Pester to run PowerShell Unit tests. 
# You can download Pester from http://go.microsoft.com/fwlink/?LinkID=534084
#

Remove-module PsCommandCache 

Describe "PsCommandCache Module" {
	Context "Module Import" {
		It "Import Should Succeed" {
			Import-Module 'D:\Projects\Visual Studio\2015\PsToolBox\PsCommandCache\PsCommandCache.psm1'
		}
		It "Contains Function Invoke-CachedCommand" {
			Get-Command Invoke-CachedCommand | Should Be $True
		}
	}	
	Context "Invoke-CachedCommand" {
		It "Should Throw when no parameters a specified" {
			Invoke-CachedCommand | Should BeOfType System.IO.DirectoryInfo
		}
	}
}

