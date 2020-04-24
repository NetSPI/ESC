# Evil SQL Client (ESC)
 
 Evil SQL Client (ESC) <br>
 Version: v1.0 <Br>
 Author: Scott Sutherland (@_nullbind), NetSPI <Br>
 Description: <br>
A SQL client with enhanced server discovery, access, and data exfiltration features. :)  Built for execution as a stand alone assembly, or through an alternative medium for  .net code execution such as msbuild and PowerShell. 
  
# Compile to EXE
Compile in visual studio. and run assembly.
  
# Execute via MSBUILD 
Run the msbuild.exe command from its path using one of the commands below. You can explicitly define the .xml or .csproj file to load, but it is not required if only one .csproj file exists your current working directory. 
 ` C:\Windows\Microsoft.NET\Framework\v4.0.30319\msbuild.exe `
 `C:\Windows\Microsoft.NET\Framework\v4.0.30319\msbuild.exe esc.csproj`
 `C:\Windows\Microsoft.NET\Framework\v4.0.30319\msbuild.exe esc.xml`
