# Evil SQL Client (ESC)
 Version: v1.0 <Br>
 Author: Scott Sutherland (@_nullbind), NetSPI <Br>
 Description: <br>
A SQL client with enhanced server discovery, access, and data exfiltration features. :)  Built for execution as a stand alone assembly, or through an alternative medium for  .net code execution such as msbuild and PowerShell. 
  
# Compile to EXE
1. Open project in Visual Studio.
2. Build.
3. Run esc.exe.
  
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
