# Fetch content from a website

import asyncdispatch
#import httpclient
import puppy
from httpcore import newHttpHeaders
from base64 import decode
import json
import std/strutils

proc execute*(url: string, reqMethod: string, headerstoUse: string, passedBody: string): Future[string] {.async.} = 
    var parsedHeaders = if len(headerstoUse) > 0: parseJson(headerstoUse) else: %*{}
    var kvPairs: seq[(string, string)]
    for k, v in parsedHeaders.pairs:
        kvPairs.add((k, v.getStr()))    
    #let touseBody = if len(passedBody) > 0: parseJson(decode(passedBody)) else: %*{}
    let touseBody = if len(passedBody) > 0: decode(passedBody) else: ""
    var pupyresponse: Response
    case toUpper(reqMethod):

        of "GET":
            pupyresponse = get(url,kvPairs)
        of "POST":
            pupyresponse = post(url,kvPairs,touseBody)                                                                                      
        else:
            pupyresponse = get(url,kvPairs)
    
    
    
    result = pupyresponse.body
    
    