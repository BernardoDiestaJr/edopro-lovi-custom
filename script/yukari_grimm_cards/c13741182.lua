--@B$0LVT3 0B$3$$10N
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x118a)
	--Activate 1 of these effects
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e0:SetCost(s.effcost)
	e0:SetTarget(s.efftg)
	e0:SetOperation(s.effop)
	e0:SetHintTiming(TIMING_END_PHASE,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e0)
end

s.counter_place_list={0x118a}
s.listed_series={0x41f,0x422}
s.listed_names={id,13741143}

function s.descostfilter(c)
	return c:ListsCode(13741143) and c:IsAbleToGraveAsCost()
end

function s.thfilter(c)
	return ((c:IsSetCard(0x41f)) or c:IsSetCard(0x422) and c:IsRace(RACE_FAIRY) and c:IsMonster()) and c:IsFaceup() and c:IsAbleToHand() and not c:IsCode(id)
end

function s.disfilter(c)
	return c:IsType(TYPE_EFFECT) and c:IsFaceup() and (c:IsNegatableMonster() or not c:IsCode(13741143))
end

function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	--● Add 1"Crawling Chaos" card or 1 Fairy "Malevolent" monster  from your GY or banishment to your hand
	local b1=Duel.IsExistingMatchingCard(s.descostfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,nil)
		and Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil)
	--● Negate the effects of an opponent's Effect Monster
	local b2=Duel.IsExistingTarget(s.disfilter,tp,0,LOCATION_MZONE,1,nil)
	if chk==0 then return b1 or b2 end
	local cd=e:GetChainData()
	cd.choice=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	if cd.choice==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.descostfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,1,nil)
		Duel.SendtoGrave(g,REASON_COST)
	elseif cd.choice==2 then
		Duel.RemoveCounter(tp,1,0,0x118a,5,REASON_COST)
	end
end

function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		local cd=e:GetChainData()
		if cd.choice==1 then
			return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and s.thfilter(chkc)
		elseif cd.choice==2 then
			return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.disfilter(chkc)
		end
	end
	--● Add 1"Crawling Chaos" card or 1 Fairy "Malevolent" monster  from your GY or banishment to your hand
	local b1=Duel.IsExistingMatchingCard(s.descostfilter,tp,LOCATION_DECK,0,1,nil)
		and Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil)
	--● Negate the effects of an opponent's Effect Monster
	local b2=Duel.IsExistingTarget(s.disfilter,tp,0,LOCATION_MZONE,1,nil)
	if chk==0 then return b1 or b2 end
	local cd=e:GetChainData()
	cd.choice=cd.choice
		or Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,1)},
			{b2,aux.Stringid(id,2)})
	if cd.choice==1 then
		e:SetCategory(CATEGORY_TOHAND)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
	elseif cd.choice==2 then
		e:SetCategory(CATEGORY_DISABLE)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
		local g=Duel.SelectTarget(tp,s.disfilter,tp,0,LOCATION_MZONE,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,tp,0)
	end
end

function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local cd=e:GetChainData()
	if cd.choice==1 then
		--● Add 1"Crawling Chaos" card or 1 Fairy "Malevolent" monster  from your GY or banishment to your hand
		Duel.SendtoHand(tc,tp,REASON_EFFECT)
	elseif cd.choice==2 then
		--● Negate the effects of an opponent's Effect Monster
		--Negate its effects
		tc:NegateEffects(c)
		--Its name becomes "Fairy Prince"
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(13741143)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_RACE)
		e2:SetValue(RACE_WARRIOR)
		tc:RegisterEffect(e2)			
	end
end
