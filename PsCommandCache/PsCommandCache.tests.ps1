#
# This is a PowerShell Unit Test file.
# You need a unit test framework such as Pester to run PowerShell Unit tests. 
# You can download Pester from http://go.microsoft.com/fwlink/?LinkID=534084
#

Describe "Module" {
	Context "Module Import" {
		It "Should Not Throw" {
			Import-Module .\PsToolBox.psm1
		}
		It "Contains Function Invoke-CachedCommand" {
			Get-Command Invoke-CachedCommand | Should Be $True
		}
	}
}