index_html = [[
<!DOCTYPE html>
<html>
	<head>
		<title>Codea Debug Server</title>
		<meta charset="UTF-8" />
	</head>
	<body>
		<div id="serverData">Waiting for connection...</div>
		
		<script type="text/javascript">
			function httpGetAsync(theUrl, callback)
			{
				var xmlHttp = new XMLHttpRequest();
				xmlHttp.onreadystatechange = function() { 
					if (xmlHttp.readyState == 4 && xmlHttp.status == 200)
					callback(xmlHttp.responseText);
				}
				xmlHttp.open("GET", theUrl, true); // true for asynchronous 
				xmlHttp.send(null);
			}
			
			function update_func()
			{
				httpGetAsync("debug_update.lua", function(response) {
					document.getElementById("serverData").innerHTML=response;
				})
			}
			
			window.setInterval(update_func, 1000 / 65); // 65Hz
		</script>
	</body>
</html>
]]