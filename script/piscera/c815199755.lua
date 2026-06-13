--Piscera Downfall
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetCondition(s.effcon)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
	
end

s.listed_names={id}
s.listed_series={0x1fe}

function s.effconfilter(c)
	return ((c:IsAttribute(ATTRIBUTE_EARTH)) or c:IsSetCard(0x1fe))
end

function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	return #g==0 or g:FilterCount(s.effconfilter,nil)==#g
end

function s.thfilter1(c)
	return c:IsSetCard(0x1fe) and c:IsMonster() and c:IsAbleToHand()
end

function s.thfilter2(c)
	return c:IsSetCard(0x1fe) and c:IsSpellTrap() and c:IsAbleToHand() and not c:IsCode(id)
end

function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=not Duel.HasFlagEffect(tp,id)
		and Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
	local b2=not Duel.HasFlagEffect(tp,id+1)
		and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==1 then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
		Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,2,PLAYER_ALL,LOCATION_ONFIELD)
	elseif op==2 then
		Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
		Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	end
end

function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Take 1860 damage
		if breakeffect then Duel.BreakEffect() end
		Duel.Damage(tp,1860,REASON_EFFECT)
		--Add 1 "Piscera" monster from your Deck or GY to your hand, then you can destroy 2 cards (1 on each field)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter1),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
		if #g==0 or Duel.SendtoHand(g,nil,REASON_EFFECT)==0 or not g:GetFirst():IsLocation(LOCATION_HAND) then return end
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		local g1=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,0)
		local g2=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
		if #g1==0 or #g2==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end
		local sg=aux.SelectUnselectGroup(g1+g2,e,tp,2,2,aux.dpcheck(Card.GetControler),1,tp,HINTMSG_DESTROY)
		if #sg==2 then
			Duel.HintSelection(sg)
			Duel.BreakEffect()
			Duel.Destroy(sg,REASON_EFFECT)
		end
	elseif op==2 then
		--Take 1860 damage
		if breakeffect then Duel.BreakEffect() end
		Duel.Damage(tp,1860,REASON_EFFECT)
		--Add 1 "Piscera" Spell/Trap from your Deck to your hand, except "Piscera Downfall", then discard 1 card
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
		if #g==0 or Duel.SendtoHand(g,nil,REASON_EFFECT)==0 then return end
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 then
			Duel.BreakEffect()
			Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT|REASON_DISCARD)
		end
	end
end