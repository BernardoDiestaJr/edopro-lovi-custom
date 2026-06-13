--Superancient Deepsea King Megatrizeus
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz summon procedure
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_EARTH),5,2)
	--Destroy 1 other EARTH monster in your hand or face-up field and search 1 "Paleozoic", "Umbriazic" or "Piscera" card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--increase ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.umicon)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	--Special Summon 1 "Umbriazic" monster, Set 1 "Piscera" monster, or Set 1 "Paleozoic" Trap.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	e3:SetCost(Cost.DetachFromSelf(2,2,nil))
	e3:SetTarget(s.spsettarget)
	e3:SetOperation(s.spsetop)
	c:RegisterEffect(e3)

end

s.listed_names={id,CARD_UMI}
s.listed_series={0x1fe,0x2f0,SET_PALEOZOIC}

function s.desfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end

function s.thfilter(c)
	return (c:IsSetCard(SET_PALEOZOIC) or c:IsSetCard(0x2f0) or c:IsSetCard(0x1fe)) and c:IsAbleToHand()
end

function s.filter(c)
	return not c:IsPublic() or c:IsMonster()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,c)
			and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
	local dg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,c)
	if not Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,tp,LOCATION_HAND|LOCATION_MZONE)
	else
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND|LOCATION_MZONE)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local exc=c:IsRelateToEffect(e) and c or nil
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local desg=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,exc)
	if #desg==0 or Duel.Destroy(desg,REASON_EFFECT)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if not sc or Duel.SendtoHand(sc,nil,REASON_EFFECT)==0 then return end
	Duel.ConfirmCards(1-tp,sc)
	Duel.ShuffleHand(tp)
end

function s.umicon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_UMI),0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		or Duel.IsEnvironment(CARD_UMI)
end

function s.atkval(e,c)
	return c:GetRank()*400
end

function s.spsetfilter(c,e,tp,ft)
	return (ft>0 and c:IsSetCard(SET_LABRYNTH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
		or (c:IsNormalTrap() and c:IsSSetable())
end

function s.spsetfilter(c,e,tp,ft)
	return (ft>0 and c:IsSetCard(0x2f0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
		or (c:IsSetCard(0x1fe) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE))
		or (c:IsSetCard(SET_PALEOZOIC) and c:IsTrap() and c:IsSSetable())
end

function s.spsettarget(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ft=Duel.GetMZoneCount(tp,c)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spsetfilter,tp,LOCATION_HAND,0,1,c,e,tp,ft) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spsetop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
	local sc=Duel.SelectMatchingCard(tp,s.spsetfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,ft):GetFirst()
	if not sc then return end
	if sc:IsSetCard(0x2f0) then
		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
	elseif sc:IsSetCard(0x1fe) then
		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
	elseif sc:IsTrap() and Duel.SSet(tp,sc)>0 then
		--It can be activated this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,3))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		sc:RegisterEffect(e1)
	end
end