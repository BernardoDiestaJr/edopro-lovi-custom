-- Final Worm Reemergence
local s,id=GetID()
function s.initial_effect(c)
	--When this card is activated: Special Summon 1 Reptile "Worm" monster from your hand or Deck in face-up Defense Position or face-down Defense Position.
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Activate 1 of these effects (but you can only use each effect of "Final Worm Reemergence" once per turn)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	e2:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e2)
end

s.listed_names={id,90075978}
s.listed_series={SET_WORM}

function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_WORM) and c:IsRace(RACE_REPTILE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE|POS_FACEDOWN_DEFENSE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,nil,e,tp)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE|POS_FACEDOWN_DEFENSE)
		if sg:GetFirst():IsFacedown() then
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end

function s.remfilter(c,tp)
	return c:IsSetCard(SET_WORM) and c:IsRace(RACE_REPTILE) and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
end

function s.tgfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_REPTILE) and c:IsMonster() and not c:IsCode(id) and c:IsAbleToGrave()
end

function s.fextrafilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_REPTILE) and c:IsFaceup() and c:IsAbleToDeck()
end

function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(s.fextrafilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,nil)
end

function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	--Banish 1 Reptile "Worm" monster from your Extra Deck, and send any number of LIGHT Reptile monster(s) (with different names) from your Deck to the GY whose total Levels are less than or equal to the added monster's original Level.
	local b1=not Duel.HasFlagEffect(tp,id) 
		and Duel.GetMatchingGroup(s.remfilter,tp,LOCATION_EXTRA,0,nil,tp)
	--Fusion Summon 1 Reptile "Worm" Fusion Monster from your Extra Deck, by shuffling LIGHT Reptile monsters from your GY or banishment into the Deck.
	local fusion_params={
			fusfilter=function(c) return c:IsSetCard(SET_WORM) and c:IsRace(RACE_REPTILE) end,
			matfilter=function(c) return c:IsRace(RACE_REPTILE) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToDeck() end,
			extrafil=s.fextra,
			extraop=Fusion.ShuffleMaterial
		}
	local b2=not Duel.HasFlagEffect(tp,id+1)
		and Fusion.SummonEffTG(fusion_params)(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_REMOVE+CATEGORY_TOGRAVE)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,LOCATION_EXTRA)
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	elseif op==2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TODECK)
		Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	end
end

function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Banish 1 Reptile "Worm" monster from your Deck, and send any number of LIGHT Reptile monster(s) (with different names) from your Deck to the GY whose total Levels are less than or equal to the added monster's original Level.
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local tc=Duel.SelectMatchingCard(tp,s.remfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp):GetFirst()
		if tc and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
			local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
			if #g==0 then return end
			local sg=aux.SelectUnselectGroup(g,e,tp,1,4,aux.dncheck,1,tp,HINTMSG_TOGRAVE)
			if #sg>0 then
				Duel.SendtoGrave(sg,REASON_EFFECT)
			end
		end
	elseif op==2 then
		--Fusion Summon 1 Reptile "Worm" Fusion Monster from your Extra Deck, by shuffling LIGHT Reptile monsters from your GY or banishment into the Deck.
		local fusion_params={
			fusfilter=function(c) return c:IsSetCard(SET_WORM) and c:IsRace(RACE_REPTILE) end,
			matfilter=function(c) return c:IsRace(RACE_REPTILE) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToDeck() end,
			extrafil=s.fextra,
			extraop=Fusion.ShuffleMaterial
		}
		Fusion.SummonEffOP(fusion_params)(e,tp,eg,ep,ev,re,r,rp)
	end
end