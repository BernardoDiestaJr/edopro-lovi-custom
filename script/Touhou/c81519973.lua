--Divine Implement - Onmyō
local s,id=GetID()
function s.initial_effect(c)
	--Equip only to "Reimu the Eternal Shrine Maiden".
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsSetCard,0x1f9))
	--Unaffected by monster effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(function(e,te) return te:IsMonsterEffect() end)
	c:RegisterEffect(e1)
	--If this card is in your GY: You can target "Reimu the Eternal Shrine Maiden" in your GY or banishment; Special Summon it, and if you do, equip it with this card, but shuffle it back to the Deck when it leaves the field.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)	
	--You can shuffle 1 "Fantasia" or Illusion monster in your banishment or GY into the Deck/Extra Deck, then target 1 face-up card on the field; destroy it.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e3:SetCondition(function() return Duel.IsMainPhase() end)
	e3:SetCost(s.descost)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	--Grant the above effects to a "Reimu the Eternal Shrine Maiden" monster equipped with this card
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetTarget(function(e,c) return e:GetHandler():GetEquipTarget()==c and c:IsSetCard(0x1f8) end)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end

s.listed_names={id,0x1f9}
s.listed_series={0x1f9,0x1fa,0x1f7}

function s.spfilter(c,e,tp,ec)
	return c:IsSetCard(0x1f9) or c:IsLinkMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and ec:CheckEquipTarget(c)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp,c) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,e,tp,c)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local c=e:GetHandler()
		--Shuffle it into the Deck when it leaves the field.
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(1307)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT|RESETS_REDIRECT)
		e1:SetValue(LOCATION_DECK)
		tc:RegisterEffect(e1,true)
		if c:IsRelateToEffect(e) and Duel.Equip(tp,c,tc) then
			--Equip limit
			local e2=Effect.CreateEffect(tc)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_EQUIP_LIMIT)
			e2:SetValue(function(e,c) return e:GetOwner()==c end)
			e2:SetReset(RESET_EVENT|RESETS_STANDARD)
			c:RegisterEffect(e2)
		end
	end
	Duel.SpecialSummonComplete()
end

function s.descostfilter(c,tp)
	return (c:IsSetCard(0x1f8) or (c:IsLevelAbove(6) and c:IsRace(RACE_ILLUSION))) and c:IsFaceup() and c:IsAbleToDeckOrExtraAsCost()
end

function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.descostfilter,tp,LOCATION_REMOVED|LOCATION_GRAVE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.descostfilter,tp,LOCATION_REMOVED|LOCATION_GRAVE,0,1,1,c)
	Duel.HintSelection(g)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,600)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g,true)
		Duel.Destroy(g,REASON_EFFECT)
		Duel.Recover(tp,600,REASON_EFFECT)
	end
end

