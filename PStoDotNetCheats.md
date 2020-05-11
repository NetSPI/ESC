## PowerShell Reflection Cheatsheet
This is a cheat sheet that shows how to call .Net assembly methods from PowerShell.  All examples have been taken from Khai Tran's [blog](https://blog.netspi.com/using-powershell-and-reflection-api-to-invoke-methods-from-net-assemblies/).

Below are a few code examples that illustrate how to deal with different scenarios:

* <a href="#1">Public Static Class: Call public static method</a>
* <a href="#2">Public Static Class: Call private static method</a>
* <a href="#3">Public Static Class: Call private static method (function overloading)</a>
* <a href="#4">Public Class: Call nonstatic public method</a>
* <a href="#5">Public Class: Call nonstatic private method (function overloading)</a>

### Public Static Class: Call public static method <a name="1"></a>

<pre>
# Load all .NET binaries in the folder
Get-ChildItem -recurse "D:\Documents\Visual Studio 2010\Projects\AesSample\AesSample\bin\Debug\"|Where-Object {($_.Extension -EQ ".dll") -or ($_.Extension -eq ".exe")} | ForEach-Object { $AssemblyName=$_.FullName; Try {[Reflection.Assembly]::LoadFile($AssemblyName)} Catch{ "***ERROR*** Not .NET assembly: " + $AssemblyName}} 

#Call public static method
[AesSample.AesLibStatic]::DecryptString("8E3C5A3088CEA26B634CFDA09D13A7DB")
</pre>

### Public Static Class: Call private static method <a name="2"></a>

<pre>
#Load all .NET binaries in the folder
Get-ChildItem -recurse "D:\Documents\Visual Studio 2010\Projects\AesSample\AesSample\bin\Debug\"|Where-Object {($_.Extension -EQ ".dll") -or ($_.Extension -eq ".exe")} | ForEach-Object { $AssemblyName=$_.FullName; Try {[Reflection.Assembly]::LoadFile($AssemblyName)} Catch{ "***ERROR*** Not .NET assembly: " + $AssemblyName}}

#Only retrieve static private method
$BindingFlags= [Reflection.BindingFlags] "NonPublic,Static"
 
#Load method based on name
$PrivateMethod = [AesSample.AesLibStatic].GetMethod("DecryptStringSecret",$bindingFlags)
 
#Invoke
$PrivateMethod.Invoke($null,"8E3C5A3088CEA26B634CFDA09D13A7DB")
</pre>

### Public Static Class: Call private static method (function overloading) <a name="3"></a>

<pre>

#Load all .NET binaries in the folder
Get-ChildItem -recurse "D:\Documents\Visual Studio 2010\Projects\AesSample\AesSample\bin\Debug\"|Where-Object {($_.Extension -EQ ".dll") -or ($_.Extension -eq ".exe")} | ForEach-Object { $AssemblyName=$_.FullName; Try {[Reflection.Assembly]::LoadFile($AssemblyName)} Catch{ "***ERROR*** Not .NET assembly: " + $AssemblyName}}

#Only retrieve static private method
$BindingFlags= [Reflection.BindingFlags] "NonPublic,Static"

#Search for private method based on name
$PrivateMethods = [AesSample.AesLibStatic].GetMethods($bindingFlags) | Where-Object Name -eq DecryptStringPrivate

$PrivateMethods | ForEach-Object{
 $PrivateMethod=$_
 $MethodParams=$PrivateMethod.GetParameters()
 $MemberSignature = $MethodParams | Select -First 1 | Select-Object Member
 #This will list all the method signatures
 $MemberSignature.Member.ToString()
 
 #Choose the correct method based on parameter list
 If ($MemberSignature.Member.ToString() -eq "System.String DecryptStringPrivate(Byte[])"){
 [byte[]]$Bytes =@(70,1,65,70,155,197,95,238,85,79,190,34,158,69,125,233,53,212,111,19,248,209,147,180,19,172,150,25,97,41,127,175)
 [Object[]] $Params=@(,$Bytes)
 
 #Call with the right arguments
 $PrivateMethod.Invoke($null,$Params)
 }
}
</pre>

### Public class: Call nonstatic public method <a name="4"></a>

<pre>
#Load all .NET binaries in the folder
Get-ChildItem -recurse "D:\Documents\Visual Studio 2010\Projects\AesSample\AesSample\bin\Debug\"|Where-Object {($_.Extension -EQ ".dll") -or ($_.Extension -eq ".exe")} | ForEach-Object { $AssemblyName=$_.FullName; Try {[Reflection.Assembly]::LoadFile($AssemblyName)} Catch{ "***ERROR*** Not .NET assembly: " + $AssemblyName}}
#Call default constructor (no argument)
$AesSample= New-Object "AesSample.AesLib"
#Call constructor with arguments using this syntax: $AesSample= New-Object "AesSample.AesLib" ("a","b")
 
#Invoke public method 
$AesSample.DecryptString("8E3C5A3088CEA26B634CFDA09D13A7DB")
</pre>

### Public class: Call nonstatic private method (function overloading) <a name="5"></a>

<pre>

# Load all .NET binaries in the folder
Get-ChildItem -recurse "D:\Documents\Visual Studio 2010\Projects\AesSample\AesSample\bin\Debug\"|Where-Object {($_.Extension -EQ ".dll") -or ($_.Extension -eq ".exe")} | ForEach-Object { $AssemblyName=$_.FullName; Try {[Reflection.Assembly]::LoadFile($AssemblyName)} Catch{ "***ERROR*** Not .NET assembly: " + $AssemblyName}}

# Call constructor
$Instance= New-Object "AesSample.AesLib" ("a","b")
 
# Find private nonstatic method. If you want to invoke static private method, replace Instance with Static
$BindingFlags= [Reflection.BindingFlags] "NonPublic,Instance"
 
$Instance.GetType().GetMethods($BindingFlags) | Where-Object Name -eq DecryptStringPrivate| 
ForEach-Object{
    $PrivateMethod=$_
    $MethodParams=$PrivateMethod.GetParameters() 
    $MemberSignature = $MethodParams | Select -First 1 | Select-Object Member
    $MemberSignature.Member.ToString()
    If ($MemberSignature.Member.ToString() -eq "System.String DecryptStringPrivate(Byte[])"){
    [byte[]]$Bytes =@(70,1,65,70,155,197,95,238,85,79,190,34,158,69,125,233,53,212,111,19,248,209,147,180,19,172,150,25,97,41,127,175)
    [Object[]] $Params=@(,$Bytes)
 
    # You will need to pass the Instance here instead of $null
    $PrivateMethod.Invoke($Instance,$Params)
  }
 }
</pre>
