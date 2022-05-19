local Slick = {
    Signal = require(script.Signal), -- Signal class for broadcasting info
    Store = require(script.Store), -- Store class for listening to state changes
    Card = require(script.Card), -- Key class for listening to key changes
    Keeper = require(script.Keeper), -- Keeper class for listening to multiple key changes
    None = require(script.None),
}

return Slick