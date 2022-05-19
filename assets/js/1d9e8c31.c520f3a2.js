"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[618],{37010:function(e){e.exports=JSON.parse('{"functions":[{"name":"_new","desc":"Constructs a new Client object","params":[{"name":"id","desc":"","lua_type":"string | number"},{"name":"server","desc":"","lua_type":"Server"}],"returns":[{"desc":"","lua_type":"Client"}],"function_type":"static","private":true,"source":{"line":21,"path":"src/Client.lua"}},{"name":"is","desc":"Returns whether or not the passed argument is a Client or not","params":[{"name":"obj","desc":"","lua_type":"any"}],"returns":[{"desc":"","lua_type":"bool"}],"function_type":"static","source":{"line":70,"path":"src/Client.lua"}},{"name":"getRemoteEvent","desc":"Gets the RemoteEventClient if it exists, returns nil otherwise","params":[{"name":"name","desc":"","lua_type":"string"}],"returns":[{"desc":"","lua_type":"RemoteEventClient | nil"}],"function_type":"method","source":{"line":80,"path":"src/Client.lua"}},{"name":"getRemoteFunction","desc":"Gets the RemoteFunctionClient if it exists, returns nil otherwise","params":[{"name":"name","desc":"","lua_type":"string"}],"returns":[{"desc":"","lua_type":"RemoteFunctionClient | nil"}],"function_type":"method","source":{"line":90,"path":"src/Client.lua"}},{"name":"disconnect","desc":"Disconnects the client from the server","params":[],"returns":[],"function_type":"method","source":{"line":97,"path":"src/Client.lua"}},{"name":"destroy","desc":"Alias for disconnect but sets destroyed field to true","params":[],"returns":[],"function_type":"method","source":{"line":116,"path":"src/Client.lua"}}],"properties":[{"name":"id","desc":"Stores the id of the client passed in the constructor\\n\\n    ","lua_type":"string | number","readonly":true,"source":{"line":35,"path":"src/Client.lua"}},{"name":"connected","desc":"Tells whether the client object is connected or not\\n\\n    ","lua_type":"bool","readonly":true,"source":{"line":44,"path":"src/Client.lua"}}],"types":[],"name":"Client","desc":"Client class","source":{"line":9,"path":"src/Client.lua"}}')}}]);