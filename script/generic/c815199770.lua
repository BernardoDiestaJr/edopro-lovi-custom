--Spinumbra Faurex
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon Procedure: 2 Level 10 Dinosaur monsters
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_DINOSAUR),10,2)
	--For this card's Xyz Summon, you can treat Level 6 or higher Dinosaur monsters you control as Level 10 monsters for material
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetCode(EFFECT_XYZ_LEVEL)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetTargetRange(LOCATION_MZONE,0)
	e0:SetTarget(function(e,c) return c:IsRace(RACE_DINOSAUR) and c:IsLevelAbove(6) end)
	e0:SetValue(function(e,_,rc) return rc==e:GetHandler() and 10 or 0 end)
	c:RegisterEffect(e0)
	--Add up to 2 Dinosaur monsters with different names from your GY or banishment to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Target 1 face-up card your opponent controls; banish it, face-down.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_BECOME_TARGET)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp,eg) return eg:IsContains(e:GetHandler()) end)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	c:RegisterEffect(e3)
	
end

s.listed_series={}
s.listed_names={id}

function s.thfilter(c)
	return c:IsRace(RACE_DINOSAUR) and c:IsMonster() and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_GRAVE|LOCATION_REMOVED)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,nil)
	if #g==0 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,2,aux.dncheck,1,tp,HINTMSG_ATOHAND)
	if #sg>0 then
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end

function s.rmvfilter(c,tp)
	return c:IsFaceup() and c:IsAbleToRemove(tp,POS_FACEDOWN,REASON_EFFECT)
end

function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and s.rmvfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.rmvfilter,tp,0,LOCATION_ONFIELD,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.rmvfilter,tp,0,LOCATION_ONFIELD,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
	end
end
