function EDRV_Init()
	--Initiation of driver. Nothing too special.
	ELAN_Trace([[                          _._       _,._]])
	ELAN_Trace([[                        _."   `. " ."   _`.')
	ELAN_Trace([[                ,"""/`""-.-.,/. ` V"\-,`.,--/"""."-..]])
	ELAN_Trace([[              ,"    `...," . ,\-----._|     `.   /   \]])
	ELAN_Trace([[            `.            .`  -"`"" .._   :> `-"   `.]])
	ELAN_Trace([[           ,"  ,-.  _,.-"| `..___ ,"   |"-..__   .._ L]])
	ELAN_Trace([[          .    \_ -"   `-"     ..      `.-" `.`-."_ .|]])
	ELAN_Trace([[          |   ,",-,--..  ,--../  `.  .-.    , `-.  ``.]])
	ELAN_Trace([[          `.," ,  |   |  `.  /"/,,.\/  |    \|   |]])
	ELAN_Trace([[               `  `---"    `j   .   \  .     "   j]])
	ELAN_Trace([[             ,__`"        ,"|`"\_/`."\"        |\-"-, _,.]])
	ELAN_Trace([[      .--...`-. `-`. /    "- ..      _,    /\ ," .--""  ,"".]])
	ELAN_Trace([[    _"-""-    --  _`"-.../ __ "."`-^,_`-""""---....__  " _,-`]])
	ELAN_Trace([[  _.----`  _..--."        |  "`-..-" __|"""         .""-. """--.._]])
	ELAN_Trace([[ /        "    /     ,  _.+-."  ||._"   """". .          `     .__\]])
	ELAN_Trace([[ `---    /        /  / j"       _/|..`  -. `-`\ \   \  \   `.  \ `-..]])
	ELAN_Trace([[," _.-" /    /` ./  /`_|_,-"   ","|       `. | -"`._,   L  \ .  `.   |]])
	ELAN_Trace([[`"" /  /  / ,__...-----| _.,  ,"            `|----.._`-.|" |. .` ..  .]])
	ELAN_Trace([[  /  "| /.,/   \--.._ `-," ,          .  "`."  __,., "  ""``._ \ \`,"]])
	ELAN_Trace([[ /_,"---  ,     \`._,-` \ //  / . \    `._,  -`,  / / _   |   `-L -]])
	ELAN_Trace([[  /       `.     ,  ..._ " `_/ "| |\ `._"       "-."   `.,"     |]])
	ELAN_Trace([[ "         /    /  ..   `.  `./ | ; `."    ,"" ,.  `.    \      |]])
	ELAN_Trace([[  `.     ,"   ,"   | |\  |       "        |  ,"\ |   \    `    ,L]])
	ELAN_Trace([[  /|`.  /    "     | `-| "                  /`-" |    L    `._/  \]])
	ELAN_Trace([[ / | .`|    |  .   `._."                   `.__,"   .  |     |  (`]])
	ELAN_Trace([["-""-"_|    `. `.__,._____     .    _,        ____ ,-  j     ".-"""]])
	ELAN_Trace([[       \      `-.  \/.    `"--.._    _,.---"""\/  "_,."     /-"]])
	ELAN_Trace([[        )        `-._ "-.        `--"      _.-".-""        `.]])
	ELAN_Trace([[       ./            `,. `".._________...""_.-"`.          _j]])
	ELAN_Trace([[      /_\.__,"".   ,."  "`-...________.---"     ."".   ,__./_\]])
	ELAN_Trace([[             \_/"""-"                           "-"""\_/`"`-`]])
	ELAN_Trace('\n  ')
	ELAN_Trace('\n  ')
	ELAN_Trace('\n  ')
	ELAN_Trace("Driver iniated")

	--create a TCP socket and show status green if successful. 
	--This is in case IP address is already set and "update driver" button was pressed, otherwise useless
	userName = ELAN_GetUserName()
	password = ELAN_GetPassword()
	encodedPassword = ELAN_GetAuthBasic()
	ipAddress = ELAN_GetIPString()
	port = ELAN_GetIPPort()
	tcpSocket = ELAN_CreateTCPClientSocket(ipAddress, port)
	if ELAN_ConnectTCPSocket(tcpSocket) then
		ELAN_Trace(string.format("Connetion successful on socket: %s",tcpSocket))
		ELAN_SetDeviceState("GREEN","Intercom online")
	end
end

function EDRV_SetIPConfig()
	--When the "apply" button is pressed, create a TCP socket
	ipAddress = ELAN_GetIPString()
	port = ELAN_GetIPPort()
	userName = ELAN_GetUserName()
	password = ELAN_GetPassword()
	encodedPassword = ELAN_GetAuthBasic()
	tcpSocket = ELAN_CreateTCPClientSocket(ipAddress, port)
	if ELAN_ConnectTCPSocket(tcpSocket) then
		--set state green if socket creation was successful
		ELAN_Trace(string.format("Connetion successful on socket: %s",tcpSocket))
		ELAN_SetDeviceState("GREEN","Intercom online")
		--getInfo() is a custom function which sends the /api/system/info command. 
		--Response is a JSON file which contains general information
		--The other "config" functions are custom functions that return specific informatoin fields from the JSON file
		res = getInfo()
		FW = configFW(res)
		model = configModel(res)
		macAddress = configMAC(res)
		--setting the relevant fields in the configurator
		ELAN_SetConfigurationString("sVarFW", FW)
		ELAN_SetConfigurationString("sVarMAC", macAddress)
		ELAN_SetConfigurationString("sVarModel", model)
		ELAN_Trace(string.format("Info dump here: %s",res))
	else
		--If socket was not successfully created, show corresponding status in configurator
		ELAN_Trace("No connection!")
		ELAN_SetDeviceState("RED","Not connected")
	end
end

function EDRV_SetOutput(index, state)
	--We don't really need a state==0 option because the Akuvox intercom does not have a toggle option to its relays apparently (I didn't find any in the manual at least)
	if state == 1 then
		--sending a GET command with username, password and door number (their relays start at 1, our start at 0)
		--Also get username and password for the get command
		userName = ELAN_GetUserName()
		password = ELAN_GetPassword()
		sHTTP = string.format("GET /fcgi/do?action=OpenDoor&UserName=%s&Password=%s&DoorNum=%d HTTP/1.0\r\n",userName,password,index+1)
		sHTTP = sHTTP .. "Host: " .. ipAddress .. "\r\n"
		sHTTP = sHTTP .. "Content-Type: text/html; charset=UTF-8\r\n"
		sHTTP = sHTTP .. "Connection: keep-alive\r\n\r\n"
		ELAN_Trace(string.format("Just sent this command: %s",sHTTP))
		--HTTPExchange is a godsent, such a great function. Allows to send the command to the intercom and capture response in one go. Very convinient.
		response = ELAN_DoHTTPExchange(tcpSocket,sHTTP, false)
		ELAN_Trace(string.format("The response was %s", response))
		--from here on out, just a simple logging tool, nothing too special and can be removed if troublesome
		--declare table
		local tLogEntry = {}
		--fill values using named keys that match the "tag" values declared for each column
		tLogEntry["relStat"] = "Relay activated"
		tLogEntry["relNum"] = index+1
		--once finished filling in all entries, call the function to write the entry and pass the table as the argument
		local b = ELAN_WriteDriverLogEntry(tLogEntry)
		ELAN_Trace(string.format("Write Log Entry Result: %s",b))
	end
end

--Pressing the "reboot intercom" button does... guess...
function EDRV_ExecuteConfigProc()
	UserName = ELAN_GetUserName()
	password = ELAN_GetPassword()
	encodedPassword = ELAN_GetAuthBasic()
	sHTTP = "GET api/system/reboot HTTP/1.0\r\n"
	sHTTP = sHTTP .. string.format("Authorization: Basic %s", encodedPassword)
	sHTTP = sHTTP .. "Host: " .. ipAddress .. "\r\n"
	sHTTP = sHTTP .. "Content-Type: text/html; charset=UTF-8\r\n"
	sHTTP = sHTTP .. "Connection: keep-alive\r\n\r\n"
	ELAN_Trace(string.format("Just sent this command: %s",sHTTP))
	--HTTPExchange is a godsent, such a great function. Allows to send the command to the intercom and capture response in one go. Very convinient.
	response = ELAN_DoHTTPExchange(tcpSocket,sHTTP, false)
	ELAN_Trace(string.format("The response was %s", response))
	local tLogEntry = {} --Adding logs to Elan confiugrator
	tLogEntry["relStat"] = "System Reboot"
	tLogEntry["relNum"] = "N/A"
	local b = ELAN_WriteDriverLogEntry(tLogEntry)
	ELAN_Trace(string.format("Write Log Entry Result: %s",b))
end

--[[********************************************
CUSTOM FUNCTIONS FROM HERE ON OUT	 
********************************************--]]

--this function is mean to aquire general system information
function getInfo()
	sHTTP = "GET /api/system/info HTTP/1.0\r\n"
	sHTTP = sHTTP .. "Authorization: Basic " .. encodedPassword
	sHTTP = sHTTP .. "Host: " .. ipAddress .. "\r\n"
	sHTTP = sHTTP .. "Content-Type: text/html; charset=UTF-8\r\n"
	sHTTP = sHTTP .. "Connection: keep-alive\r\n\r\n"
	ELAN_Trace(string.format("Just sent this command: %s",sHTTP))
	--HTTPExchange is a godsent, such a great function. Allows to send the command to the intercom and capture response in one go. Very convinient.
	response = ELAN_DoHTTPExchange(tcpSocket,sHTTP,false)
	return response
end

--returns the firmware version from the Info JSON response
function configFW(response)
	hJSON = ELAN_CreateJSONMsg(response)
	baseNode = ELAN_FindJSONNode(hJSON,hJSON,"data")
	baseSubNode  = ELAN_FindJSONNode(hJSON,baseNode,"Status")
	firmwareVersion = ELAN_FindJSONValueByKey(hJSON,baseSubNode,"FirmwareVersion")
	return firmwareVersion
end

--returns the MAC address from the Info JSON response
function configMAC(response)
	hJSON = ELAN_CreateJSONMsg(response)
	baseNode = ELAN_FindJSONNode(hJSON,hJSON,"data")
	baseSubNode  = ELAN_FindJSONNode(hJSON,baseNode,"Status")
	macAd = ELAN_FindJSONValueByKey(hJSON,baseSubNode,"MAC")
	return macAd 
end

--returns the model from the Info JSON response
function configModel(response)
	hJSON = ELAN_CreateJSONMsg(response)
	baseNode = ELAN_FindJSONNode(hJSON,hJSON,"data")
	baseSubNode  = ELAN_FindJSONNode(hJSON,baseNode,"Status")
	mod = ELAN_FindJSONValueByKey(hJSON,baseSubNode,"Model")
	return mod
end













