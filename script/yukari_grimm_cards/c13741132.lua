--Theatre of Darkness - Grand Guignol
local s,id=GetID()
function s.initial_effect(c)
	--Add 1 "Vicious Theatre" card from your Deck to your hand.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--"Vicious Theatre" monsters you control gain 300 ATK/DEF for each different Type you control
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.atktg)
	e2:SetValue(function(e,c) return 300*Duel.GetMatchingGroup(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil):GetBinClassCount(Card.GetRace) end)
	e2:SetCondition(s.effcon)
	e2:SetLabel(1)
	c:RegisterEffect(e2)	
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)	
	--Set 1 "Vicious Theatre" Spell/Trap from your Deck
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetCost(s.setcost)
	e4:SetCondition(s.effcon)
	e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
	e4:SetLabel(2)
	c:RegisterEffect(e4)	
	--Your opponent cannot target "Vicious Theatre" monsters you control with card effects
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetTarget(function(e,c) return c:IsSetCard(0x41e) end)
	e5:SetValue(aux.tgoval)
	e5:SetLabel(3)
	c:RegisterEffect(e5)
end

s.listed_series={0x41e}
s.listed_names={id}

function s.thfilter(c)
	return c:IsSetCard(0x41e) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.confilter(c)
	return c:IsSetCard(0x41e) and c:IsMonster()
end

function s.effcons(e,tp)
	local g=Duel.GetMatchingGroup(s.confilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)>=e:GetLabel()
end

function s.effcon(value)
	return function(e)
		local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,0x41e),e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
		return (value>=1 and ct==value)
	end
end

function s.atktg(e,c)
	return c:IsSetCard(0x41e)
end

function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST|REASON_DISCARD)
end

function s.setfilter(c)
	return c:IsSetCard(0x41e) and c:IsSpellTrap() and c:IsSSetable()
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end
