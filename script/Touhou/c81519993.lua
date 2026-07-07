--Onmyō Dragite Stiacciato
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Add 1 "Onmyō" non-Normal Spell and/or 1 Level 6 or lower Spirit monster from your Deck and/or GY to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)	
end

s.listed_names={id,81519991}
s.listed_series={0x1f8,0x1fa}

function s.confilter(c)
	return (c:IsRace(RACE_ILLUSION) or c:IsRace(RACE_ROCK))
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	return #g==0 or g:FilterCount(s.confilter,nil)==#g
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,81519991,0,TYPES_TOKEN,900,600,6,RACE_ROCK,ATTRIBUTE_EARTH) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,81519991,0,TYPES_TOKEN,900,600,6,RACE_ROCK,ATTRIBUTE_EARTH) then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local sg=Group.CreateGroup()
	for i=1,ft do
		local token=Duel.CreateToken(tp,81519991)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		sg:AddCard(token)
	end
	--Destroy them during the End Phase of this turn
	aux.DelayedOperation(sg,PHASE_END,id,e,tp,function(ag) Duel.Destroy(ag,REASON_EFFECT) end,nil,nil,1,aux.Stringid(id,1))
	Duel.SpecialSummonComplete()
	--You cannot Special Summon for the rest of this turn, except Link and Ritual monsters
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsLinkMonster() and not c:IsType(TYPE_RITUAL) and not c:IsOriginalType(TYPE_RITUAL) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function s.thfilter(c)
	return c:IsSetCard(0x1fa) and not c:IsNormalSpell() or c:IsLevelBelow(6) and c:IsType(TYPE_SPIRIT) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end

function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsSetCard,nil,0x1fa) and sg:FilterCount(Card.IsNormalSpell,nil)<=1 and sg:FilterCount(Card.IsType,nil,TYPE_SPIRIT) and sg:FilterCount(Card.IsLevelBelow,nil,6)<=1
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,nil)
	if #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,2,s.rescon,1,tp,HINTMSG_ATOHAND)
		if #sg>0 and Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 then
			Duel.ConfirmCards(1-tp,sg)
			Duel.ShuffleHand(tp)
			Duel.ShuffleDeck(tp)			
			if Duel.GetMatchingGroupCount(nil,tp,0,LOCATION_MZONE,nil)>0 then
			local ssg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
			if #ssg==0 then return end
			Duel.ConfirmCards(tp,ssg)
			Duel.ShuffleHand(1-tp)		
			end
		end
	end
end

