--Windrous Faithful Nativity
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Place 1 "Windrous Shrine" from your hand or Deck face-up in your Field Zone
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(s.plcost)
	e1:SetOperation(s.plop)
	c:RegisterEffect(e1)
	--Banish 1 monster from the field with less ATK or DEF than that monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.remcon)
	e2:SetTarget(s.remtg)
	e2:SetOperation(s.remop)
	c:RegisterEffect(e2)	
	--Special Summon 1 "Sanae, Windrous Fantasia Priestess" from your hand, Deck or GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_REMOVE)
	e3:SetCountLimit(1,{id,2})
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	
end

s.listed_series={0x2f1}
s.listed_names={id,81520003,81519989}

function s.plcostfilter(c,e,tp)
	return c:IsMonster() and c:IsAttribute(ATTRIBUTE_WIND) and c:IsAbleToGraveAsCost()
end

function s.plcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.plcostfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sc=Duel.SelectMatchingCard(tp,s.plcostfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SendtoGrave(sc,REASON_COST)
end

function s.plfilter(c,tp)
	return c:IsCode(81520003) and not c:IsForbidden()
end

function s.plop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.plfilter,tp,LOCATION_HAND|LOCATION_DECK,0,nil,tp)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		if not tc then return end
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	end
end

function s.remconfilter(c,tp)
	return c:IsSynchroSummoned() and c:IsSetCard(0x2f1) and c:IsLevelAbove(9) and c:IsSummonPlayer(tp) and c:IsFaceup()
end

function s.remcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.remconfilter,1,nil,tp)
end

function s.tgfilter(c,tp)
	return c:IsType(TYPE_SYNCHRO) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsFaceup()
		and Duel.IsExistingMatchingCard(s.remfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c:GetAttack())
end

function s.remfilter(c,atk)
	return c:IsAbleToRemove() and c:IsFaceup() and c:GetAttack()<atk
end

function s.remtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE|LOCATION_GRAVE) and chkc:IsControler(tp) and s.tgfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD)
end

function s.remop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
	local atk=tc:GetAttack()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.remfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,atk)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Remove(g,nil,REASON_EFFECT)
	end
end

function s.spfilter(c,e,tp)
	return (c:IsCode(81519989) or (c:IsMonster() and c:ListsCode(81519989))) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end