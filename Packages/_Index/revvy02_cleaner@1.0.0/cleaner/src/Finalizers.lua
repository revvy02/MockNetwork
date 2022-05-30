local Finalizers = {
    ["function"] = function(trash)
        trash()
     end,
 
     ["Instance"] = game.Destroy,
 
     ["RBXScriptConnection"] = Instance.new("BindableEvent").Event:Connect(function() end).Disconnect,

     ["thread"] = coroutine.close,
}

return Finalizers