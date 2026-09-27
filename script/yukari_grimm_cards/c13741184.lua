--Dinah the Tearing Beast
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTunerEx(Card.IsRace,RACE_WARRIOR),1,99)	
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
	e0:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e0)
	--Gains 400 ATK for each DARK Tuner in the GYs
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	--Target up to 4 cards your opponent controls; send them to the GY
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,0))
	e2a:SetCategory(CATEGORY_TOGRAVE)
	e2a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2a:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2a:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2a:SetCountLimit(1,id)
	e2a:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():IsSynchroSummoned() and e:GetLabel()==1 or (re and re:GetHandler():IsCode(13741185)) end)
	e2a:SetTarget(s.tgtg)
	e2a:SetOperation(s.tgop)
	c:RegisterEffect(e2a)
	local e2b=Effect.CreateEffect(c)
	e2b:SetType(EFFECT_TYPE_SINGLE)
	e2b:SetCode(EFFECT_MATERIAL_CHECK)
	e2b:SetValue(s.valcheck)
	e2b:SetLabelObject(e2a)
	c:RegisterEffect(e2b)	
	
end

s.counter_place_list={}
s.listed_series={}
s.listed_names={id,13741143,13741185}

function s.atkfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_TUNER) and c:IsFaceup()
end

function s.atkval(e,c)
	return 400*Duel.GetMatchingGroupCount(s.atkfilter,0,LOCATION_GRAVE,LOCATION_GRAVE,nil)
end

function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsCode,1,nil,13741143) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end

function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToGrave() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,4,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,tp,0)
end

function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.SendtoGrave(tg,REASON_EFFECT)
	end
end