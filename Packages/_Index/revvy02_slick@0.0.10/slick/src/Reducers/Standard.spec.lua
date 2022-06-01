local Standard = require(script.Parent.Standard)

return function()
    describe("Standard.setValue", function()
        it("should return the new value", function()
            local state = {
                key = 0,
            }

            local old = state.key
            local new = Standard.setValue(state.key, 1)

            expect(new).to.equal(1)
            expect(old).to.equal(0)
        end)
    end)

    describe("Standard.setIndex", function()
        it("should return the new value with the index set and not mutate the old value", function()
            local state = {
                key = {
                    value = 0,
                }
            }

            local old = state.key
            local new = Standard.setIndex(state.key, "value", 1)

            expect(new.value).to.equal(1)
            expect(old.value).to.equal(0)
        end)
    end)

    describe("Standard.insertValue", function()
        it("should return the new value with the value inserted at the end and not mutate the old value if no index is passed", function()
            local state = {
                keys = {
                    "sword",
                    "bow",
                }
            }

            local old = state.keys
            local new = Standard.insertValue(state.keys, "gun")

            expect(#old).to.equal(2)
            expect(old[1]).to.equal("sword")
            expect(old[2]).to.equal("bow")

            expect(#new).to.equal(3)
            expect(new[1]).to.equal("sword")
            expect(new[2]).to.equal("bow")
            expect(new[3]).to.equal("gun")

            expect(old ~= new).to.equal(true)
        end)

        it("should return the new value with the value inserted at the passed index and not mutate the old value", function()
            local state = {
                keys = {
                    "sword",
                    "bow",
                }
            }

            local old = state.keys
            local new = Standard.insertValue(state.keys, "gun", 1)

            expect(#old).to.equal(2)
            expect(old[1]).to.equal("sword")
            expect(old[2]).to.equal("bow")

            expect(#new).to.equal(3)
            expect(new[1]).to.equal("gun")
            expect(new[2]).to.equal("sword")
            expect(new[3]).to.equal("bow")

            expect(old ~= new).to.equal(true)
        end)
    end)
    
    describe("Standard.removeIndex", function()
        it("should remove the value at the index and collapse the table to fill the empty space and not mutate the old value", function()
            local state = {
                keys = {
                    "sword",
                    "bow",
                    "gun",
                }
            }

            local old = state.keys
            local new = Standard.removeIndex(state.keys, 2)

            expect(#old).to.equal(3)
            expect(old[1]).to.equal("sword")
            expect(old[2]).to.equal("bow")
            expect(old[3]).to.equal("gun")

            expect(#new).to.equal(2)
            expect(new[1]).to.equal("sword")
            expect(new[2]).to.equal("gun")

            expect(old ~= new).to.equal(true)
        end)
    end)

    describe("Standard.removeValue", function()
        it("should find the first instance of a value and remove it and collapse the table to fill the empty space and not mutate the old value", function()
            local state = {
                keys = {
                    "sword",
                    "bow",
                    "gun",
                    "bow",
                }
            }

            local old = state.keys
            local new = Standard.removeValue(state.keys, "bow")

            expect(#old).to.equal(4)
            expect(old[1]).to.equal("sword")
            expect(old[2]).to.equal("bow")
            expect(old[3]).to.equal("gun")
            expect(old[4]).to.equal("bow")

            expect(#new).to.equal(3)
            expect(new[1]).to.equal("sword")
            expect(new[2]).to.equal("gun")
            expect(new[3]).to.equal("bow")

            expect(old ~= new).to.equal(true)
        end)
    end)
end