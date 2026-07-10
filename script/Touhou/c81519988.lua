--Chen of Velvet Boundaries
local s,id=GetID()
function s.initial_effect(c)
	--Can be treated as a non-Tuner for a Synchro Summon
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_NONTUNER)
	e0:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e0)	
	--Special Summon this card, but banish it when it leaves the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.selfspcon)
	e1:SetTarget(s.selfsptg)
	e1:SetOperation(s.selfspop)
	c:RegisterEffect(e1)
	--Special Summon 1 "Ran of Velvet Boundaries" from your hand, Deck, GY, or banishment.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)	
end

s.listed_names={id,81519982,81519987}
s.listed_series={0x1fa}

function s.selfspcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,{81519982,81519987}),tp,LOCATION_MZONE,0,1,nil)
end

function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end

function s.selfspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		--Banish it when it leaves the field
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(1307)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_DECK)
		e1:SetReset(RESET_EVENT|RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
	end
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.IsTurnPlayer(tp) and Duel.IsMainPhase()) or Duel.IsTurnPlayer(1-tp)
end

function s.spfilter(c,e,tp)
	return (c:IsCode(81519982) or (c:IsLevelBelow(8) and c:ListsCode(81519982) and not c:IsCode(id))) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove() and Duel.GetMZoneCount(tp,c)>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and aux.RemoveUntil(c,nil,REASON_EFFECT,PHASE_END,id,e,tp,aux.DefaultFieldReturnOp)
		and Duel.GetLocationCount(tp,LOCATION_MZONE) 
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp) 
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,e,tp)
		if #g==0 then return end
		Duel.BreakEffect()
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

