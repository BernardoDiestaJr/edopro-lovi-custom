--Crawling Chaos Jubjub
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x118a,0x118b)
	c:EnableReviveLimit()
	--Synchro Summon procedure
	Synchro.AddProcedure(c,aux.FilterBoolFunction(Card.IsLevel,4),1,1,Synchro.NonTunerEx(Card.IsRace,RACE_WARRIOR),1,99)	
	--Each time your opponent activates a monster effect, place 1 Black Feather Counter on this card when that effect resolves, and if you do, inflict 700 damage to your opponent
	local e0a=Effect.CreateEffect(c)
	e0a:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0a:SetCode(EVENT_CHAINING)
	e0a:SetRange(LOCATION_MZONE)
	e0a:SetOperation(aux.chainreg)
	c:RegisterEffect(e0a)
	local e0b=Effect.CreateEffect(c)
	e0b:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0b:SetCode(EVENT_CHAIN_SOLVED)
	e0b:SetRange(LOCATION_MZONE)
	e0b:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return ep==1-tp and re:IsMonsterEffect() and (re:GetActivateLocation()==LOCATION_MZONE or re:GetActivateLocation()==LOCATION_HAND) and e:GetHandler():HasFlagEffect(1) end)
	e0b:SetOperation(s.desop)
	c:RegisterEffect(e0b)	
	--Place Madness counters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCost(s.ctcost)
	e1:SetTarget(s.cttg)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)	
	--disable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.discon)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)	
	--If this Synchro Summoned card is sent to the GY: You can banish this card from your GY, then target 1 Level 4 Tuner monster from your GY; add it to your hand or Special Summon it, then immediately after this effect resolves, you can Synchro Summon 1 Synchro Monster
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(function(e) local c=e:GetHandler() return c:IsSynchroSummoned() and c:IsPreviousLocation(LOCATION_MZONE) end)
	e3:SetCost(Cost.SelfBanish)
	e3:SetTarget(s.thsptg)
	e3:SetOperation(s.thspop)
	c:RegisterEffect(e3)	
end

s.counter_place_list={0x118a,0x118b}
s.listed_series={}
s.listed_names={id}

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:AddCounter(0x118a,1) then
		local g=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local dg=g:Select(tp,1,1,nil)
			if #dg==0 then return end
			Duel.HintSelection(dg)
			Duel.BreakEffect()
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end

function s.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x118a,10,REASON_COST) end
	Duel.RemoveCounter(tp,1,0,0x118a,10,REASON_COST)
end

function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,e:GetHandler()) end
end

function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,e:GetHandler())
	for tc in g:Iter() do
		tc:AddCounter(0x118b,1)
	end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,2)
end

function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	return rp==1-tp and re:IsMonsterEffect() and re:GetHandler():GetCounter(0x118b)>0
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end

function s.thspfilter(c,e,tp,mmz_chk)
	return c:IsType(TYPE_TUNER) and c:IsLevel(4) and c:IsFaceup()
		and (c:IsAbleToHand() or (mmz_chk and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end

function s.thsptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local mmz_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thspfilter(chkc,e,tp,mmz_chk) end
	if chk==0 then return Duel.IsExistingTarget(s.thspfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,mmz_chk) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
	local g=Duel.SelectTarget(tp,s.thspfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,mmz_chk)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
	if g:GetFirst():IsLocation(LOCATION_GRAVE) then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,tp,0)
	end
end

function s.thspop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or not aux.ToHandOrElse(tc,tp,
		function() return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) end,
		function() return Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 end,
		aux.Stringid(id,4)
	) then return end
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		Duel.SynchroSummon(tp,sg:GetFirst())
	end
end