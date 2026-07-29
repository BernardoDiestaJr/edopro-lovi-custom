--Yang Zing Realized
local s,id=GetID()
function s.initial_effect(c)
	--Add 2 "Yang Zing" monsters with different attributes from your Deck to your hand, then place 1 card from your hand on the bottom of the Deck
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TODECK)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e0:SetCost(s.cost)
	e0:SetTarget(s.target)
	e0:SetOperation(s.activate)
	c:RegisterEffect(e0)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
	--If a "Yang Zing" monster(s) you control would be destroyed by battle or card effect, you can banish this card from your GY instead
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetTarget(s.reptg)
	e1:SetValue(function(e,c) return s.repfilter(c,e:GetHandlerPlayer()) end)
	e1:SetOperation(function(e) Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT|REASON_REPLACE) end)
	c:RegisterEffect(e1)	
end

s.listed_series={SET_YANG_ZING}
s.listed_names={id}

function s.counterfilter(c)
	return c:GetSummonLocation()~=LOCATION_EXTRA or c:IsType(TYPE_SYNCHRO)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--Lizard check
	aux.addTempLizardCheck(e:GetHandler(),tp,s.lizfilter)
end

function s.lizfilter(e,c)
	return not c:IsOriginalType(TYPE_SYNCHRO)
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end

function s.thfilter(c)
	return c:IsSetCard(SET_YANG_ZING) and c:IsMonster() and c:IsAbleToHand()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
		return g:GetClassCount(Card.GetAttribute)>=2
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetAttribute)>=2 then
		local sg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dpcheck(Card.GetAttribute),1,tp,HINTMSG_ATOHAND)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local td=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
		if #td>0 then
			Duel.DisableShuffleCheck()
			Duel.BreakEffect()
			Duel.SendtoDeck(td,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end

function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(SET_YANG_ZING)
		and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_BATTLE|REASON_EFFECT)
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,c,96)
end	