import asyncdispatch
import httpclient
# from httpcore import newHttpHeaders
import json

proc test*(url: string, reqMethod: string, headerstoUse: string): Future[string] {.async.} =    
    var parsedHeaders = if len(headerstoUse) > 0: parseJson(headerstoUse) else: %*{}
    var kvPairs: seq[(string, string)]
    for k, v in parsedHeaders.pairs:
        echo "key: ", k, " and val: ", v
        kvPairs.add((k, v.getStr()))
    
    echo "kvPairs: ", $(kvPairs)
    

    echo "parsedHeaders: ", parsedHeaders, " typeof: ", typeof(parsedHeaders)
    let client = newAsyncHttpClient()
    let resp = await client.request(url, reqMethod, headers=newHttpHeaders(kvPairs))
    result = await resp.body
  

let headers = """{"User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.97 Safari/537.36"} """
echo waitFor test("http://example.com", "POST", headers)