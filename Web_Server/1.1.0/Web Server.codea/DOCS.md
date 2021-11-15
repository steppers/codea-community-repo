# Codea Web Server Documentation

Thank you for checking out my Web Server for Codea!

For an example of many of these concepts please look at the ‘Main’ tab of the ‘Web Server’ project & the corresponding ‘Web Server Demo` asset pack for HTML/Javascript source.

I hope this documentation provides a good resource to those who wish to use this in one of their own projects. If you have any questions, feel free to direct them at me (Steppers) over on the forum :)

### WARNING:

This Web Server uses insecure HTTP and NOT the secure variant HTTPS. Do not use this for transmitting sensitive or private data across networks you do not fully trust. I take no responsibility for anything stupid you may decide to do…

---

## Features

- Super simple interface with one line server creation
- Support for multiple request types (GET, POST, HEAD, etc.)
- Server side lua scripting, embedded inside HTML sources
- Bi-directional WebSocket support


## Getting started

To create your own web server & local website you need only 2 things; a folder for your website HTML to live & a new project to run the server (with Web Server added as a dependency).

In this example, we only need 3 lines in the entire project to start a web server:

```
function setup()
    WebServer(asset.documents.Web_Server_Demo)
end
```

That's it! The example above starts a web server that serves files found in the `Web Server Demo` folder in Codea's documents folder.

If all you need is a web server to provide static content (HTML & Javascript) then look no further, this is all you likely need.

---

## Custom Resources

Resources definitions in this web server are all implemented using a simple interface. Once a WebServer object has been created, you may add additional resource definitions that are defined by a URL pattern & a request handler function. The example below demonstrates the basic use of this:

```
-- Create our Web Server
server = WebServer(asset.documents.Web_Server_Demo)

-- Add a new resource definition
server:add_resource("/codea_demo_resource", function(request)

    -- Only GET supported on this resource
    if request.method ~= "GET" then
        return 501 -- Unsupported
    end
    
    -- Return status code '200 OK' & the response content to send to the client
    return 200, "Hello Codea!"
end)
```

In the example above, the url `http://localhost/codea_demo_resource` will match with this resource definition and as such, trigger its request handler.

The request handler function is passed a single parameter by default, the `request` table which represents the current request being made by a client.

A request table is formed like so:

```
request = {
    uri,        -- String - The full URL path component (E.g '/index.html')
    method,     -- String - The request method (GET, POST, PUT, HEAD, etc.)
    body,       -- String - Any data provided by the client (common with POST & PUT)
    headers,    -- Table  - key-value headers provided with the request
    query       -- Table  - Any query key-value pairs provided in the request
}
```

Passed along with the request table are any captures defined in the URL pattern. For example `server:add_resource("/test/(.*)", function(request, path) ..` will pass the value captured in `(.*)` (that is, anything following /test/) to the request handler as `path`. If multiple captures are defined in the pattern, then the corresponding number of additional parameters are provided. This allows us to change behaviour depending on the URL used.

Using this information from the request, many custom behaviours can be produced for web pages. For example, this resource definition returns HTML content displaying the custom uri path used:

```
server = WebServer(asset.documents.demo_site)

server:add_resource("/test/(.*)", function(request, path)
    -- Only GET supported on this resource
    if request.method ~= "GET" then
        return 501 -- Unsupported
    end
    
    -- Return the path used
    return 200, "<html>URL sub-path used: " .. path .. "</html>"
end)
```

## Server Side Scripting

The Web Server has support for server side Lua scripts embedded in HTML content.

Any HTML content sent to clients can be pre-processed to detect `<?lua ... ?>` code blocks. These code blocks are executed and replaced by their produced output.

The default resource definition (reading from the source folder) applies this pre-processing automatically. For user defined resources the pre-processing can be applied to any HTML source using `source = WebServer.preprocess_html(source)`.

This HTML example will list all items in Codea's documents folder:

```
<html>
<?lua
    local items = asset.documents.all
    
    for _,item in ipairs(items) do
        print(item.name .. "<br>")
    end
?>
</html>
```

## Web Sockets

The Web Server also has WebSocket support, providing a bi-directional communications link between a connected browser & Codea.

A WebSocket sends data between devices in the form of messages. A message can be either a UTF-8 string or arbitrary binary data.

When using WebSockets in your Codea project you have 3 objects at your disposal:

- Endpoint Definitions
- WebSocketClient
- WebSocketClientGroup

### Endpoints

In order to start using WebSockets we first need to define the endpoint that will be used to start a connection.

Similarly to how we define custom resources we define a URI to match against. We also provide a callback function used to handle new client connections:

```
server = WebServer(asset.documents.demo_site)

server:add_websocket("/updates", function(new_client)
   
    -- Add a message handler
    function new_client:on_message(msg)
        print(msg)
    end
    
    -- Send a connection message
    new_client:send("Connected!")
end)
```

Lets walk through the example above one piece at a time.


```
server = WebServer(asset.documents.demo_site)
```
creates our WebServer instance, serving files from the `demo_site` folder.
<br><br>

```
server:add_websocket("/updates", function(new_client)
```
defines a new WebSocket endpoint. This means that a WebSocket connection can be made using the URL `ws://localhost/updates` from the same device or `ws://192.168.0.9/updates` (in my case) from other devices on the local network.
The function provided is intended to alert the application to new connections.
<br><br>

```
function new_client:on_message(msg)
    print(msg)
end
```
overrides the default blank message handler used by all new client connections. This allows us to define a custom message handler function that will be called whenever a message is sent from a client to the server. In this case, we print all received messages to the console.
<br><br>

```
new_client:send("Connected!")
```
sends a simple UTF-8 string message to the newly connected client. If the data to be sent consisted of a binary string then the function should be called like so; `new_client:send(binary_data_str, true)` where the 'true' indicates that this should be treated as binary data by the Javascript client.

### Javascript side

In order to use WebSockets a little Javascript is required in your HTML source to connect to an endpoint defined in Lua. [JS WebSocket API documentation](https://developer.mozilla.org/en-US/docs/Web/API/WebSocket) is also available.

The example below is what is used by the provided Web Server Demo site. It initiates a WebSocket connection, defines its message handler callback (`onmessage`) and provides automatic reconnection when a connection is lost.

Note that this example is intended to be embedded in a HTML source file, as a result `location.host` provides the server address the enclosing HTML file was received from.

```
<script type="text/javascript">
	let ws = null;

	function connect(ws_url, onmessage){
		ws = new WebSocket(ws_url);
    		
	    ws.onmessage = onmessage;
	    
	    ws.onopen = function(e)
	    {
			// Change status to connected
			document.getElementById("server_message").innerHTML="Connected";
			
			// Send a test message
			ws.send("Browser says hello!");
		};
		
	    ws.onclose = function()
	    {
			// Change status to disconnected
			document.getElementById("server_message").innerHTML="Waiting for connection...";
	    
			// Try to reconnect every second
			setTimeout(function(){
				connect(ws_url, onmessage)
			}, 1000);
		};
	}
	
	// Connect to the websocket
	connect("ws://" + location.host + "/updates", function(message) {
		// Change status message
		document.getElementById("server_message").innerHTML=message.data;
  	})
</script>
```

### WebSocketClientGroup

To help with broadcasting to multiple connected clients at once, `WebSocketClientGroup` stores `WebSocketClient` references and allows clients to be added & removed from the group at will.

The number of clients in the group can be obtained using the `WebSocketClientGroup:size()` function.

A WebSocketClientGroup is created:

```
clients = WebSocketClientGroup()
```
<br>

New connection clients are added to the group:

```
server:add_websocket("/updates", function(client)
	...
	clients:add(client)
	...
end)
```
<br>

Elsewhere within your Codea project a message can be sent to all connected clients using:

```
clients:broadcast(“I’m a broadcast!”)
```