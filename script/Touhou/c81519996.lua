--Fantasia Maiden of Onmyō
local s,id=GetID()
function s.initial_effect(c)
	--You can Tribute this card from your hand or field; Ritual Summon 1 Spirit Ritual Monster from your hand or GY by Tributing Rock, Illusion and/or Spirit monsters from your hand or field whose total Levels equal or exceed the Level of the Ritual Monster
	local e1=Ritual.AddProcGreater({handler=c,filter=s.ritualfilter,matfilter=s.ritmatfilter,location=LOCATION_HAND|LOCATION_GRAVE},aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND|LOCATION_MZONE)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(Cost.SelfTribute)
	e1:SetCondition(function() return Duel.IsMainPhase() end)
	c:RegisterEffect(e1)	
	--Add 1 Level 9 or lower "Onmyō" monster or 1 "Onmyō" Spell from your Deck to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.nstg)
	e2:SetOperation(s.nsop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end

s.listed_names={id}
s.listed_series={0x1fa}


function s.ritualfilter(c)
	return c:IsType(TYPE_SPIRIT) and c:IsRitualMonster()
end

function s.ritmatfilter(c)
	return (c:IsType(TYPE_SPIRIT) or c:IsRace(RACE_ROCK) or c:IsRace(RACE_ILLUSION))
end

function s.nsfilter(c)
	return (c:IsLevelBelow(9) and c:IsSetCard(0x1fa) and not c:IsCode(id) or c:IsSpell() and c:IsSetCard(0x1fa)) and c:IsAbleToHand()
end

function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.nsfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.sumfilter(c)
	return c:IsType(TYPE_SPIRIT) and c:IsSummonable(true,nil)
end

function s.nsop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.nsfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		if not g:GetFirst():IsLocation(LOCATION_HAND) then return end
		local sg1=Duel.GetMatchingGroup(s.sumfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,nil)
		if #sg1>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Duel.ShuffleHand(tp)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
			local sg2=sg1:Select(tp,1,1,nil):GetFirst()
			Duel.Summon(tp,sg2,true,nil)
		end
	end
end
