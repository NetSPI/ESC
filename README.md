# Evil SQL Client (ESC)
 Version: v1.0 <Br>
 Author: Scott Sutherland (@_nullbind), NetSPI <Br>
<br>
Evil SQL Client (ESC) is an interactive .net SQL console client with enhanced server discovery, access, and data exfiltration features. :)  Built for execution as a stand alone assembly, or through a alternative mediums for .net code execution such as msbuild and PowerShell. While it is a very handy SQL Client for legitimate purposes, it was designed for use during penetration testing and red team engagements.<br>
 
Functionality based on the PowerUpSQL, DAFT, and SQLi Wiki projects which are also related to SQL Server.
  
# Compile to Exe
1. Open project in Visual Studio from the esc folder.
2. Build.
3. Run esc.exe.

# Download Release Exe
You can download compiled releases from: https://github.com/NetSPI/ESC/releases
  
# Execute via MSBUILD 
Run the msbuild.exe command from its path using one of the commands below. You can explicitly define the .xml or .csproj file to load, but it is not required if only one .csproj file exists your current working directory. 
 ` C:\Windows\Microsoft.NET\Framework\v4.0.30319\msbuild.exe ` <br>
 `C:\Windows\Microsoft.NET\Framework\v4.0.30319\msbuild.exe esc.csproj` <Br>
 `C:\Windows\Microsoft.NET\Framework\v4.0.30319\msbuild.exe esc.xml` <br>
 
 # RECOMMENDED COMMAND SEQUENCE:
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
 </pre>
