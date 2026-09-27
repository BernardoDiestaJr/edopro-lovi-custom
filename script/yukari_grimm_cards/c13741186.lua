--Node the Pale Librarian
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Add from your Deck to your hand, 1 "Grimm the Tragic Knight", or 1 monster that mentions it, except "Node the Pale Librarian"
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e0:SetType(EFFECT_TYPE_IGNITION)
	e0:SetRange(LOCATION_HAND)
	e0:SetCountLimit(1,{id,0})
	e0:SetCost(s.thcost1)
	e0:SetTarget(s.thtg1)
	e0:SetOperation(s.thop1)
	c:RegisterEffect(e0)	
	--Add 1 DARK Beast Tuner and/or 1 "Wonderland" 
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,1))
	e1a:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1a:SetProperty(EFFECT_FLAG_DELAY)
	e1a:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1a:SetCountLimit(1,{id,1})
	e1a:SetCondition(function(e) return e:GetHandler():IsRitualSummoned() end)
	e1a:SetTarget(s.thtg2)
	e1a:SetOperation(s.thop2)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EVENT_REMOVE)
	e1b:SetCondition(function(e) return Duel.GetCurrentPhase()~=PHASE_DAMAGE and e:GetHandler():IsReason(REASON_EFFECT) end)
	c:RegisterEffect(e1b)

end

s.counter_place_list={}
s.listed_series={}
s.listed_names={id,13741143,13741176}

function s.thcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsPublic() and c:GetFlagEffect(id)==0 and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST|REASON_DISCARD,e:GetHandler())
end

function s.thfilter1(c)
	return (c:IsCode(13741143) or (c:IsMonster() and c:ListsCode(13741143)))
		and c:IsAbleToHand() and not c:IsCode(id)
end

function s.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.DarkBeastTuner(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_BEAST) and c:IsType(TYPE_TUNER)
end

function s.thfilter2(c)
	return c:IsAbleToHand() and (s.DarkBeastTuner(c) or c:IsCode(13741176))
end

function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsCode,nil,13741176)<=1
		and sg:FilterCount(s.DarkBeastTuner,nil)<=1
end

function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter2,tp,LOCATION_DECK,0,nil)
	if #g>0 then
		local tg=aux.SelectUnselectGroup(g,e,tp,1,2,s.rescon,1,tp,HINTMSG_ATOHAND)
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tg)
	end
end