--Windrous Ardent Offering
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--Set this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,{id,2})
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:IsMonsterEffect() end)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end

s.listed_series={0x2f1}
s.listed_names={id,81519989}

function s.plfilter(c)
	return c:IsSetCard(0x2f1) and c:IsType(TYPE_SYNCHRO) and c:IsMonster() and not c:IsForbidden()
end

function s.tgfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsLevel(9) and c:IsAbleToGrave()
end

function s.tdfilter(c,tp)
	return c:IsSetCard(0x2f1) and c:IsMonsterCard() and c:IsOwner(tp) and c:IsFaceup() and c:IsAbleToExtra()
end

function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=not Duel.HasFlagEffect(tp,id)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_EXTRA|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil)
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
	local b2=not Duel.HasFlagEffect(tp,id+1)
		and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_STZONE,0,1,nil,tp)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_TOGRAVE)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	elseif op==2 then
		e:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
		Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1)
		Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_STZONE)
		Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	end
end

function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local c=e:GetHandler()
	if op==1 then
		--Place 1 Synchro "Windrous" monster from your Extra Deck, GY or banishment in your Spell & Trap Zone as a face-up Continuous Trap, and if you do, send 1 Level 9 WIND monster from your Deck to the GY.
		if Duel.GetLocationCount(tp,LOCATION_SZONE)==0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.plfilter),tp,LOCATION_EXTRA|LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil):GetFirst()
		if tc and Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
			--Treat as Continuous Trap
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetValue(TYPE_TRAP|TYPE_CONTINUOUS)
			e1:SetReset((RESET_EVENT|RESETS_STANDARD)&~RESET_TURN_SET)
			tc:RegisterEffect(e1)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
			if #g>0 then
				Duel.SendtoGrave(g,REASON_EFFECT)
			end
		end
	elseif op==2 then
		--Return 1 "Windrous" Monster Card you own from your Spell & Trap Zone to the Extra Deck, then you can Special Summon it, then you can take 1 WIND monster from your GY, and either shuffle it into the Deck or Special Summon it.
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sc=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_STZONE,0,1,1,nil,tp):GetFirst()
		if not sc then return end	
		Duel.HintSelection(sc)		
		if Duel.SendtoDeck(sc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_EXTRA)
			and Duel.GetLocationCountFromEx(tp,tp,nil,sc)>0
			and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
			Duel.BreakEffect()
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	--You cannot Special Summon from the Extra Deck for the rest of this turn, except Synchro Monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,5))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsSynchroMonster() end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,tp,0)
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsSSetable() and Duel.SSet(tp,c) then
		--Return it to Deck if it leaves the field
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3301)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT|RESETS_REDIRECT)
		e1:SetValue(LOCATION_DECKBOT)
		c:RegisterEffect(e1)		
	end
end
