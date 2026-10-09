--Climactic Battle of the Black Souls
local s,id=GetID()
function s.initial_effect(c)
	--Banish as many monsters on the field as possible, then you can Special Summon 1 "Grimm the Tragic Knight" and 1 "Red Hood" from your hand, Deck and/or GY
	--And if you do, Special Summon 1 "Alice Token" (Fairy/DARK/Level 8/ATK 3200/DEF 1900) to your opponent's field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_BATTLE_PHASE)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	
end


s.listed_series={}
s.listed_names={id,13741143,13741194,13741193}

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsBattlePhase()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lp_cost=Duel.GetLP(tp)-2300
	if chk==0 then return lp_cost>0 and Duel.CheckLPCost(tp,lp_cost) end
	e:SetLabel(lp_cost)
	Duel.PayLPCost(tp,lp_cost)
end

function s.spfilter(c,e,tp)
	return c:IsCode(13741143,13741194) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,LOCATION_MZONE)>0
		and not Duel.HasFlagEffect(tp,id)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>-Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>-Duel.GetFieldGroupCount(1-tp,LOCATION_MZONE,0)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,13741193,0,TYPES_TOKEN,3200,1900,8,RACE_FAIRY,ATTRIBUTE_DARK) end
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK|LOCATION_GRAVE)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.HasFlagEffect(tp,id) then return end
	Duel.RegisterFlagEffect(tp,id,0,0,1)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 
		and Duel.IsPlayerCanSpecialSummonMonster(tp,13741193,0,TYPES_TOKEN,3200,1900,8,RACE_FAIRY,ATTRIBUTE_DARK) then 
		local token=Duel.CreateToken(tp,13741193)
		Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP)
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
		local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,nil,e,tp)	
		if #sg>=2 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			local ssg=aux.SelectUnselectGroup(sg,e,tp,2,2,aux.dncheck,1,tp,HINTMSG_SPSUMMON)
			if #ssg>0 then
				Duel.BreakEffect()
				Duel.SpecialSummon(ssg,0,tp,tp,false,false,POS_FACEUP)
			end
		end		
	end
	--Cannot Special Summon monsters
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE|PHASE_END)
	e1:SetTargetRange(1,1)
	Duel.RegisterEffect(e1,tp)
end
