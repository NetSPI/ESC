# Evil SQL Client (ESC)
 Version: v1.0 <Br>
 Author: Scott Sutherland (@_nullbind), NetSPI <Br>
<br>
Evil SQL Client (ESC) is an interactive .net SQL console client with enhanced server discovery, access, and data exfiltration features. :)  Built for execution as a stand alone assembly, or through a alternative mediums for .net code execution such as msbuild and PowerShell. While it is a very handy SQL Client for legitimate purposes, it was designed for use during penetration testing and red team engagements.<br>
 
Most of ESC's functionality is based on the [PowerUpSQL](https://github.com/NetSPI/PowerUpSQL/wiki/), [DAFT](https://github.com/NetSPI/DAFT), and [SQLInjectionWiki](https://sqlwiki.netspi.com/) projects which are also related to SQL Server.




# Execution Options
Below is a list of the currently supported commands.

### Compile and Run Exe
1. Open project in Visual Studio from the esc folder.
2. Build.
3. Run esc.exe.

![buildesc](https://github.com/NetSPI/ESC/blob/master/screenshots/start-esc-compile-1.png) 
![runescexe](https://github.com/NetSPI/ESC/blob/master/screenshots/start-esc-compile-2.png) 

### Download and Run Exe
1. Download compiled [release](https://github.com/NetSPI/ESC/releases). 
2. Run esc.exe.
  
### Run via Msbuild.exe
Using msbuild.exe to execute .net code through inline tasks is a technique that was developed by Casey Smith. Related material can be found [here](https://bleepsec.com/2018/11/26/using-attack-atomic-red-team-part1.html). 
<br><br>
Run one of the msbuild commands below to start the Evil SQL Client console using the esc.csproj file.  You can explicitly provide it as a .xml or .csproj file, but no file name has to be provided if only one .csproj file exists in the directory your executing msbuild.exe from.
<br><br>
 ` C:\Windows\Microsoft.NET\Framework\v4.0.30319\msbuild.exe ` <br>
 `C:\Windows\Microsoft.NET\Framework\v4.0.30319\msbuild.exe esc.csproj` <Br>
 `C:\Windows\Microsoft.NET\Framework\v4.0.30319\msbuild.exe esc.xml` <br>

![runescexe](https://github.com/NetSPI/ESC/blob/master/screenshots/start-esc-msbuild-1.png) 
![runescexe](https://github.com/NetSPI/ESC/blob/master/screenshots/start-esc-msbuild-2.png) 
 
 # Supported Commands

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
 
 ### Recommended Command Sequence
 Below is a recommended command sequence for those of you who want to quickly discover SQL Server instances and determine which ones you have immediate access to.
 <pre>
 discover domainspn 
 discover broadcast
 show discovered
 set targetall enabled
 show settings
 check access
 check defaultpw
 check loginaspw
 show access
 export discovered c:\temp\discovered.csv
 export access c:\temp\access.csv
 export access c:\temp\access.csv instance
 </pre>
 
 # Pending Features
* Add discover local 
* Add column find
* Add domain account enumeration
* Add link crawl + linkquery + linkoscmd
* Add escalate dbowner
* Add escalate imperonsate
* Threading
* Finish data encryption
* Create python/powershell script to decrypt encrypted exfiltrated data
