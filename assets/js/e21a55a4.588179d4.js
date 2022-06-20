"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[637],{20417:function(e){e.exports=JSON.parse('{"functions":[{"name":"_new","desc":"Constructs a new RemoteEventServer object","params":[{"name":"name","desc":"","lua_type":"string"},{"name":"server","desc":"","lua_type":"Server"}],"returns":[{"desc":"","lua_type":"RemoteEventServer"}],"function_type":"static","private":true,"source":{"line":22,"path":"src/RemoteEventServer.lua"}},{"name":"_fireServer","desc":"Called by RemoteEventClient to fire the server","params":[{"name":"client","desc":"","lua_type":"Client"},{"name":"...","desc":"","lua_type":"any"}],"returns":[],"function_type":"method","private":true,"source":{"line":43,"path":"src/RemoteEventServer.lua"}},{"name":"destroy","desc":"Prepares RemoteEventServer for garbage  collection","params":[],"returns":[],"function_type":"method","source":{"line":50,"path":"src/RemoteEventServer.lua"}},{"name":"fireClient","desc":"Fires the corresponding RemoteEventClient instance\'s OnClientEvent signal with the passed arguments","params":[{"name":"client","desc":"","lua_type":"Client"},{"name":"...","desc":"","lua_type":"any"}],"returns":[],"function_type":"method","source":{"line":67,"path":"src/RemoteEventServer.lua"}},{"name":"fireAllClients","desc":"Fires the corresponding RemoteEventClient instance\'s OnClientEvent signal with the passed arguments for each client","params":[{"name":"...","desc":"","lua_type":"any"}],"returns":[],"function_type":"method","source":{"line":76,"path":"src/RemoteEventServer.lua"}},{"name":"FireClient","desc":"PascalCase alias for fireServer","params":[{"name":"client","desc":"","lua_type":"Client"},{"name":"...","desc":"","lua_type":"any"}],"returns":[],"function_type":"method","source":{"line":91,"path":"src/RemoteEventServer.lua"}},{"name":"FireAllClients","desc":"PascalCase alias for fireAllClients","params":[{"name":"...","desc":"","lua_type":"any"}],"returns":[],"function_type":"method","source":{"line":101,"path":"src/RemoteEventServer.lua"}},{"name":"Destroy","desc":"PascalCase alias for destroy","params":[],"returns":[],"function_type":"method","source":{"line":109,"path":"src/RemoteEventServer.lua"}}],"properties":[],"types":[],"name":"RemoteEventServer","desc":"RemoteEventServer class","source":{"line":10,"path":"src/RemoteEventServer.lua"}}')}}]);