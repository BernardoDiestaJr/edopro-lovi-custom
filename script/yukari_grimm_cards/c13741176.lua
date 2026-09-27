--Wonderland
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x118a)
	--Add 1 "Crawling Chaos" card or 1 "Malevolent" card from your Deck to your hand, then immediately after this effect resolves, you can Normal Summon 1 Warrior monster with 2300 ATK
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SUMMON)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,id)
	e0:SetTarget(s.thtg)
	e0:SetOperation(s.thop)
	c:RegisterEffect(e0)
	--Cannot be targeted
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_SINGLE)
	e1a:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1a:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1a:SetRange(LOCATION_FZONE)
	e1a:SetCondition(function(e) return Duel.IsExistingMatchingCard(s.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil) end)
	e1a:SetValue(aux.tgoval)
	c:RegisterEffect(e1a)
	--Prevent destruction by effects
	local e1b=e1a:Clone()
	e1b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1b:SetValue(aux.indoval)
	c:RegisterEffect(e1b)	
	--Place 1 Black Soul Counter on this card
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,2))
	e2a:SetCategory(CATEGORY_COUNTER)
	e2a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2a:SetProperty(EFFECT_FLAG_DELAY)
	e2a:SetCode(EVENT_CHAINING)
	e2a:SetRange(LOCATION_FZONE)
	e2a:SetCondition(s.ctcon)
	e2a:SetTarget(s.cttg)
	e2a:SetOperation(s.ctop)
	c:RegisterEffect(e2a)
	--● 8+: WIND "Crawling Chaos" Synchro Monsters you control can attack directly
	local e3a=Effect.CreateEffect(c)
	e3a:SetType(EFFECT_TYPE_FIELD)
	e3a:SetCode(EFFECT_DIRECT_ATTACK)
	e3a:SetRange(LOCATION_FZONE)
	e3a:SetTargetRange(LOCATION_MZONE,0)
	e3a:SetCondition(function(e) return e:GetHandler():GetCounter(0x118a)>=8 end)
	e3a:SetTarget(function(e,c) return c:IsAttribute(ATTRIBUTE_WIND) and c:IsSetCard(0x41f) and c:IsType(TYPE_SYNCHRO) end)
	c:RegisterEffect(e3a)
	--● 16+: The original ATK and DEF of all non-FIRE monsters your opponent controls are switched
	local e3b=Effect.CreateEffect(c)
	e3b:SetType(EFFECT_TYPE_FIELD)
	e3b:SetCode(EFFECT_SWAP_BASE_AD)
	e3b:SetRange(LOCATION_FZONE)
	e3b:SetTargetRange(0,LOCATION_MZONE)
	e3b:SetCondition(function(e) return e:GetHandler():GetCounter(0x118a)>=16 end)
	e3b:SetTarget(function(e,c) return not c:IsAttribute(ATTRIBUTE_FIRE) and c:IsType(TYPE_MONSTER) end)
	c:RegisterEffect(e3b)
	--● 24+: During the turn they were Special Summoned, your opponent cannot target DARK "Crawling Chaos" Synchro Monsters you control with card effects
	local e3c=Effect.CreateEffect(c)
	e3c:SetType(EFFECT_TYPE_FIELD)
	e3c:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3c:SetRange(LOCATION_FZONE)
	e3c:SetTargetRange(LOCATION_MZONE,0)
	e3c:SetCondition(function(e) return e:GetHandler():GetCounter(0x118a)>=24 end)
	e3c:SetTarget(function(e,c) return c:IsAttribute(ATTRIBUTE_DARK) and c:IsSetCard(0x41f) and c:IsType(TYPE_SYNCHRO) and c:IsStatus(STATUS_SPSUMMON_TURN) end)
	c:RegisterEffect(e3c)

end

s.counter_place_list={0x118a}
s.listed_series={0x41f,0x422}
s.listed_names={id}

function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x41f) and c:IsType(TYPE_SYNCHRO)
end

function s.thfilter(c)
	return c:IsAbleToHand() and ((c:IsSetCard(0x41f)) or c:IsSetCard(0x422))
end

function s.nsfilter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAttackBelow(2300) and c:IsSummonable(true,nil)
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
		local nsc=Duel.SelectMatchingCard(tp,s.nsfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil):GetFirst()
		if nsc then
			Duel.Summon(tp,nsc,true,nil)
		end
	end
end

function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	local code1,code2=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CODE,CHAININFO_TRIGGERING_CODE2)
	return code1~=id and code2~=id
end

function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanAddCounter(0x118a,1) end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,tp,0x118a)
end

function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:AddCounter(0x118a,1)
	end
end

