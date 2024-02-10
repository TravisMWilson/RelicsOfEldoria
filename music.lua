Music = Object:extend()

local function setMusicVolumes(self, volume)
    for _, mus in pairs(self.music) do
        mus:setVolume(volume)
    end
end

local function setSFXVolumes(self, volume)
    for _, sfx in pairs(self.sfx) do
        sfx:setVolume(volume)
    end
end

local function setVoiceVolumes(self, volume)
    for _, voice in pairs(self.voice) do
        voice:setVolume(volume)
    end
end

local function playMusic(self)
    for _, mus in pairs(self.music) do
        mus:play()
    end
end

local function setLooping(list, bool)
    for _, sfx in pairs(list) do
        sfx:setLooping(bool)
    end
end

function Music:new()
    self.music = {}
    self.sfx = {}

    self.music.townMusic = love.audio.newSource("SFX/TownMusic.wav", "stream")--
    self.music.townAmb = love.audio.newSource("SFX/TownAmb.mp3", "stream")--
    self.music.dungeonMusic = love.audio.newSource("SFX/DungeonMusic.wav", "stream")--
    self.music.dungeonAmb = love.audio.newSource("SFX/DungeonAmb.mp3", "stream")--
    self.music.fightingMusic = love.audio.newSource("SFX/FightingMusic.wav", "stream")--
    self.music.deathMusic = love.audio.newSource("SFX/DeathMusic.wav", "stream")--
    setLooping(self.music, true)

    self.sfx.bagOpenSFX = love.audio.newSource("SFX/BagOpen.mp3", "static")
    self.sfx.bagCloseSFX = love.audio.newSource("SFX/BagClose.mp3", "static")
    self.sfx.coinSellSFX = love.audio.newSource("SFX/CoinSell.mp3", "static")
    self.sfx.deleteItemSFX = love.audio.newSource("SFX/DeleteItemSFX.mp3", "static")
    self.sfx.equipWeaponSFX = love.audio.newSource("SFX/EquipWeapon.mp3", "static")
    self.sfx.healSFX = love.audio.newSource("SFX/HealSFX.wav", "static")--
    self.sfx.skillCloseSFX = love.audio.newSource("SFX/SkillClose.mp3", "static")
    self.sfx.skillOpenSFX = love.audio.newSource("SFX/SkillOpen.mp3", "static")
    self.sfx.teleportSFX = love.audio.newSource("SFX/Teleport.wav", "static")--
    self.sfx.deathLaughterSFX = love.audio.newSource("SFX/DeathLaughter.mp3", "static")--
    self.sfx.deathSFX = love.audio.newSource("SFX/DeathSFX.mp3", "static")--
    self.sfx.blockSFX = love.audio.newSource("SFX/BlockSFX.mp3", "static")--
    self.sfx.buttonPressSFX = love.audio.newSource("SFX/ButtonPressSFX.mp3", "static")
    self.sfx.enterDungeonSFX = love.audio.newSource("SFX/EnterDungeonSFX.mp3", "static")--
    self.sfx.changeLevelSFX = love.audio.newSource("SFX/ChangeLevelSFX.wav", "static")--
    self.sfx.chestOpenSFX = love.audio.newSource("SFX/ChestOpenSFX.mp3", "static")--
    self.sfx.levelUpSFX = love.audio.newSource("SFX/LevelUpSFX.mp3", "static")--
    self.sfx.noKeySFX = love.audio.newSource("SFX/NoKeySFX.mp3", "static")--
    self.sfx.pickupKeySFX = love.audio.newSource("SFX/PickupKeySFX.mp3", "static")--
    self.sfx.lootChestSFX = love.audio.newSource("SFX/LootChestSFX.mp3", "static")--
    self.sfx.enemyHitPlayerSFX = love.audio.newSource("SFX/EnemyHitPlayerSFX.mp3", "static")--
    self.sfx.playerHitEnemySFX = love.audio.newSource("SFX/PlayerHitEnemySFX.mp3", "static")--
    self.sfx.enemySwingSFX = love.audio.newSource("SFX/EnemySwingSFX.mp3", "static")--
    self.sfx.swordSwingSFX = love.audio.newSource("SFX/SwordSwingSFX.mp3", "static")--
    self.sfx.drinkPotionSFX = love.audio.newSource("SFX/DrinkPotionSFX.wav", "static")--
    self.sfx.enemyDieSFX = love.audio.newSource("SFX/EnemyDieSFX.wav", "static")--
    self.sfx.changeRoomSFX = love.audio.newSource("SFX/ChangeRoomSFX.mp3", "static")--
    self.sfx.potionHealSFX = love.audio.newSource("SFX/PotionHealSFX.wav", "static")--
    self.sfx.pickupPotionSFX = love.audio.newSource("SFX/PickupPotionSFX.mp3", "static")--
    self.sfx.pickupRelicSFX = love.audio.newSource("SFX/PickupRelicSFX.wav", "static")--
    self.sfx.cantDeleteVoiceSFX = love.audio.newSource("SFX/CantDeleteVoice.wav", "static")--
    self.sfx.inventoryFullVoiceSFX = love.audio.newSource("SFX/InventoryFullVoice.wav", "static")--
    self.sfx.inventoryGettingFullVoiceSFX = love.audio.newSource("SFX/InventoryGettingFullVoice.wav", "static")--
    self.sfx.inventoryAlreadyFullVoiceSFX = love.audio.newSource("SFX/InventoryAlreadyFullVoice.wav", "static")--
    self.sfx.alreadyFullHealthVoiceSFX = love.audio.newSource("SFX/AlreadyFullHealthVoice.wav", "static")--
    self.sfx.powerUsedUpVoiceSFX = love.audio.newSource("SFX/PowerUsedUpVoice.wav", "static")--
    self.sfx.alreadyThereVoiceSFX = love.audio.newSource("SFX/AlreadyThereVoice.wav", "static")--
    self.sfx.needBetterKeyVoiceSFX = love.audio.newSource("SFX/NeedBetterKeyVoice.wav", "static")--
    self.sfx.newSwordVoiceSFX = love.audio.newSource("SFX/NewSwordVoice.wav", "static")--
    setLooping(self.sfx, false)

    self.voice = {}
    self.voice["voiceStory11"] = love.audio.newSource("SFX/VoiceStory11.wav", "static")
    self.voice["voiceStory12"] = love.audio.newSource("SFX/VoiceStory12.wav", "static")
    self.voice["voiceStory13"] = love.audio.newSource("SFX/VoiceStory13.wav", "static")
    self.voice["voiceStory14"] = love.audio.newSource("SFX/VoiceStory14.wav", "static")
    self.voice["voiceStory15"] = love.audio.newSource("SFX/VoiceStory15.wav", "static")
    self.voice["voiceStory16"] = love.audio.newSource("SFX/VoiceStory16.wav", "static")
    self.voice["voiceStory21"] = love.audio.newSource("SFX/VoiceStory21.wav", "static")
    self.voice["voiceStory22"] = love.audio.newSource("SFX/VoiceStory22.wav", "static")
    self.voice["voiceStory31"] = love.audio.newSource("SFX/VoiceStory31.wav", "static")
    self.voice["voiceStory32"] = love.audio.newSource("SFX/VoiceStory32.wav", "static")
    self.voice["voiceStory41"] = love.audio.newSource("SFX/VoiceStory41.wav", "static")
    self.voice["voiceStory42"] = love.audio.newSource("SFX/VoiceStory42.wav", "static")
    self.voice["voiceStory43"] = love.audio.newSource("SFX/VoiceStory43.wav", "static")
    self.voice["voiceStory44"] = love.audio.newSource("SFX/VoiceStory44.wav", "static")
    setLooping(self.voice, false)

    self.currentMusic = 0
    setMusicVolumes(self, 0)
    self.music.townMusic:setVolume(1)
    self.music.townAmb:setVolume(1)
    setSFXVolumes(self, 1)
    setVoiceVolumes(self, 1)
    playMusic(self)
end

function Music:update(dt)
    if currentLevel == 0 then
        if self.currentMusic ~= 0 then
            self.currentMusic = 0
            setMusicVolumes(self, 0)
            self.music.townMusic:setVolume(1)
            self.music.townAmb:setVolume(1)
            playMusic(self)
        end
    elseif currentLevel > 0 and player.dead then
        if self.currentMusic ~= 1 then
            self.currentMusic = 1
            setMusicVolumes(self, 0)
            self.music.deathMusic:setVolume(1)
            music:play(self.sfx.deathLaughterSFX)
            music:play(self.sfx.deathSFX)
            playMusic(self)
        end
    elseif currentLevel > 0 and enemy.dead then
        if self.currentMusic ~= 2 then
            self.currentMusic = 2
            setMusicVolumes(self, 0)
            self.music.dungeonMusic:setVolume(1)
            self.music.dungeonAmb:setVolume(1)
            playMusic(self)
        end
    elseif currentLevel > 0 and not enemy.dead then
        if self.currentMusic ~= 3 then
            self.currentMusic = 3
            setMusicVolumes(self, 0)
            self.music.fightingMusic:setVolume(1)
            playMusic(self)
        end
    end
end

function Music:draw()

end

function Music:play(sound)
    local newSource = sound:clone()
    newSource:play()
end