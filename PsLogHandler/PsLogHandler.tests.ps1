#
# This is a PowerShell Unit Test file.
# You need a unit test framework such as Pester to run PowerShell Unit tests. 
# You can download Pester from http://go.microsoft.com/fwlink/?LinkID=534084
#

Remove-module PsLogHandler

Describe "PsLogHandler" {
	Context "Module Import" {
		It "import Should Succeed" {
			{Import-Module "D:\Projects\Visual Studio\2015\PsToolBox\PsLogHandler\PsLogHandler.psm1"} | Should Not Throw
		}
		It "contains Function Log-Start" {
			Get-Command Log-Start | Should Be $true
		}
		It "contains Function Log-Write" {
			Get-Command Log-Write | Should Be $true
		}
		It "contains Function Log-Error" {
			Get-Command Log-Error | Should Be $true
		}
		It "contains Function Log-Finish" {
			Get-Command Log-Finish | Should Be $true
		}
		It "contains Function Log-Email" {
			Get-Command Log-Email | Should Be $true
		}
	}	
}
	