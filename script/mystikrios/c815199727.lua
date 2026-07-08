--Mystikrios Radiant Remtania Arni
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,0,id)
	--Fusion Summon procedure
	Fusion.AddProcMix(c,true,true,s.matfilter1,s.matfilter2)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,true)
	--Flip up to 3 monsters face-down
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.postg)
	e1:SetOperation(s.posop)
	c:RegisterEffect(e1)
	--You can shuffle 1 Level 6 or lower Beast monster from your GY into the Deck, then you can Special Summon this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)	
	
end

s.listed_series={0x1fc}
s.listed_names={id}

function s.matfilter1(c,fc,sumtype,tp)
	return c:IsSetCard(0x1fc,fc,sumtype,tp) and c:IsLevelAbove(6) and c:IsRace(RACE_BEAST) and c:IsType(TYPE_FUSION,fc,sumtype,tp)
end

function s.matfilter2(c,fc,sumtype,tp)
	return c:IsSetCard(0x1fc,fc,sumtype,tp) and c:IsRace(RACE_FAIRY) and c:IsType(TYPE_XYZ,fc,sumtype,tp)
end

function s.contactfil(tp)
	local loc=LOCATION_ONFIELD|LOCATION_GRAVE
	if Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) then loc=LOCATION_ONFIELD end
	return Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,loc,0,nil)
end

function s.contactop(g)
	Duel.Remove(g,POS_FACEUP,REASON_COST|REASON_MATERIAL)
end

function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanTurnSet() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,1,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end

function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g==0 or Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)==0 then return end
	local c=e:GetHandler()
	g:Match(Card.IsControler,nil,1-tp)
	for tc in g:Match(Card.IsPosition,nil,POS_FACEDOWN_DEFENSE):Iter() do
		--Cannot change its battle position
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3313)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end

function s.tdfilter(c)
	return c:IsSetCard(0x1fc) and c:IsAbleToDeck()
end

function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,tp,0)
end

function s.tdop(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetTargetCards(e)
	if #g==0 or Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 then return end
	local ct=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_DECK|LOCATION_EXTRA|LOCATION_HAND)
	if ct>0 and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local rg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,ct,nil)
		if #rg>0 then
			Duel.HintSelection(rg)
			Duel.SendtoDeck(rg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end