# Fetch content from a website

import asyncdispatch
import httpclient
from httpcore import newHttpHeaders
from base64 import decode
import json

proc execute*(url: string, reqMethod: string, headerstoUse: string, passedBody: string): Future[string] {.async.} = 
    var parsedHeaders = if len(headerstoUse) > 0: parseJson(headerstoUse) else: %*{}
    var kvPairs: seq[(string, string)]
    for k, v in parsedHeaders.pairs:
        kvPairs.add((k, v.getStr()))    
    let touseBody = if len(passedBody) > 0: parseJson(decode(passedBody)) else: %*{}
    let client = newAsyncHttpClient()
    # Four possible cases
    # 1. Has headers and body
    # 2. Headers, no body
    # 3. No headers, has body
    # 4. No headers no body
    let resp = if len(headerstoUse) > 0 and len(passedBody) > 0: await client.request(url, reqMethod, body = $touseBody, headers =  newHttpHeaders(kvPairs))
             elif len(headerstoUse) > 0 and len(passedBody) == 0: await client.request(url, reqMethod, headers = newHttpHeaders(kvPairs))
             elif len(headerstoUse) == 0 and len(passedBody) > 0: await client.request(url, reqMethod, body = $touseBody)
             else: await client.request(url, reqMethod)
    result = await resp.body
    