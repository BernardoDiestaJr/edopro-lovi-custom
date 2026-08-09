--Windrous Divitant Mishaguji
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure: "Sanae, Windrous Fantasia Priestess" + 1+ Tuner Synchro Monsters
	Synchro.AddProcedure(c,aux.FALSE,1,1,s.tunerfilter,1,99,aux.FilterSummonCode(81519989))
	--Banish 1 "Windrous" card from your hand, Deck or GY, except "Windrous Divitant Misakujin", then target 1 WIND non-Tuner monster in your GY or banishment; Special Summon it in Defense Position, then you can destroy 1 face-up monster on the field
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e0:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCountLimit(1,{id,0})
	e0:SetCost(s.spcost)
	e0:SetTarget(s.sptg)
	e0:SetOperation(s.spop)
	c:RegisterEffect(e0)
	--Return 1 "Windrous" Monster Card you own from your Spell & Trap Zone to the Extra Deck, then you Special Summon it
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,1})
	e1:SetCondition(function(e,tp) return Duel.IsTurnPlayer(1-tp) end)
	e1:SetCost(Cost.SelfTribute)
	e1:SetTarget(s.tdsptg)
	e1:SetOperation(s.tdspop)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)	
	
end

s.listed_series={0x2f1}
s.listed_names={id,81519989}
s.material={81519989}

function s.tunerfilter(c,scard,sumtype,tp)
	return c:IsType(TYPE_TUNER,scard,sumtype,tp) and c:IsType(TYPE_SYNCHRO) or c:IsHasEffect(EFFECT_CAN_BE_TUNER)
end

function s.spcostfilter(c)
	return c:IsSetCard(0x2f1) and not c:IsCode(id) and c:IsAbleToRemoveAsCost()
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.spfilter(c,e,tp)
	return not c:IsType(TYPE_TUNER) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,PLAYER_EITHER,LOCATION_MZONE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
		local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local dg=g:Select(tp,1,1,nil)
			if #dg==0 then return end
			Duel.HintSelection(dg)
			Duel.BreakEffect()
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end

function s.tdspfilter(c,tp)
	return c:IsMonsterCard() and c:IsOwner(tp) and c:IsFaceup() and c:IsAbleToExtra()
end

function s.tdsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdspfilter,tp,LOCATION_STZONE,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_STZONE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.tdspop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sc=Duel.SelectMatchingCard(tp,s.tdspfilter,tp,LOCATION_STZONE,0,1,1,nil,tp):GetFirst()
	if not sc then return end
	Duel.HintSelection(sc)
	if Duel.SendtoDeck(sc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_EXTRA)
		and Duel.GetLocationCountFromEx(tp,tp,nil,sc)>0
		and sc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.BreakEffect()
		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetValue(1600)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		sc:RegisterEffect(e1)
	end
	--You cannot Special Summon from the Extra Deck for the rest of this turn, except Synchro Monsters
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsSynchroMonster() end)
	e2:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
