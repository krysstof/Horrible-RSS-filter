# Horrible-RSS-filter
small horrible local webserver in powershell to filter RSS feed from horriblesubs
 
 launch a web server locally that will grab HS feed and filter for specific show

quick and dirty slapped together code, but some wanted a way to filter rss feed# wait for @HS to improve RSS feed and add "?show=" in the url 

## SYNTAX
 
 http://localhost:8008/?show=.....&res=.....
* show= the name or partial name of the show, case sensitive, space replaced by +
* res= resolution like hs : sd, 720 or 1080.
missing these 2 argument will yield nothing, 
malformatting show will result in random stuff overtime try in your browser before setting the url directly in your torrent client
resolution is controlled and defaulted to 1080 in case of typo, $res to change that
replace 8008 with desired port in the code directly, otherwise don't touch it

## EXAMPLES 

http://localhost:8008/?show=One+Piece&res=720  >> will grab one piece, mind the case and space become +#

http://localhost:8008/?show=lanet&res=1080 >> will return Clockwork Planet

http://localhost:8008/?show=Sa&res=1080 >> will return multiple show

http://localhost:8008/stop >> will kill the server

## INTALL
* save as a .PS1 file where ever you want on your computer
* right clic on the file and "Run with powershell", a windows fill pop then disappear
* you can change or comment the line hidding the windows if you want a control on whether the server is running ( line #53 starting with "[UserWindows]::")

#dealwithit #nologs #yolocoding
no way to see what is does or why it does it wrong# open powershell, type "get-process powershell" if you get more than 1 line you probably have a problem, kill all powershell in doubt 
