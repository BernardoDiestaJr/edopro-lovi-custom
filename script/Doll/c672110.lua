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
	--Xyz Summon 1 DARK Xyz Monster using Level 4 monsters or Normal Monsters
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,5))
	e4:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return ep==1-tp end)
	e4:SetCost(Cost.DetachFromSelf(1))	
	e4:SetTarget(s.xyztg)
	e4:SetOperation(s.xyzop)
	c:RegisterEffect(e4)
	
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

function s.xyzfilter(c,e,tp,mmz_chk)
	return (c:IsLevel(4) or c:IsType(TYPE_NORMAL) and c:IsLevelAbove(4)) and c:IsFaceup() and (c:IsAbleToDeck() or (mmz_chk and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end

function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local mmz_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.xyzfilter(chkc,e,tp,mmz_chk) end
	if chk==0 then return Duel.IsExistingTarget(s.xyzfilter,tp,LOCATION_GRAVE,0,2,nil,e,tp,mmz_chk) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,6))
	local g=Duel.SelectTarget(tp,s.xyzfilter,tp,LOCATION_GRAVE,0,2,2,nil,e,tp,mmz_chk)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,g,2,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,tp,0)
	if g:GetFirst():IsLocation(LOCATION_GRAVE) then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,2,tp,0)
	end
end

function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or not aux.ToDeckOrElse(tc,tp, function() return Duel.GetLocationCount(tp,LOCATION_MZONE)<2 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) end, function() return Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 end, aux.Stringid(id,7)) then return end
	local g=Duel.GetMatchingGroup(Card.IsXyzSummonable,tp,LOCATION_EXTRA,0,1,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,8)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		Duel.XyzSummon(tp,sg:GetFirst())
	end
end