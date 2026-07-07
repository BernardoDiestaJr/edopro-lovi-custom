--Onmyō Go-Shintai Method
local s,id=GetID()
function s.initial_effect(c)
	--Ritual Summon any Spirit Ritual Monster from your hand or GY
	local e1=Ritual.AddProcGreater({handler=c,filter=s.ritualfilter,matfilter=s.ritmatfilter,location=LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED})
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,{id,0})
	c:RegisterEffect(e1)
	--Banish 1 face-up card your opponent controls face-down.
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.remcost)
	e2:SetTarget(s.remtg)
	e2:SetOperation(s.remop)
	c:RegisterEffect(e2)
end

function s.ritualfilter(c)
	return c:IsType(TYPE_SPIRIT) and c:IsRitualMonster()
end

function s.ritmatfilter(c)
	return (c:IsType(TYPE_SPIRIT) or c:IsRace(RACE_ROCK) or c:IsRace(RACE_ILLUSION))
end

function s.remcostfilter(c)
	return c:IsType(TYPE_SPIRIT) and c:IsMonster() and c:IsAbleToRemoveAsCost()
end

function s.remfilter(c)
	return c:IsFaceup() and c:IsAbleToRemove(tp,POS_FACEDOWN,REASON_EFFECT)
end

function s.remcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		and Duel.IsExistingMatchingCard(s.remcostfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.remcostfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	g:AddCard(c)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.remtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and s.rmvfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.remfilter,tp,0,LOCATION_ONFIELD,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.remfilter,tp,0,LOCATION_ONFIELD,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end

function s.remop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
	end
end