--Lovely Princess Cologne
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	--cannot be target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)	
	--Special Summon or attach a "Grandpa Demetto" 
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,id)
	e3:SetCondition(function(e) return e:GetHandler():IsXyzSummoned() end)
	e3:SetTarget(s.attg)
	e3:SetOperation(s.atop)
	c:RegisterEffect(e3)	
end

s.listed_series={SET_RANK_UP_MAGIC}
s.listed_names={id,44190146}

function s.gdfilter(c,e,tp,ft)
	return c:IsCode(44190146) and ((ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE))
		or Duel.IsExistingMatchingCard(s.attfilter,tp,LOCATION_MZONE,0,1,nil,e))
end

function s.attfilter(c,e)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and not c:IsImmuneToEffect(e)
end

function s.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return Duel.IsExistingMatchingCard(s.gdfilter,tp,LOCATION_DECK|LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp,ft) end
	e:SetLabel(Duel.IsBattlePhase() and 1 or 0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_HAND|LOCATION_GRAVE)
end

function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local tc=Duel.SelectMatchingCard(tp,s.gdfilter,tp,LOCATION_DECK|LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp,ft):GetFirst()
	if not tc then return end
	local spchk=ft>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
	local attchk=Duel.IsExistingMatchingCard(s.attfilter,tp,LOCATION_MZONE,0,1,nil,e)
	if not (spchk or attchk) then return end
	local op=Duel.SelectEffect(tp,
		{spchk,aux.Stringid(id,2)},
		{attchk,aux.Stringid(id,3)})
	local success_chk=nil
	if op==1 and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
		success_chk=true
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local oc=Duel.SelectMatchingCard(tp,s.attfilter,tp,LOCATION_MZONE,0,1,1,nil,e):GetFirst()
		if oc then
			success_chk=true
			Duel.HintSelection(oc,true)
			Duel.Overlay(oc,tc)
		end
	end
end