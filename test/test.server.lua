local package = game.ServerScriptService.MockNetwork

package.Parent = game.ReplicatedStorage.Packages

require(package.Parent.TestEZ).TestBootstrap:run({
    package["MockRemoteEvent.spec"],
    package["MockRemoteFunction.spec"],
    
    package["RemoteEventClient.spec"],
    package["RemoteEventServer.spec"],

    package["RemoteFunctionClient.spec"],
    package["RemoteFunctionServer.spec"],

    package["Server.spec"],
    package["Client.spec"],
})
