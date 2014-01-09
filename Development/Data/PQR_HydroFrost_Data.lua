if not PQR_LoadedDataFile then
	PQR_LoadedDateFile = 1
	PQ_PlayerName = UnitName("player")
	PQ_PlayerRace = select(2, UnitRace("player"))
	print("|cffFFBE69Frost 2H Data File - Jan 9, 2014|cffffffff")
end

TargetValidation = nil
function TargetValidation(unit, spell)
	if UnitExists(unit)
	and PQR_SpellAvailable(spell)
	and UnitCanAttack("player", unit) == 1 
	and not UnitIsDeadOrGhost(unit) 
	and not PQR_IsOutOfSight(unit, 1)
	and IsSpellInRange(GetSpellInfo(spell), unit) == 1 then
		return true
	else
		return false
	end
end

TargetValidationMelee = nil
function TargetValidationMelee(unit, spell)
	if UnitExists(unit)
	and PQR_SpellAvailable(spell)
	and UnitCanAttack("player", unit) == 1 
	and not UnitIsDeadOrGhost(unit) 
	and not PQR_IsOutOfSight(unit, 1)
	and IsSpellInRange(GetSpellInfo(PQ_PlagueStrike), unit) == 1 then
		return true
	else
		return false
	end
end

GlyphCheck = nil
function GlyphCheck(glyphid)
	for i=1, 6 do
		if select(4, GetGlyphSocketInfo(i)) == glyphid then
			return true
		end
	end
	return false
end

CastSpell = nil
function CastSpell(id, t)
	CastSpellByName(id, t)
	PQ_ShouldWait = true
	PQ_WaitCD = GetTime() + 0.05
end

PQ_FaceRange = math.rad(45) -- 45 degree facing limit
CheckFacing = nil
function CheckFacing(t)
	t = t or "target"
	
	if not UnitExists(t) then return false end
	
	local rad, lower, upper = nil, nil, nil
	local x1, y1 = GetPlayerMapPosition("player")
	local x2, y2 = GetPlayerMapPosition(t)
	local face = GetPlayerFacing()
	
	local x = x2 - x1
	local y = y2 - y1
	
	if (x == 0 and y == 0) then return true end -- we are directly inside the target ... return true
	
	if (x == 0) then
		if (y > 0) then
			rad = 0
		elseif (y < 0) then
			rad = math.pi
		end
	elseif (y < 0) then
		rad = math.pi - math.atan(x/y)
	elseif (x > 0) then
		rad = 2*math.pi - math.atan(x/y)
	else
		rad = math.atan(x/y) * -1
	end
	
	lower = (rad - PQ_FaceRange) % (2*math.pi)
	upper = (rad + PQ_FaceRange) % (2*math.pi)
	
	if (lower < upper) then
	  return (face < upper and face > lower)
	else
	  return (face > lower) or (face < upper)
	end
end

PQ_BossUnits = {
	-- Cataclysm Dungeons --
	-- Abyssal Maw: Throne of the Tides
	40586,		-- Lady Naz'jar
	40765,		-- Commander Ulthok
	40825,		-- Erunak Stonespeaker
	40788,		-- Mindbender Ghur'sha
	42172,		-- Ozumat
	-- Blackrock Caverns
	39665,		-- Rom'ogg Bonecrusher
	39679,		-- Corla, Herald of Twilight
	39698,		-- Karsh Steelbender
	39700,		-- Beauty
	39705,		-- Ascendant Lord Obsidius
	-- The Stonecore
	43438,		-- Corborus
	43214,		-- Slabhide
	42188,		-- Ozruk
	42333,		-- High Priestess Azil
	-- The Vortex Pinnacle
	43878,		-- Grand Vizier Ertan
	43873,		-- Altairus
	43875,		-- Asaad
	-- Grim Batol
	39625,		-- General Umbriss
	40177,		-- Forgemaster Throngus
	40319,		-- Drahga Shadowburner
	40484,		-- Erudax
	-- Halls of Origination
	39425,		-- Temple Guardian Anhuur
	39428,		-- Earthrager Ptah
	39788,		-- Anraphet
	39587,		-- Isiset
	39731,		-- Ammunae
	39732,		-- Setesh
	39378,		-- Rajh
	-- Lost City of the Tol'vir
	44577,		-- General Husam
	43612,		-- High Prophet Barim
	43614,		-- Lockmaw
	49045,		-- Augh
	44819,		-- Siamat
	-- Zul'Aman
	23574,		-- Akil'zon
	23576,		-- Nalorakk
	23578,		-- Jan'alai
	23577,		-- Halazzi
	24239,		-- Hex Lord Malacrass
	23863,		-- Daakara
	-- Zul'Gurub
	52155,		-- High Priest Venoxis
	52151,		-- Bloodlord Mandokir
	52271,		-- Edge of Madness
	52059,		-- High Priestess Kilnara
	52053,		-- Zanzil
	52148,		-- Jin'do the Godbreaker
	-- End Time
	54431,		-- Echo of Baine
	54445,		-- Echo of Jaina
	54123,		-- Echo of Sylvanas
	54544,		-- Echo of Tyrande
	54432,		-- Murozond
	-- Hour of Twilight
	54590,		-- Arcurion
	54968,		-- Asira Dawnslayer
	54938,		-- Archbishop Benedictus
	-- Well of Eternity
	55085,		-- Peroth'arn
	54853,		-- Queen Azshara
	54969,		-- Mannoroth
	55419,		-- Captain Varo'then
	
	-- Mists of Pandaria Dungeons --
	-- Scarlet Halls
	59303,		-- Houndmaster Braun
	58632,		-- Armsmaster Harlan
	59150,		-- Flameweaver Koegler
	-- Scarlet Monastery
	59789,		-- Thalnos the Soulrender
	59223,		-- Brother Korloff
	3977,		-- High Inquisitor Whitemane
	60040,		-- Commander Durand
	-- Scholomance
	58633,		-- Instructor Chillheart
	59184,		-- Jandice Barov
	59153,		-- Rattlegore
	58722,		-- Lilian Voss
	58791,		-- Lilian's Soul
	59080,		-- Darkmaster Gandling
	-- Stormstout Brewery
	56637,		-- Ook-Ook
	56717,		-- Hoptallus
	59479,		-- Yan-Zhu the Uncasked
	-- Tempe of the Jade Serpent
	56448,		-- Wise Mari
	56843,		-- Lorewalker Stonestep
	59051,		-- Strife
	59726,		-- Peril
	58826,		-- Zao Sunseeker
	56732,		-- Liu Flameheart
	56762,		-- Yu'lon
	56439,		-- Sha of Doubt
	-- Mogu'shan Palace
	61444,		-- Ming the Cunning
	61442,		-- Kuai the Brute
	61445,		-- Haiyan the Unstoppable
	61243,		-- Gekkan
	61398,		-- Xin the Weaponmaster
	-- Shado-Pan Monastery
	56747,		-- Gu Cloudstrike
	56541,		-- Master Snowdrift
	56719,		-- Sha of Violence
	56884,		-- Taran Zhu
	-- Gate of the Setting Sun
	56906,		-- Saboteur Kip'tilak
	56589,		-- Striker Ga'dok
	56636,		-- Commander Ri'mok
	56877,		-- Raigonn
	-- Siege of Niuzao Temple
	61567,		-- Vizier Jin'bak
	61634,		-- Commander Vo'jak
	61485,		-- General Pa'valak
	62205,		-- Wing Leader Ner'onok

	-- Training Dummies --
	46647,		-- Level 85 Training Dummy
	67127		-- Level 90 Training Dummy
}

	----------------
	-- Player has Buff --
	----------------	
	PlayerHasBuff = nil
	function PlayerHasBuff(spellid)
		local check
		check = UnitBuffID("player", spellid)
		if check == nil then return false end
		return true
	end
	----------------
	-- Player has Debuff --
	----------------	
	PlayerHasDebuff = nil
	function PlayerHasDebuff(spellid)
		local check
		check = UnitDebuffID("player", spellid)
		if check == nil then return false end
		return true
	end	
	
	TargetHasBuff = nil
	function TargetHasBuff(spellid)
	local check
		check = UnitBuffID("target", spellid)
		if check == nil then return false end
		return true
	end	
	TargetHasDebuff = nil
	function TargetHasDebuff(spellid)
		local check
		check = UnitDebuffID("target", spellid, "player")
		if check == nil then return false end
		return true
	end	

	----------------
	-- BOSS CHECK --
	----------------
	BossCheck = nil
	function BossCheck()
		if UseCDBoss == false
		and UseCD == false
			then return true
		end
		
		if UseCDBoss == true
		and UseCD == false
		and SpecialUnit()
			then return true	
		end
		return false
	end
	
	----------------
	-- SPEC CHECK --
	----------------
	SpecCheck = nil
	function SpecCheck()
		if GetSpecialization() == 1 then
			Spec = "Blood"
		elseif GetSpecialization() == 2 then
			Spec = "Frost"
		elseif GetSpecialization() == 3 then
			Spec = "Unholy"
		end
	end
	
	
SpecialUnit = nil
function SpecialUnit()
	local PQ_BossUnits = PQ_BossUnits
	
	if UnitExists("target") then
		local npcID = tonumber(UnitGUID("target"):sub(6,10), 16)
		
		if UnitLevel("target") == -1 then return true else
			for i=1,#PQ_BossUnits do
				if PQ_BossUnits[i] == npcID then return true end
			end
			return false
		end
	else return false end
end

buffs = { 19506, 57330,	6673 }

PQ_SelfBuff = nil
function PQ_SelfBuff()
	for x = 1,#buffs do
		local name, _, texture = UnitBuff("Player", (GetSpellInfo(buffs[x])))
		if texture then
			return name, _, texture
		end
	end
	return nil, nil, nil
end

-- Spells
PQ_Pillar = 51271
PQ_RaiseAlly = 61999
PQ_RaiseDead = 46584
PQ_Empower = 47568
PQ_Horn = 57330
PQ_DnD = 43265
PQ_Howling = 49184
PQ_FrostStrike = 49143
PQ_HowlingBlast = 49184
PQ_PlagueStrike = 45462
PQ_Outbreak = 77575
PQ_BloodTap = 45529
PQ_Obliterate = 49020
PQ_PlagueLeech = 123693
PQ_SoulReaper = 130735
PQ_Pestilence = 50842
PQ_DeathPact = 48743
PQ_DeathSiphon = 108196
PQ_AMS = 48707
PQ_AMZ = 51052
PQ_MindFreeze = 47528
PQ_DeathsAdvance = 96268
PQ_DeathGrip = 49576
PQ_IceboundFortitude = 48792
PQ_DeathStrike = 49998
PQ_IcyTouch = 45477
PQ_UnholyBlight = 115989
PQ_RunicEmpowerment = 81229
PQ_RunicCorruption = 51462
PQ_Asphyxiate = 108194

-- Buffs
PQ_Conversion = 119975
PQ_Rime = 59052
PQ_KillingMachine = 51124
PQ_BloodCharge = 114851
PQ_RunicCorruptionBuff = 51460
PQ_DarkSuccor = 101568


-- Debuffs
PQ_FrostFever = 55095
PQ_BloodPlague = 55078

-- Switch
CD_BossOnly = 1
CD_Auto = 2

PQ_ShouldPestilence = false
PQ_PestilenceCD = 0
PQ_CD = CD_BossOnly
PQ_CDTimer = 0
PQ_HB = true
PQ_HBTimer = 0
PQ_AOE = false
PQ_AOETimer = 0
PQ_DND = true
PQ_DNDTimer = 0

-- CDs
PQ_SoulReaperCD = 0
PQ_GCD = 0
PQ_BTCD = 0
PQ_WaitCD = 0
PQ_OutbreakCD = 0
PQ_ImpalingSpearCD = 0
PQ_MindFreezeCD = 0

-- Items
PQ_HealthStoneItem = 5512
PQ_HealthStoneSpell = 6262
PQ_PotionOfMoguPowerSpell = 105706

-- Boss Casts
PQ_ImpalingSpear = 122224

-- Racials
PQ_GiftOfTheNaaru = 59545 -- Draenei (heal) working
PQ_EveryManForHimself = 59752 -- Human used
PQ_BloodFury = 20572 -- Orc (dmg) used
PQ_Berserking = 26297 -- Troll (dmg/HC like) unused
PQ_WillOfTheForsaken = 7744 -- Undead unused
PQ_RocketBarrage = 69041 -- Goblin (dmg, triggers GCD) unused

-- Professions
PQ_Lifeblood = 121279 -- Herbalism
PQ_SynapseSprings = 126734 -- Engineering

PQ_HasEngineering = false
PQ_Has2MinCD = false

PQ_2MinCDList = {
	PQ_BloodFury,
	PQ_Lifeblood
}

-- Combatlog Events
PQ_Frame = nil
PQ_CanCast = true
PQ_CanBT = true
PQ_ShouldWait = false
PQ_CanImpalingSpear = true
PQ_CanMindFreeze = true
function PQ_Frame_OnEvent(self, event, ...)
	if ... ~= "player" then return end
	
	local spellID = select(5, ...)
	
	if  spellID ~= PQ_BloodTap
	and spellID ~= PQ_Pillar
	and spellID ~= PQ_Empower
	and spellID ~= PQ_AMS
	and spellID ~= PQ_AMZ
	and spellID ~= PQ_MindFreeze
	and spellID ~= PQ_DeathPact
	and spellID ~= PQ_DeathsAdvance
	and spellID ~= PQ_DeathGrip
	and spellID ~= PQ_HealthStoneSpell
	and spellID ~= PQ_IceboundFortitude
	and spellID ~= PQ_PotionOfMoguPowerSpell
	and spellID ~= PQ_ImpalingSpear
	and spellID ~= PQ_GiftOfTheNaaru
	and spellID ~= PQ_EveryManForHimself
	and spellID ~= PQ_BloodFury
	and spellID ~= PQ_Berserking
	and spellID ~= PQ_WillOfTheForsaken
	and spellID ~= PQ_Lifeblood
	and spellID ~= PQ_SynapseSprings
	and spellID ~= PQ_UnholyBlight then
		PQ_GCD = GetTime() + 0.7
		PQ_CanCast = false
	end
			
	if spellID == PQ_Outbreak then
		PQ_OutbreakCD = GetTime() + 60
	elseif spellID == PQ_Pestilence then
		PQ_ShouldPestilence = false
		PQ_PestilenceCD = GetTime() + 28
	elseif spellID == PQ_SoulReaper then
		PQ_SoulReaperCD = GetTime() + 6
	elseif spellID == PQ_ImpalingSpear then
		PQ_ImpalingSpearCD = GetTime() + 5
		PQ_CanImpalingSpear = false
	elseif spellID == PQ_SynapseSprings then
		PQ_HasEngineering = true
	elseif spellID == PQ_MindFreeze then
		PQ_MindFreezeCD = GetTime() + 15
		PQ_CanMindFreeze = false
	end
end