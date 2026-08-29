local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Logger = require(ReplicatedStorage.Utilities.Logger)
local ProfileStore = require(ServerStorage.ThirdParty.ProfileStore)

-- Fake sentinel used for documentation purposes where code cannot run after
-- calls to deliberately erroneous functions, i.e. LOGGER.error
local ERROR_RAISED = -1
local DATA_TEMPLATE = {
    Money = 0,
}
local LOGGER = Logger.new(script)
local STORE = ProfileStore.New("PlayerData", DATA_TEMPLATE)
local saveDataLoadedBindable = Instance.new("BindableEvent")
saveDataLoadedBindable.Name = "SaveDataLoaded"
saveDataLoadedBindable.Parent = script

export type Profile = typeof(STORE:StartSessionAsync("", {}))
export type SaveData = typeof(DATA_TEMPLATE)

local PlayerData = {
    Profiles = {} :: { [Player]: Profile },
    SaveDataLoaded = saveDataLoadedBindable.Event :: RBXScriptSignal<Player, SaveData>,
    SaveDataLoadedBindable = saveDataLoadedBindable,
}

local function setup(player: Player): ()
    local profileFound = STORE:StartSessionAsync(`{player.UserId}`, {
        Cancel = function()
            return player.Parent ~= Players
        end,
    })

    if not profileFound then
        player:Kick("Failed to retrieve player data - please rejoin")

        return
    end

    profileFound:AddUserId(player.UserId)
    profileFound:Reconcile()

    profileFound.OnSessionEnd:Connect(function()
        PlayerData.Profiles[player] = nil

        player:Kick("Profile session end - please rejoin")
    end)

    if player.Parent ~= Players then
        profileFound:EndSession()

        return
    end

    PlayerData.Profiles[player] = profileFound

    PlayerData.SaveDataLoadedBindable:Fire(player, profileFound.Data)
    print(`Profile loaded for {player}!`)
end

function PlayerData.getProfile(player: Player): Profile
    local profileFound = PlayerData.Profiles[player]

    if not profileFound then
        LOGGER.error(`Unable to retrieve profile for player {player}`)

        return ERROR_RAISED
    end

    return profileFound
end

local function save(player: Player): ()
    local playerProfile = PlayerData.getProfile(player)

    playerProfile:EndSession()
end

PlayerData.onPlayerAdded = setup
PlayerData.onPlayerRemoving = save

function PlayerData.initialise(): ()
    for _, player in Players:GetPlayers() do
        task.spawn(setup, player)
    end
end

return PlayerData

