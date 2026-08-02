--Sanae the Green Fantasia Priestess
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon this card from the hand
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_HAND)
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e0:SetCondition(s.selfspcon)
	e0:SetTarget(s.selfsptg)
	e0:SetOperation(s.selfspop)
	c:RegisterEffect(e0)
	--Banish 1 "Windrous" card from your hand, Deck or GY, except "Sanae, Windrous Fantasia Priestess"; Special Summon 1 "Windrous Token" (Fairy/Tuner/WIND/Level 1/ATK 0/DEF 0)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,1})
	e1:SetCost(s.tkcost)
	e1:SetTarget(s.tktg)
	e1:SetOperation(s.tkop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)	
	
end

s.listed_series={0x2f1,0x1f8}
s.listed_names={id,81520000}

function s.selfspconfilter1(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsType(TYPE_SYNCHRO) and c:IsAbleToGraveAsCost()
end

function s.selfspconfilter2(c)
	return not (c:IsAttribute(ATTRIBUTE_WIND) and c:IsFaceup())
end

function s.selfspcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroup(s.selfspconfilter1,tp,LOCATION_EXTRA,0,nil)
	return #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and not Duel.IsExistingMatchingCard(s.selfspconfilter2,tp,LOCATION_MZONE,0,1,nil)
end

function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local rg=Duel.GetMatchingGroup(s.selfspconfilter1,tp,LOCATION_EXTRA,0,nil)
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),1,tp,HINTMSG_TOGRAVE,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end

function s.selfspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoGrave(g,REASON_COST)
end

function s.tkcostfilter(c)
	return c:IsSetCard(0x2f1) and not c:IsCode(id) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end

function s.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tkcostfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.tkcostfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.thconfilter(c)
	return c:IsFaceup() and not c:IsAttribute(ATTRIBUTE_WIND)
end

function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsPlayerCanSpecialSummonMonster(tp,81520000,0x2f1,TYPES_TOKEN+TYPE_TUNER,0,0,1,RACE_FAIRY,ATTRIBUTE_WIND)
			and not Duel.IsExistingMatchingCard(s.thconfilter,tp,LOCATION_MZONE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end

function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	if s.tktg(e,tp,eg,ep,ev,re,r,rp,0) then
		local c=e:GetHandler()
		local token=Duel.CreateToken(tp,81520000)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
