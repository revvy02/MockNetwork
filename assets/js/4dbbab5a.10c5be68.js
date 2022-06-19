"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[281],{80215:function(e){e.exports=JSON.parse('{"functions":[{"name":"new","desc":"Constructs a new Server object","params":[{"name":"clients","desc":"","lua_type":"table"}],"returns":[{"desc":"","lua_type":"Server"}],"function_type":"static","source":{"line":25,"path":"src/Server.lua"}},{"name":"createRemoteEvent","desc":"Creates a new RemoteEvent on server and clients","params":[{"name":"name","desc":"","lua_type":"string"}],"returns":[{"desc":"","lua_type":"RemoteEventServer"}],"function_type":"method","source":{"line":50,"path":"src/Server.lua"}},{"name":"getRemoteEvent","desc":"Gets the RemoteEventServer instance","params":[{"name":"name","desc":"","lua_type":"string"}],"returns":[{"desc":"","lua_type":"RemoteEventServer"}],"function_type":"method","errors":[{"lua_type":"\\"%s is not a valid RemoteEvent\\"","desc":""}],"source":{"line":66,"path":"src/Server.lua"}},{"name":"createRemoteFunction","desc":"Creates a new RemoteFunction on server and clients","params":[{"name":"name","desc":"","lua_type":"string"}],"returns":[{"desc":"","lua_type":"RemoteFunctionServer"}],"function_type":"method","source":{"line":77,"path":"src/Server.lua"}},{"name":"getRemoteFunction","desc":"Gets the RemoteFunctionServer instance","params":[{"name":"name","desc":"","lua_type":"string"}],"returns":[{"desc":"","lua_type":"RemoteFunctionServer"}],"function_type":"method","errors":[{"lua_type":"\\"%s is not a valid RemoteFunction\\"","desc":""}],"source":{"line":93,"path":"src/Server.lua"}},{"name":"connect","desc":"Connects a new client to the server","params":[{"name":"id","desc":"","lua_type":"string"}],"returns":[{"desc":"","lua_type":"Client"}],"function_type":"method","source":{"line":104,"path":"src/Server.lua"}},{"name":"disconnect","desc":"Disconnects client from server","params":[{"name":"id","desc":"","lua_type":"string"}],"returns":[],"function_type":"method","source":{"line":113,"path":"src/Server.lua"}},{"name":"getClient","desc":"Gets the client object from id","params":[{"name":"id","desc":"","lua_type":"string"}],"returns":[{"desc":"","lua_type":"Client"}],"function_type":"method","source":{"line":123,"path":"src/Server.lua"}},{"name":"getClientsMapped","desc":"Returns a map with each connected client\'s id mapped to the client instance","params":[],"returns":[{"desc":"","lua_type":"table"}],"function_type":"method","source":{"line":132,"path":"src/Server.lua"}},{"name":"getClientsListed","desc":"Returns a list with each connected client","params":[],"returns":[{"desc":"","lua_type":"table"}],"function_type":"method","source":{"line":147,"path":"src/Server.lua"}},{"name":"destroy","desc":"Prepares server for garbage collection","params":[],"returns":[],"function_type":"method","source":{"line":160,"path":"src/Server.lua"}}],"properties":[],"types":[],"name":"Server","desc":"Server class","source":{"line":16,"path":"src/Server.lua"}}')}}]);