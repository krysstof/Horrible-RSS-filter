 ### launch a web server locally that will grab HS feed and filter for specific show

# quick and dirty slapped together code, but some wanted a way to filter rss feed
# wait for @HS to improve RSS feed and add "?show=" in the url 

### syntax http://localhost:8008/?show=.....&res=.....
###  show= the name or partial name of the show, case sensitive, space replaced by +
###  res= resolution like hs : sd, 720 or 1080.
### missing these 2 argument will yield nothing, 
### malformatting show will result in random stuff overtime try in your browser before setting the url directly in your torrent client
### resolution is controlled and defaulted to 1080 in case of typo, $res to change that
### replace 8008 with desired port in the code below, otherwise don't touch it

### http://localhost:8008/?show=One+Piece&res=720  >> will grab one piece, mind the case and space become +
### http://localhost:8008/?show=lanet&res=1080 >> will return Clockwork Planet
### http://localhost:8008/?show=Sa&res=1080 >> will return multiple show
### http://localhost:8008/stop >> will kill the server

　
### install:
### save as a .PS1 file where ever you want on your computer (windows)
### right clic on the file and "Run with powershell", a windows fill pop then disappear

#dealwithit
#no logs, no way to see what is does or why it does it wrong
# open powershell, type "get-process powershell" if you get more than 1 line you probably have a problem, kill all powershell in doubt

　
$res="1080" #default res if mal formatted. (replace with "720" or "sd" if you want)

#Run as admin
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
if (-not $myWindowsPrincipal.IsInRole($adminRole))
{
    $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
    $newProcess.Arguments = $myInvocation.MyCommand.Definition;
    $newProcess.Verb = "runas";
    [System.Diagnostics.Process]::Start($newProcess);
    exit
}

#hide or minimize
Add-Type @"
  using System;
  using System.Runtime.InteropServices;
  public class UserWindows {
    [DllImport("user32.dll")] 
    public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow); 
}
"@
[UserWindows]::ShowWindowAsync((get-process -id $PID).MainWindowHandle, 0)|out-null # 2 = minimize, 0 is hidden

　
$ServerThreadCode = {
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add("http://+:8008/") #change port here if not working
    $listener.Start()
    while ($listener.IsListening) {
        $context = $listener.GetContext() # waits for a request
        $request = $context.Request
        $response = $context.Response

	$show=""
	$show=$request.querystring.item("show")
	$t_res=$request.querystring.item("res")
	if($t_res -ne "1080" -and $t_res -ne "720" -and $t_res -ne "sd") {$t_res=$res} 

	$quitnow=$false
        if ($request.Url -match '/stop$') { $quitnow=$true; $message="Server exited"}
	else{
            if($show -ne ""){
		$response.Headers.Add("Content-Type","application/xml")
		[xml]$rss=(invoke-WebRequest "http://horriblesubs.info/rss.php?res=$t_res").content
		$rss.rss.channel.SelectNodes("//item[not(contains(title,'$show'))]") |%{$rss.rss.channel.RemoveChild($_)} |out-null

		$message = $rss.InnerXml
	        $response.StatusCode = 200	
            }
            else {
		$message="noshow";
		$response.StatusCode = 500
	    }
	}	

        [byte[]] $buffer = [System.Text.Encoding]::UTF8.GetBytes($message)
        $response.ContentLength64 = $buffer.length
        $output = $response.OutputStream
        $output.Write($buffer, 0, $buffer.length)
        $output.Close()
	if($quitnow){break}
    }
 
    $listener.Stop()
}
  
$serverJob = Start-Job $ServerThreadCode

$serverJob | Wait-Job 
